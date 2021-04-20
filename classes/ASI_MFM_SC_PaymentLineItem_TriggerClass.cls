public without sharing class ASI_MFM_SC_PaymentLineItem_TriggerClass {

    public static void routineAfterAll(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        /*        
        set<id> ph_set = new set<id>();
        set<id> phpl_set = new set<id>();
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
        
        if (trigger_oldmap == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                phpl_set.add(pi.ASI_MFM_Payment__c);
            }
        }
        else if (trigger_new == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                phpl_set.add(pi.ASI_MFM_Payment__c);            
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
        */
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
        
/*          
        if (payment_set.size() > 0) {
            map<id, ASI_MFM_Payment__c> payment_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_SC_Supplier_Name__c from ASI_MFM_Payment__c where id in :payment_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {  
                if (pi.ASI_MFM_Payee__c == null && payment_map.containsKey(pi.ASI_MFM_Payment__c)) {
                    pi.ASI_MFM_Payee__c = payment_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_SC_Supplier_Name__c;
                }               
            }            
        }
*/
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

    public static void routineBeforeUpdate(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
// Not allow to change when the voucher created flag is on
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_Payment_Line_Item__c i : trigger_new)
            setPYI.add(i.ASI_MFM_Payment__c);   

        Map<ID, ASI_MFM_Payment__c> paymentMap = new Map<ID, ASI_MFM_Payment__c>([SELECT ID, Name, recordtypeID FROM ASI_MFM_Payment__c WHERE ID IN: setPYI]);
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && pi.ASI_MFM_Voucher_Created__c) {
                pi.addError('Not allow to change because voucher has been created');
            }
        }           
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        // Changed by KF Leung (Introv) 2014-04-26, Retrieve RecordTypeId from Global Cache
        Map<String, ID> MRecTypeID = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Payment_Line_Item__c')){
            MRecTypeID.put(rec.developername,rec.id);
        }
        // end of Changes
        Set<id> SCNRecTypeID = new Set<id>();
        Set<id> SGFRecTypeID = new Set<id>();

        
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        set<id> supplier_set = new set<id>();
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            
            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }
           
            pay_set.add(pi.ASI_MFM_Payment__c);       
        }
        
        
        map<id, ASI_MFM_Payment__c> pay_map;
// Set invoice number and invoice date
        if (pay_set.size() > 0) {
            pay_map = new map<id, ASI_MFM_Payment__c>([select id,ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c,asi_mfm_exchange_rate__c from ASI_MFM_Payment__c where id in :pay_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                if(pay_map.get(pi.ASI_MFM_Payment__c)==null)
                    continue;
                if (pi.ASI_MFM_Invoice_Date__c == null) {   
                    if(pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c!=null)
                        pi.ASI_MFM_Invoice_Date__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c;
                }
                if (pi.ASI_MFM_Invoice_Number__c == null) { 
                    if(pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c!=null)
                        pi.ASI_MFM_Invoice_Number__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c;
                } 
                pi.ASI_MFM_Paid_Amount_in_Base_Currency__c=pay_map.get(pi.ASI_MFM_Payment__c).asi_mfm_exchange_rate__c*pi.asi_mfm_payment_amount__c;
            }    
            
        }       
        
// Recalculate the paid amount in PO currency     
        string country =  'HK';
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
                    pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);                
                }else
                     pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = pi.ASI_MFM_Payment_Amount__c;
                
            }
        }      
    }       
}