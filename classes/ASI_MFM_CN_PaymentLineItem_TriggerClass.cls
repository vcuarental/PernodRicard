/* Filename:    ASI_MFM_CN_PaymentLineItem_TriggerClass.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Handle CN Payment Line Item Trigger Logic
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2013-06-04   michael.yip@introv.com      Create
 * 2014-09-02   michael.yip@introv.com      Amount rounding for VAT deductable
 *                                            - When compare the PO receipt amount and after-tax Payment amount, use round(after-tax Payment amount, 2) - 0.10 to compare the PO receipt amount. 
 * 2014-10-31	Axel.Leung@introv.com		#96, Allow negative payment on negative receipt
 */
public with sharing class ASI_MFM_CN_PaymentLineItem_TriggerClass {
    
    Private Static Set<String> PO_TYPE_SET = new Set<String>{'emarket', 'it opex', 'it capex hardware region', 'it capex hardware hq', 'it capex software', 'iT capex renovation'};
    
     public static void routineAfterAll(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
         
         if(trigger_new != Null){//20170706 Introv
             
             //20161117 Elufa
             List<ASI_MFM_Payment_Line_Item__c> paymentLineITemList = new List<ASI_MFM_Payment_Line_Item__c>([SELECT Id, ASI_MFM_Payment__r.OwnerId, ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c, ASI_MFM_Payment__c, ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Team__c, ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Team__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand_Director__c FROM ASI_MFM_Payment_Line_Item__c WHERE Id IN : trigger_new ORDER BY ASI_MFM_Payment__c DESC, LastModifiedDate DESC]);
             ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(paymentLineITemList, trigger_new);
             //20161117 End
         }
         
// Recalculate payment amount in payment request header
        set<id> ph_set = new set<id>();
        if (trigger_oldmap == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                ph_set.add(pi.ASI_MFM_Payment__c);
            }
        }
        else if (trigger_new == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                ph_set.add(pi.ASI_MFM_Payment__c);              
            }
        }
        else {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pi.id).ASI_MFM_Payment_Amount__c) {
                    ph_set.add(pi.ASI_MFM_Payment__c);
                }
            }           
        }
        if (ph_set.size() > 0) {
            list<ASI_MFM_Payment__c> ph_list = [select (select ASI_MFM_Payment_Amount__c from Payment_Line_Items__r) from ASI_MFM_Payment__c where id in :ph_set];
            for (ASI_MFM_Payment__c ph:ph_list) {
                ph.ASI_MFM_Payment_Amount__c = 0;
                for (ASI_MFM_Payment_Line_Item__c pi:ph.Payment_Line_Items__r) {
                    if (pi.ASI_MFM_Payment_Amount__c != null) {
                        ph.ASI_MFM_Payment_Amount__c += pi.ASI_MFM_Payment_Amount__c;
                    }
                }
            }
            update ph_list;
        }       
        /* Not Applicable to CN MFM
        // Pass Payment and line item details to Data Warehouse 
        if (!ASI_MFM_Function.bypassCallouts()) {       
            set<id> pid_set = new set<id>();
            if (trigger_new != null) {
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                    if (trigger_oldMap == null || pi.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(pi.id).ASI_MFM_Sys_Sync_Time__c) {
                        pid_set.add(pi.ASI_MFM_Payment__c);
                    }               
                }
            }
            else if (trigger_oldMap != null) {
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldMap.values()) {
                    pid_set.add(pi.ASI_MFM_Payment__c);             
                }           
            }
            if (pid_set.size() > 0 && !system.isFuture()) {
                if (!(test.isRunningTest() && limits.getFutureCalls() >= limits.getLimitFutureCalls())) {               
                    ASI_MFM_Callout.updatePayment(pid_set);
                }
            }
        }*/ 
    }

    public static void routineBeforeDelete(list<ASI_MFM_Payment_Line_Item__c> trigger_old) {
// Not allowed to delete if the Payment is in final or complete status or voucher created flag is on
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Payment__c);
        }
        map<id, ASI_MFM_Payment__c> Payment_map = new map<id, ASI_MFM_Payment__c>([select id from ASI_MFM_Payment__c where id in :pid_set and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Complete')]);        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_old) {
            if (Payment_map.containsKey(pi.ASI_MFM_Payment__c)) {
                pi.addError('Not allowed to delete because the payment is in \'Final\' or \'Complete\' status');
            }
            if (pi.ASI_MFM_Voucher_Created__c) {
                pi.addError('Not allowed to delete because voucher has been created');
            }           
        }
    }

    public static void routineBeforeInsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new) {
        set<id> payment_set = new set<id>();
        set<id> pol_set = new set<id>();    
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
            if (pi.ASI_MFM_Payee__c == null) {
                payment_set.add(pi.ASI_MFM_Payment__c);
            }
            if (pi.ASI_MFM_PO_Line_Currency__c == null || pi.ASI_MFM_PO_Line_Remaining_Amount__c == null) {
                pol_set.add(pi.ASI_MFM_PO_Line_Item__c);
            }
        }
        
// Set payee to payment header's supplier if not input by user          
        if (payment_set.size() > 0) {
            map<id, ASI_MFM_Payment__c> payment_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Supplier_Name__c from ASI_MFM_Payment__c where id in :payment_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {  
                if (pi.ASI_MFM_Payee__c == null && payment_map.containsKey(pi.ASI_MFM_Payment__c)) {
                    pi.ASI_MFM_Payee__c = payment_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Supplier_Name__c;
                }               
            }            
        }

// Set PO line currency, PO line remaining amount and PO line description
        if (pol_set.size() > 0) {
            map<id, ASI_MFM_PO_Line_Item__c> pol_map = new map<id, ASI_MFM_PO_Line_Item__c>([select ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c, 
                ASI_MFM_List_Item_Description__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Paid_Amount__c
                from ASI_MFM_PO_Line_Item__c where id in :pol_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                if (pol_map.containsKey(pi.ASI_MFM_PO_Line_Item__c)) {
                    if (pi.ASI_MFM_PO_Line_Currency__c == null) {
                        pi.ASI_MFM_PO_Line_Currency__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Currency__c;
                    }
                    if (pi.ASI_MFM_PO_Line_Remaining_Amount__c == null) {
                        pi.ASI_MFM_PO_Line_Remaining_Amount__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Remaining_Balance__c;
                    }
                    if (pi.ASI_MFM_PO_Line_Description__c == null) {
                        pi.ASI_MFM_PO_Line_Description__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_List_Item_Description__c;
                    }                   
                }
            }               
        }
        
        /*  Added by Michael Yip (Introv) 17Mar2014
            reject prepayment if there is receipt or payment
        */
        List<RecordType> LRT = Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c');
        Map<string, id> MRecTypeID = new Map<string,id>();
        for(RecordType rt : LRT){
            MRecTypeID.put(rt.developername,rt.id);
        }
        Set<id> SCNRecTypeID = new Set<id>();
        
        for(String key : MRecTypeID.keySet()){
            
            if(key.contains('CN_Payment')){
                SCNRecTypeID.add(MRecTypeID.get(key));
            } 
        }
        Set<id> SPaymentID = new Set<id>();
        Map<id, ASI_MFM_Payment__c> MPayment = new Map<id,ASI_MFM_Payment__c>();
        for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){         
            if(SCNRecTypeID.contains(Pi.recordtypeid)){
                pol_set.add(pi.ASI_MFM_PO_Line_Item__c);
                SPaymentID.add(pi.ASI_MFM_Payment__c);
            }
        }
        Set<id> SPrepaymentID = new Set<id>();
        for(ASI_MFM_Payment__c p : [Select ASI_MFM_Pre_payment__c, id from ASI_MFM_Payment__c where id IN :SpaymentID]){
            if(p.ASI_MFM_Pre_payment__c){
                SPrepaymentID.add(p.id);
            }
        }
        if (pol_set.size() > 0) {
            map<id, ASI_MFM_PO_Line_Item__c> pol_map = new map<id, ASI_MFM_PO_Line_Item__c>([select ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c, 
                ASI_MFM_List_Item_Description__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Paid_Amount__c
                from ASI_MFM_PO_Line_Item__c where id in :pol_set]);
            for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){         
                if(SCNRecTypeID.contains(Pi.recordtypeid)){
                    if((pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Paid_Amount__c > 0 || pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_CN_Receipt_Amount__c > 0) && SPrepaymentID.contains(pi.asi_mfm_payment__c)){
                        pi.addError('Pre-payment is not allowed after receipt/payment made!');
                    }
                }
            }
        }
    }

    public static void routineBeforeUpdate(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {

    /* Not applicable to CN MFM
// Not allow to change when the voucher created flag is on
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_Payment_Line_Item__c i : trigger_new)
            setPYI.add(i.ASI_MFM_Payment__c);   

        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';
        // Changed by KF Leung (Introv) 2014-04-26, Retrieve RecordTypeId from Global Cache
        Map<String, ID> rt_map = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Payment__c')){
            rt_map.put(rec.developername,rec.id);
        }
        // end of Changes
        Map<ID, ASI_MFM_Payment__c> paymentMap = new Map<ID, ASI_MFM_Payment__c>([SELECT ID, Name, recordtypeID FROM ASI_MFM_Payment__c WHERE ID IN: setPYI]);
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin) {
                pi.addError('Not allow to change because voucher has been created');
            }
            if (paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_TW_Payment_Read_Only') && !isuserAdmin && !System.isFuture())
            {
                pi.ASI_MFM_Currency__c.addError('You can NOT modify the Payment Line under an approved Payment');
            }
        } 
        */          
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        // Obsolete: Edited by Michael Yip (Introv) 04Jun2014, recordtype checking done in trigger
        // Changed by KF Leung (Introv) 2014-04-26, Retrieve RecordTypeId from Global Cache
        /*Map<String, ID> MRecTypeID = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c')){
            MRecTypeID.put(rec.developername,rec.id);
        }
        // end of Changes
        Set<id> SCNRecTypeID = new Set<id>();
        for(String key : MRecTypeID.keySet()){
            if(key.contains('CN_Payment')){
                SCNRecTypeID.add(MRecTypeID.get(key));
            } 
        }*/
        
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            // Added by Michael Yip 15Mar2014 to copy invoice amount to payment amount for MFM CN
            //if(SCNRecTypeID.contains(pi.recordtypeid)){
                if(pi.ASI_MFM_CN_Invoice_Amount__c != null){
                    pi.ASI_MFM_Payment_Amount__c = pi.ASI_MFM_CN_Invoice_Amount__c;
                }
                else{
                    pi.ASI_MFM_Payment_Amount__c = 0;
                }
            //}
            
            // Check if there was an input in the decimal number output error
            boolean isDecimal = ASI_MFM_Function.containsDecimalValue(pi.ASI_MFM_Payment_Amount__c) && pi.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                pi.addError(' You Cannot input a decimal number for a TWD currency.');
            
            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }
            
            if (pi.ASI_MFM_Invoice_Date__c == null || pi.ASI_MFM_Invoice_Number__c == null) {
                pay_set.add(pi.ASI_MFM_Payment__c);
            }
        }
        map<id, ASI_MFM_Payment__c> pay_map;
// Set invoice number and invoice date
        if (pay_set.size() > 0) {
            pay_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c,recordType.developerName from ASI_MFM_Payment__c where id in :pay_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                if (pi.ASI_MFM_Invoice_Date__c == null) {   
                    pi.ASI_MFM_Invoice_Date__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c;
                }
                if (pi.ASI_MFM_Invoice_Number__c == null) { 
                    pi.ASI_MFM_Invoice_Number__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c;
                }                                   
            }    
            
        }       
        
// Recalculate the paid amount in PO currency     
//Modified by Steve Wan 08May2014 to reduce SOQL  
        //string country = [select recordType.developerName from ASI_MFM_Payment__c where id = :trigger_new[0].ASI_MFM_Payment__c].recordType.developerName.substring(8,10);
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
        list<ASI_MFM_Exchange_Rate__c> xr_list = new list<ASI_MFM_Exchange_Rate__c>();
        if (pay_ccy_set.size() > 0 && po_ccy_set.size() > 0) {
            xr_list = [select ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c in :pay_ccy_set and ASI_MFM_Counter_Currency__c in :po_ccy_set and
                ASI_MFM_Country__c = :country and ASI_MFM_Effective_Date__c <= :date.today() order by ASI_MFM_Effective_Date__c desc];
        }
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = null;
            if (pi.ASI_MFM_Payment_Amount__c != null) {
                decimal xrate;
                if (pi.ASI_MFM_Currency__c == pi.ASI_MFM_PO_Line_Currency__c) {
                    xrate = 1;
                }
                else {
                    for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                        if (xr.ASI_MFM_Base_Currency__c == pi.ASI_MFM_Currency__c && xr.ASI_MFM_Counter_Currency__c == pi.ASI_MFM_PO_Line_Currency__c) {
                            xrate = xr.ASI_MFM_Exchange_Rate__c;
                            break;
                        }
                    }
                }
                if (xrate != null) {
                    if (country == 'TW' && pi.ASI_MFM_PO_Line_Currency__c == 'TWD') {
                        pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(0, roundingMode.half_up);
                    }
                    else {
                        pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                    }
                }
            }
        }
        
        /*  Added by Michael Yip (Introv) 20Dec2013
            retreive recordtype by sojbect and filter out record by record type and filter out CN Payment
        */
        
        Set<id> SPaymentID = new Set<id>();
        Set<id> SPOLineItemID = new Set<id>();
        //Map<id, ASI_MFM_Payment__c> MPayment = new Map<id,ASI_MFM_Payment__c>();
        for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){         
            //if(SCNRecTypeID.contains(Pi.recordtypeid)){
            system.debug(pi.ASI_MFM_Tax_Amount__c+'/'+pi.ASI_MFM_Payment_Amount__c+'/'+pi.ASI_MFM_Tax__c);
                pi.ASI_MFM_Tax_Amount__c = pi.ASI_MFM_Payment_Amount__c - (pi.ASI_MFM_Payment_Amount__c / (1 + (pi.ASI_MFM_Tax__c/100)));
                SPaymentID.add(pi.asi_mfm_payment__c);
                SPOLineItemID.add(pi.ASI_MFM_PO_Line_Item__c);
            //}
        }
        Set<id> SPrepaymentID = new Set<id>();
        Map<id, ASI_MFM_Payment__c> MPayment = new Map<id,ASI_MFM_Payment__c>([Select ASI_MFM_Pre_payment__c, id from ASI_MFM_Payment__c where id IN :SpaymentID]);//20180531 Introv
        
        for(ASI_MFM_Payment__c p : MPayment.values()){
            if(p.ASI_MFM_Pre_payment__c){
                SPrepaymentID.add(p.id);
            }
        }
        
        Map<id, ASI_MFM_PO_Line_Item__c> MPOLineItem = new Map<id, ASI_MFM_PO_Line_Item__c>([Select id, ASI_MFM_CN_Receipt_Amount__c
                                                                                             , ASI_MFM_CN_Paid_Amount__c
                                                                                             , ASI_MFM_Amount__c
                                                                                             , ASI_MFM_Remaining_Balance__c
                                                                                             , ASI_MFM_CN_Remaining_Receipt_Balance__c
                                                                                             , name
                                                                                             , ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c // 20180531 Introv
                                                                                             , ASI_MFM_PO__r.ASI_MFM_PO_Type__c
                                                                                             , ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c
                                                                                             from ASI_MFM_PO_Line_Item__c where id IN :SPOLineItemID]);
        
        
        for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){
            //if(SCNRecTypeID.contains(Pi.recordtypeid) ){
            // To Handle Prepayment
                if(SPrepaymentID.contains(pi.asi_mfm_payment__c)){
                    pi.ASI_MFM_CN_Pre_Payment__c = true;
                    
                    //20190214@Introv - (log#64) fix pre-payment error //&& MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Amount__c != pi.ASI_MFM_Payment_Amount_Net_of_Tax__c
                    decimal dPOLnAmt = MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Amount__c.setScale(2);
                    decimal dPayAmtNetTax = (pi.ASI_MFM_Payment_Amount__c - pi.ASI_MFM_Tax_Amount__c).setScale(2);
                    system.debug('Prepayment:['+dPOLnAmt+'/'+dPayAmtNetTax+'/'+pi.ASI_MFM_Payment_Amount__c+'/'+pi.ASI_MFM_Tax_Amount__c+']');
                    
                    //20180531 Introv
                    if(MPOLineItem.containsKey(pi.ASI_MFM_PO_Line_Item__c)
                       && MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c
                       && String.isNotBlank(MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_PO_Type__c)
                       && !PO_TYPE_SET.contains(MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_PO_Type__c.toLowerCase())
                       && MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c != '61202305'
                       && dPOLnAmt < dPayAmtNetTax
                      ){
                        pi.ASI_MFM_Payment_Amount__c.addError('Auto-Receipt Prepayment must be fully paid');
                    }
                    
                    if(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c != null){
                        pi.ASI_MFM_CN_PrePaid_Amount_in_PO_Currency__c = pi.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                        //pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = 0* pi.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                    }
                }
            //}
            // Added by Michael Yip (Introv) 04Jun2014, validation for total payment amount under each po line item cannot exceed po line item amount and receipt amount 
            if(MPOLineItem.containsKey(pi.ASI_MFM_PO_Line_Item__c)){
                ASI_MFM_PO_Line_Item__c pol = MPOLineItem.get(pi.ASI_MFM_PO_Line_Item__c);
                if(trigger_oldMap == null){ // insert
                    // By Axel@introv		2014-10-20		PRCN-MFM Issue #34 to allow also 0.1 buffer on payment amount vs po amount
                    Decimal AmountNetOfTax = (pi.ASI_MFM_Paid_Amount_in_PO_Currency__c - pi.ASI_MFM_Tax_Amount__c).setScale(2) - 0.1;
                    //String aaa = 'ASI_MFM_Remaining_Balance__c:' + String.valueof(pol.ASI_MFM_Remaining_Balance__c) + ', AmountNetOfTax: ' + string.valueof(AmountNetOfTax) + 
                    //    ', pi.ASI_MFM_Paid_Amount_in_PO_Currency__c: ' + string.valueof(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c) + ', pi.ASI_MFM_Tax_Amount__c: ' + string.valueof(pi.ASI_MFM_Tax_Amount__c);
                    if(Math.abs(pol.ASI_MFM_Remaining_Balance__c) < AmountNetOfTax){
                        pi.addError('Total Payment amount cannot be greater than PO Line Item amount: ' +  pol.name );
                        System.debug('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + AmountNetOfTax).setScale(2)  +' incl. this payment) cannot be greater than PO Line Item amount ('+pol.ASI_MFM_Amount__c+'): ' +  pol.name + '');
                    }                   
                    //else if(!pi.ASI_MFM_CN_Pre_Payment__c && ((pol.ASI_MFM_CN_Receipt_Amount__c - pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100)).setScale(2) < pi.ASI_MFM_Paid_Amount_in_PO_Currency__c.setScale(2) - 0.1){
                    else if(!pi.ASI_MFM_CN_Pre_Payment__c && Math.abs((pol.ASI_MFM_CN_Receipt_Amount__c - pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100)).setScale(2) < pi.ASI_MFM_Paid_Amount_in_PO_Currency__c.setScale(2)-0.1){
                    // edited by Michael Yip (Introv) 02Sep2014 for Amount rounding for VAT deductable compared against PO receipt amt
                    //else if(!pi.ASI_MFM_CN_Pre_Payment__c && (pol.ASI_MFM_CN_Receipt_Amount__c - pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100) < pi.ASI_MFM_Paid_Amount_in_PO_Currency__c){
                        pi.addError('Total Payment amount cannot be greater than PO receipt amount: ' +  pol.name );
                        system.debug('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + pi.ASI_MFM_Paid_Amount_in_PO_Currency__c).setScale(2)  +' incl. this payment) cannot be greater than PO receipt amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c+(pol.ASI_MFM_CN_Receipt_Amount__c-pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100)).setScale(2 )+'): ' +  pol.name);
                    }
                    else if(!pi.ASI_MFM_CN_Pre_Payment__c && pi.ASI_MFM_Paid_Amount_in_PO_Currency__c<0 && pol.ASI_MFM_CN_Receipt_Amount__c==0){
						pi.addError('Only Prepayment is allowed if PO Receipt Amount is 0: ' +  pol.name );
					}
                    System.debug(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c +'/'+pi.ASI_MFM_Tax_Amount__c+'/'+pol.ASI_MFM_Remaining_Balance__c);
                    System.debug((pol.ASI_MFM_CN_Receipt_Amount__c - pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100) +'/' + pi.ASI_MFM_Paid_Amount_in_PO_Currency__c);
                    System.debug(pi.ASI_MFM_Tax__c);
                }
                else{   //update
                    // By Axel@introv		2014-10-20		PRCN-MFM Issue #34 to allow also 0.1 buffer on payment amount vs po amount
                    Decimal AmountDelta = (Math.abs(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c) - Math.abs(pi.ASI_MFM_Tax_Amount__c) - (Math.abs(trigger_oldMap.get(pi.id).ASI_MFM_Paid_Amount_in_PO_Currency__c) - Math.abs(trigger_oldMap.get(pi.id).ASI_MFM_Tax_Amount__c))).setScale(2);
                    //String aaaa = String.valueOf(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c) + ' - ' + String.valueOf(pi.ASI_MFM_Tax_Amount__c) + ' - ' + String.valueOf((trigger_oldMap.get(pi.id).ASI_MFM_Paid_Amount_in_PO_Currency__c) + ' -' +
                    //              String.valueOf(trigger_oldMap.get(pi.id).ASI_MFM_Tax_Amount__c)); 
                    //if(pol.ASI_MFM_Remaining_Balance__c < AmountDelta){
                    decimal polremaining = Math.abs(pol.ASI_MFM_Amount__c) - Math.abs(pol.ASI_MFM_CN_Paid_Amount__c);
                    if(Math.abs(polremaining + 0.1) < AmountDelta){
                        pi.addError('Total Payment amount cannot be greater than PO Line Item amount: ' +  pol.name);//'..........' + String.valueOf(pol.ASI_MFM_Remaining_Balance__c) + ' < ' + String.valueOf(AmountDelta)  );
                        System.debug('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + AmountDelta).setScale(2)  +' incl. this payment) cannot be greater than PO Line Item amount ('+pol.ASI_MFM_Amount__c+'): ' +  pol.name + '');
                    }                   
                    //else if(!pi.ASI_MFM_CN_Pre_Payment__c && (pol.ASI_MFM_CN_Receipt_Amount__c - pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100).setScale(2) < (pi.ASI_MFM_Paid_Amount_in_PO_Currency__c - trigger_oldMap.get(pi.id).ASI_MFM_Paid_Amount_in_PO_Currency__c).setScale(2)-0.1){
                    //    pi.addError('Total Payment amount cannot be greater than PO receipt amount: ' +  pol.name    + 'pol.ASI_MFM_CN_Receipt_Amount__c:' + String.valueOf(pol.ASI_MFM_CN_Receipt_Amount__c) + ' pol.ASI_MFM_CN_Paid_Amount__c:' + String.valueOf(pol.ASI_MFM_CN_Paid_Amount__c) + ' pi.ASI_MFM_Paid_Amount_in_PO_Currency__c:' + String.valueOf(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c));
                    //    system.debug('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + pi.ASI_MFM_Paid_Amount_in_PO_Currency__c).setScale(2)  +' incl. this payment) cannot be greater than PO receipt amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c+(pol.ASI_MFM_CN_Receipt_Amount__c-pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100)).setScale(2 )+'): ' +  pol.name);
                   // }
                    
                    else if(!pi.ASI_MFM_CN_Pre_Payment__c && Math.abs((pol.ASI_MFM_CN_Receipt_Amount__c - pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100)).setScale(2) < (Math.abs(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c) - Math.abs(trigger_oldMap.get(pi.id).ASI_MFM_Paid_Amount_in_PO_Currency__c)).setScale(2)-0.1){
                        pi.addError('Total Payment amount cannot be greater than PO receipt amount: ' +  pol.name);//+ 'pol.ASI_MFM_CN_Receipt_Amount__c:' + String.valueOf(pol.ASI_MFM_CN_Receipt_Amount__c) + ' pol.ASI_MFM_CN_Paid_Amount__c:' + String.valueOf(pol.ASI_MFM_CN_Paid_Amount__c) + ' pi.ASI_MFM_Paid_Amount_in_PO_Currency__c:' + String.valueOf(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c));
                        system.debug('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + pi.ASI_MFM_Paid_Amount_in_PO_Currency__c).setScale(2)  +' incl. this payment) cannot be greater than PO receipt amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c+(pol.ASI_MFM_CN_Receipt_Amount__c-pol.ASI_MFM_CN_Paid_Amount__c)*(1+pi.ASI_MFM_Tax__c/100)).setScale(2 )+'): ' +  pol.name);
                   }
                    else if(!pi.ASI_MFM_CN_Pre_Payment__c && pi.ASI_MFM_Paid_Amount_in_PO_Currency__c<0 && pol.ASI_MFM_CN_Receipt_Amount__c==0){
						pi.addError('Only Prepayment is allowed if PO Receipt Amount is 0: ' +  pol.name );
					}
                    
                    /*
                    if(pol.ASI_MFM_Remaining_Balance__c < AmountDelta){
                        pi.addError('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + AmountDelta)  +' incl. this payment) cannot be greater than PO Line Item amount ('+pol.ASI_MFM_Amount__c+'): ' +  pol.name + '');
                    }
                    else if(!pi.ASI_MFM_CN_Pre_Payment__c && pol.ASI_MFM_CN_Remaining_Receipt_Balance__c < AmountDelta){
                        pi.addError('Total Payment amount ('+ (pol.ASI_MFM_CN_Paid_Amount__c + AmountDelta)  +' incl. this payment) cannot be greater than PO receipt amount ('+pol.ASI_MFM_CN_Receipt_Amount__c+'): ' +  pol.name);
                    }*/
                }
            }
        }
        
        
    }
    
    /*private decimal NulltoZero(Decimal input1){
        if(input == null)
            return 0;
        else return input;
    } */
}