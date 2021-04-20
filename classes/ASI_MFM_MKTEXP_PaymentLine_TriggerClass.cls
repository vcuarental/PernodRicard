public without sharing class ASI_MFM_MKTEXP_PaymentLine_TriggerClass {
    public static void routineAfterAll(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
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
        /*
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
        
        Set<id> SPaymentID = new Set<id>();
        Map<id, ASI_MFM_Payment__c> MPayment = new Map<id,ASI_MFM_Payment__c>();
        if (pol_set.size() > 0) {
            map<id, ASI_MFM_PO_Line_Item__c> pol_map = new map<id, ASI_MFM_PO_Line_Item__c>([select ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c, 
                ASI_MFM_List_Item_Description__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Paid_Amount__c
                from ASI_MFM_PO_Line_Item__c where id in :pol_set]);
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
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
        
            if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin) {
                pi.addError('Not allow to change because voucher has been created');
            }
        }           
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        set<id> pol_set = new set<id>();
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {

            pol_set.add(pi.ASI_MFM_PO_Line_Item__c);
            
            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }
            /*
            if (pi.ASI_MFM_Invoice_Date__c == null || pi.ASI_MFM_Invoice_Number__c == null) {
                pay_set.add(pi.ASI_MFM_Payment__c);
            }*/
            pay_set.add(pi.ASI_MFM_Payment__c);
        }
        
        map<id, ASI_MFM_Payment__c> pay_map;
// Set invoice number and invoice date
        if (pay_set.size() > 0) {
            pay_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Status__c, ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c,ASI_MFM_Actual_MKT_Expense_Allocation__c, recordType.developerName from ASI_MFM_Payment__c where id in :pay_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                pi.ASI_MFM_MKTEXP_Payment_Status__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Status__c;
                if (pi.ASI_MFM_Invoice_Date__c == null) {   
                    pi.ASI_MFM_Invoice_Date__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c;
                }
                if (pi.ASI_MFM_Invoice_Number__c == null) { 
                    pi.ASI_MFM_Invoice_Number__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c;
                }                                   
            }    
            
        }       
        /*
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
                if (xrate != null && pi.ASI_MFM_Paid_Amount_in_PO_Currency__c == null && pi.ASI_MFM_Paid_Amount_in_Base_Currency__c != null) {
                    pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Paid_Amount_in_Base_Currency__c / xrate).setScale(2, roundingMode.half_up);
                }
            }
        }
        */
        
        // Recalculate the paid amount   
        Map<id, ASI_MFM_PO_Line_Item__c> pol_map;
        if(pol_set != null && pol_set.size() > 0) 
            pol_map = new Map<id, ASI_MFM_PO_Line_Item__c>([select id, ASI_MFM_G_L_Date__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Reference_2__c from ASI_MFM_PO_Line_Item__c where id IN :pol_set]);

        System.debug('pol_map:'+pol_map);
        
        // [SH] 2019-03-29
        // get CAPEX default A/C Code
        List<ASI_MFM_A_C_Code__c> CapexAC = [Select id from ASI_MFM_A_C_Code__c where recordtype.name like '%TR%' and ASI_MFM_A_C_Code__c like '1747.000000%' limit 1];
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            if(pay_map.get(pi.ASI_MFM_Payment__c) != null && pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Actual_MKT_Expense_Allocation__c == false) {
                if (pi.ASI_MFM_Payment_Amount__c != null && pol_map.get(pi.ASI_MFM_PO_Line_Item__c) != null 
                    && (pi.ASI_MFM_MKTEXP_Payment_Status__c == 'Submitted' || pi.ASI_MFM_MKTEXP_Payment_Status__c == 'Final' || pi.ASI_MFM_MKTEXP_Payment_Status__c == 'Finance Verified' || pi.ASI_MFM_MKTEXP_Payment_Status__c == 'Pending Goods/Service Receipt')) {
                    if(Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && (pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c == 'Manual' || pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c == 'Advanced Pricing') && pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Exchange_Rate__c != null)
                        pi.ASI_MFM_Paid_Amount_in_Base_Currency__c = pi.ASI_MFM_Payment_Amount__c * pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Exchange_Rate__c;
                    else {
                        pi.ASI_MFM_Paid_Amount_in_Base_Currency__c = pi.ASI_MFM_Payment_Amount__c * pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c;  
                    }
                    pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = pi.ASI_MFM_Payment_Amount__c;
                    /*
                    pi.ASI_MFM_Accrual_Amount_Payment_Currency__c = (pi.ASI_MFM_Invoice_Date__c >= pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_G_L_Date__c) ? pi.ASI_MFM_Payment_Amount__c : 0;
                    pi.ASI_MFM_Accrual_Amount_Base_Currency__c = (pi.ASI_MFM_Invoice_Date__c >= pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_G_L_Date__c) ? pi.ASI_MFM_Paid_Amount_in_Base_Currency__c : 0;
                    pi.ASI_MFM_Accrual_Amount_PO_Currency__c = (pi.ASI_MFM_Invoice_Date__c >= pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_G_L_Date__c) ? pi.ASI_MFM_Paid_Amount_in_PO_Currency__c : 0;
                    */
                }
                else {
                    pi.ASI_MFM_Paid_Amount_in_Base_Currency__c = 0;
                    pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = 0;
                    /*
                    pi.ASI_MFM_Accrual_Amount_Payment_Currency__c = 0;
                    pi.ASI_MFM_Accrual_Amount_Base_Currency__c = 0;
                    pi.ASI_MFM_Accrual_Amount_PO_Currency__c = 0;
                    */
                }
            }
            
            // [SH] 2019-03-29 
            //  set default A/C Code 1747.000000 WIP if CAPEX PO Payment
            if(pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__r.ASI_MFM_Reference_2__c == 'CAPEX'){
                if(CapexAC != null){
                    pi.ASI_MFM_A_C_Code__c = CapexAC[0].id;
                }
            }
        }
    }        
}