public without sharing class ASI_MFM_PaymentLineItem_TriggerClass {

    public static void routineAfterAll(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
// Recalculate payment amount in payment request header
        set<id> ph_set = new set<id>();
        set<id> phpl_set = new set<id>();
        set<id> pyl_set = new set<id>();
        if (trigger_oldmap == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                ph_set.add(pi.ASI_MFM_Payment__c);
                phpl_set.add(pi.ASI_MFM_Payment__c);
                pyl_set.add(pi.id);
            }
        }
        else if (trigger_new == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                ph_set.add(pi.ASI_MFM_Payment__c);  
                phpl_set.add(pi.ASI_MFM_Payment__c);
                pyl_set.add(pi.id);
            }
        }
        else {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                phpl_set.add(pi.ASI_MFM_Payment__c);
                pyl_set.add(pi.id);
                if (pi.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pi.id).ASI_MFM_Payment_Amount__c) {
                    ph_set.add(pi.ASI_MFM_Payment__c);
                }
            }           
        }

        if (ph_set.size() > 0) {
            list<ASI_MFM_Payment__c> ph_list = [select (select ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c from Payment_Line_Items__r) from ASI_MFM_Payment__c where id in :ph_set];
            for (ASI_MFM_Payment__c ph:ph_list) {
                ph.ASI_MFM_Payment_Amount__c = 0;
                for (ASI_MFM_Payment_Line_Item__c pi:ph.Payment_Line_Items__r) {
                    if (pi.ASI_MFM_Payment_Amount__c != null) {
                        system.debug('test21');
                        ph.ASI_MFM_Payment_Amount__c += pi.ASI_MFM_Payment_Amount__c;
                    }
                }
            }  
            update ph_list;
        }
        
        if (trigger_new != null){
/*            
            if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
                if (phpl_set.size() > 0) {
                    Boolean isupdate = false;
                    list<ASI_MFM_Payment__c> phpl_list = [select ASI_MFM_Plan__c,(select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c from Payment_Line_Items__r ORDER BY Name ASC) from ASI_MFM_Payment__c where id in :phpl_set];
                    for (ASI_MFM_Payment__c ph:phpl_list) {
                        for (ASI_MFM_Payment_Line_Item__c pi:ph.Payment_Line_Items__r) {
                            if (ph.ASI_MFM_Plan__c == null){
                                isupdate = true;
                                ph.ASI_MFM_Plan__c = pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c;
                            }
                        }
                    }
                    if (isupdate){
                    	update phpl_list;
                    }
                }
            }
*/
            if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_SG') || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_TH')){
                List<ASI_MFM_PO_Line_Item__c> pol_list = new List<ASI_MFM_PO_Line_Item__c>();
                set<id> pol_set = new set<id>();
                List<ASI_MFM_PO_Line_Item__c> pol_list2 = new List<ASI_MFM_PO_Line_Item__c>();
                set<id> pol_set2 = new set<id>();
                List<ASI_MFM_PO_Line_Item__c> pol_list3 = new List<ASI_MFM_PO_Line_Item__c>();
                set<id> pol_set3 = new set<id>();
                List<ASI_MFM_Payment_Line_Item__c> pyl_list = [Select id,ASI_MFM_PO_Line_Item__c, ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c, ASI_MFM_Partial_Payment__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c from ASI_MFM_Payment_Line_Item__c Where id in :pyl_set];
                for (ASI_MFM_Payment_Line_Item__c pal : pyl_list){ 
                    if (pal.ASI_MFM_POSM_Deposit__c == true && pal.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Final'){
                        if (!pol_set.contains(pal.ASI_MFM_PO_Line_Item__c)) {
                            pol_list.add(new ASI_MFM_PO_Line_Item__c(id=pal.ASI_MFM_PO_Line_Item__c, ASI_MFM_POSM_Deposit__c=pal.ASI_MFM_POSM_Deposit__c));
                            pol_set.add(pal.ASI_MFM_PO_Line_Item__c);
                        }
                    	
                	}
                    if (pal.ASI_MFM_POSM_Balance__c == true && pal.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Final'){
                        if (!pol_set2.contains(pal.ASI_MFM_PO_Line_Item__c)) {
                    		pol_list2.add(new ASI_MFM_PO_Line_Item__c(id=pal.ASI_MFM_PO_Line_Item__c, ASI_MFM_POSM_Balance__c=pal.ASI_MFM_POSM_Balance__c));
                            pol_set2.add(pal.ASI_MFM_PO_Line_Item__c);
                        }
                	}
                    if (pal.ASI_MFM_Partial_Payment__c == true && pal.ASI_MFM_Payment__r.ASI_MFM_Status__c=='Final'){
                        if (!pol_set3.contains(pal.ASI_MFM_PO_Line_Item__c)) {
                            pol_list3.add(new ASI_MFM_PO_Line_Item__c(id=pal.ASI_MFM_PO_Line_Item__c, ASI_MFM_Partial_Payment__c=pal.ASI_MFM_Partial_Payment__c));
                            pol_set3.add(pal.ASI_MFM_PO_Line_Item__c);
                        }
                	}
                }
                if (pol_list.size()>0){
					update pol_list;
                }
                if (pol_list2.size()>0){
					update pol_list2;
                }
                if (pol_list3.size()>0){
					update pol_list3;
                }
                
            }  //
        }


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
        } 
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
        Set<id> SGFRecTypeID = new Set<id>();
        
        
        for(String key : MRecTypeID.keySet()){
            //China and Gulf MFM both applies Pre-payment and PO Receipt function
            if(key.contains('CN_Payment')){
                SCNRecTypeID.add(MRecTypeID.get(key));
            } 
            else if(key.contains('GF_Payment')){
                SGFRecTypeID.add(MRecTypeID.get(key));
            }
        }
        Set<id> SPaymentID = new Set<id>();
        Map<id, ASI_MFM_Payment__c> MPayment = new Map<id,ASI_MFM_Payment__c>();
        for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){         
            if(SCNRecTypeID.contains(Pi.recordtypeid) || SGFRecTypeID.contains(Pi.recordtypeid)){
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
                else if (SGFRecTypeID.contains(Pi.recordtypeid)){
                    if((pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_CN_Receipt_Amount__c > 0) && SPrepaymentID.contains(pi.asi_mfm_payment__c)){
                        pi.addError('Pre-payment is not allowed after receipt made!');
                    }
                }
            }
        }
    }

    public static void routineBeforeUpdate(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
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
         set<string> CustomPermission =new set<string> ();
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_SG') && ! Test.isRunningTest() ){
            CustomPermission = ASI_MFM_ByPass_Setting.GetCustomPermissions();
        }
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            //If ETL is checked, updated ETL Date to now
            if(paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_JP_Payment_Read_Only') ||paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_JP_Payment')){
                if(pi.ASI_MFM_ETL__c && !trigger_oldMap.get(pi.id).ASI_MFM_ETL__c){
                    pi.ASI_MFM_ETL_Date__c=datetime.now();
                }
            }
            
               //KR MFM If ETL is checked, updated ETL Date to now
            if(paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_KR_Payment_Read_Only') ||paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_KR_Payment')){
                if(pi.ASI_MFM_ETL__c && !trigger_oldMap.get(pi.id).ASI_MFM_ETL__c){
                    pi.ASI_MFM_ETL_Date__c=datetime.now();
                }
                if(!pi.ASI_MFM_ETL__c){
                    pi.ASI_MFM_ETL_Date__c=null;
                }
            }
            
            if(paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_SG_Payment_Read_Only') 
               || paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_SG_Payment')){
                   if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin && !CustomPermission.contains('ASI_MFM_SG_SetPaymentStatus')) {
                       if (trigger_oldMap.get(pi.id).ASI_MFM_Effective__c != false && pi.ASI_MFM_Effective__c != true){   
                           pi.addError('Not allow to change because voucher has been created');
                       }
                   }
                   //20180114 Introv add KR RecordType
               }else if(paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_KR_Payment') || paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_KR_Payment_Read_Only') ||
                        paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_MY_Payment_Read_Only')||paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_MY_Payment') || paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_JP_Payment_Read_Only') ||paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_JP_Payment')||paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_PH_DF_Payment')||  paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_PH_DF_Payment_Read_Only') ||paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_PH_DP_Payment')||  paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_PH_DP_Payment_Read_Only') ){
                            //BYPASS JP PH MFM
               }
            else {
                if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin) {
                    pi.addError('Not allow to change because voucher has been created');
                }
                if (paymentMap.get(pi.ASI_MFM_Payment__c).RecordTypeID == rt_map.get('ASI_MFM_TW_Payment_Read_Only') && !isuserAdmin && !System.isFuture())
                {
                    pi.ASI_MFM_Currency__c.addError('You can NOT modify the Payment Line under an approved Payment');
                }
            }
        }               
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        // Changed by KF Leung (Introv) 2014-04-26, Retrieve RecordTypeId from Global Cache
        Map<String, ID> MRecTypeID = new Map<String, id>();
        Set<ID> setPYI = new Set<ID>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c')){
            MRecTypeID.put(rec.developername,rec.id);
        }
        // end of Changes
        Set<id> SCNRecTypeID = new Set<id>();
        Set<id> SGFRecTypeID = new Set<id>();
        Set<id> STHRecTypeID = new Set<id>();
        for(String key : MRecTypeID.keySet()){
            if(key.contains('CN_Payment')){
                SCNRecTypeID.add(MRecTypeID.get(key));
            } 
            else if(key.contains('GF_Payment')){
                SGFRecTypeID.add(MRecTypeID.get(key));
            }else if(key.contains('TH_Payment')){
                STHRecTypeID.add(MRecTypeID.get(key));
            }
        }
        
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        set<id> supplier_set = new set<id>();
        set<id> supplier_THset = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            // Added by Michael Yip 15Mar2014 to copy invoice amount to payment amount for MFM CN
            if(SCNRecTypeID.contains(pi.recordtypeid)){
                if(pi.ASI_MFM_CN_Invoice_Amount__c != null){
                    pi.ASI_MFM_Payment_Amount__c = pi.ASI_MFM_CN_Invoice_Amount__c;
                }
                else{
                    pi.ASI_MFM_Payment_Amount__c = 0;
                }
            }
            
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
            
            if (SGFRecTypeID.contains(pi.recordtypeid)){
                supplier_set.add(pi.ASI_MFM_Payee__c);
            }
            
            if(STHRecTypeID.contains(pi.recordtypeid)){
                supplier_THset.add(pi.ASI_MFM_Payee__c);
            }
        }
        
        //GF Logic: Duplicate Invoice Number checking
        System.debug('GF Duplicate Invoice Check: Supplier_set size: ' + supplier_set.size() + ' supplier set: ' + supplier_set);
        if (supplier_set.size() > 0){
            List<ASI_MFM_Payment_Line_Item__c> payLines = [select ASI_MFM_Payment__c, ASI_MFM_Payment__r.Name, ASI_MFM_Payee__c, ASI_MFM_Invoice_Number__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c = :supplier_set];
            System.debug('GF payLines.size : ' + payLines.size());
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                for (ASI_MFM_Payment_Line_Item__c payLine:payLines){
                    System.debug('Current Line: ID:' + pi.id + ' Supplier ID: ' + pi.ASI_MFM_Payee__c + ' Inv no.: ' + pi.ASI_MFM_Invoice_Number__c + ' Payment ID: ' + pi.ASI_MFM_Payment__c);
                    System.debug('Query Line: ID:' + payLine.id + ' Supplier ID: ' + payLine.ASI_MFM_Payee__c + ' Inv no.: ' + payLine.ASI_MFM_Invoice_Number__c + ' Payment ID: ' + payLine.ASI_MFM_Payment__c);
                    if (pi.id != payLine.id && pi.ASI_MFM_Payee__c == payLine.ASI_MFM_Payee__c && pi.ASI_MFM_Invoice_Number__c == payLine.ASI_MFM_Invoice_Number__c
                        && pi.ASI_MFM_Payment__c != payLine.ASI_MFM_Payment__c){
                        pi.addError('Duplicate Invoice Number from the same Supplier is found on Payment: ' + payLine.ASI_MFM_Payment__r.Name);
                    }
                }
            }
        }
        
                 //TH Logic: Duplicate Invoice Number checking
        if (supplier_THset.size() > 0 && Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_TH') ){
            //20160901, add bypass
            if(!ASI_MFM_Function.bypassTriggersFunction('ASI_MFM_PaymentLineItem_TriggerClass'))
            {
            if( !ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_PaymentLineItem_TriggerClass.DuplicateInvoiceNumberChecking','TH')){
                map<String,set<id>> pl_map = new map<String, set<id>>();
                Map<id,String> pay_map=new Map<id,String> ();
                List<ASI_MFM_Payment_Line_Item__c> payLines = [select ASI_MFM_Payment__c, ASI_MFM_Payment__r.Name, ASI_MFM_Payee__c, ASI_MFM_Invoice_Number__c from ASI_MFM_Payment_Line_Item__c where RecordType.DeveloperName =:'ASI_MFM_TH_Payment_Line_Item' and  ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c = :supplier_THset];
                for(ASI_MFM_Payment_Line_Item__c payLine:payLines){
                    String KeyValue=String.valueOf(payLine.ASI_MFM_Payee__c)+payLine.ASI_MFM_Invoice_Number__c;
                    if(pl_map.containsKey(KeyValue)){
                        pl_map.get(KeyValue).add(payLine.ASI_MFM_Payment__c);
                    }else{
                        set<id> payID_set = new set<id> ();
                        payID_set.add(payLine.ASI_MFM_Payment__c);
                        pl_map.put(KeyValue, payID_set);
                    }
                    pay_map.put(payLine.ASI_MFM_Payment__c, payLine.ASI_MFM_Payment__r.Name);
                }// end of for loop   system.assertEquals(null,pl_map);
                
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                    String KeyValue=String.valueOf(pi.ASI_MFM_Payee__c)+pi.ASI_MFM_Invoice_Number__c;
                    if(pl_map.containsKey(KeyValue)){
                        if(pl_map.get(KeyValue).size()>1){
                            String PaymentName='';
                            For(String payID:pl_map.get(KeyValue)){
                                if(pay_map.containsKey(payID)){
                                    PaymentName+=': '+pay_map.get(payID);
                                }
                                
                            }
                             pi.addError('Duplicate Invoice Number from the same Supplier is found on Payment ' +PaymentName);
                        }
                    }
                }
            }
        }//20160901, add bypass
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
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
        if(country == 'PH'){
            ASI_MFM_Payment__c py=[select id,RecordType.DeveloperName from ASI_MFM_Payment__c where id=:trigger_new[0].ASI_MFM_Payment__c];
            if(py.RecordType.DeveloperName=='ASI_MFM_PH_DF_Payment'){ 
                country = 'SG';
            }
        }    
        list<ASI_MFM_Exchange_Rate__c> xr_list = new list<ASI_MFM_Exchange_Rate__c>();
        if (pay_ccy_set.size() > 0 && po_ccy_set.size() > 0) {
            xr_list = [select ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c in :pay_ccy_set and ASI_MFM_Counter_Currency__c in :po_ccy_set and
                ASI_MFM_Country__c = :country and ASI_MFM_Effective_Date__c <= :date.today() order by ASI_MFM_Effective_Date__c desc];
        }
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = null;
            pi.ASI_MFM_GF_Paid_Amount_in_PO_Currency__c = null;
            
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
                    else if (Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_GF')){
                        pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                         if(pi.ASI_MFM_Payment_Amount_Distributor__c!=null){
                            pi.ASI_MFM_DistributorAmount_in_POCurrency__c = (pi.ASI_MFM_Payment_Amount_Distributor__c / xrate).setScale(2, roundingMode.half_up);
                        }
                        pi.ASI_MFM_GF_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_GF_Payment_Amount_PR_Gulf__c / xrate).setScale(2, roundingMode.half_up);
                    }else if (Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_SG')){
                        if(pi.ASI_MFM_Invoice_Total__c!=null){
                            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Invoice_Total__c / xrate).setScale(2, roundingMode.half_up);
                        }else{
                            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                        }
                    }
                    else {
                        pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                    }
                }
            }
            if(Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_MY') || Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_JP') || Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_KR')){ // Add By Tony Ren For MY Use
                if(pi.ASI_MFM_Exchange_Rate__c!=null){
                    pi.ASI_MFM_Paid_Amount_in_Base_Currency__c=pi.ASI_MFM_Exchange_Rate__c*pi.ASI_MFM_Payment_Amount__c;
                }
                
            }
        }
        
        /*  Added by Michael Yip (Introv) 20Dec2013
            retreive recordtype by sojbect and filter out record by record type and filter out CN PO
        */
        
        Set<id> SPaymentID = new Set<id>();
        Map<id, ASI_MFM_Payment__c> MPayment = new Map<id,ASI_MFM_Payment__c>();
        for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){         
            if(SCNRecTypeID.contains(Pi.recordtypeid)){
            system.debug(pi.ASI_MFM_Tax_Amount__c+'/'+pi.ASI_MFM_Payment_Amount__c+'/'+pi.ASI_MFM_Tax__c);
                pi.ASI_MFM_Tax_Amount__c = pi.ASI_MFM_Payment_Amount__c - (pi.ASI_MFM_Payment_Amount__c / (1 + (pi.ASI_MFM_Tax__c/100)));
                SPaymentID.add(pi.asi_mfm_payment__c);
            }
        }
        Set<id> SPrepaymentID = new Set<id>();
        for(ASI_MFM_Payment__c p : [Select ASI_MFM_Pre_payment__c, id from ASI_MFM_Payment__c where id IN :SpaymentID]){
            if(p.ASI_MFM_Pre_payment__c){
                SPrepaymentID.add(p.id);
            }
        }
        for(ASI_MFM_Payment_Line_Item__c pi : trigger_new){
            if(SCNRecTypeID.contains(Pi.recordtypeid) || SGFRecTypeID.contains(Pi.recordtypeid)){
                if(SPrepaymentID.contains(pi.asi_mfm_payment__c)){
                    pi.ASI_MFM_CN_Pre_Payment__c = true;
                    if(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c != null){
                        pi.ASI_MFM_CN_PrePaid_Amount_in_PO_Currency__c = pi.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                        //pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = 0* pi.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                    }
                }
            }
        }
        
        
    }       
}