public without sharing class ASI_MFM_PH_POLineItem_TriggerClass {
    
    public static void routineAfterUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
// If the checkbox for spreading by month is checked, replace the original PO line item with multiple P:O line items 
// based on the PO start date and end date.     
        set<id> po_set = new set<id>();
        
        //Added by Michael (Introv) 21Feb2014 to update receipt balance and remaining
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c')){
            MRecType.put(rec.developername,rec.id);
        }
        // end of Changes
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            if (pi.ASI_MFM_Spread_by_Months__c && pi.ASI_MFM_Amount__c != null) {
                po_set.add(pi.ASI_MFM_PO__c);
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
                        
                        sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(2, roundingmode.half_up);
                        
                        decimal rounding_err = sp_amt * month_count - pi.ASI_MFM_Amount__c;
                        date sp_date = po.ASI_MFM_PO_Start_Date__c;
                        for (integer i=0; i<month_count; i++) {
                            ASI_MFM_PO_Line_Item__c npi = pi.clone(false, true);
                            npi.ASI_MFM_Amount__c = sp_amt;
                            
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
            
            if (PO_map.containsKey(pi.ASI_MFM_PO__c)) {                
                pi.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');                                    
            }
        }
    }

    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
                
        //PH 
        String PHDevName = 'ASI_MFM_PH_PO_Line_Item';

        set<id> setOfPlan = new set<id>();
        map <ID, ID> mapOfPOWithPlan = new map <ID, ID>();
        map <ID, set<ID>> mapOfPlanWithSubBrand = new map <ID, set<ID>>();        
                
        //Update by Steve Introv 12 Jun 2014 to get all customer
        Set<ID> setCUI = new Set<ID>();
        Set<ID> setPYI = new Set<ID>();
        Set<ID> setAPI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            
            i.ASI_MFM_Location__c=PHDevName.substring(8,13);
            setPYI.add(i.ASI_MFM_PO__c);                    
            setAPI.add(i.ASI_MFM_AP_Code__c);
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);
        }
        
        
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
                
        Set<id> SPOLineItemID = new Set<id>();
                        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> portList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:portList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator');
        
        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_Exchange_Rate__c,ASI_MFM_Accrual_PO__c, recordtypeID, ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_BU_Code__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        //Map<ID, ASI_MFM_AP_Code__c> apMap = new  Map<ID, ASI_MFM_AP_Code__c>([Select id, ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where id = :setAPI]);
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();
               
         
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            pi.ASI_MFM_Exchange_Rate__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null? poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c: pi.ASI_MFM_Exchange_Rate__c;
                        
            // Not allow increase amount if status not in draft
            if(trigger_oldmap != null && pi.ASI_MFM_PO_Status__c != 'Draft'){
                if(trigger_oldmap.get(pi.id).ASI_MFM_Amount__c < pi.ASI_MFM_Amount__c)
                    pi.addError('Not allow increate amount in "Final" status');
            }
            if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null) {
                sku_set.add(pi.ASI_MFM_SKU_Code__c);
            }
            
            if (pi.ASI_MFM_SKU_Code__c != null)
                sku_setDescription.add(pi.ASI_MFM_SKU_Code__c);
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

}