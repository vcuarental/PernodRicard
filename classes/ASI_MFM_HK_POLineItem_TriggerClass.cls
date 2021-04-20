public without sharing class ASI_MFM_HK_POLineItem_TriggerClass {

    public static void routineBeforeUpdate(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {             
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
                if (pi.ASI_MFM_Synced__c == true || pi.ASI_MFM_Complete__c == true){
                    if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                        pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
                        pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                        pi.ASI_MFM_TH_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Unit__c ||
                        pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
                        pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
                        pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
                        pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
                        pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
                        if(!Test.isRunningTest()){     
                            if(pi.ASI_MFM_Synced__c == true)
                                pi.addError('Cannot change Synced PO line: ' + pi.Name);
                            if(pi.ASI_MFM_Complete__c == true)
                                pi.addError('Cannot change Completed PO line: ' + pi.Name);
                        }
                    }      
                }       
            }
        }//for
    }//routineBeforeUpdate()
    
    public static void routineAfterUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) { 
        set<id> po_set = new set<id>();
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            if (pi.ASI_MFM_Spread_by_Months__c && pi.ASI_MFM_Amount__c != null && !po_set.contains(pi.ASI_MFM_PO__c)) {
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
                        decimal gf_sp_amt;
                              
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

    public static void routineBeforeInsert(list<ASI_MFM_PO_Line_Item__c> trigger_new) {

        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
                //Auto fill in GL Date when clone and original PO GL Date is earlier than today
                if (pi.ASI_MFM_PO__r.ASI_MFM_Cloned_PO_ID__c != null && pi.ASI_MFM_G_L_Date__c != null && pi.ASI_MFM_G_L_Date__c < Date.today() && !pi.ASI_MFM_List_Item_Description__c.contains('(Reversal due to PO Completion)')){//20171006 Introv Added  && !pi.ASI_MFM_List_Item_Description__c.contains('(Reversal due to PO Completion)')
                    pi.ASI_MFM_G_L_Date__c = Date.today();
                }
            }
        }       
    }

    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
                
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
            
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_PO__c);    
            
        }
                
        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_Accrual_PO__c, ASI_MFM_Exchange_Rate__c, recordtypeID, ASI_MFM_BU_Code__c,ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();      
         
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                                 
            if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null) {
                sku_set.add(pi.ASI_MFM_SKU_Code__c);
            }
            
            if (pi.ASI_MFM_SKU_Code__c != null)
                sku_setDescription.add(pi.ASI_MFM_SKU_Code__c);
                
            //HK MFM Logic: Auto fill in BU base on prefix
            if (Global_RecordTypeCache.getRt(poMap.get(pi.ASI_MFM_PO__c).recordTypeID).DeveloperName.contains('ASI_MFM_HK')){
                if (pi.ASI_MFM_BU_Code__c == null && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c != null)
                    pi.ASI_MFM_BU_Code__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c;
            }
            
            // Set the exchange rate from the PO header 
            if(poMap.values().size() > 0){  system.debug('Linus: POMap: ' + poMap.get(pi.ASI_MFM_PO__c)); system.debug(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c);
                pi.ASI_MFM_Exchange_Rate__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null? poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c : pi.ASI_MFM_Exchange_Rate__c;
                pi.ASI_MFM_Base_Currency_Amount__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null ? (Decimal)pi.ASI_MFM_Amount__c * (Decimal)poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c: (Decimal)pi.ASI_MFM_Amount__c;
            }
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