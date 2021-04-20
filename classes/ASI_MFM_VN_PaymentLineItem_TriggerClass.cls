/*********************************************************************************
 * Name:ASI_MFM_VN_PaymentLineItem_TriggerClass
 * Description: Trigger Class for PH and VN common use
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 12/2/2019       Laputa: Andy Zhang       Add country VN
 * 24/4/2019       Laputa: Andy Zhang       Update AC Code
 * 7/5/2019        Laputa: Andy Zhang       PAVN01-140 prevent duplicate invoice number being saved under same PO
*********************************************************************************/
public without sharing class ASI_MFM_VN_PaymentLineItem_TriggerClass {

    public static void routineAfterAll(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
// Recalculate payment amount in payment request header
        set<id> ph_set = new set<id>();
        set<id> phpl_set = new set<id>();
        set<id> pyl_set = new set<id>();

        if (trigger_oldmap == null) {               // Insert
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                ph_set.add(pi.ASI_MFM_Payment__c);
                phpl_set.add(pi.ASI_MFM_Payment__c);
                pyl_set.add(pi.id);
            }
        }
        else if (trigger_new == null) {             // Delete
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                ph_set.add(pi.ASI_MFM_Payment__c);
                phpl_set.add(pi.ASI_MFM_Payment__c);
                pyl_set.add(pi.id);
            }
        }
        else {                                      // Update
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                phpl_set.add(pi.ASI_MFM_Payment__c);
                pyl_set.add(pi.id);
                if (pi.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pi.id).ASI_MFM_Payment_Amount__c || pi.ASI_MFM_PO_Line_Currency__c != pi.ASI_MFM_Currency__c)
                    ph_set.add(pi.ASI_MFM_Payment__c);

            }
        }

        if (ph_set.size() > 0) {
            list<ASI_MFM_Payment__c> ph_list = [select id, ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c, (select ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c , ASI_MFM_PO_Line_Item__r.ASI_MFM_Currency__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Exchange_Rate__c from Payment_Line_Items__r) from ASI_MFM_Payment__c where id in :ph_set];
            for (ASI_MFM_Payment__c ph:ph_list) {
                ph.ASI_MFM_Payment_Amount__c = 0;
                for (ASI_MFM_Payment_Line_Item__c pi:ph.Payment_Line_Items__r) {
                    if (pi.ASI_MFM_Payment_Amount__c != null) {
                        system.debug('test21');
                        ph.ASI_MFM_Payment_Amount__c += pi.ASI_MFM_Payment_Amount__c;
                    }
                    ph.ASI_MFM_Currency__c = pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_Currency__c;
                    ph.ASI_MFM_Exchange_Rate__c = pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_Exchange_Rate__c;
                }
            }
            if(!Test.isRunningTest())
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
        // Update ASI_MFM_A_C_Code__c of the object ASI_MFM_Payment_Line_Item__c added by andy zhang 20190424
        if (pol_set.size() > 0) {
            map<id, ASI_MFM_PO_Line_Item__c> pol_map = new map<id, ASI_MFM_PO_Line_Item__c>([select ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c,
                ASI_MFM_List_Item_Description__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Paid_Amount__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c
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
                    if(pi.ASI_MFM_A_C_Code__c != null){
                        pi.ASI_MFM_Account_Code__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
                    }
                }
            }
        }


    }

    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {

        Set<ID> setPYI = new Set<ID>();
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        set<id> supplier_set = new set<id>();
        set<id> supplier_THset = new set<id>();
        set<id> po_Set = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {

            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }

            if (pi.ASI_MFM_Invoice_Date__c == null || pi.ASI_MFM_Invoice_Number__c == null) {
                pay_set.add(pi.ASI_MFM_Payment__c);
            }

            if (pi.ASI_MFM_PO_Line_Item__c != null)
                po_set.add(pi.ASI_MFM_PO_Line_Item__c);
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

        // Get A&P Segmentation from PO line    ***** Added by 2018-09-18 Linus@introv
        // Update ac code added by Andy Zhang 2019-4-24
        Map<id, ASI_MFM_PO_Line_Item__c> pol_map;
        if(po_set.size() > 0){
            pol_Map = new map<id, ASI_MFM_PO_Line_Item__c>( [Select id, ASI_MFM_AP_Description__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c where id IN: po_set]);
            for(ASI_MFM_Payment_Line_Item__c pi: trigger_new){
                pi.ASI_MFM_PH_A_P_Segmentation__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_AP_Description__c;
                //pi.ASI_MFM_Account_Code__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
            }
        }

        // Recalculate the paid amount in PO currency
        // Add country for VN by Andy Zhang Laputa
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
        if(country == 'VN'){
            ASI_MFM_Payment__c py=[select id,RecordType.DeveloperName from ASI_MFM_Payment__c where id=:trigger_new[0].ASI_MFM_Payment__c];
            if(py.RecordType.DeveloperName=='ASI_MFM_VN_DF_Payment'){
                country = 'SG';
            }
        }
        SYSTEM.debug('NOW country'+country);
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

                }
            }

        }

        // Not allow to change when the voucher created flag is on except [Effective?] is false
        if(trigger_oldMap != null){
            Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
            boolean isuserAdmin = prof.name.contains('System Administrator') == true ? true :false ;

            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {

                if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin) {
                    if (trigger_oldMap.get(pi.id).ASI_MFM_Effective__c != false && pi.ASI_MFM_Effective__c != true){       // Added by 2018-06-04 Linus@introv [LH 1.0]
                        pi.addError('Not allow to change because voucher has been created');
                    }
                }
            }
        }

        // prevent duplicate invoice number being saved under same PO added by Andy Zhang 20190507
        set<id> pol_set = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            //if (pi.ASI_MFM_PO_Line_Currency__c == null || pi.ASI_MFM_PO_Line_Remaining_Amount__c == null) {
                pol_set.add(pi.ASI_MFM_PO_Line_Item__c);

        }
        list<ASI_MFM_Payment_Line_Item__c> paymentLineItems = [select ASI_MFM_PO_Line_Item__c,ASI_MFM_Invoice_Number__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__c =:pol_set];
        for(ASI_MFM_Payment_Line_Item__c payl:paymentLineItems){
            for(ASI_MFM_Payment_Line_Item__c payl_new:trigger_new ){
                if(payl_new.ASI_MFM_PO_Line_Item__c == payl.ASI_MFM_PO_Line_Item__c && payl_new.ASI_MFM_Invoice_Number__c == payl.ASI_MFM_Invoice_Number__c && payl_new.Id!=payl.Id){
                    payl_new.addError('Duplicate invoice number for same PO is not allowed!');
                }
            }
        }


    }
}