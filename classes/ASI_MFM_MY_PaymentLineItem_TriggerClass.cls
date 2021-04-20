public without sharing class ASI_MFM_MY_PaymentLineItem_TriggerClass {

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
        
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        // Changed by KF Leung (Introv) 2014-04-26, Retrieve RecordTypeId from Global Cache
        Map<String, ID> MRecTypeID = new Map<String, id>();
        Set<ID> setPYI = new Set<ID>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c')){
            MRecTypeID.put(rec.developername,rec.id);
        }
        
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        set<id> supplier_set = new set<id>();

        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            // Added by Michael Yip 15Mar2014 to copy invoice amount to payment amount for MFM CN
            
            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }
            
            if (pi.ASI_MFM_Invoice_Date__c == null || pi.ASI_MFM_Invoice_Number__c == null) {
                pay_set.add(pi.ASI_MFM_Payment__c);
            }
            
            supplier_set.add(pi.ASI_MFM_Payee__c);
        }
        
        //MY Logic: Duplicate Invoice Number checking  ******** Added by 2018-05-25 Linus@introv
        System.debug('MY Duplicate Invoice Check: Supplier_set size: ' + supplier_set.size() + ' supplier set: ' + supplier_set);
        if (supplier_set.size() > 0){
            List<ASI_MFM_Payment_Line_Item__c> payLines = [select Name, ASI_MFM_Payment__c, ASI_MFM_Payment__r.Name, ASI_MFM_Payee__c, ASI_MFM_Invoice_Number__c, ASI_MFM_MY_Allow_Duplicate_Inv__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c = :supplier_set];
            System.debug('MY payLines.size : ' + payLines.size());
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if(trigger_oldmap == null || (trigger_oldmap != null && pi.ASI_MFM_Invoice_Number__c != trigger_oldmap.get(pi.id).ASI_MFM_Invoice_Number__c) || 
                   (trigger_oldmap != null && pi.ASI_MFM_MY_Allow_Duplicate_Inv__c != trigger_oldmap.get(pi.id).ASI_MFM_MY_Allow_Duplicate_Inv__c)){
                    for (ASI_MFM_Payment_Line_Item__c payLine:payLines){
                        System.debug('Current Line: ID:' + pi.id + ' Supplier ID: ' + pi.ASI_MFM_Payee__c + ' Inv no.: ' + pi.ASI_MFM_Invoice_Number__c + ' Payment ID: ' + pi.ASI_MFM_Payment__c);
                        System.debug('Query Line: ID:' + payLine.id + ' Supplier ID: ' + payLine.ASI_MFM_Payee__c + ' Inv no.: ' + payLine.ASI_MFM_Invoice_Number__c + ' Payment ID: ' + payLine.ASI_MFM_Payment__c);
                        if (pi.id != payLine.id && pi.ASI_MFM_MY_Allow_Duplicate_Inv__c == false && pi.ASI_MFM_Payee__c == payLine.ASI_MFM_Payee__c && pi.ASI_MFM_Invoice_Number__c == payLine.ASI_MFM_Invoice_Number__c
                            //&& pi.ASI_MFM_Payment__c != payLine.ASI_MFM_Payment__c
                            ){
                            pi.addError('Duplicate Invoice Number from the same Supplier is found on Payment: ' + payLine.Name); 
                        }
                    }
                }    
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
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
        
        SYSTEM.debug('NOW country'+country);
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
                    
                        pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                    
                }
            }
            
            if(Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_MY')){ // Add By Tony Ren For MY Use
                if(pi.ASI_MFM_Exchange_Rate__c!=null){
                    pi.ASI_MFM_Paid_Amount_in_Base_Currency__c=pi.ASI_MFM_Exchange_Rate__c*pi.ASI_MFM_Payment_Amount__c;
                }
                
            }
        }
         
         // Not allow to change when the voucher created flag is on       
         if(trigger_oldMap != null){
            Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
            boolean isuserAdmin = prof.name.contains('System Administrator') == true ? true :false ;
            
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {            
    
                       if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin) {                           
                           if (trigger_oldMap.get(pi.id).ASI_MFM_Effective__c != false && pi.ASI_MFM_Effective__c != true){    
                               pi.addError('Not allow to change because voucher has been created');                           
                           }
                       }
                   
            }   
        }
    }       
}