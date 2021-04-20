/*********************************************************************************
* Name:ASI_MFM_SG_POLineItem_TriggerClass
* Description: 
* Test Class: 
*ASI_MFM_SG_PO_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 08/05/2018       Wilken                  [WL 1.0] Auto assign AG Code based on FOC PO FOC Type
* 15/08/2018       Linus                   [LH 1.0] Remove SKU Cost error message and add null checking on SKU Duty Cost
* 19/08/2019       Wilken                  [WL 2.0] RITM0043553 Change FOC Type picklist description
*********************************************************************************/
public without sharing class ASI_MFM_SG_POLineItem_TriggerClass {
    
    public static void routineBeforeUpdate(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_SG')){
                //Already had payment or receipt, do not allow change
                if (pi.ASI_MFM_Complete__c == true){
                    if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                        pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                        pi.ASI_MFM_SG_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_SG_Unit__c ||
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
        
        Set<id> SPOLineItemID = new Set<id>();
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
            if (Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_SG')){
                if(pi.ASI_MFM_Delete_Reject__c==true && pi.ASI_MFM_Spread_by_Months__c ==false){
                    pi.addError('Not allowed to delete approved PO Lines');
                }            
            }
            
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        
        
        set<id> setOfPlan = new set<id>();
        set<String> setOfAPCodes = new set<String>();
        Map<String,Id> APCodeMap = new Map<String,Id>();
        Set<ID> setPYI = new Set<ID>();
        map <ID, ID> mapOfPOWithPlan = new map <ID, ID>();
        map <ID, set<ID>> mapOfPlanWithSubBrand = new map <ID, set<ID>>();
        
        //Update by Steve Introv 12 Jun 2014 to get all customer
        Set<ID> setCUI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        for (ASI_MFM_PO_Line_Item__c pi : trigger_new){
            if(pi.ASI_MFM_SG_A_P_Segment__c!=null){
                setOfAPCodes.add(pi.ASI_MFM_SG_A_P_Segment__c);
            }
            
            setPYI.add(pi.ASI_MFM_PO__c);
            if (pi.ASI_MFM_Customer_Name__c != null && !setCUI.contains(pi.ASI_MFM_Customer_Name__c))
                setCUI.add(pi.ASI_MFM_Customer_Name__c);                        
        }
        
        if(setOfAPCodes.size()>0){
            for(ASI_MFM_AP_Code__c ap : [select id,name from ASI_MFM_AP_Code__c where recordType.developerName = 'ASI_MFM_SG_Code' and Name in :setOfAPCodes  ]){
                APCodeMap.put(ap.name,ap.id);
            }
        }
        
        
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> portList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:portList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';
        
        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        //Updated by Introv 20180329 (added "ASI_MFM_Is_FOC_PO__c", "ASI_MFM_Event_Start_Date__c" field in the query; )
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, ASI_MFM_Event_Start_Date__c, Name, ASI_MFM_Accrual_PO__c, recordtypeID, ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_BU_Code__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c, ASI_MFM_Is_FOC_PO__c, ASI_MFM_PO_Start_Date__c , ASI_MFM_Exchange_Rate__c FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();
        
        /*[WL 1.0] BEGIN*/
        Boolean hasFOCPO = false;
        /*[WL 1.0] END*/
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {        
            
            if(pi.ASI_MFM_SG_A_P_Segment__c!=null && APCodeMap.containsKey(pi.ASI_MFM_SG_A_P_Segment__c) ){
                pi.ASI_MFM_AP_Code__c = APCodeMap.get(pi.ASI_MFM_SG_A_P_Segment__c);
            }
            
            // Set the exchange rate from the PO header 
            pi.ASI_MFM_Exchange_Rate__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null? poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c : pi.ASI_MFM_Exchange_Rate__c;
            
            //Updated by Introv 20180329 for ASI_MFM_Is_FOC_PO__c = true
            if ( (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU__c != null) || (pi.ASI_MFM_SKU__c != null && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Is_FOC_PO__c==true)) {
                sku_set.add(pi.ASI_MFM_SKU__c);
                
                /*[WL 1.0] BEGIN*/
                hasFOCPO = true;
                /*[WL 1.0] END*/
            }
            
            if (pi.ASI_MFM_SKU__c != null){
                sku_setDescription.add(pi.ASI_MFM_SKU__c);
            }
            
            
            
            //SG Logic: pass header customer to line if customer is null 
            if(pi.ASI_MFM_Customer_Name__c == null && poMap.get(pi.ASI_MFM_PO__c).recordTypeID == rt_map.get('ASI_MFM_SG_PO') ){
                //if(pi.ASI_MFM_Customer_Name__c == null && Global_RecordTypeCache.getRt(poMap.get(pi.ASI_MFM_PO__c).recordTypeID).DeveloperName.contains('ASI_MFM_SG')){
                pi.ASI_MFM_Customer_Name__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_SG_Customer__c;
            }
        }
        
        /*[WL 1.0] BEGIN*/
        if (hasFOCPO){
            List<ASI_CRM_SG_FOC_Type_Mapping__c> focTypeMappingList = [SELECT ASI_CRM_SG_AG_Code_GL_Class__c, ASI_CRM_SG_FOC_Type__c FROM ASI_CRM_SG_FOC_Type_Mapping__c];
            
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {     
                if (pi.ASI_MFM_FOC_Type__c != null){
                    /*[WL 2.0] BEGIN*/  //FOC Mapping custom setting is obsolete, system retrieve AG Code directly from FOC Type picklist description           
                    if (pi.ASI_MFM_FOC_Type__c.contains('-')){
                        pi.ASI_MFM_AG_Code__c = pi.ASI_MFM_FOC_Type__c.substringAfterLast('- ');
                    }
                    /*[WL 2.0] END*/
                    else {
                        for (ASI_CRM_SG_FOC_Type_Mapping__c focType:focTypeMappingList){
                            if (focType.ASI_CRM_SG_FOC_Type__c == pi.ASI_MFM_FOC_Type__c)
                                pi.ASI_MFM_AG_Code__c = focType.ASI_CRM_SG_AG_Code_GL_Class__c;
                        }
                    }                   
                }
            }           
        }
        /*[WL 1.0] END*/
        
        // Set sub-brand code if it is not input by user
        if (sku_set.size() > 0) {
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_Sub_brand__c from ASI_MFM_SKU_Code__c where id = :sku_set]);
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                //Updated by Introv 20180329 for ASI_MFM_Is_FOC_PO__c = true
                if ( (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU__c != null && sku_map.containsKey(pi.ASI_MFM_SKU__c)) || (pi.ASI_MFM_SKU__c != null && sku_map.containsKey(pi.ASI_MFM_SKU__c) && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Is_FOC_PO__c==true) ) {
                    pi.ASI_MFM_Sub_brand_Code__c = sku_map.get(pi.ASI_MFM_SKU__c).ASI_MFM_Sub_brand__c;
                }           
            }           
        }
        
        // Set Description AND UOM1 if it is not input by user
        if (sku_setDescription.size() > 0){
            //Updated by Introv 20180329 (added fields in the query; )
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_SKU_Description__c, ASI_HK_CRM_UOM1__c, ASI_HK_CRM_Base_Price__c, ASI_HK_CRM_Packaging_Size__c from ASI_MFM_SKU_Code__c where id IN :sku_setDescription]);
            list<ASI_CRM_MY_SKUPriceCost__c> skuprice_map = new list<ASI_CRM_MY_SKUPriceCost__c>([select recordTypeId, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c,ASI_CRM_SKU__c from ASI_CRM_MY_SKUPriceCost__c 
                                                                                                  where ( recordTypeId = : Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') 
                                                                                                         OR recordTypeId = : Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle')
                                                                                                         OR recordTypeId = : Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle')
                                                                                                        )
                                                                                                  and ASI_CRM_SKU__c in :sku_map.keySet() order by ASI_CRM_EffectiveDate__c desc]);
            
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) 
            {
                if (pi.ASI_MFM_List_Item_Description__c == null && pi.ASI_MFM_SKU__c != null && sku_map.containsKey(pi.ASI_MFM_SKU__c))
                    pi.ASI_MFM_List_Item_Description__c = sku_map.get(pi.ASI_MFM_SKU__c).ASI_MFM_SKU_Description__c;
                
                if (pi.ASI_MFM_UOM__c == null && pi.ASI_MFM_SKU__c != null && sku_map.containsKey(pi.ASI_MFM_SKU__c))
                    pi.ASI_MFM_UOM__c = sku_map.get(pi.ASI_MFM_SKU__c).ASI_HK_CRM_UOM1__c;
                
                
                //Updated by Introv 20180329 for ASI_MFM_Is_FOC_PO__c = true and calculate the unit price and amount 
                if(pi.ASI_MFM_SKU__c != null && sku_map.containsKey(pi.ASI_MFM_SKU__c) && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Is_FOC_PO__c==true && skuprice_map!=null){
                    //clear pervious data 
                    pi.ASI_MFM_Unit_Price__c = null;
                    pi.ASI_MFM_Amount__c = null;
                    ASI_CRM_MY_SKUPriceCost__c selectedSkuPriceCost = null;
                    ASI_CRM_MY_SKUPriceCost__c selectedSkuFOBCost = null;
                    ASI_CRM_MY_SKUPriceCost__c selectedSkuHandlingCost = null;
                    
                    //20180409 Introv
                    Boolean hasIGCost = False;
                    Boolean hasFOBCost = False;
                    Boolean hasHandlingCost = False;
                    
                    for(ASI_CRM_MY_SKUPriceCost__c skuPriceCost: skuprice_map){
                        
                        if( skuPriceCost.ASI_CRM_SKU__c == pi.ASI_MFM_SKU__c && skuPriceCost.ASI_CRM_EffectiveDate__c <= poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Event_Start_Date__c){
                            
                            skuPriceCost.ASI_CRM_Cost__c = skuPriceCost.ASI_CRM_Cost__c == Null ? 0 : skuPriceCost.ASI_CRM_Cost__c;
                            
                            if(skuPriceCost.recordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle') && !hasIGCost){
                                selectedSkuPriceCost = skuPriceCost;
                                hasIGCost = True;
                            }else if(skuPriceCost.recordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') && !hasHandlingCost){                               
                                selectedSkuHandlingCost = skuPriceCost;
                                hasHandlingCost = True;
                            }else if(skuPriceCost.recordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle') && !hasFOBCost){
                                selectedSkuFOBCost = skuPriceCost;
                                hasFOBCost = True;
                            }
                        }
                        
                        if(hasIGCost && hasHandlingCost && hasFOBCost)
                            Break;
                    }
                    
                    ASI_MFM_SKU_Code__c sku = sku_map.get(pi.ASI_MFM_SKU__c);
                    // [LH 1.0]
                    pi.ASI_MFM_Unit_Price__c = (selectedSkuPriceCost != null ? selectedSkuPriceCost.ASI_CRM_Cost__c: 0) + (selectedSkuFOBCost != Null ? selectedSkuFOBCost.ASI_CRM_Cost__c : 0) + (selectedSkuHandlingCost != Null ? selectedSkuHandlingCost.ASI_CRM_Cost__c : 0);
                  
                    if(pi.ASI_MFM_Quantity__c!=null && pi.ASI_MFM_Unit_Price__c!=null){
                        pi.ASI_MFM_Amount__c = pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Price__c;
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
}