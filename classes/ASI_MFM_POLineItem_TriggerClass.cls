public without sharing class ASI_MFM_POLineItem_TriggerClass {

    public static void routineAfterAll(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
// Pass PO and line item details to Data Warehouse  
        /*if (!ASI_MFM_Function.bypassCallouts()) {   
            set<id> pid_set = new set<id>();
            if (trigger_new != null) {
                for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                    if (trigger_oldMap == null || pi.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(pi.id).ASI_MFM_Sys_Sync_Time__c) {
                        pid_set.add(pi.ASI_MFM_PO__c);
                    }               
                }
            }
            else if (trigger_oldMap != null) {
                for (ASI_MFM_PO_Line_Item__c pi:trigger_oldMap.values()) {
                    pid_set.add(pi.ASI_MFM_PO__c);              
                }           
            }
            if (pid_set.size() > 0 && !system.isFuture()) {
                if (!(test.isRunningTest() && limits.getFutureCalls() >= limits.getLimitFutureCalls())) {               
                    ASI_MFM_Callout.updatePO(pid_set);
                }
            }    
        } */
    }

    public static void routineBeforeUpdate(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        boolean BPTRchecking=false;//By Pass TR checkning
        // if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        //     BPTRchecking=ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_PO_TriggerClass.TRroutineBeforeUpdate','TR');
        // }
        
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
        //     if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_TR')){
        //         if (pi.ASI_MFM_Synced__c == true && !BPTRchecking){
        //             if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
        //                 pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
        //                 pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
        //                 pi.ASI_MFM_TH_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Unit__c ||
        //                 pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
        //                 pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
        //                 pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
        //                 pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
        //                 pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
        //                     if(!Test.isRunningTest()){                                            
        //                         pi.addError('Cannot change Synced PO line: ' + pi.Name);
        //                     }
        //                 }
                    
        //         }
        //     }else if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
        //         if (pi.ASI_MFM_Synced__c == true){
        //             if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
        //                 pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
        //                 pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
        //                 pi.ASI_MFM_TH_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Unit__c ||
        //                 pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
        //                 pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
        //                 pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
        //                 pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
        //                 pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
        //                     if(!Test.isRunningTest()){                                            
        //                         pi.addError('Cannot change Synced PO line: ' + pi.Name);
        //                     }
        //                 }
                    
        //         }
        //     }
            
            
        //     if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF')){
        //         //Already had payment or receipt, do not allow change
        //         if ((pi.ASI_MFM_Paid_Amount__c > 0 || pi.ASI_MFM_CN_Receipt_Amount__c > 0) && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_GF_LockPOLine')){
        //             if (pi.ASI_MFM_Sub_brand_Allocation_Type__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Allocation_Type__c ||
        //                     pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
        //                         pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
        //                             pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
        //                                 pi.ASI_MFM_SKU_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_SKU_Code__c ||
        //                                     pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
        //                                         pi.ASI_MFM_UOM__c != trigger_oldMap.get(pi.id).ASI_MFM_UOM__c ||
        //                                             pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
        //                                                 pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
        //                                                     pi.ASI_MFM_Recharge__c != trigger_oldMap.get(pi.id).ASI_MFM_Recharge__c ||
        //                                                         pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
        //                                                             pi.ASI_MFM_Pay_Acc__c != trigger_oldMap.get(pi.id).ASI_MFM_Pay_Acc__c){
                                                                    
        //                 pi.addError('Cannot change PO line after PO Receipt or Payment');
        //             }
        //         }
        //     }
            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_TH')){
                //Already had payment or receipt, do not allow change
                if (pi.ASI_MFM_Complete__c == true){
                     if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                                pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
                                    pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                                        pi.ASI_MFM_TH_Region__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Region__c ||
                                            pi.ASI_MFM_TH_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Unit__c ||
                                                pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
                                                    pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
                                                        pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
                                                        pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
                                                            pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
                                                                if(!Test.isRunningTest()){                                            
                                                                    pi.addError('Cannot change Completed PO line: ' + pi.Name);
                                                                }
                    }
                }
            }
              if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_MY')){
                //Already had payment or receipt, do not allow change For MY add by Tony Ren
                if (pi.ASI_MFM_Complete__c == true){
                     if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                                pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
                                    pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                                        pi.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(pi.id).ASI_MFM_Invoice_Number__c ||
                                            pi.ASI_MFM_TH_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Unit__c ||
                                                pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
                                                    pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||pi.ASI_MFM_PO_Percentage__c != trigger_oldMap.get(pi.id).ASI_MFM_PO_Percentage__c ||
                                                        pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
                                                        pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||pi.ASI_MFM_Spread_by_Months__c != trigger_oldMap.get(pi.id).ASI_MFM_Spread_by_Months__c ||
                                                            pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
                                                                if(!Test.isRunningTest()){                                            
                                                                    pi.addError('Cannot change Completed PO line: ' + pi.Name);
                                                                }
                    }
                }
            }
            // if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_SG')){
            //     //Already had payment or receipt, do not allow change
            //     if (pi.ASI_MFM_Complete__c == true){
            //         if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
            //             pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
            //             pi.ASI_MFM_SG_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_SG_Unit__c ||
            //             pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
            //             pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
            //             pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
            //             pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
            //             pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
            //                 if(!Test.isRunningTest()){                                                                    
            //                     pi.addError('Cannot change Completed PO line: ' + pi.Name);
            //                 }
            //             }
            //     }
            // }
            
            // if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
            //     //Already had payment or receipt, do not allow change
            //     if (pi.ASI_MFM_Complete__c == true){
            //         if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
            //             pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
            //             pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
            //             pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
            //             pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
            //             pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
            //             pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
            //             pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
            //                 if(!Test.isRunningTest()){
            //                     pi.addError('Cannot change Completed PO line: ' + pi.Name);
            //                 }
            //             }
            //     }
            // }
        }
    }
    
    public static void routineAfterUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
// If the checkbox for spreading by month is checked, replace the original PO line item with multiple PO line items 
// based on the PO start date and end date.     
        set<id> po_set = new set<id>();
        
        //Added by Michael (Introv) 21Feb2014 to update receipt balance and remaining
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c')){
            MRecType.put(rec.developername,rec.id);
        }
        // end of Changes
        String CNRecTypeID = MRecType.get('ASI_MFM_CN_PO_Line_Item');
        Set<id> SPOLineItemID = new Set<id>();
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            if (pi.ASI_MFM_Spread_by_Months__c && pi.ASI_MFM_Amount__c != null) {
                po_set.add(pi.ASI_MFM_PO__c);
            }
            if(pi.RecordTypeId == CNRecTypeID){
                SPOLineItemID.add(pi.id);
            }
        }
        
        
        
        if(SPOLineItemID != null && SPOLineItemID.size()>0){
            List<ASI_MFM_Payment_Line_Item__c> LPItem = [Select ASI_MFM_POL_Receipt_Amount__c, ASI_MFM_Receipt_but_no_Paid__c,
                ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c, 
                ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Paid_Amount__c
                 from ASI_MFM_Payment_Line_Item__c 
                where ASI_MFM_PO_Line_Item__c IN :SPOLineItemID];
            if(LPItem != null && LPItem.size()>0){
                for(ASI_MFM_Payment_Line_Item__c i : LPItem){
                    i.ASI_MFM_POL_Receipt_Amount__c = i.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c;
                    i.ASI_MFM_Receipt_but_no_Paid__c = i.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Receipt_Amount__c- i.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Paid_Amount__c;
                }
                try{
                    update LPItem;
                }
                catch(exception e){
                    system.debug('Error caused by PMO validation when process PO receipt');
                }
            }
            List<ASI_MFM_PO_Receipt_Item__c> LPItem2 = [Select ASI_MFM_PO_Line_Item_Receipt_Amount__c, PO_Line_Item_Receipt_Amount_Temp__c,
                ASI_MFM_Remaining_Receipt_Balance_Temp__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c
                 from ASI_MFM_PO_Receipt_Item__c 
                where ASI_MFM_PO_Line_Item__c IN :SPOLineItemID];   
            if(LPItem2 != null && LPItem2.size()>0){
                for(ASI_MFM_PO_Receipt_Item__c i : LPItem2){
                    i.PO_Line_Item_Receipt_Amount_Temp__c = i.ASI_MFM_PO_Line_Item_Receipt_Amount__c;
                    i.ASI_MFM_Remaining_Receipt_Balance_Temp__c = i.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c;
                }
                update LPItem2;
            }
        }
        
        if (po_set.size() > 0) {
            map<id, ASI_MFM_PO__c> po_map = new map<id, ASI_MFM_PO__c>([select ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c, ASI_MFM_Is_Direct_Payment__c, recordType.developerName from ASI_MFM_PO__c where id in :po_set]);
            list<ASI_MFM_PO_Line_Item__c> npi_list = new list<ASI_MFM_PO_Line_Item__c>();
            set<id> dpi_set = new set<id>();
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Spread_by_Months__c && pi.ASI_MFM_Amount__c != null) {   
                    ASI_MFM_PO__c po = po_map.get(pi.ASI_MFM_PO__c);
                    if (po.ASI_MFM_PO_End_Date__c > po.ASI_MFM_PO_Start_Date__c) {
                        integer month_count = po.ASI_MFM_PO_Start_Date__c.monthsBetween(po.ASI_MFM_PO_End_Date__c) + 1;
                        decimal sp_amt;
                        decimal gf_sp_amt;
                        
                        if (po.recordType.DeveloperName.startsWith('ASI_MFM_TW') && pi.ASI_MFM_Currency__c == 'TWD') {
                            sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(0, roundingmode.half_up);
                        }
                        else {
                            sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(2, roundingmode.half_up);
                            // if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF') && pi.ASI_MFM_Distributor_Amount__c != null){
                            //     gf_sp_amt = (pi.ASI_MFM_Distributor_Amount__c / month_count).setScale(2, roundingmode.half_up);
                            // }
                        }                       
                        decimal rounding_err = sp_amt * month_count - pi.ASI_MFM_Amount__c;
                        date sp_date = po.ASI_MFM_PO_Start_Date__c;
                        for (integer i=0; i<month_count; i++) {
                            ASI_MFM_PO_Line_Item__c npi = pi.clone(false, true);
                            npi.ASI_MFM_Amount__c = sp_amt;
                            
                            // if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF')){
                            //     npi.ASI_MFM_Distributor_Amount__c = gf_sp_amt;
                            // }
                            
                            npi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_Start_Date__c.addMonths(i);
                            npi.ASI_MFM_Quantity__c = null;
                            npi.ASI_MFM_PO_Percentage__c = null;
                            npi.ASI_MFM_Spread_by_Months__c = false;
                            if (month_count > 1 && i + 1 == month_count) {
                                npi.ASI_MFM_Amount__c -= rounding_err;
                                npi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_End_Date__c;
                            }
                            npi_list.add(npi);                          
                        }
                        dpi_set.add(pi.id);
                    }
                }
            }
            if (npi_list.size() > 0) {
                insert npi_list;
            }
            if (dpi_set.size() > 0) {
                list<ASI_MFM_PO_Line_Item__c> dpi_list = [select id from ASI_MFM_PO_Line_Item__c where id in :dpi_set];
                delete dpi_list;
            }               
        }       
    }

    public static void routineBeforeDelete(list<ASI_MFM_PO_Line_Item__c> trigger_old) {
// Not allowed to delete if the PO is in final or complete status
        set<id> pid_set = new set<id>();
        for (ASI_MFM_PO_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_PO__c);
        }
        map<id, ASI_MFM_PO__c> PO_map = new map<id, ASI_MFM_PO__c>([select id from ASI_MFM_PO__c where id in :pid_set and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Complete') and ASI_MFM_Is_Direct_Payment__c != TRUE]);        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_old) {
            // if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_SG')){
            //     if(pi.ASI_MFM_Delete_Reject__c==true && pi.ASI_MFM_Spread_by_Months__c ==false){
            //         pi.addError('Not allowed to delete approved PO Lines');
            //     }            
            // }
			if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_CN')){
                if (pi.ASI_MFM_Already_Paid_or_Receipt__c)
                    pi.addError('Not allowed to delete because the PO already has PO Receipt or Payment');
            }//20160601 Elufa
            if (PO_map.containsKey(pi.ASI_MFM_PO__c)) {
                if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF')){
                    if (pi.ASI_MFM_Already_Paid_or_Receipt__c)
                        pi.addError('Not allowed to delete because the PO already has PO Receipt or Payment');
                }
                // else if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_TR')){
                //     if (pi.ASI_MFM_Already_Paid_or_Receipt__c)
                //         pi.addError('Not allowed to delete because the PO already has PO Receipt or Payment');
                // }
                else {
                    //Introv @20181125 to allow deletion of exceed PO Line Items
                    if (!Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_SG') && !pi.ASI_MFM_Exceed__c){
                        pi.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');
                    }
                    //End Introv @20181125
                }
            }
        }
    }

    public static void routineBeforeInsert(list<ASI_MFM_PO_Line_Item__c> trigger_new) {
// Set the exchange rate from the PO header
        set<id> po_set = new set<id>();
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            po_set.add(pi.ASI_MFM_PO__c);
        }
                
        map<id, ASI_MFM_PO__c> po_map = new map<id, ASI_MFM_PO__c>([select ASI_MFM_Exchange_Rate__c, ASI_MFM_Cloned_PO_ID__c from ASI_MFM_PO__c where id in :po_set]);
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            if (po_map.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null)
                pi.ASI_MFM_Exchange_Rate__c = po_map.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c;
            
            // if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
            //     //Auto fill in GL Date when clone and original PO GL Date is earlier than today
            //     if (po_map.get(pi.ASI_MFM_PO__c).ASI_MFM_Cloned_PO_ID__c != null && pi.ASI_MFM_G_L_Date__c != null && pi.ASI_MFM_G_L_Date__c < Date.today() && !pi.ASI_MFM_List_Item_Description__c.contains('(Reversal due to PO Completion)')){//20171006 Introv Added  && !pi.ASI_MFM_List_Item_Description__c.contains('(Reversal due to PO Completion)')
            //         pi.ASI_MFM_G_L_Date__c = Date.today();
            //     }
            // }
        }       
    }

    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        // Check if PO sub-brand NOT in line with PP e.g. 22140506
        // Added by Daniel WONG 2014-12-11
        // for RecordType = CN,  
        
        //HK
        // Set<Id> setPOHK = new Set<Id>();
        // Map<Id, ASI_MFM_PO_Line_Item__c> mapPOLine = new Map <Id, ASI_MFM_PO_Line_Item__c>();
        // for(ASI_MFM_PO_Line_Item__c pi : trigger_new){
        //     if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')){
        //         setPOHK.add(pi.ASI_MFM_PO__c);
        //         if (setPOHK.size() > 0) {
        //             List<ASI_MFM_PO_Line_Item__c> lstPOLineItem = [SELECT id, ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c from ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c in :setPOHK];
        //             if (lstPOLineItem.size() > 0) {
        //                 for (ASI_MFM_PO_Line_Item__c idxPOLineItem : lstPOLineItem) {
        //                     mapPOLine.put(idxPOLineItem.id, idxPOLineItem);
        //                 }
        //             }
        //         }
        //     }
        // }
        
        // for(ASI_MFM_PO_Line_Item__c pi : trigger_new){
        //     if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item')){
        //         if (mapPOLine.size() > 0) {
        //             //pi.ASI_MFM_AC_Code_Number__c = mapPOLine.get(pi.id).ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
        //             //pi.ASI_MFM_BU_Code_Number__c = mapPOLine.get(pi.id).ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c;
        //         }
        //     }
        // }
        
        set<id> setOfPO = new set<id>();
         //PH 
        set<id> setOfPOPH = new set<id>();
        Map<id, string> PORTMap = new Map<id, string>();
        for(ASI_MFM_PO_Line_Item__c pi : trigger_new){
             if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item')){
                setOfPOPH.add(pi.ASI_MFM_PO__c);
            }
            if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item'))
                setOfPO.add(pi.ASI_MFM_PO__c);
        }
      //Country:PH
        if(setOfPOPH.size()>0){
            for(ASI_MFM_PO__c i:[select id,RecordType.DeveloperName from ASI_MFM_PO__c where id in : setOfPOPH]){
                if(!PORTMap.containsKey(i.id)){
                    PORTMap.put(i.id,i.RecordType.DeveloperName);
                }
            }
        }
        set<id> setOfPlan = new set<id>();
        map <ID, ID> mapOfPOWithPlan = new map <ID, ID>();
        map <ID, set<ID>> mapOfPlanWithSubBrand = new map <ID, set<ID>>();
        if(setOfPO.size()>0){
        
            for(ASI_MFM_PO__c i : [SELECT ASI_MFM_Plan__c FROM ASI_MFM_PO__c WHERE id IN :setOfPO]){
                mapOfPOWithPlan.put(i.id, i.ASI_MFM_Plan__c);
                setOfPlan.add(i.ASI_MFM_Plan__c);
            }
            
            
            
            for(ASI_MFM_Plan_Line_Item__c i : [SELECT ASI_MFM_Plan__c, ASI_MFM_Sub_brand_Code__c
                                               FROM ASI_MFM_Plan_Line_Item__c
                                               WHERE ASI_MFM_Sub_brand_Code__c != NULL
                                               AND ASI_MFM_Plan__c IN :setOfPlan
                                              ]){
                id idKey = i.ASI_MFM_Plan__c;
                set <ID> setOfID = new set <ID>();
                if(mapOfPlanWithSubBrand.get(i.ASI_MFM_Plan__c) != NULL)
                    setOfID = mapOfPlanWithSubBrand.get(i.ASI_MFM_Plan__c);
                setOfID.add(i.ASI_MFM_Sub_brand_Code__c);
                
                mapOfPlanWithSubBrand.put(idKey, setOfID);
            }   
        }
        //Update by Steve Introv 12 Jun 2014 to get all customer
        Set<ID> setCUI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            if(i.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item')){
                 i.ASI_MFM_Location__c=PORTMap.get(i.ASI_MFM_PO__c).substring(8,13);
             }		
            //CAPEX Recordtype Only: Set default G/L date to be the current fiscal year
            if(i.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item')){
                if(i.ASI_MFM_G_L_Date__c == null){
                    Date fiscalYearDate = date.newInstance(date.today().year(), 06, 30);
                    if(fiscalYearDate < date.today())
                        fiscalYearDate = fiscalYearDate.addYears(1);
                    i.ASI_MFM_G_L_Date__c = fiscalYearDate;
                }
            }
            // End of CAPEX Change
            
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);
        }
        // Added by Michael Yip (Introv) 19Feb2014 to add default customer for CN PO line item
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c');
        
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        
        String CNRecTypeID = MRecType.get('ASI_MFM_CN_PO_Line_Item');
        String CNCustomerDefault;
        
        String JPRecTypeID = MRecType.get('ASI_MFM_JP_PO_Line_Item');
        String JPCustomerDefault;
        String JPBUCodeDefault;
        
        String RMRecTypeID = MRecType.get('ASI_MFM_RM_PO_Line_Item');
        String RMCustomerDefault;
        
        // String GFRecTypeID = MRecType.get('ASI_MFM_GF_PO_Line_Item');
        // String GFVAP_APCode_Default;
        // String GFFOC_UOM_Default;
        
        String MYRecTypeID = MRecType.get('ASI_MFM_MY_PO_Line_Item');
        String MYCustomerDefault;
        String MYBUCodeDefault;
        
        String TRJDFBUCodeDefault;
        
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        
        // String TRRecTypeID = MRecType.get('ASI_MFM_TR_PO_Line_Item');
        // System.debug('country_pfx : ' +  country_pfx );
        // if (country_pfx.contains('ASI_MFM_TR')){
        //     accMap = new Map<ID, account>([SELECT ID, Name, recordtypeID, ASI_HK_CRM_Location__c FROM account WHERE ID IN: setCUI]);
        //     Boolean allowEdit = checkTRAdminPermissionSet();
            
        //     for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
        //         if (pi.ASI_MFM_PO_Status__c == 'Final'){
        //             if (!allowEdit && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')){
        //                 pi.addError('Only admin user can edit an approved PO.');
        //             }
        //             else if (pi.ASI_MFM_Synced__c && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger') && (
        //                 pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c || 
        //                 pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c || 
        //                 pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c || 
        //                 pi.ASI_MFM_AP_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_AP_Code__c || 
        //                 pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c || 
        //                 pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c || 
        //                 pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c || 
        //                 pi.ASI_MFM_UOM__c != trigger_oldMap.get(pi.id).ASI_MFM_UOM__c || 
        //                 pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c || 
        //                 pi.ASI_MFM_Pay_Acc__c != trigger_oldMap.get(pi.id).ASI_MFM_Pay_Acc__c || 
        //                 pi.ASI_MFM_Next_Year__c != trigger_oldMap.get(pi.id).ASI_MFM_Next_Year__c)){
        //                 //Only block if PO Line Synced flag is TRUE before & after the update, to allow ETL to update this flag after JDE interface
        //                 pi.addError('Not allowed to update because the PO already has PO Receipt');
        //             }
        //         }
        //     }
        // }
        
        //CAPEX: Add CapexBUDefault
        String CAPEX_BUCodeDefault;
        String OPEX_BUCodeDefault;
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            if(Setting.ASI_MFM_Object__c == 'ASI_MFM_PO_Line_Item__c' && Setting.name == 'CN_Customer_Name__c' && Setting.Country__c == 'CN'){
                CNCustomerDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'JP_Customer_Name__c' && Setting.Country__c == 'JP'){
                JPCustomerDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'JP_BU_Code__c' && Setting.Country__c == 'JP'){
                JPBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'RM_Customer_Name__c' && Setting.Country__c == 'RM'){
                RMCustomerDefault = Setting.ASI_MFM_value__c;
            }
            // if(Setting.name == 'GF_VAP_AP_Code__c' && Setting.Country__c == 'GF'){
            //     GFVAP_APCode_Default = Setting.ASI_MFM_value__c;
            // }
            // if(Setting.name == 'GF_FOC_UOM__c' && Setting.Country__c == 'GF'){
            //     GFFOC_UOM_Default = Setting.ASI_MFM_value__c;
            // }
            if(Setting.name == 'MY_BU_Code__c' && Setting.Country__c == 'MY'){
                MYBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'MY_Customer_Name__c' && Setting.Country__c == 'MY'){
                MYCustomerDefault = Setting.ASI_MFM_value__c;
            }
            // if(Setting.name == 'TR_JDF_BU_Code__c' && Setting.Country__c == 'TR'){
            //     TRJDFBUCodeDefault = Setting.ASI_MFM_value__c;
            // }
            // // CAPEX: set the capex bu code default
            // if (setting.name == 'CAP_CAPEX_BU_Code__c' && Setting.Country__c == 'HK') {
            //     CAPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            // }
            // // OPEX: set the opex bu code default
            // if (setting.name == 'CAP_OPEX_BU_Code__c' && Setting.Country__c == 'HK') {
            //     OPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            // }
        }
        
        System.debug(CNCustomerDefault);
        
        Set<id> SPOLineItemID = new Set<id>();
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_PO__c);
            
            // Check if PO sub-brand NOT in line with PP e.g. 22140506
            // Added by Daniel WONG 2014-12-11
            if(i.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item')){
                if(i.ASI_MFM_Sub_brand_Code__c != NULL){
                    ID idKey = mapOfPOWithPlan.get(i.ASI_MFM_PO__c);
                
                    if(mapOfPlanWithSubBrand.get(idKey) != NULL){
                        set <ID> setOfID = mapOfPlanWithSubBrand.get(idKey);
                        if(!(setOfID.contains(i.ASI_MFM_Sub_brand_Code__c)))
                            i.addError('The sub-brand is NOT exists in the Plan Line Item.');
                    }else{
                            i.addError('There is NO sub-brand in the Plan Line Item.');
                    }
                }
            }
   
            //CAPEX Recordtype Only: Set Default BU Code if its empty
            if(i.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item')){
                if (i.ASI_MFM_PO_Type__c == 'CAPEX' && i.ASI_MFM_BU_Code__c == null){
                    i.ASI_MFM_BU_Code__c = CAPEX_BUCodeDefault;
                }
                else if (i.ASI_MFM_PO_Type__c == 'OPEX' && i.ASI_MFM_BU_Code__c == null){
                    i.ASI_MFM_BU_Code__c = OPEX_BUCodeDefault;
                }
            }
            
            // Added by Michael Yip (Introv) 19Feb2014 to add default customer for CN PO line item
            if(i.ASI_MFM_Customer_Name__c == null && i.RecordTypeId == CNRecTypeID && CNCustomerDefault != null && CNCustomerDefault != ''){
                i.ASI_MFM_Customer_Name__c = CNCustomerDefault;
                
            }  
            // Added by Steve Wan (Introv) 24Feb2014 to add default customer for JP PO line item
            else if(i.ASI_MFM_Customer_Name__c == null && i.RecordTypeId == JPRecTypeID && JPCustomerDefault != null && JPCustomerDefault != ''){
                i.ASI_MFM_Customer_Name__c = JPCustomerDefault;
            }    
            // Added by Wilken Lee (PR) 17Mar2014 to add default customer for RM PO line item
            else if(i.ASI_MFM_Customer_Name__c == null && i.RecordTypeId == RMRecTypeID && RMCustomerDefault != null && RMCustomerDefault != ''){
                i.ASI_MFM_Customer_Name__c = RMCustomerDefault;
            }  
                        
            // Added by by Steve Wan (Introv) 09Jun2014 to add default customer for JP PO line item
            if(i.ASI_MFM_BU_Code__c == null && i.RecordTypeId == JPRecTypeID && JPBUCodeDefault != null && JPBUCodeDefault != ''){
                i.ASI_MFM_BU_Code__c = JPBUCodeDefault;
            }  
            // Added by by Steve Wan (Introv) 12Jun2014 to add default BU for TR PO line item
            // if( i.RecordTypeId == TRRecTypeID ){
                
            //     if (i.ASI_MFM_TR_Rec_Type__c == 'JDF' && TRJDFBUCodeDefault != null && TRJDFBUCodeDefault != ''){
            //         //JDF BU
            //          i.ASI_MFM_BU_Code__c = TRJDFBUCodeDefault;
            //     }
            //     else{
            //         //ATR BU
            //         System.debug('Loc Code: ' + accMap.get(i.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c + '' + bu_list );
            //         For(ASI_MFM_BU__c bu : bu_list) {
            //             System.debug('bu Code: ' +  bu.ASI_MFM_BU_Code__c);
            //             if (bu.ASI_MFM_BU_Description__c.contains(accMap.get(i.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c) && bu.ASI_MFM_BU_Code__c != 'JDF'){
            //                     i.ASI_MFM_BU_Code__c = bu.id;
            //                     break;
            //             } 
            //         } 
            //     }
                
            // }
            //GF Logic: default AP Code to VAP for PO Type of VAP Brand Owner and VAP FOC
            // if((i.ASI_MFM_PO_Type__c == 'VAP Brand Owner' || i.ASI_MFM_PO_Type__c == 'VAP FOC') && i.RecordTypeId == GFRecTypeID && GFVAP_APCode_Default != null && GFVAP_APCode_Default != ''){
            //     i.ASI_MFM_AP_Code__c = GFVAP_APCode_Default;
            // }
            
            //GF Logic: default UOM to CA for PO Type of VAP FOC
            // if(i.ASI_MFM_PO_Type__c == 'VAP FOC' && i.ASI_MFM_UOM__c == null && i.RecordTypeId == GFRecTypeID && GFFOC_UOM_Default != null && GFFOC_UOM_Default != ''){
            //     i.ASI_MFM_UOM__c = GFFOC_UOM_Default;
            // }                

            //MY Logic:Default AP Code, BU Code, Customer, GL Date
            if(i.RecordTypeId == MYRecTypeID){     
                if(i.ASI_MFM_Customer_Name__c == null &&  MYCustomerDefault != null && MYCustomerDefault != ''){
                     i.ASI_MFM_Customer_Name__c = MYCustomerDefault;
                }
                if(i.ASI_MFM_BU_Code__c == null &&  MYBUCodeDefault != null && MYBUCodeDefault != ''){
                     i.ASI_MFM_BU_Code__c = MYBUCodeDefault;
                }
                if(i.ASI_MFM_G_L_Date__c == null ){
                     i.ASI_MFM_G_L_Date__c = date.today();
                }
            }
        }
        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> portList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:portList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';

        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_Accrual_PO__c, recordtypeID, ASI_MFM_BU_Code__c,ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();
        
        //GF VAP FOC SKU Amount Logic, Query SKU Unit Price
        Map<id,ASI_MFM_SKU_Code__c> skuMap = new Map<id,ASI_MFM_SKU_Code__c>();
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        
        //GF Logic: Auto fill in A/C Code if selected AP Code
        List<ASI_MFM_AP_Code__c> apCodeList = new List<ASI_MFM_AP_Code__c>();
        Map<id,id> apACMap = new Map<id,id>();
        // if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_GF')){
        //     List<ASI_MFM_AP_Code__c> apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_GF_AP_Code')];
            
        //     for (ASI_MFM_AP_Code__c ap:apCode){
        //         apACMap.put(ap.id, ap.ASI_MFM_A_C_Code__c);
        //     }
            
            
        //     skuList = [select ID, ASI_FOC_Unit_Cost__c from ASI_MFM_SKU_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_GF_SKU')];
            
        //     for (ASI_MFM_SKU_Code__c sku:skuList){
        //         skuMap.put(sku.id, sku);
        //     }
        // }
        // else if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_TR')){
        //     List<ASI_MFM_AP_Code__c> apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code')];
            
        //     for (ASI_MFM_AP_Code__c ap:apCode){
        //         apACMap.put(ap.id, ap.ASI_MFM_A_C_Code__c);
        //     }
        // }
        //CAPEX/OPEX Prefill AC Code if AP Code is selected
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_CAP')){
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_CAP_TW')) {
                List<ASI_MFM_AP_Code__c> apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_OTH_AP_Code')];
            
                for (ASI_MFM_AP_Code__c ap:apCode){
                    apACMap.put(ap.id, ap.ASI_MFM_A_C_Code__c);
                }
            } else {
                List<ASI_MFM_AP_Code__c> apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code')];
            
                for (ASI_MFM_AP_Code__c ap:apCode){
                    apACMap.put(ap.id, ap.ASI_MFM_A_C_Code__c);
                }
            }
        }
         
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            // Check if there was an input in the decimal number output error
            boolean isDecimal = (ASI_MFM_Function.containsDecimalValue(pi.ASI_MFM_Amount__c)) && pi.ASI_MFM_Currency__c == 'TWD';
                    
            if (isDecimal)
                pi.addError(' You Cannot input a decimal number for a TWD currency.');
                
            // Bypass checking if roll up summary payment item related is updated
			// Updated by Introv at 20170808 (Exclude the case when PO Header's "ASI_MFM_Accrual_PO__c = true")
            if (poMap != NULL && poMap.get(pi.ASI_MFM_PO__c) != NULL && poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_TW_PO_Read_Only') && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Is_Direct_Payment__c != TRUE && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Accrual_PO__C == FALSE && !isuserAdmin && !System.isFuture() && trigger_oldMap != NULL && trigger_oldMap.get(pi.id) != NULL && pi.ASI_MFM_Paid_Amount__c == trigger_oldMap.get(pi.id).ASI_MFM_Paid_Amount__c){
                    pi.addError('You can NOT modify the PO Line under a Final or Complete PO');                
            }
            
            if (pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item')){
                pi = asi_mfm_POLineItem.setAmount(pi);
            }
            
            if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null) {
                sku_set.add(pi.ASI_MFM_SKU_Code__c);
            }
            
            if (pi.ASI_MFM_SKU_Code__c != null)
                sku_setDescription.add(pi.ASI_MFM_SKU_Code__c);
            
            // Updated by Michael Yip (Introv) 4 Feb 2013 to add default valud for list item description for CN PO Line item
            if(pi.ASI_MFM_List_Item_Description__c == null && (poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_CN_PO') || poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_CN_PO_Read_Only'))){
                pi.ASI_MFM_List_Item_Description__c = '/';
            }
            
            // Updated by Steve Wan (Introv) 24 Feb 2014 to add default valid for list item description for JP PO Line item
            if(pi.ASI_MFM_List_Item_Description__c == null && poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_JP_PO') ){
                pi.ASI_MFM_List_Item_Description__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Remarks__c;
            }
            
            // Updated by Michael Yip (Introv) 6 Jan 2014 to exclude CN PO Line item    
            // Updated by Steve Wan (Introv) 24 Feb 2014 to exclude JP PO Line item
            if (pi.ASI_MFM_SKU_Code__c == null && pi.ASI_MFM_List_Item_Description__c == null && (poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_TW_PO') || poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_TW_PO_Read_Only')))
                pi.adderror('SKU code and Item Line Description cannot be both empty');
            
            //TR Logic:
            // if (Global_RecordTypeCache.getRt(poMap.get(pi.ASI_MFM_PO__c).recordTypeID).DeveloperName.contains('ASI_MFM_TR')){
            //     if (pi.ASI_MFM_AP_Code__c != null)
            //         pi.ASI_MFM_A_C_Code__c = apACMap.get(pi.ASI_MFM_AP_Code__c);
            // }
            
            //CAPEX LOGIC: Auto Fill AC based on AP Code
            if (Global_RecordTypeCache.getRt(poMap.get(pi.ASI_MFM_PO__c).recordTypeID).DeveloperName.contains('ASI_MFM_CAP')){
                //Updated by Wilken 17 Oct 2014 to exclude ETL user
                if (pi.ASI_MFM_AP_Code__c != null && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_ValidateSubBrandCode'))
                    pi.ASI_MFM_A_C_Code__c = apACMap.get(pi.ASI_MFM_AP_Code__c);
            }
            
            //GF Logic:
            // if (pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item')){
            //     //GF Auto fill A/C Code Logic
            //     if (pi.ASI_MFM_AP_Code__c != null)
            //         pi.ASI_MFM_A_C_Code__c = apACMap.get(pi.ASI_MFM_AP_Code__c);
                
            //     //GF Auto Calculate SKU Cost for VAP FOC PO
            //     if (pi.ASI_MFM_PO_Type__c == 'VAP FOC' && pi.ASI_MFM_Amount__c == null && pi.ASI_MFM_SKU_Code__c != null && pi.ASI_MFM_Quantity__c != null){
            //         if (skuMap.get(pi.ASI_MFM_SKU_Code__c).ASI_FOC_Unit_Cost__c != null){
            //             pi.ASI_MFM_Amount__c = skuMap.get(pi.ASI_MFM_SKU_Code__c).ASI_FOC_Unit_Cost__c * pi.ASI_MFM_Quantity__c;
            //         }
            //     }
            // }
            
            //HK MFM Logic: Auto fill in BU base on prefix
            // if (Global_RecordTypeCache.getRt(poMap.get(pi.ASI_MFM_PO__c).recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
            //     if (pi.ASI_MFM_BU_Code__c == null && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c != null)
            //         pi.ASI_MFM_BU_Code__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c;
            // }
            
            //MY Logic auto calculate PO line amount from quantity and unit cost     
            System.debug('Recordtype ID: ' + pi.recordTypeID + ' Amount: ' + pi.ASI_MFM_Amount__c + ' Qty: ' + pi.ASI_MFM_Quantity__c + ' Unit Price: ' + pi.ASI_MFM_Unit_Price__c);
            if ((pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item')||pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TR_PO_Line_Item')||pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item')) && pi.ASI_MFM_Amount__c == null && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Price__c != null) {
                pi.ASI_MFM_Amount__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Price__c).setScale(2, roundingmode.half_up);
                System.debug('Auto calculated PLine Amt by Qty: ' + (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Price__c).setScale(2, roundingmode.half_up));
            }
            if ((pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TH_PO_Line_Item')) && pi.ASI_MFM_Amount__c == null && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_TH_Unit__c != null) {
                pi.ASI_MFM_Amount__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_TH_Unit__c).setScale(2, roundingmode.half_up);
            }
            if (((pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TH_PO_Line_Item')) || (pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item')))&& pi.ASI_MFM_Amount__c == null && (pi.ASI_MFM_Quantity__c == null || pi.ASI_MFM_TH_Unit__c == null)) {
                pi.ASI_MFM_Amount__c = 0;
            }
            //SG Logic: pass header customer to line if customer is null 
            // if(pi.ASI_MFM_Customer_Name__c == null && poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_SG_PO') ){
            // //if(pi.ASI_MFM_Customer_Name__c == null && Global_RecordTypeCache.getRt(poMap.get(pi.ASI_MFM_PO__c).recordTypeID).DeveloperName.contains('ASI_MFM_SG')){
            //     pi.ASI_MFM_Customer_Name__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_SG_Customer__c; 
            // }
        }
        
// Set sub-brand code if it is not input by user
        if (sku_set.size() > 0) {
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_Sub_brand__c from ASI_MFM_SKU_Code__c where id = :sku_set]);
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c)) {
                    pi.ASI_MFM_Sub_brand_Code__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_MFM_Sub_brand__c;
                }           
            }           
        }

// Set Description AND UOM1 if it is not input by user
        if (sku_setDescription.size() > 0){
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_SKU_Description__c, ASI_HK_CRM_UOM1__c from ASI_MFM_SKU_Code__c where id = :sku_setDescription]);
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) 
            {
                if (pi.ASI_MFM_List_Item_Description__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c))
                    pi.ASI_MFM_List_Item_Description__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_MFM_SKU_Description__c;
                    
                if (pi.ASI_MFM_UOM__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c))
                    pi.ASI_MFM_UOM__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_HK_CRM_UOM1__c;
            }
        }
        
        // Added by Michael Yip (Introv) 10Feb2014 to set default BU code to be same as PO BU code for CN PO
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            if (pi.ASI_MFM_BU_Code__c != poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_BU_Code__c && (poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_CN_PO') || poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_CN_PO_Read_Only'))) {
                pi.ASI_MFM_BU_Code__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_BU_Code__c;
            }
            
            if(pi.ASI_MFM_G_L_Date__c == null && (poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_CN_PO') || poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_CN_PO_Read_Only'))){
                pi.ASI_MFM_G_L_Date__c = date.today();
            }
        } 
        
        // Added by Steve Wan (Introv) 10Mar2014 to set JP logic validate correct sub Brand
        if (rt.developerName.startsWith('ASI_MFM_JP')){
            set<id> px_set = new set<id>();
            set<id> pr_set = new set<id>();
            
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                pr_set.add(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Responsible_By__c);
                px_set.add(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Prefix__c);
            }
        
            List<ASI_MFM_Brand_Route_Type_Map__c> brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Responsible_By__c from ASI_MFM_Brand_Route_Type_Map__c 
                    where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Responsible_By__c in :pr_set) 
                    order by ASI_MFM_Prefix__c, ASI_MFM_Responsible_By__c desc];
            set<id> rt_set = new set<id>();     
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }           
            list<ASI_MFM_Route_Type_Brands_Relationship__c> rule_list = [select Brand_MFM__c, ASI_MFM_Route_Type__c from ASI_MFM_Route_Type_Brands_Relationship__c 
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, Brand_MFM__c];
            set<id> br_set = new set<id>();     
            for (ASI_MFM_Route_Type_Brands_Relationship__c br:rule_list) {
                br_set.add(br.Brand_MFM__c);
            }      
            map<id, ASI_MFM_Sub_brand__c> sb_map = new map<id, ASI_MFM_Sub_brand__c>([select id, ASI_MFM_Brand__c from ASI_MFM_Sub_brand__c 
                where ASI_MFM_Brand__c in :br_set order by ASI_MFM_Brand__c]);
            boolean validSubBrand = false;
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if ( poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_JP_PO') && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_ValidateSubBrandCode')){
                    if (sb_map.containsKey(pi.ASI_MFM_Sub_brand_Code__c) ) {
                        validSubBrand = true;
                    }else
                    {
                        pi.ASI_MFM_Sub_brand_Code__c.adderror('Sub Brand Code is not allow for the route type');
                    }
                }
            }       
        }
        
        
// Set default BU code if not input by user
       
        setDefaultBUCode(trigger_new, bu_list);             
    }       
    
    public static void setDefaultBUCode(list<ASI_MFM_PO_Line_Item__c> listPi, list<ASI_MFM_BU__c> bu_list)
    {
        if(bu_list.size()==1) {
            for (ASI_MFM_PO_Line_Item__c pi:listPi) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                    pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                }        
            }
        }
    }
    private static boolean checkTRAdminPermissionSet(){
             /*String soql = 'SELECT PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = \'ASI_TR_MFM_Admin_User\'';
             System.debug('soql :' + soql + ';'  );
              //UserInfo.getUserId()
             List<PermissionSetAssignment> pmsList = database.query(soql);
             if (pmsList.size()>0 ){
                 for(PermissionSetAssignment psa : pmsList)
                 {
                     if (psa.AssigneeId  == UserInfo.getUserId())
                         return true;
                 }
                 return false;
             }else{
                 return false;
             }*/
        List<PermissionSetAssignment> pmsList = [SELECT id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ASI_TR_MFM_Admin_User' AND AssigneeId = :UserInfo.getUserId()];
        if (pmsList.size()>0)
            return true;
        else
            return false;
        }
}