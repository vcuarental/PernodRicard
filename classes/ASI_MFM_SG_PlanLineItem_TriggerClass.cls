public without sharing class ASI_MFM_SG_PlanLineItem_TriggerClass {
    
    public static void routineBeforeDelete(list<ASI_MFM_Plan_Line_Item__c> trigger_old) {
// Not allowed to delete if the plan is in final or complete status
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Plan__c);
        }
        map<id, ASI_MFM_Plan__c> plan_map = new map<id, ASI_MFM_Plan__c>([select id from ASI_MFM_Plan__c where id in :pid_set and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Complete')]); 
        Map<ID,ASI_MFM_Plan_Line_Item__c> gfPlanLineIDMap = new Map<ID,ASI_MFM_Plan_Line_Item__c>();
        
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            if (plan_map.containsKey(pi.ASI_MFM_Plan__c)) {
                pi.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }
            
            
        }
        
        //Block user to delete plan line if already has budget associated with it
        if (gfPlanLineIDMap.size() > 0){
            List<ASI_MFM_Budget__c> budgetList = [select id from ASI_MFM_Budget__c where ASI_MFM_Plan_Line_Item__c in :gfPlanLineIDMap.keySet()];
            
            if (budgetList.size() > 0){
                for (ASI_MFM_Plan_Line_Item__c pi:gfPlanLineIDMap.values()){
                    if (gfPlanLineIDMap.containsKey(pi.id))
                        pi.addError('Cannot delete plan line which is already associated with budget. Please change Plan Line Amount to 0');
                }
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan_Line_Item__c> trigger_new, map<id, ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {        
        Set<ID> setPYI = new Set<ID>();
        Set<ID> setCUI = new Set<ID>();
        Set<ID> setAPI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        Map<ID, ASI_MFM_AP_Code__c> apMap = new  Map<ID, ASI_MFM_AP_Code__c>();
        
        for (ASI_MFM_Plan_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_Plan__c);
            
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);
                
            if (i.ASI_MFM_AP_Code__c != null && !setAPI.contains(i.ASI_MFM_AP_Code__c))
                setAPI.add(i.ASI_MFM_AP_Code__c);
            
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
        Map<ID, ASI_MFM_Plan__c> planMap = new Map<ID, ASI_MFM_Plan__c>([SELECT ID, Name, ASI_CRM_Converted_Date__c, recordtypeID,ASI_MFM_Plan_External_ID_Upload__c,ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c,ASI_MFM_Prefix__r.name,ASI_MFM_Fiscal_year__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c FROM ASI_MFM_Plan__c WHERE ID IN: setPYI]);
        
        //Add By Tony Ren   For TH Use Only
        Decimal BudgetSum=0;
        Decimal PlanSum=0;
        String CurrPrefix;
        String FiscalYear;
        String PlanName;
        Id CurrPlanId;
        set<id> currentIdset=new set<id>();
        //        
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {  
            
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_SG')){ 
                // set SG default Customer 
                if (pi.ASI_MFM_Customer_Name__c == null && planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c != null){
                     pi.ASI_MFM_Customer_Name__c = planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c;
                }
                //If status=Final, can not upload Plan Line
                if(planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Status__c=='Final' && planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Plan_External_ID_Upload__c!= null){
                    if(!Test.isRunningTest()){ 
                        pi.addError('No Allow to update Plan Line Items with Final Status');
                    }
                }
                
            }                        
            
              
             if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_SG')){
               //SG and TH Logic: Sum up total cost by month cost if total cost is empty and month cost is filled 
                 CurrPrefix=planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Prefix__r.name;
                 FiscalYear=planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Fiscal_year__c;
                 CurrPlanId=planMap.get(pi.ASI_MFM_Plan__c).ID;
                 PlanName=planMap.get(pi.ASI_MFM_Plan__c).Name;
                if(pi.ASI_MFM_Total_Cost__c == null && (pi.ASI_MFM_Month_1_Cost__c != null || pi.ASI_MFM_Month_2_Cost__c != null || 
                    pi.ASI_MFM_Month_3_Cost__c != null || pi.ASI_MFM_Month_4_Cost__c != null || 
                        pi.ASI_MFM_Month_5_Cost__c != null || pi.ASI_MFM_Month_6_Cost__c != null || 
                            pi.ASI_MFM_Month_7_Cost__c != null || pi.ASI_MFM_Month_8_Cost__c != null ||     
                                pi.ASI_MFM_Month_9_Cost__c != null || pi.ASI_MFM_Month_10_Cost__c != null || 
                                    pi.ASI_MFM_Month_11_Cost__c != null || pi.ASI_MFM_Month_12_Cost__c != null)){
                    pi.ASI_MFM_Total_Cost__c = 0;
                    if(pi.ASI_MFM_Month_1_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_1_Cost__c;
                    if(pi.ASI_MFM_Month_2_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_2_Cost__c;
                    if(pi.ASI_MFM_Month_3_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_3_Cost__c;
                    if(pi.ASI_MFM_Month_4_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_4_Cost__c;
                    if(pi.ASI_MFM_Month_5_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_5_Cost__c;
                    if(pi.ASI_MFM_Month_6_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_6_Cost__c;
                    if(pi.ASI_MFM_Month_7_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_7_Cost__c;
                    if(pi.ASI_MFM_Month_8_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_8_Cost__c;
                    if(pi.ASI_MFM_Month_9_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_9_Cost__c;
                    if(pi.ASI_MFM_Month_10_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_10_Cost__c;
                    if(pi.ASI_MFM_Month_11_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_11_Cost__c;
                    if(pi.ASI_MFM_Month_12_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_12_Cost__c;
                }
                
                // Check consistency of total cost and month cost
                else if(pi.ASI_MFM_Total_Cost__c != null &&(pi.ASI_MFM_Month_1_Cost__c != null || pi.ASI_MFM_Month_2_Cost__c != null || 
                    pi.ASI_MFM_Month_3_Cost__c != null || pi.ASI_MFM_Month_4_Cost__c != null || 
                        pi.ASI_MFM_Month_5_Cost__c != null || pi.ASI_MFM_Month_6_Cost__c != null || 
                            pi.ASI_MFM_Month_7_Cost__c != null || pi.ASI_MFM_Month_8_Cost__c != null ||     
                                pi.ASI_MFM_Month_9_Cost__c != null || pi.ASI_MFM_Month_10_Cost__c != null || 
                                    pi.ASI_MFM_Month_11_Cost__c != null || pi.ASI_MFM_Month_12_Cost__c != null)){
                    Decimal tempSum = 0;
                    if(pi.ASI_MFM_Month_1_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_1_Cost__c;
                    if(pi.ASI_MFM_Month_2_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_2_Cost__c;
                    if(pi.ASI_MFM_Month_3_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_3_Cost__c;
                    if(pi.ASI_MFM_Month_4_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_4_Cost__c;
                    if(pi.ASI_MFM_Month_5_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_5_Cost__c;
                    if(pi.ASI_MFM_Month_6_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_6_Cost__c;
                    if(pi.ASI_MFM_Month_7_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_7_Cost__c;
                    if(pi.ASI_MFM_Month_8_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_8_Cost__c;
                    if(pi.ASI_MFM_Month_9_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_9_Cost__c;
                    if(pi.ASI_MFM_Month_10_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_10_Cost__c;
                    if(pi.ASI_MFM_Month_11_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_11_Cost__c;
                    if(pi.ASI_MFM_Month_12_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_12_Cost__c;
                    if(tempSum != pi.ASI_MFM_Total_Cost__c){
                        pi.addError('Item with Sub-Brand Code: '+pi.ASI_MFM_Sub_Brand_Code_Name__c+' Plan Line Amount('+pi.ASI_MFM_Total_Cost__c+') does not match sum of P1-P12 Cost('+tempSum+')');
                    }
                }
                 //System.debug('ASI_MFM_SG_Plan Test  : ' +  pi.ASI_MFM_Total_Cost__c);
                 if(pi.ASI_MFM_Total_Cost__c!=null){
                     PlanSum=PlanSum+pi.ASI_MFM_Total_Cost__c;
                 }
                 currentIdset.add(pi.id);
            }// End Of SG 
            
            //Update Default BU Logic
            if (bu_list.size() == 1) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                        pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                } 
            } 
            //End Update Default BU Logic
            
// Calculate total cost from quantity and unit cost       // Not for TW Plan ** Modified by 2017-08-14 Linus@introv
            if ((pi.ASI_MFM_Total_Cost__c == null || pi.ASI_MFM_Total_Cost__c == 0) && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Cost__c != null && planMap.get(pi.ASI_MFM_Plan__c).recordTypeID != rt_map.get('ASI_MFM_TW_Plan')) {
                pi.ASI_MFM_Total_Cost__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up);
                System.debug('Auto calculated PLine Amt by Qty: ' + (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up));
            }           
            
            //Spread logic 
            // LAPUTA* Update Trigger Class: Apply Spread logic to CAP
            if (planMap.get(pi.ASI_MFM_Plan__c).recordTypeID == rt_map.get('ASI_MFM_SG_Plan') || planMap.get(pi.ASI_MFM_Plan__c).recordTypeID == rt_map.get('ASI_MFM_SG_Plan_Read_Only')){
                // Set values to monthly cost fields if they are not input by user   
                if (pi.ASI_MFM_Total_Cost__c != null && pi.ASI_MFM_Plan_End_Date__c >= pi.ASI_MFM_Plan_Start_Date__c &&
                    pi.ASI_MFM_Month_1_Cost__c == null && pi.ASI_MFM_Month_2_Cost__c == null && 
                    pi.ASI_MFM_Month_3_Cost__c == null && pi.ASI_MFM_Month_4_Cost__c == null && 
                    pi.ASI_MFM_Month_5_Cost__c == null && pi.ASI_MFM_Month_6_Cost__c == null && 
                    pi.ASI_MFM_Month_7_Cost__c == null && pi.ASI_MFM_Month_8_Cost__c == null &&     
                    pi.ASI_MFM_Month_9_Cost__c == null && pi.ASI_MFM_Month_10_Cost__c == null && 
                    pi.ASI_MFM_Month_11_Cost__c == null && pi.ASI_MFM_Month_12_Cost__c == null) {
                    system.debug('All monthly costs are null');
                    integer number_of_months = pi.ASI_MFM_Plan_Start_Date__c.monthsBetween(pi.ASI_MFM_Plan_End_Date__c) + 1;    
                    decimal monthly_cost = (pi.ASI_MFM_Total_Cost__c / number_of_months).setScale(2);                       
                    decimal rounding_err = monthly_cost * number_of_months - pi.ASI_MFM_Total_Cost__c;
                    map<integer, decimal> mc_map = new map<integer, decimal>();
                    for (integer i = 1; i < 13; i++) {
                        mc_map.put(i, null);
                    }
                    integer start_month = pi.ASI_MFM_Plan_Start_Date__c.month();
                    integer end_month = start_month + number_of_months - 1;
                    if (start_month < 7) {
                        start_month += 12;
                        end_month += 12;
                    }
                    decimal monthly_cost_x, cum_cost;
                    integer idx;                
                    for (integer i = start_month; i <= end_month; i++) {
                        monthly_cost_x = monthly_cost;
                        if (i == end_month) monthly_cost_x -= rounding_err;
                        idx = i - 6;
                        if (idx < 13) {
                            mc_map.put(idx, monthly_cost_x);
                        }
                        else {
                            cum_cost = mc_map.get(12) + monthly_cost_x;
                            mc_map.put(12, cum_cost);                       
                        }
                    }
                    pi.ASI_MFM_Month_1_Cost__c = mc_map.get(1); 
                    pi.ASI_MFM_Month_2_Cost__c = mc_map.get(2); 
                    pi.ASI_MFM_Month_3_Cost__c = mc_map.get(3); 
                    pi.ASI_MFM_Month_4_Cost__c = mc_map.get(4); 
                    pi.ASI_MFM_Month_5_Cost__c = mc_map.get(5); 
                    pi.ASI_MFM_Month_6_Cost__c = mc_map.get(6);                 
                    pi.ASI_MFM_Month_7_Cost__c = mc_map.get(7); 
                    pi.ASI_MFM_Month_8_Cost__c = mc_map.get(8); 
                    pi.ASI_MFM_Month_9_Cost__c = mc_map.get(9); 
                    pi.ASI_MFM_Month_10_Cost__c = mc_map.get(10);   
                    pi.ASI_MFM_Month_11_Cost__c = mc_map.get(11);   
                    pi.ASI_MFM_Month_12_Cost__c = mc_map.get(12);   
                }
                
    // Check if there was an input in the decimal number output error
                boolean isDecimal = ASI_MFM_Function.containsDecimalValue(pi.ASI_MFM_Total_Cost__c) && pi.ASI_MFM_Currency__c == 'TWD';
                if (isDecimal)
                  pi.addError(' You Cannot input a decimal number for a TWD currency.');
            }
        }
        
        
    }
}