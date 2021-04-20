public without sharing class ASI_MFM_MY_PlanLineItem_TriggerClass {
    
    public static void routineBeforeDelete(list<ASI_MFM_Plan_Line_Item__c> trigger_old) {
    // Not allowed to delete if the plan is in final or complete status
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Plan__c);
        }
        map<id, ASI_MFM_Plan__c> plan_map = new map<id, ASI_MFM_Plan__c>([select id from ASI_MFM_Plan__c where id in :pid_set and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Complete')]); 

        
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            if (plan_map.containsKey(pi.ASI_MFM_Plan__c)) {
                pi.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }

        }
        
        
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan_Line_Item__c> trigger_new, map<id, ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {        
        Set<ID> setPYI = new Set<ID>();
        Set<ID> setCUI = new Set<ID>();
        Set<ID> setAPI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        Map<ID, ASI_MFM_AP_Code__c> apMap = new  Map<ID, ASI_MFM_AP_Code__c>();
        
        String fiscalYear;
        Set<id> sb_set = new Set<id>();
        
        for (ASI_MFM_Plan_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_Plan__c);
            
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);
                
            if (i.ASI_MFM_AP_Code__c != null && !setAPI.contains(i.ASI_MFM_AP_Code__c))
                setAPI.add(i.ASI_MFM_AP_Code__c);
            
            sb_set.add(i.ASI_MFM_Sub_brand_Code__c);
            fiscalYear = i.ASI_MFM_Fiscal_Year_sys__c;
        }
        system.debug('setCUI: ' + setCUI);
        // Set default BU code if not input by user 
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c,ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        System.debug('country_pfx : ' +  country_pfx );

        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c');
        Map<ID, ASI_MFM_Plan__c> planMap = new Map<ID, ASI_MFM_Plan__c>([SELECT ID, Name, ASI_CRM_Converted_Date__c, recordtypeID,ASI_MFM_Plan_External_ID_Upload__c,ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c,ASI_MFM_Prefix__r.name,ASI_MFM_Fiscal_year__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c FROM ASI_MFM_Plan__c WHERE ID IN: setPYI]);
        
        for (recordType rtt:rtList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        //Customer Default Value
        String MYCustomerDefault;
        String MYBUCodeDefault;
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            
            if(Setting.name == 'MY_BU_Code__c' && Setting.Country__c == 'MY'){
                MYBUCodeDefault = Setting.ASI_MFM_value__c;
                
            }
            if(Setting.name == 'MY_Customer_Name__c' && Setting.Country__c == 'MY'){
                MYCustomerDefault = Setting.ASI_MFM_value__c;
            }
        }
        System.debug('ASI_MFM_Default_Value__cTest:'+ASI_MFM_Default_Value__c.getAll().values());
        
        List<ASI_MFM_Budget__c> budget_list = new List<ASI_MFM_Budget__c>([Select id, ASI_MFM_Total_Amount__c,ASI_MFM_A_C_Code__c, ASI_MFM_Sub_Brand_Code__c, ASI_MFM_Fiscal_year__c  from ASI_MFM_Budget__c where recordType.DeveloperName = 'ASI_MFM_MY_Budget' and ASI_MFM_Sub_brand_Code__c = :sb_set and ASI_MFM_Fiscal_year__c = :fiscalYear ]);        
        system.debug(budget_list);
        List<ASI_MFM_Plan_Line_Item__c> pl_list = new List<ASI_MFM_Plan_Line_Item__c>([Select id, ASI_MFM_Total_Cost__c,ASI_MFM_A_C_Code__c, ASI_MFM_Sub_Brand_Code__c, ASI_MFM_Fiscal_Year_Sys__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Sub_brand_Code__c = :sb_set and ASI_MFM_Fiscal_year_sys__c = :fiscalYear and (recordType.DeveloperName like 'ASI_MFM_MY%')]);        
          
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {  
                      
            //MY Plan Line Logic: Default AP Code, BU Code, Customer, GL Date
            if (planMap.get(pi.ASI_MFM_Plan__c).recordTypeID == rt_map.get('ASI_MFM_MY_Plan')){
                if(pi.ASI_MFM_Customer_Name__c == null &&  MYCustomerDefault != null && MYCustomerDefault != ''){
                     pi.ASI_MFM_Customer_Name__c = MYCustomerDefault;
                }
                if(pi.ASI_MFM_BU_Code__c == null &&  MYBUCodeDefault != null && MYBUCodeDefault != ''){
                     pi.ASI_MFM_BU_Code__c = MYBUCodeDefault;
                }
            }
            
            // Added by 2017-11-16 Linus@introv
            // Check if there is 1 plan line over budget, occur error when submit for approval            
            Decimal budget = 0;
            Decimal existTtlAmt = 0;     
            for(ASI_MFM_Budget__c b: budget_list){
                if(b.ASI_MFM_Sub_brand_Code__c == pi.ASI_MFM_Sub_Brand_Code__c && b.ASI_MFM_Fiscal_Year__c == pi.ASI_MFM_Fiscal_Year_Sys__c)
                budget += b.ASI_MFM_Total_Amount__c;
            }
            system.debug('Linus: Budget: ' + budget);
            for(ASI_MFM_Plan_Line_Item__c pl: pl_list){
                if(pl.id != pi.id && pl.ASI_MFM_Sub_Brand_Code__c == pi.ASI_MFM_Sub_brand_Code__c && pl.ASI_MFM_Fiscal_Year_Sys__c == pi.ASI_MFM_Fiscal_Year_Sys__c)
                existTtlAmt += pl.ASI_MFM_Total_Cost__c;
            }                   
            system.debug('Linus: existTtlAmt: ' + existTtlAmt); system.debug('Linus: current total cost: ' + pi.ASI_MFM_Total_Cost__c);
            pi.ASI_MFM_Over_Budget__c = budget == 0 || pi.ASI_MFM_Total_Cost__c + existTtlAmt > budget ? true: false; system.debug('Linus: check over budget');
            
            //Update Default BU Logic
            if (bu_list.size() == 1) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                        pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                } 
            } 
            //End Update Default BU Logic
            
            // Calculate total cost from quantity and unit cost       // Not for TW Plan ** Modified by 2017-08-14 Linus@introv
            if ((pi.ASI_MFM_Total_Cost__c == null || pi.ASI_MFM_Total_Cost__c == 0) && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Cost__c != null) {
                pi.ASI_MFM_Total_Cost__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up);
                System.debug('Auto calculated PLine Amt by Qty: ' + (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up));
            }           
            
        }
        
    }
}