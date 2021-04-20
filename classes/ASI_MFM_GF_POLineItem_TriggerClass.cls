public without sharing class ASI_MFM_GF_POLineItem_TriggerClass {
    

    public static void routineBeforeUpdate(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            
            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF')){
                //Already had payment or receipt, do not allow change
                if (Test.isRunningTest() || ((pi.ASI_MFM_Paid_Amount__c > 0 || pi.ASI_MFM_CN_Receipt_Amount__c > 0) && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_GF_LockPOLine'))){
                    if (pi.ASI_MFM_Sub_brand_Allocation_Type__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Allocation_Type__c ||
                            pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                                pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
                                    pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                                        pi.ASI_MFM_SKU_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_SKU_Code__c ||
                                            pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
                                                pi.ASI_MFM_UOM__c != trigger_oldMap.get(pi.id).ASI_MFM_UOM__c ||
                                                    pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
                                                        pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
                                                            pi.ASI_MFM_Recharge__c != trigger_oldMap.get(pi.id).ASI_MFM_Recharge__c ||
                                                                pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
                                                                    pi.ASI_MFM_Pay_Acc__c != trigger_oldMap.get(pi.id).ASI_MFM_Pay_Acc__c){
                                                                    
                        pi.addError('Cannot change PO line after PO Receipt or Payment');
                    }
                }
            }
            
        }
        
        
        
    }
    
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
                        decimal gf_sp_amt;
                        
                        
                            sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(2, roundingmode.half_up);
                            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF') && pi.ASI_MFM_Distributor_Amount__c != null){
                                gf_sp_amt = (pi.ASI_MFM_Distributor_Amount__c / month_count).setScale(2, roundingmode.half_up);
                            }
                                              
                        decimal rounding_err = sp_amt * month_count - pi.ASI_MFM_Amount__c;
                        date sp_date = po.ASI_MFM_PO_Start_Date__c;
                        for (integer i=0; i<month_count; i++) {
                            ASI_MFM_PO_Line_Item__c npi = pi.clone(false, true);
                            npi.ASI_MFM_Amount__c = sp_amt;
                            
                            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF')){
                                npi.ASI_MFM_Distributor_Amount__c = gf_sp_amt;
                            }
                            
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


    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        
        //Update by Steve Introv 12 Jun 2014 to get all customer
        Set<ID> setCUI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){            
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);                        
            
        }
        
        // Added by Michael Yip (Introv) 19Feb2014 to add default customer for CN PO line item
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c');
        
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        
        
        String GFRecTypeID = MRecType.get('ASI_MFM_GF_PO_Line_Item');
        String GFVAP_APCode_Default;
        String GFFOC_UOM_Default;
        
        
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            
            if(Setting.name == 'GF_VAP_AP_Code__c' && Setting.Country__c == 'GF'){
                GFVAP_APCode_Default = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'GF_FOC_UOM__c' && Setting.Country__c == 'GF'){
                GFFOC_UOM_Default = Setting.ASI_MFM_value__c;
            }
            
        }
        
        
        
        Set<id> SPOLineItemID = new Set<id>();
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_PO__c);
            
            
            //GF Logic: default AP Code to VAP for PO Type of VAP Brand Owner and VAP FOC
            if((i.ASI_MFM_PO_Type__c == 'VAP Brand Owner' || i.ASI_MFM_PO_Type__c == 'VAP FOC') && i.RecordTypeId == GFRecTypeID && GFVAP_APCode_Default != null && GFVAP_APCode_Default != ''){
                i.ASI_MFM_AP_Code__c = GFVAP_APCode_Default;
            }
            
            //GF Logic: default UOM to CA for PO Type of VAP FOC
            if(i.ASI_MFM_PO_Type__c == 'VAP FOC' && i.ASI_MFM_UOM__c == null && i.RecordTypeId == GFRecTypeID && GFFOC_UOM_Default != null && GFFOC_UOM_Default != ''){
                i.ASI_MFM_UOM__c = GFFOC_UOM_Default;
            }                

            
        }
        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> portList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:portList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        
        
        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_Accrual_PO__c, recordtypeID, ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_BU_Code__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c , ASI_MFM_Exchange_Rate__c FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();
        
        //GF VAP FOC SKU Amount Logic, Query SKU Unit Price
        Map<id,ASI_MFM_SKU_Code__c> skuMap = new Map<id,ASI_MFM_SKU_Code__c>();
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        
        //GF Logic: Auto fill in A/C Code if selected AP Code
        List<ASI_MFM_AP_Code__c> apCodeList = new List<ASI_MFM_AP_Code__c>();
        Map<id,id> apACMap = new Map<id,id>();
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_GF')){
            List<ASI_MFM_AP_Code__c> apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_GF_AP_Code')];
            
            for (ASI_MFM_AP_Code__c ap:apCode){
                apACMap.put(ap.id, ap.ASI_MFM_A_C_Code__c);
            }
            
            
            skuList = [select ID, ASI_FOC_Unit_Cost__c from ASI_MFM_SKU_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_GF_SKU')];
            
            for (ASI_MFM_SKU_Code__c sku:skuList){
                skuMap.put(sku.id, sku);
            }
        }
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            // Set the exchange rate from the PO header	   
            pi.ASI_MFM_Exchange_Rate__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null? poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c : pi.ASI_MFM_Exchange_Rate__c;            
            
            if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null) {
                sku_set.add(pi.ASI_MFM_SKU_Code__c);
            }
            
            if (pi.ASI_MFM_SKU_Code__c != null)
                sku_setDescription.add(pi.ASI_MFM_SKU_Code__c);
            
            
            //GF Logic:
            if (pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item')){
                //GF Auto fill A/C Code Logic
                if (pi.ASI_MFM_AP_Code__c != null)
                    pi.ASI_MFM_A_C_Code__c = apACMap.get(pi.ASI_MFM_AP_Code__c);
                
                //GF Auto Calculate SKU Cost for VAP FOC PO
                if (pi.ASI_MFM_PO_Type__c == 'VAP FOC' && pi.ASI_MFM_Amount__c == null && pi.ASI_MFM_SKU_Code__c != null && pi.ASI_MFM_Quantity__c != null){
                    if (skuMap.get(pi.ASI_MFM_SKU_Code__c).ASI_FOC_Unit_Cost__c != null){
                        pi.ASI_MFM_Amount__c = skuMap.get(pi.ASI_MFM_SKU_Code__c).ASI_FOC_Unit_Cost__c * pi.ASI_MFM_Quantity__c;
                    }
                }
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
        
        
        
        
// Set default BU code if not input by user
       
        setDefaultBUCode(trigger_new, bu_list);  
        
        
        // Added by 2017-12-28 Linus@introv
        // Calculate PO amount including VAT rate    
        for(ASI_MFM_PO_Line_Item__c pi: trigger_new){
            
            String VATRate = pi.ASI_MFM_GF_VAT_Rate__c != null? pi.ASI_MFM_GF_VAT_Rate__c.split('\\(')[1].split('%')[0]: '0';
                
            pi.ASI_MFM_GF_PO_Amount_Include_VAT__c = pi.ASI_MFM_Amount__c != null? pi.ASI_MFM_Amount__c * decimal.valueOf('1.0' + VATRate): 0;
            pi.ASI_MFM_VAT_Amount__c = pi.ASI_MFM_Amount__c != null? pi.ASI_MFM_Amount__c * decimal.valueOf('0.0' + VATRate): 0;
            
        }           
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