/*********************************************************************************
 * Name: ASI_MFM_VN_PlanLineItem_TriggerClass
 * Description: Trigger Class for ASI_MFM_Plan_Line_Item__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-02-13       Calvin Chiu             Cloned from ASI_MFM_PH_PlanLineItem_TriggerClass
 * 2019-05-28       Andy  Zhang             Resolve over budget problem
*/
public without sharing class ASI_MFM_VN_PlanLineItem_TriggerClass{    
    public static void routineBeforeDelete(list<ASI_MFM_Plan_Line_Item__c> trigger_old) {
        // Not allowed to delete if the plan is in final or complete status
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Plan__c);
        }
        map<id, ASI_MFM_Plan__c> plan_map = new map<id, ASI_MFM_Plan__c>([select id, ASI_MFM_PH_Sub_Brand_Allocation__c, ASI_MFM_Status__c from ASI_MFM_Plan__c where id in :pid_set ]); 
        Map<ID,ASI_MFM_Plan_Line_Item__c> gfPlanLineIDMap = new Map<ID,ASI_MFM_Plan_Line_Item__c>();
        
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            if (plan_map.get(pi.ASI_MFM_Plan__c).ASI_MFM_Status__c != 'Draft') {
                pi.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }    
          
            // Not allow delete line if sub-brand allocation is not null
            if(plan_map.get(pi.ASI_MFM_Plan__c).ASI_MFM_PH_Sub_Brand_Allocation__c != null){
                pi.addError('Not allowed to delete because the plan is selected sub-brand allocation');
            }
        }
        
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan_Line_Item__c> trigger_new, map<id, ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {        
        Set<ID> setPYI = new Set<ID>();
        Set<ID> setCUI = new Set<ID>();
        //Set<ID> setAPI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();        
        Map<ID, ID> MapAPI = new Map<Id,Id>();
        
        Profile prof = [select Name, id from Profile where Id = :UserInfo.getProfileId()];
        boolean isuserAdmin = prof.name.contains('System Administrator') ;
        
        boolean isSbAl = false;
        String budgetRtName;
        String fiscalYear;
        for (ASI_MFM_Plan_Line_Item__c i : trigger_new){
                        
            setPYI.add(i.ASI_MFM_Plan__c);
            
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);
                
            /*if (i.ASI_MFM_A_C_Code__c != null ){        
                SetAPI.add(i.ASI_MFM_A_C_Code__c);  
                MapAPI.put(i.id, i.ASI_MFM_AP_Code__c);
            }*/
            
        }
        
        system.debug('setCUI: ' + setCUI);
        // Set default BU code if not input by user 
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c,ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        System.debug('country_pfx : ' +  country_pfx );

        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c');
        
        for (recordType rtt:rtList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
                
        //Added by Introv @20161205 - Line Itms of Plan converted from PAF cannot be edited
        Map<ID, ASI_MFM_Plan__c> planMap = new Map<ID, ASI_MFM_Plan__c>([SELECT ID, Name, ASI_CRM_Converted_Date__c, recordtypeID,ASI_MFM_Plan_External_ID_Upload__c,ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c,ASI_MFM_Prefix__r.name,ASI_MFM_Fiscal_year__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c , ASI_MFM_PH_Total_plan_Amount__c , ASI_MFM_Plan_Amount__c FROM ASI_MFM_Plan__c WHERE ID IN: setPYI]);
        
        //Map<ID, ASI_MFM_AP_Code__c> apMap = new  Map<ID, ASI_MFM_AP_Code__c>([Select id, ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where id = :SetAPI]);
        
        Set<id> ac_set = new Set<id>();
        Set<id> sb_set = new Set<id>();
        Decimal totalAmount = 0;
                
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {  
            
               
            //Update Default BU Logic
            if (bu_list.size() == 1) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                    pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                } 
            } 
            //End Update Default BU Logic
            
            ac_set.add(pi.ASI_MFM_A_C_Code__c);
            sb_set.add(pi.ASI_MFM_Sub_brand_Code__c);
            
            /*// Auto-fill A/C Code when user choose AP Code
            if(apMap.values().size() > 0){
                pi.ASI_MFM_A_C_Code__c = apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c;                                 
            }*/
            
            // Calculate total cost from quantity and unit cost      
            if ((pi.ASI_MFM_Total_Cost__c == null || pi.ASI_MFM_Total_Cost__c == 0) && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Cost__c != null ) {
                pi.ASI_MFM_Total_Cost__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up);
                System.debug('Auto calculated PLine Amt by Qty: ' + (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up));
            } 
            
            if(trigger_oldmap != null){ 
                if(planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Status__c != 'Draft'){
                    if(trigger_oldmap.get(pi.id).ASI_MFM_Total_Cost__c < pi.ASI_MFM_Total_Cost__c){
                        pi.addError('Not allow increase amount in "Final" status');
                    }
                }
                
            }  
            
            budgetRtName = Global_RecordTypeCache.getRt(planMap.get(pi.ASI_MFM_Plan__c).recordTypeId).developerName.contains('ASI_MFM_VN_DF')? 'ASI_MFM_VN_DF_Budget':'ASI_MFM_VN_DP_Budget';
            fiscalYear = pi.ASI_MFM_Fiscal_Year_sys__c;
            
        }
        system.debug(ac_set); system.debug(sb_set);system.debug(budgetRtName);
        // Budget checking with combination of (A/C Code + Sub-Brand)
        /*
        String budgetType = 'Budget'; 
        for(ASI_MFM_Budget_Setup__c setup: [Select id, ASI_MFM_Type__c from ASI_MFM_Budget_Setup__c where recordtype.name like '%VN%' and ASI_MFM_Fiscal_Year__c =: fiscalYear and ASI_MFM_Active__c = true]){
            budgetType = setup.ASI_MFM_Type__c;
        }system.debug(budgetType);
    */
        // Check the latest Budget created 
        List<ASI_MFM_Budget__c> budget_list = new List<ASI_MFM_Budget__c>([Select id,ASI_MFM_Total_Budget_Amount__c, ASI_MFM_Total_Amount__c,ASI_MFM_A_C_Code__c, ASI_MFM_Sub_Brand_Code__c  from ASI_MFM_Budget__c where recordType.DeveloperName = :budgetRtName and ASI_MFM_A_C_Code__c = :ac_set and ASI_MFM_Sub_brand_Code__c = :sb_set and ASI_MFM_Fiscal_year__c = :fiscalYear order by CreatedDate desc limit 1]);
        system.debug(budget_list);
        List<ASI_MFM_Plan_Line_Item__c> pl_list = new List<ASI_MFM_Plan_Line_Item__c>([Select id, ASI_MFM_Plan__r.ASI_MFM_Exchange_Rate__c, ASI_MFM_Total_Cost__c,ASI_MFM_A_C_Code__c, ASI_MFM_Sub_Brand_Code__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_A_C_Code__c = :ac_set and ASI_MFM_Sub_brand_Code__c = :sb_set and ASI_MFM_Fiscal_year_sys__c = :fiscalYear and (recordType.DeveloperName like 'ASI_MFM_VN%')]);
        system.debug(pl_list);
        for(ASI_MFM_Plan_Line_Item__c pi: trigger_new){
            
            Decimal budget = 0;
            Decimal existTtlAmt = 0;
            Decimal tolerance = 0;                        
            
            pi.ASI_MFM_Over_Budget__c = false;
            
            for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
                if(Setting.name == 'VN_Budget_Tolerance__c' && Setting.Country__c == 'VN'){
                    tolerance = Decimal.valueOf(Setting.ASI_MFM_value__c);
                }
            }
            system.debug('Linus: A/C Code: ' + pi.ASI_MFM_A_C_Code__c + ' & ' + 'Sub-brand: ' + pi.ASI_MFM_Sub_brand_Code__c);
            for(ASI_MFM_Budget__c b: budget_list){
                if(b.ASI_MFM_A_C_Code__c == pi.ASI_MFM_A_C_Code__c && b.ASI_MFM_Sub_Brand_Code__c == pi.ASI_MFM_Sub_brand_Code__c){
                 // budget = b.ASI_MFM_Total_Amount__c * (1 + tolerance/100);
                    budget = b.ASI_MFM_Total_Budget_Amount__c * (1 + tolerance/100);
                    system.debug('here');
                    break;
                }
            }
            system.debug('Linus: ' + budget);
            for(ASI_MFM_Plan_Line_Item__c p: pl_list){
                if(p.id != pi.id && p.ASI_MFM_A_C_Code__c == pi.ASI_MFM_A_C_Code__c && p.ASI_MFM_Sub_brand_Code__c == pi.ASI_MFM_Sub_brand_Code__c)
                    existTtlAmt = existTtlAmt + (p.ASI_MFM_Total_Cost__c * p.ASI_MFM_Plan__r.ASI_MFM_Exchange_Rate__c);
            }
            system.debug('Linus: ' + existTtlAmt);
            
            if(!Test.isRunningTest()){
                pi.ASI_MFM_Over_Budget__c = budget == 0? true: pi.ASI_MFM_Total_Cost__c + existTtlAmt > budget ? true:false;     system.debug('Linus: check over budget');
            }
            system.debug(pi.ASI_MFM_Total_Cost__c);
            system.debug(existTtlAmt);
        }
        // END - check over budget
        
        // Check the sum of adjusted amount is equal to total amount
        Decimal TtlplanAmt = 0;
        for(ASI_MFM_Plan_Line_Item__c pl: [Select id, ASI_MFM_Total_Cost__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: trigger_new[0].ASI_MFM_Plan__c]){
            TtlplanAmt += pl.ASI_MFM_Total_Cost__c;
        }
        if(!Test.isRunningTest() && trigger_oldmap != null && planMap.get(trigger_new[0].ASI_MFM_Plan__c).ASI_MFM_PH_Total_Plan_Amount__c != null && TtlplanAmt != planMap.get(trigger_new[0].ASI_MFM_Plan__c).ASI_MFM_PH_Total_Plan_Amount__c){
            trigger_new[0].addError('Please check the amount in header. It should be same as the sum of detail line amount.');
        }
    }
}