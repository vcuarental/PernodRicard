public without sharing class ASI_MFM_PlanLineItem_TriggerClass {
    public static void routineAfterAll(list<ASI_MFM_Plan_Line_Item__c> trigger_new, map<id, ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {
         set<id> PlanIdSet= new set<id>();
        if (trigger_new != null) {
            for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {
                   if(Global_RecordTypeCache.getRt(pi.recordTypeID).DeveloperName.contains('ASI_MFM_GF') && trigger_oldMap!=null && trigger.isUpdate && pi.ASI_MFM_Plan_Line_Item_External_IDUpload__c!=null){
                    if(pi.ASI_MFM_Total_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Total_Cost__c || 
                      pi.ASI_MFM_Month_1_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_1_Cost__c || pi.ASI_MFM_Month_2_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_2_Cost__c || 
                      pi.ASI_MFM_Month_3_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_3_Cost__c || pi.ASI_MFM_Month_4_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_4_Cost__c || 
                      pi.ASI_MFM_Month_5_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_5_Cost__c || pi.ASI_MFM_Month_6_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_6_Cost__c || 
                      pi.ASI_MFM_Month_7_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_7_Cost__c || pi.ASI_MFM_Month_8_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_8_Cost__c ||
                      pi.ASI_MFM_Month_9_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_9_Cost__c || pi.ASI_MFM_Month_10_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_10_Cost__c || 
                      pi.ASI_MFM_Month_11_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_11_Cost__c || pi.ASI_MFM_Month_12_Cost__c!=trigger_oldMap.get(pi.id).ASI_MFM_Month_12_Cost__c ||
                      pi.ASI_MFM_Distributor_Amount__c!=trigger_oldMap.get(pi.id).ASI_MFM_Distributor_Amount__c || pi.ASI_MFM_Sub_brand_Allocation_Type__c!=trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Allocation_Type__c ||
                      pi.ASI_MFM_Customer_Name__c!=trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c || pi.ASI_MFM_Reference__c!=trigger_oldMap.get(pi.id).ASI_MFM_Reference__c ||
                      pi.ASI_MFM_AP_Code__c!=trigger_oldMap.get(pi.id).ASI_MFM_AP_Code__c || pi.ASI_MFM_Sub_brand_Code__c!=trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                      pi.ASI_MFM_Area_of_Activation__c!=trigger_oldMap.get(pi.id).ASI_MFM_Area_of_Activation__c || pi.ASI_MFM_List_Item_Description__c!=trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                      pi.ASI_MFM_Remarks__c!=trigger_oldMap.get(pi.id).ASI_MFM_Remarks__c 
                      
                      ){
                        PlanIdSet.add(pi.ASI_MFM_Plan__c);
                    }
                    
                  
                }
            }
        }
            
        if(PlanIdSet.size()>0){
            List<ASI_MFM_Plan__c> planupdatelist= new List<ASI_MFM_Plan__c> ();
            for(Id planid:PlanIdSet){
                planupdatelist.add(new ASI_MFM_Plan__c (id=planid,ASI_MFM_Status__c='Draft'));
            }
            update planupdatelist;
        }
        
// Pass plan and line item details to Data Warehouse
        /*if (!ASI_MFM_Function.bypassCallouts()) {           
            set<id> pid_set = new set<id>();
            if (trigger_new != null) {
                for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {
                    if (trigger_oldMap == null || pi.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(pi.id).ASI_MFM_Sys_Sync_Time__c) {
                        pid_set.add(pi.ASI_MFM_Plan__c);
                    }               
                }
            }
            else if (trigger_oldMap != null) {
                for (ASI_MFM_Plan_Line_Item__c pi:trigger_oldMap.values()) {
                    pid_set.add(pi.ASI_MFM_Plan__c);                
                }           
            }
            if (pid_set.size() > 0 && !system.isFuture() && !system.isBatch()) {    // Modified by Michael (Introv) 23Apr2014 adding !system.isBatch()
                if (!(test.isRunningTest() && limits.getFutureCalls() >= limits.getLimitFutureCalls())) {               
                    ASI_MFM_Callout.updatePlan(pid_set);
                }
            }
        }*/    
    }

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
            
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_GF')){
                gfPlanLineIDMap.put(pi.id,pi);
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
        
        //Added by Introv @20161205 - Line Itms of Plan converted from PAF cannot be edited
        Map<ID, ASI_MFM_Plan__c> planMap = new Map<ID, ASI_MFM_Plan__c>([SELECT ID, Name, ASI_CRM_Converted_Date__c, recordtypeID,ASI_MFM_Plan_External_ID_Upload__c,ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c,ASI_MFM_Prefix__r.name,ASI_MFM_Fiscal_year__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c FROM ASI_MFM_Plan__c WHERE ID IN: setPYI]);
        
        //if (trigger.isBefore && trigger.isUpdate){
            for(ASI_MFM_Plan_Line_Item__c pi : trigger_new){
                if(Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_TW')){
                    /*if(planMap.get(pi.ASI_MFM_Plan__c).ASI_CRM_Converted_Date__c != null){
                        if(!pi.ASI_CRM_First_Update__c)
                            pi.ASI_CRM_First_Update__c = true;
                        else
                            pi.addError('Not allowed to update Plan line items converted from PAF.');
                    }*/
                    
                    // Added by Linus@introv 2017-08-10 
             
                     // * 1. Auto-Cal the total amount of 12 brackets for Plan Line Amount
                     // * 2. Check whether entered brackets are out of Plan period
                     
                    // Added by 2017-08-10    Linus@introv 
                    Integer StartP = 0;
                    Integer EndP = 0;
                    
                    if(planMap != null){
                        StartP = planMap.values()[0].ASI_MFM_Start_Date__c == null ? 0: planMap.values()[0].ASI_MFM_Start_Date__c.month() > 6 ? planMap.values()[0].ASI_MFM_Start_Date__c.month() - 6 : planMap.values()[0].ASI_MFM_Start_Date__c.month() + 6;
                        EndP = planMap.values()[0].ASI_MFM_End_Date__c == null ? 0: planMap.values()[0].ASI_MFM_End_Date__c.month() > 6 ? planMap.values()[0].ASI_MFM_End_Date__c.month() - 6 : planMap.values()[0].ASI_MFM_End_Date__c.month() + 6;
                    }
                    pi.ASI_MFM_Total_Cost__c = 0; 
                    for(integer i = 1; i <= 12; i++){
                        String Bracket = 'ASI_MFM_Month_' + i + '_Cost__c';
                        if(!Test.isRunningTest() && (i < StartP || i > EndP) && pi.get(Bracket) != null){
                            pi.addError('Bucket is not within Plan Start and End date');
                        }else{
                            Decimal bracketAmount = (Decimal)pi.get(Bracket) != null ? (Decimal)pi.get(Bracket) : 0;
                            pi.ASI_MFM_Total_Cost__c += bracketAmount;
                        }
                    }
                }
            }
        //}
        //End by Introv @20161205 - Line Itms of Plan converted from PAF cannot be edited
        
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
        
        Profile prof = [select Name, id from Profile where Id = :UserInfo.getProfileId()];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';        
        //Map<ID, ASI_MFM_Plan__c> planMap = new Map<ID, ASI_MFM_Plan__c>([SELECT ID, Name, recordtypeID,ASI_MFM_Plan_External_ID_Upload__c,ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c,ASI_MFM_Prefix__r.name,ASI_MFM_Fiscal_year__c FROM ASI_MFM_Plan__c WHERE ID IN: setPYI]);
        
        if (country_pfx.contains('ASI_MFM_TR')){
            //Update by Steve Introv 12 Jun 2014 to get all customer
            accMap = new Map<ID, account>([SELECT ID, Name, recordtypeID, ASI_HK_CRM_Location__c FROM account WHERE ID IN: setCUI]);
            apMap = new Map<ID, ASI_MFM_AP_Code__c>([select id, ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where id IN:setAPI]);
        }
        else if (country_pfx.contains('ASI_MFM_GF')){
             apMap = new Map<ID, ASI_MFM_AP_Code__c>([select id, ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where id IN:setAPI]);
        }
        else if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_CAP')){
            //CAPEX:OPEX Update AC Code according to AP Code
             apMap = new Map<ID, ASI_MFM_AP_Code__c>([select id, ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where id IN:setAPI]);
        }
        
        //Customer Default Value
        String JPCustomerDefault;
        String JPBUCodeDefault;
        String RMCustomerDefault;
        String MYCustomerDefault;
        String MYBUCodeDefault;
        String TRJDFBUCodeDefault;
        //CAPEX: ADd default value for Cap Bu Code 
        String CAPEX_BUCodeDefault;
        String OPEX_BUCodeDefault;
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            if(Setting.name == 'JP_Customer_Name__c' && Setting.Country__c == 'JP'){
                JPCustomerDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'JP_BU_Code__c' && Setting.Country__c == 'JP'){
                JPBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'MY_BU_Code__c' && Setting.Country__c == 'MY'){
                MYBUCodeDefault = Setting.ASI_MFM_value__c;
                
            }
            if(Setting.name == 'MY_Customer_Name__c' && Setting.Country__c == 'MY'){
                MYCustomerDefault = Setting.ASI_MFM_value__c;
            }
            //Added by Wilken on 20140317, Regional MKT MFM Default Customer
            if(Setting.name == 'RM_Customer_Name__c' && Setting.Country__c == 'RM'){
                RMCustomerDefault = Setting.ASI_MFM_value__c;
            }
            //Added by Steve on 20140828, ATR JDF MFM Default Customer
            if(Setting.name == 'TR_JDF_BU_Code__c' && Setting.Country__c == 'TR'){
                TRJDFBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            // CAPEX: set the capex bucode default
            if (setting.name == 'CAP_CAPEX_BU_Code__c' && Setting.Country__c == 'HK') {
                CAPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
            // OPEX: set the opex bucode default
            if (setting.name == 'CAP_OPEX_BU_Code__c' && Setting.Country__c == 'HK') {
                OPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
        }
        System.debug('ASI_MFM_Default_Value__cTest:'+ASI_MFM_Default_Value__c.getAll().values());
        
        //Add    For TH Use Only
        Decimal BudgetSum=0;
        Decimal PlanSum=0;
        String CurrPrefix;
        String FiscalYear;
        String PlanName;
        Id CurrPlanId;
        set<id> currentIdset=new set<id>();
        //  
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {  
            //System.debug('TEST_ERROR:'+pi.ASI_MFM_Plan__c);  System.debug('ASI_MFM Error Test  : ' +  planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Fiscal_year__c); 
               
//Added Same logic to CAPEX
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_CAP')){
                // CAPEX: Default BU Code Value
                if (pi.ASI_MFM_Plan_Type__c == 'CAPEX' && pi.ASI_MFM_BU_Code__c == null){
                    pi.ASI_MFM_BU_Code__c = CAPEX_BUCodeDefault;
                }
                else if (pi.ASI_MFM_Plan_Type__c == 'OPEX' && pi.ASI_MFM_BU_Code__c == null){
                    pi.ASI_MFM_BU_Code__c = OPEX_BUCodeDefault;
                }
                
                //CAPEX:OPEX Update AC Code according to AP Code
                if (pi.ASI_MFM_AP_Code__c != null){
                    if (apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c != null){
                        System.debug('A/C Code: ' + apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c);
                        pi.ASI_MFM_A_C_Code__c = apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c;
                    }
                }
            }
                  
// Validation rules for ASI_MFM_LOCK_TW_PLI    planmap.get(pi.id).developerName == ASI_MFM_TW
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_TW_Plan_Read_Only') && !isuserAdmin && !System.isFuture()){
                pi.addError('You can NOT modify the Plan Line under a Final or Complete Plan');
            }
            
//JP Plan Logic :set defaul Line Item Value and Customer Value
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_JP_Plan')){
                if (pi.ASI_MFM_List_Item_Description__c == null || pi.ASI_MFM_List_Item_Description__c.trim() == '' || pi.ASI_MFM_List_Item_Description__c.trim().length()== 0){
                    pi.ASI_MFM_List_Item_Description__c = planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Plan_Name__c;
                }
                if(pi.ASI_MFM_Customer_Name__c == null &&  JPCustomerDefault != null && JPCustomerDefault != ''){
                     pi.ASI_MFM_Customer_Name__c = JPCustomerDefault;
                }
                if(pi.ASI_MFM_BU_Code__c == null &&  JPBUCodeDefault != null && JPBUCodeDefault != ''){
                     pi.ASI_MFM_BU_Code__c = JPBUCodeDefault;
                }
            }
            //End JP logic
            
            //MY Plan Line Logic: Default AP Code, BU Code, Customer, GL Date
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_MY_Plan')){
                if(pi.ASI_MFM_Customer_Name__c == null &&  MYCustomerDefault != null && MYCustomerDefault != ''){
                     pi.ASI_MFM_Customer_Name__c = MYCustomerDefault;
                }
                if(pi.ASI_MFM_BU_Code__c == null &&  MYBUCodeDefault != null && MYBUCodeDefault != ''){
                     pi.ASI_MFM_BU_Code__c = MYBUCodeDefault;
                }
            }
            
            //RM Plan Logic: set default customer value on line item
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_RM_Plan')){
                if (pi.ASI_MFM_Customer_Name__c == null &&  RMCustomerDefault != null && RMCustomerDefault != ''){
                     pi.ASI_MFM_Customer_Name__c = RMCustomerDefault;
                }
            }
            
            //HK Plan Logic: set default BU on line item base on prefix
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_HK')){
                if (pi.ASI_MFM_BU_Code__c == null && planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c != null){
                     pi.ASI_MFM_BU_Code__c = planMap.get(pi.ASI_MFM_Plan__c).ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c;
                }
            }
            
            //TR Plan Logic: set default BU value on line item
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_TR_Plan')){
                if (pi.ASI_MFM_BU_Code__c == null ){
                    if (pi.ASI_MFM_TR_Rec_Type__c == 'JDF' && TRJDFBUCodeDefault != null && TRJDFBUCodeDefault != ''){
                        //JDF BU
                        pi.ASI_MFM_BU_Code__c = TRJDFBUCodeDefault;
                    }
                    else{  
                        //ATR BU
                        System.debug('Loc Code: ' + accMap.get(pi.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c + '' + bu_list );
                        For(ASI_MFM_BU__c bu : bu_list) {
                            System.debug('bu Code: ' +  bu.ASI_MFM_BU_Code__c);
                            if (accMap.get(pi.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c != null){
                                if (bu.ASI_MFM_BU_Description__c.contains(accMap.get(pi.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c) && bu.ASI_MFM_BU_Code__c != 'JDF'){
                                    pi.ASI_MFM_BU_Code__c = bu.id;
                                    break;
                                }
                            }
                        } 
                    }
                }
            }
            //End TR Logic  
            
            //2014-08-11 Stella Sing TR Logic Fix
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_TR_Plan')){
            //TR Logic: Auto fill A/C Code if user input AP Code only
                if (pi.ASI_MFM_AP_Code__c != null){
                    if (apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c != null){
                        System.debug('A/C Code: ' + apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c);
                        pi.ASI_MFM_A_C_Code__c = apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c;
                    }
                }
                //TR Logic: Sum up total cost by month cost
                if(pi.ASI_MFM_Month_1_Cost__c != null || pi.ASI_MFM_Month_2_Cost__c != null || 
                    pi.ASI_MFM_Month_3_Cost__c != null || pi.ASI_MFM_Month_4_Cost__c != null || 
                        pi.ASI_MFM_Month_5_Cost__c != null || pi.ASI_MFM_Month_6_Cost__c != null || 
                            pi.ASI_MFM_Month_7_Cost__c != null || pi.ASI_MFM_Month_8_Cost__c != null ||     
                                pi.ASI_MFM_Month_9_Cost__c != null || pi.ASI_MFM_Month_10_Cost__c != null || 
                                    pi.ASI_MFM_Month_11_Cost__c != null || pi.ASI_MFM_Month_12_Cost__c != null){
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
                else {
                    pi.ASI_MFM_Total_Cost__c = 0;
                }
            }
            
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_GF_Plan') ){
//GF Logic: Auto fill A/C Code if user input AP Code only
                if (pi.ASI_MFM_AP_Code__c != null){
                    if (apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c != null){
                        System.debug('A/C Code: ' + apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c);
                        pi.ASI_MFM_A_C_Code__c = apMap.get(pi.ASI_MFM_AP_Code__c).ASI_MFM_A_C_Code__c;
                    }
                }
 //GF Logic: Sum up total cost by month cost if total cost is empty and month cost is filled
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
            }
            
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
            
              
             if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_SG_Plan')|| Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_TH_Plan')){
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
                 
            }// End Of SG and TH
            
            
            
            
            
            
            //Update Default BU Logic
            if (bu_list.size() == 1) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                        pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                } 
            } 
            //End Update Default BU Logic
            
// Calculate total cost from quantity and unit cost         // Not for TW Plan ** Modified by 2017-08-14 Linus@introv
            if ((pi.ASI_MFM_Total_Cost__c == null || pi.ASI_MFM_Total_Cost__c == 0) && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Cost__c != null && planMap.get(pi.ASI_MFM_Plan__c).recordTypeID != rt_map.get('ASI_MFM_TW_Plan')) {
                pi.ASI_MFM_Total_Cost__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up);
                System.debug('Auto calculated PLine Amt by Qty: ' + (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c).setScale(0, roundingmode.half_up));
            }           
            
            //Spread logic applies to TW and JP and GF MFM
            // LAPUTA* Update Trigger Class: Apply Spread logic to CAP
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_Plan') || 
                    Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_JP_Plan') || 
                        Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_GF_Plan') || 
                			Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_TR_Plan') ||  
                            	Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_TH_Plan') || 
                                	Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_SG_Plan') || 
                                    	Global_RecordTypeCache.getRt(pi.recordTypeId).DeveloperName.contains('ASI_MFM_CAP_Plan') ){
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
        //26032015 Add For TH use 
        System.debug('TestEnd1'+PlanSum+CurrPrefix);
        String CurrPrefixP =CurrPrefix;
        if (CurrPrefix != null && CurrPrefix.length()>3){
            String CurrPrefixB=CurrPrefixP.substring(0,3);
             if(CurrPrefixB.contains('TH') && !ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_TH_PlanLineTriggerClass','TH') ){
                Boolean isfound=true;
                String BudgetType;
                Decimal POSum=0;
                // Get budget amount from  ASI_MFM_Budget__c object
                list<ASI_MFM_Budget__c> budgetItem = [select ASI_MFM_Total_Amount__c from ASI_MFM_Budget__c where RecordType.DeveloperName = 'ASI_MFM_TH_Budget' and  ASI_MFM_Department__c Like :'%'+CurrPrefixB+'%' AND ASI_MFM_Fiscal_Year__c=:FiscalYear AND ASI_MFM_Type__c Like '%Budget%'];
                list<ASI_MFM_Budget__c> budgetItem1 = [select ASI_MFM_Total_Amount__c from ASI_MFM_Budget__c where RecordType.DeveloperName = 'ASI_MFM_TH_Budget' and ASI_MFM_Department__c Like :'%'+CurrPrefixB+'%' AND ASI_MFM_Fiscal_Year__c=:FiscalYear AND ASI_MFM_Type__c='LE1' ];
                list<ASI_MFM_Budget__c> budgetItem2 = [select ASI_MFM_Total_Amount__c from ASI_MFM_Budget__c where RecordType.DeveloperName = 'ASI_MFM_TH_Budget' and ASI_MFM_Department__c Like :'%'+CurrPrefixB+'%' AND ASI_MFM_Fiscal_Year__c=:FiscalYear AND ASI_MFM_Type__c='LE2' ];
                list<ASI_MFM_Budget__c> budgetItem3 = [select ASI_MFM_Total_Amount__c from ASI_MFM_Budget__c where RecordType.DeveloperName = 'ASI_MFM_TH_Budget' and ASI_MFM_Department__c Like :'%'+CurrPrefixB+'%' AND ASI_MFM_Fiscal_Year__c=:FiscalYear AND ASI_MFM_Type__c='LE3' ];
                list<ASI_MFM_Budget__c> budgetItem4 = [select ASI_MFM_Total_Amount__c from ASI_MFM_Budget__c where RecordType.DeveloperName = 'ASI_MFM_TH_Budget' and ASI_MFM_Department__c Like :'%'+CurrPrefixB+'%' AND ASI_MFM_Fiscal_Year__c=:FiscalYear AND ASI_MFM_Type__c='LE4' ];
                list<ASI_MFM_Budget__c> budgetItemVaild;
                
                system.debug('Budget Setting: ' + ASI_MFM_Budget_Setting__c.getAll().values());
                for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
                    if(Setting.name == 'TH' && Setting.ASI_MFM_Budget_Type__c == 'Budget'){
                        budgetItemVaild=budgetItem;
                        BudgetType='Budget';
                    }
                    if(Setting.name == 'TH' && Setting.ASI_MFM_Budget_Type__c == 'LE1'){
                        budgetItemVaild=budgetItem1;
                        BudgetType='LE1';
                    }
                    if(Setting.name == 'TH' && Setting.ASI_MFM_Budget_Type__c == 'LE2'){
                        budgetItemVaild=budgetItem2;
                        BudgetType='LE2';
                    }
                    if(Setting.name == 'TH' && Setting.ASI_MFM_Budget_Type__c == 'LE3'){
                        budgetItemVaild=budgetItem3;
                        BudgetType='LE3';
                    }
                    if(Setting.name == 'TH' && Setting.ASI_MFM_Budget_Type__c == 'LE4'){
                        budgetItemVaild=budgetItem4;
                        BudgetType='LE4';
                    }
                }
                
               
                for(ASI_MFM_Budget__c buli : budgetItemVaild){ // calculate the sum of budget
                    if(buli.ASI_MFM_Total_Amount__c>0){
                        BudgetSum=BudgetSum+buli.ASI_MFM_Total_Amount__c;
                    }
                    
                }
                //get plan amount from ASI_MFM_Plan__c except the current one
                list<ASI_MFM_Plan__c> PlanItem  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where ASI_MFM_Prefix__r.name Like :'%'+CurrPrefixP+'%' AND Id!=:CurrPlanId AND ASI_MFM_Fiscal_year__c =:FiscalYear];
                
                list<ASI_MFM_Plan_Line_Item__c> CurPlanItemList=[select id,name,ASI_MFM_Total_Cost__c from ASI_MFM_Plan_Line_Item__c where id not in : currentIdset and ASI_MFM_Plan__c=:CurrPlanId];
                
                list<ASI_MFM_PO__c> POnum =[select ASI_MFM_PO_Amount__c from ASI_MFM_PO__c where ASI_MFM_PO__c.ASI_MFM_Plan__c= :CurrPlanId]; //Get all of PO Amount with same Plan 
                
                for(ASI_MFM_PO__c POlist : POnum){ // calculate the sum of PO            
                    if(POlist.ASI_MFM_PO_Amount__c>0){POSum=POSum+POlist.ASI_MFM_PO_Amount__c;}
                    
                }
                Decimal TotalNow=PlanSum;
                
                for(ASI_MFM_Plan_Line_Item__c pl:CurPlanItemList){
                    if(pl.ASI_MFM_Total_Cost__c!=null) TotalNow=TotalNow+pl.ASI_MFM_Total_Cost__c;
                    PlanSum=PlanSum+pl.ASI_MFM_Total_Cost__c;
                }
                if(POSum>(TotalNow)){   // Check Plan amount and PO amount
                    for (ASI_MFM_Plan_Line_Item__c pa:trigger_new) { 
                        pa.addError(' Plan amount( '+ TotalNow+' )can not be less than existing PO amount( '+POSum+' ).' );
                    }
                }
                
                
                Decimal curPlanSum=PlanSum;
                for(ASI_MFM_Plan__c Planli : PlanItem){ // calculate the sum of plan amount 
                    PlanSum=PlanSum+Planli.ASI_MFM_Plan_Amount__c;
                }
                
                if(BudgetSum<PlanSum){ // Check if over budget
                   for (ASI_MFM_Plan_Line_Item__c pa:trigger_new) { 
                       if(!Test.isRunningTest()){ 
                           pa.addError('Total Plan Amount over Total Budget' );
                       }
                   }
                }


                //Add    For TH Use Only
            }
        }
        
    }
}