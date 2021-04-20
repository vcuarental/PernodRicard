public without sharing class ASI_MFM_Plan_TriggerClass {
    
    Private Static Integer counting = 0;//20170105 Elufa
    public static final String CNTPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan');
    
    public static void routineAfterDelete(list<ASI_MFM_Plan__c> trigger_old) { }
    
    public static void routineBeforeDelete (list<ASI_MFM_Plan__c> trigger_old) {
        // Not allowed to delete final plan
        Set<id> pid_set = new Set<id>();
        for (ASI_MFM_Plan__c plan : trigger_old)
        { 
            if ( (plan.ASI_MFM_Status__c == 'Final' || plan.ASI_MFM_Status__c == 'Complete')&& !Test.isRunningTest() ){
                plan.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }
            else if ((plan.ASI_MFM_Status__c == 'Draft' && Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_TR'))||(plan.ASI_MFM_Status__c == 'Draft' && (Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_SG') || Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_TH')))){
                pid_set.add(plan.id);
            }
            else if (Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_KR')  ){ // 
                if( (plan.ASI_MFM_Status__c == 'Approved' || plan.ASI_MFM_Status__c == 'Closed' ||plan.ASI_MFM_Status__c == 'Submitted' ) && !Test.isRunningTest() ){
                    plan.addError('Not allowed to delete because the plan is in \'Submitted\' or \'Approved\' or \'Closed\'  status');
                }
                
            }
        }
        if (pid_set.size() > 0) {
            map<id, ASI_MFM_Plan__c> p_map = new map<id, ASI_MFM_Plan__c>([select (select id from POs__r) from ASI_MFM_Plan__c where id in :pid_set]);
            for (ASI_MFM_Plan__c p:trigger_old) {
                if (p_map.containsKey(p.id) && p_map.get(p.id).POs__r.size() > 0) {
                    p.addError('Not allowed to delete because the plan is contain PO');
                }
            }
        }
    }
    
    public static void routineAfterInsert(list<ASI_MFM_Plan__c> trigger_new) {
        set<id> pid_set = new set<id>();
        map<id, id> cid_map = new map<id, id>();
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (p.ASI_MFM_Cloned_Plan_ID__c != p.id) {
                pid_set.add(p.id);
                if (p.ASI_MFM_Cloned_Plan_ID__c != null) {
                    cid_map.put(p.id, p.ASI_MFM_Cloned_Plan_ID__c);
                }    
            }
        }
        
        // Set cloned plan ID to the new plan ID 
        // Set the status to Draft for cloned plan       
        if (pid_set.size() > 0) {
            list<ASI_MFM_plan__c> plan_list = [select ASI_MFM_cloned_plan_id__c from ASI_MFM_plan__c where id in :pid_set for update];
            for (ASI_MFM_plan__c p:plan_list) {
                if (p.ASI_MFM_cloned_plan_id__c != null) {
                    p.ASI_MFM_Status__c = 'Draft';
                }
                p.ASI_MFM_cloned_plan_id__c = p.id;
                p.ASI_MFM_Sys_Sync_Time__c = datetime.now();
            }
            update plan_list;
        } 
        
        // If cloned plan ID is not null, clone the line items of the cloned plan to the new plan         
        if (cid_map.size() > 0) {
            list<id> cid_list = cid_map.values();
            string query_string = 'select (' + ASI_MFM_Function.buildQuery('ASI_MFM_plan_line_item__c', null, 'plan_line_items__r order by name') + ') from ASI_MFM_plan__c where id in :cid_list';
            map<id, ASI_MFM_plan__c> clone_map = new map<id, ASI_MFM_plan__c>();
            for (ASI_MFM_plan__c p:database.query(query_string)) {
                clone_map.put(p.id, p);
            }
            list<ASI_MFM_plan_line_item__c> cloned_pi_list = new list<ASI_MFM_plan_line_item__c>();
            list<ASI_MFM_plan_line_item__c> pi_list = new list<ASI_MFM_plan_line_item__c>(); 
            for (id plan_id:cid_map.keySet()) {
                cloned_pi_list = clone_map.get(cid_map.get(plan_id)).plan_line_items__r;
                for (ASI_MFM_plan_line_item__c cloned_pi:cloned_pi_list) {
                    ASI_MFM_plan_line_item__c pi = cloned_pi.clone(false, true);
                    pi.ASI_MFM_plan__c = plan_id;
                    pi.ASI_MFM_Sys_Deduplication_Key__c = null;
                    pi.ASI_MFM_Plan_Line_Item_External_IDUpload__c = null; 
                    pi.ASI_MFM_Plan_Line_Item_External_ID__c = null;
                    pi_list.add(pi);
                }
            }
            insert pi_list;
        }       
    } 
    
    public static void routineAfterUpsert(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        //20161107 Elufa
        if(counting == 0){//20170105 Elufa
            Set<Id> CNPlanId = new Set<Id>();
            Map<Id, Set<Id>> mapPlanTeam = new Map<Id, Set<Id>>();
            List<ASI_MFM_Plan__Share> insertPlanSharing = new List<ASI_MFM_Plan__Share>();
            
            for(ASI_MFM_Plan__c obj : trigger_new){
                if(Global_RecordTypeCache.getRt(obj.recordTypeId).developerName.contains('ASI_MFM_CN')){
                    
                    Set<Id> tmpPlanSet = new Set<Id>();
                    
                    if(obj.ASI_MFM_Project_Team__c != Null && mapPlanTeam.containsKey(obj.ASI_MFM_Project_Team__c))
                        tmpPlanSet = mapPlanTeam.get(obj.ASI_MFM_Project_Team__c);
                    
                    tmpPlanSet.add(obj.id);
                    
                    mapPlanTeam.put(obj.ASI_MFM_Project_Team__c, tmpPlanSet);
                    CNPlanId.add(obj.id);
                }
            }
            
            if(mapPlanTeam.keySet().size() > 0 && CNPlanId.size() > 0){
                
                Delete [SELECT Id, RowCause, UserOrGroupId, ParentID FROM ASI_MFM_Plan__Share WHERE RowCause = : Schema.ASI_MFM_Plan__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c AND ParentID IN : CNPlanId];
                
                for(ASI_MFM_Team_Member__c obj : [SELECT id, ASI_MFM_Team_Member__c, ASI_MFM_Team__c FROM ASI_MFM_Team_Member__c WHERE ASI_MFM_Team__c IN : mapPlanTeam.keySet()]){
                    
                    for(Id PlanId : mapPlanTeam.get(obj.ASI_MFM_Team__c)){
                        insertPlanSharing.add(new ASI_MFM_Plan__Share(RowCause = Schema.ASI_MFM_Plan__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c , AccessLevel = 'Edit' , ParentID = PlanId , UserOrGroupId = obj.ASI_MFM_Team_Member__c ));
                    }
                }
                
                if(insertPlanSharing.size() > 0)//20170105 Elufa
                    Insert insertPlanSharing;
                counting++;//20170105 Elufa
            }
        }
        
        
    }
    
    public static void routineAfterUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        
        List<ASI_HK_CRM_Pre_Approval_Form__c> listPAFtoUpdate = new List<ASI_HK_CRM_Pre_Approval_Form__c>(); //Added by Twinkle (Introv) @20170113 for TW CRM3
        Map<Id, ASI_MFM_Plan__c> mapPlan = new Map<Id, ASI_MFM_Plan__c>(); //Added by Twinkle (Introv) @20170113 for TW CRM3
        
        // Added by Alan Wong (Elufa) 25Feb2015
        // Mass submit for approval SG/TH
        for(ASI_MFM_Plan__c plan : trigger_new){
            Map<String, id> MRecType = new Map<String, id>();
            for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c')){
                MRecType.put(rec.developername,rec.id);
            }
            
            if (plan.RecordTypeId == MRecType.get('ASI_MFM_SG_Plan') || plan.RecordTypeId == MRecType.get('ASI_MFM_TH_Plan')){
                if(plan.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(plan.id).ASI_MFM_Status__c == 'Draft'){
                    try
                    {
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setObjectId(plan.id);
                        Approval.ProcessResult result = Approval.process(req1);
                        if (!result.isSuccess())
                        {
                            plan.addError('Plan ' + plan.name + ' failed for submit for approval.');
                        }
                    }
                    catch (System.DmlException e)
                    {
                        plan.addError(e.getDmlMessage(0));
                    } 
                }  
            }
             
        }
        
    }
    
    public static void routineBeforeInsert(list<ASI_MFM_Plan__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Plan__c p:trigger_new) {
            setOwnerLink(p);
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        
        // Set the plan ID for new plan 
        // set fiscal year  
        // Set plan type    
        // Update by Steve Wan(Introv) 28 Apr 2014 to add FY for plan with tr record type prefix       
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c, ASI_MFM_Fiscal_year__c, Plan_Type__c, recordtypeid,ASI_MFM_TR_Rec_Type__c, ASI_MFM_Location__c from asi_mfm_prefix__c 
                                                                            where asi_mfm_module__c = 'Plan' and id in :px_set for update]);
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Prefix__c')){
            MRecType.put(rec.developername,rec.id);
        }
        //Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c');
        String CNRecTypeID = MRecType.get('ASI_MFM_CN_Prefix');
        String TRRecTypeID = MRecType.get('ASI_MFM_TR_Prefix');
        String MYRecTypeID = MRecType.get('ASI_MFM_MY_Prefix');
        String THRecTypeID = MRecType.get('ASI_MFM_TH_Prefix');
        String PHPRecTypeID = MRecType.get('ASI_MFM_PH_DP_Prefix');
        String PHFRecTypeID = MRecType.get('ASI_MFM_PH_DF_Prefix');
        String HKRecTypeID = MRecType.get('ASI_MFM_HK_Prefix');
        
        boolean SGChangeCurrency =false;
  
        
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                //TR Logic:
                if(px_map.get(p.asi_mfm_prefix__c).recordtypeid == TRRecTypeID ||px_map.get(p.asi_mfm_prefix__c).recordtypeid == HKRecTypeID){
                    //This logic is target for using lesser 'for loop' to cather different TR record type and plan type 
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 4){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    }
                    else if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }
                    else { //else == 6
                        p.name = px_map.get(p.asi_mfm_prefix__c).name +  string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 100).substring(1, 3);
                    }
                }
                else if(px_map.get(p.asi_mfm_prefix__c).recordtypeid == MYRecTypeID ){
                    //For Prefix of M, add 7 digits running number
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 1){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name.substring(0, 1) + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000000).substring(1, 8);
                    }
                    else if (px_map.get(p.asi_mfm_prefix__c).name.length() == 3){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name.substring(0, 3) + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 100000).substring(1, 6);
                    }
                    else if (px_map.get(p.asi_mfm_prefix__c).name.length() == 4){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name.substring(0, 4) + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 100000).substring(1, 5);
                    }else{
                        p.name = px_map.get(p.asi_mfm_prefix__c).name +  string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 100).substring(1, 3);
                    }
                }
                else if( px_map.get(p.asi_mfm_prefix__c).recordtypeid == THRecTypeID){
                    //For SG and TH Prefix, add 3 digits running number
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name.substring(0, 5) + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }
                }
                
                else{
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                }
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                if (p.ASI_MFM_Fiscal_year__c == null) {
                    p.ASI_MFM_Fiscal_year__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Fiscal_year__c;
                }
                if(px_map.get(p.asi_mfm_prefix__c).recordtypeid != TRRecTypeID ){
                    p.ASI_MFM_Sys_Plan_Type__c = px_map.get(p.asi_mfm_prefix__c).Plan_Type__c;
                }
                // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
                if(px_map.get(p.asi_mfm_prefix__c).recordtypeid == CNRecTypeID){
                    // 2014-10-21       Updated by Axel@introv      Log #71, Change _FY postfix to __FY
                    p.name += '__FY' + px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Fiscal_year__c.substring(2,4);
                    //20151112 Ben @ Elufa System
                    integer a = integer.valueOf('20' + px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Fiscal_year__c.substring(2,4));
                    if (p.RecordTypeId != CNTPRTID) {//modify Jack for cn trade plan 2020-04
                        p.ASI_MFM_Start_Date__c = date.newInstance(a, 7, 1);
                        p.ASI_MFM_End_Date__c = date.newInstance( (a+1), 6, 30);
                    }
                    //End 20151112
                }
                // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());        
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        // Set the owner link     System.debug('ASI_MFM_Plan_TriggerClass:routineBeforeUpdate: start()');
        // Set the approvers for the plan based on the routing rule objects                         System.debug('Number of Queries used in this Apex code so far: ' + Limits.getQueries());
        set<id> pid_set = new set<id>();
        Set<id> OwnerId = new Set<id>();
        set<id> px_set = new set<id>();
        Map<ID, User> OwnerMap  = new Map<ID,User>();
        set<id> setPid_TW = new set<id>(); // Added by Twinkle (Introv) @20161219
        Boolean IsTHPlan= false;
        // Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment
        Set<id> SCNRecTypeID = new Set<id>();
        for(RecordType rec : Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c')){
            if(rec.DeveloperName.contains('CN_Plan')){
                SCNRecTypeID.add(rec.id);
            }
        }
        
        set<string> STeam = new set<string>();
        // Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment       
        Set<id> SPID = new Set<id>();
        for (ASI_MFM_Plan__c p:trigger_new) {
            OwnerId.add(p.OwnerId);
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                IsTHPlan = true;
            }
            //20170609 Introv Copy PP Category From Marketing Category When creation
            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_CN')){
                
                if(p.ASI_MFM_Default_PP_Category__c != Null && p.ASI_MFM_Default_PP_Category__c != ''){
                    
                    try{
                        Id ppcatId = id.valueOf(p.ASI_MFM_Default_PP_Category__c);
                    }catch(exception e){
                        p.addError(e.getMessage());
                    }
                    
                    p.ASI_MFM_PP_Category__c = p.ASI_MFM_Default_PP_Category__c;
                    p.ASI_MFM_Default_PP_Category__c = '';
                }
            }
            
            setOwnerLink(p);
            
            //TW MFM Logic,added by Elufa 20151116 
            boolean isTW=false;
            if(p.ASI_MFM_Status__c!='Draft' && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW')){
                isTW=true;
            }
            
            if (p.ASI_MFM_Plan_Amount__c != null && !isTW) {
                
                if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF') && p.ASI_MFM_Status__c == 'Draft'){
                    pid_set.add(p.id);  //troubleshoot on 21 March
                    px_set.add(p.ASI_MFM_Prefix__c); //troubleshoot on 21 March
                }
                
                if (!Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF') && !Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_KR') ){ // added bypass KR Plan by Elufa on March 23
                    if(SCNRecTypeID.contains(P.recordtypeid) && p.ASI_MFM_Status__c != 'Final'){
                        SPID.add(P.id); 
                        STeam.add(p.asi_mfm_budget_owner_team__c); 
                        pid_set.add(p.id);
                        px_set.add(p.ASI_MFM_Prefix__c);
                        p.ASI_MFM_Approver_1__c = null;
                        p.ASI_MFM_Approver_2__c = null;
                        p.ASI_MFM_Approver_3__c = null;
                        p.ASI_MFM_Approver_4__c = null;
                        p.ASI_MFM_Approver_5__c = null; 
                        p.ASI_MFM_Approver_6__c = null;
                        p.ASI_MFM_Approver_7__c = null;
                        p.ASI_MFM_Approver_8__c = null;
                        p.ASI_MFM_Approver_9__c = null;
                        p.ASI_MFM_Approver_10__c = null;
                    }else if (!SCNRecTypeID.contains(P.recordtypeid)){
                        pid_set.add(p.id);
                        px_set.add(p.ASI_MFM_Prefix__c);
                        p.ASI_MFM_Approver_1__c = null;
                        p.ASI_MFM_Approver_2__c = null;
                        p.ASI_MFM_Approver_3__c = null;
                        p.ASI_MFM_Approver_4__c = null;
                        p.ASI_MFM_Approver_5__c = null; 
                        p.ASI_MFM_Approver_6__c = null;
                        p.ASI_MFM_Approver_7__c = null;
                        p.ASI_MFM_Approver_8__c = null;
                        p.ASI_MFM_Approver_9__c = null;
                        p.ASI_MFM_Approver_10__c = null;
                    }    
                }
                // Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment                                               
            }
            
            //GF Logic: Do not allow increase Plan amount if status is Final
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                if (p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Plan_Amount__c > p.ASI_MFM_Original_Plan_Amount__c && p.ASI_MFM_Plan_Amount__c != trigger_oldMap.get(p.id).ASI_MFM_Plan_Amount__c){
                    p.addError('You cannot increase Plan amount after the Plan is Final');
                }
            }
        }
        
        
        if(IsTHPlan){
            OwnerMap  = new Map<ID,User>([SELECT ID, Name,managerId  FROM User WHERE Id in :  OwnerId ]);
        }
        
        if (pid_set.size() > 0) {       
            map<id, id> sb_map = new map<id, id>();
            for (ASI_MFM_Plan_Line_Item__c pi:[select ASI_MFM_Plan__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_Plan_Line_Item__c 
                                               where ASI_MFM_Plan__c in :pid_set order by name desc]) {
                                                   sb_map.put(pi.ASI_MFM_Plan__c, pi.ASI_MFM_Sub_brand_Code__c);
                                               }
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                                                              where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) 
                                                              order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];
            set<id> rt_set = new set<id>();     
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }  
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Sequence__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                                                            where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];
            
            // Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment
            // Edited by Steve Wan (Introv) 09May2014 for reduce SOQL
            Map<string, ASI_MFM_Fix_Approval_Route__c> MAppRouteFix;
            Map<string, ASI_MFM_Fix_Approval_Route__c> MAppRouteFixCN = new Map<string, ASI_MFM_Fix_Approval_Route__c>();//20160810 Ben @ Elufa
            if (STeam.size() >0){
                MAppRouteFix = new Map<string, ASI_MFM_Fix_Approval_Route__c>();
                List<ASI_MFM_Fix_Approval_Route__c> LFApp =   [Select ASI_MFM_BA__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c, ASI_MFM_Finance__c, ASI_MFM_Module__c, ASI_MFM_Team__c, ASI_MFM_Approval_Limit_BA__c, ASI_MFM_Approval_Limit_CA1__c, ASI_MFM_Approval_Limit_CA2__c, ASI_MFM_Approval_Limit_Finance__c, recordType.DeveloperName from ASI_MFM_Fix_Approval_Route__c where ASI_MFM_Module__c = 'Plan' and ASI_MFM_Team__c IN :STeam];
                for(ASI_MFM_Fix_Approval_Route__c a : LFApp){
                    if(a.recordType.DeveloperName == 'ASI_MFM_CN_Fix_Approval_Route'){
                        MAppRouteFixCN.put(a.ASI_MFM_Team__c, a);
                    }else{
                        MAppRouteFix.put(a.ASI_MFM_Team__c, a);
                    }
                }
            }// Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment
            
            for (ASI_MFM_Plan__c p:trigger_new) {
                
                integer approver_count = 0;
                if (pid_set.contains(p.id) && !SPID.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null)) {
                            rtid = brm.ASI_MFM_Route_Type__c;
                            break;
                        }
                        else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                            break;
                        }                       
                    }
                    if (rtid != null) {
                        for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= p.ASI_MFM_Plan_Amount__c && rd.ASI_MFM_Sequence__c != 999 && !Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH_DF')) {
                                if (approver_count == 0) {
                                    p.ASI_MFM_Approver_1__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 1) {                                 
                                    p.ASI_MFM_Approver_2__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 2) {                                 
                                    p.ASI_MFM_Approver_3__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 3) {                                 
                                    p.ASI_MFM_Approver_4__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 4) {                                 
                                    p.ASI_MFM_Approver_5__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 5) {                                 
                                    p.ASI_MFM_Approver_6__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 6) {                                 
                                    p.ASI_MFM_Approver_7__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 7) {                                 
                                    p.ASI_MFM_Approver_8__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 8) {                                 
                                    p.ASI_MFM_Approver_9__c = rd.ASI_MFM_Approver__c;
                                }
                                else if (approver_count == 9) {                                 
                                    p.ASI_MFM_Approver_10__c = rd.ASI_MFM_Approver__c;
                                }                                                                                                    
                                approver_count++;                                                                                                                               
                            }
                            else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                break;
                            }
                            
                        }
                       
                        //Change the Approver For THP Team Only                 Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && p.ASI_MFM_TH_Prefix_Name__c=='region' && p.ASI_MFM_TH_Region__c!=null
                        if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && p.ASI_MFM_TH_Prefix_Name__c== true && p.ASI_MFM_TH_Region__c!=null){
                            String[] region=p.ASI_MFM_TH_Region__c.split(';');  // Approver By region 
                            approver_count=0;
                            List<String> tempapproverlist = new List<String>();  // Store the Approver list
                            List<String> approverlist = new List<String>();  // Store the Approver list
                            Set<id> approverids = new Set<id>();
                            for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                                if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= p.ASI_MFM_Plan_Amount__c && rd.ASI_MFM_Sequence__c != 999) {
                                    tempapproverlist.add(rd.ASI_MFM_Approver__c);
                                    Boolean isexist=false;
                                    if(rd.ASI_MFM_Region__c != null){
                                        for(String regions:region){
                                            
                                            if(regions==rd.ASI_MFM_Region__c){
                                                isexist=true;
                                                
                                            }// Find the Approver in  ASI MFM Route Types
                                        }
                                        if(isexist==true){
                                            if(approverids.contains(rd.ASI_MFM_Approver__c) != true)
                                            {
                                                approverlist.add(rd.ASI_MFM_Approver__c); // add to the list 
                                                approverids.add(rd.ASI_MFM_Approver__c);
                                            }
                                        }
                                        approver_count++;
                                    }
                                }else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                    break;
                                }
                            }
                            for (Integer i = approver_count;i<tempapproverlist.size();i++){
                                approverlist.add(tempapproverlist[i]);
                            }
                            p.ASI_MFM_Approver_1__c=null; // remove the data 
                            p.ASI_MFM_Approver_2__c=null;
                            p.ASI_MFM_Approver_3__c=null;
                            p.ASI_MFM_Approver_4__c=null;
                            p.ASI_MFM_Approver_5__c=null;
                            p.ASI_MFM_Approver_6__c=null;
                            p.ASI_MFM_Approver_7__c=null;
                            p.ASI_MFM_Approver_8__c=null;
                            p.ASI_MFM_Approver_9__c=null;
                            p.ASI_MFM_Approver_10__c=null;
                            
                            integer Countnum=0;
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_1__c=approverlist[0]; // resave the Approver
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_2__c=approverlist[1];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_3__c=approverlist[2];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_4__c=approverlist[3];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_5__c=approverlist[4];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_6__c=approverlist[5];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_7__c=approverlist[6];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_8__c=approverlist[7];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Approver_9__c=approverlist[8];
                                Countnum++;
                            }
                        }        
                        //End Logic
                        
                        if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                            if(p.ASI_MFM_Approver_1__c == p.OwnerID && OwnerMap.containskey(p.OwnerID) ){
                                p.ASI_MFM_Approver_1__c =OwnerMap.get(p.OwnerID).managerId;
                            }
                            if(p.ASI_MFM_Approver_2__c == p.OwnerID && OwnerMap.containskey(p.OwnerID) ){
                                p.ASI_MFM_Approver_2__c =OwnerMap.get(p.OwnerID).managerId;
                            } 
                            if(p.ASI_MFM_Approver_3__c == p.OwnerID && OwnerMap.containskey(p.OwnerID) ){
                                p.ASI_MFM_Approver_3__c=OwnerMap.get(p.OwnerID).managerId;
                            }
                            if(p.ASI_MFM_Approver_1__c ==p.ASI_MFM_Approver_2__c){
                                p.ASI_MFM_Approver_2__c = null;
                            }
                            if(p.ASI_MFM_Approver_2__c ==p.ASI_MFM_Approver_3__c){
                                p.ASI_MFM_Approver_3__c = null;
                            }
                            
                            if(p.ASI_MFM_Approver_1__c == null && p.ASI_MFM_Approver_2__c == null && p.ASI_MFM_Approver_3__c == null && p.ASI_MFM_Approver_4__c == null && OwnerMap.containskey(p.OwnerID) ){
                                p.ASI_MFM_Approver_1__c =OwnerMap.get(p.OwnerID).managerId;
                            }
                        }
                        
                    }
                    
                    
                }
                else if(pid_set.contains(p.id) && SPID.contains(p.id)){// Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment
                    ASI_MFM_Fix_Approval_Route__c fixApprover = MAppRouteFixCN.get(p.ASI_MFM_Budget_Owner_Team__c);
                    if(fixApprover != null){
                        if(approver_count == 0){
                            p.ASI_MFM_Approver_1__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 1){
                            p.ASI_MFM_Approver_2__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 2){
                            p.ASI_MFM_Approver_3__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 3){
                            p.ASI_MFM_Approver_4__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 4){
                            p.ASI_MFM_Approver_5__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 5){
                            p.ASI_MFM_Approver_6__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 6){
                            p.ASI_MFM_Approver_7__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 7){
                            p.ASI_MFM_Approver_8__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 8){
                            p.ASI_MFM_Approver_9__c = fixApprover.ASI_MFM_BA__c;
                        }
                        else if(approver_count == 9){
                            p.ASI_MFM_Approver_10__c = fixApprover.ASI_MFM_BA__c;
                        }                                                                                     
                    }
                }               
            }               
        }
        
        // The related PO must be in Complete status before a plan can be set to Complete status
        pid_set.clear();
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (p.ASI_MFM_Status__c == 'Complete' && p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c) {
                pid_set.add(p.id);
            }
        }
        if (pid_set.size() > 0) {
            map<id, ASI_MFM_Plan__c> p_map = new map<id, ASI_MFM_Plan__c>([select (select id from POs__r where ASI_MFM_Status__c != 'Complete') from ASI_MFM_Plan__c where id in :pid_set]);
            for (ASI_MFM_Plan__c p:trigger_new) {
                if (p_map.containsKey(p.id) && p_map.get(p.id).POs__r.size() > 0) {
                    
                    p.addError('You can NOT complete the Plan before you complete all the underlying POs');
                }
            }
        }
        
        // Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Plan__c> reject_map = new map<id, ASI_MFM_Plan__c>();
        for (ASI_MFM_Plan__c p:trigger_new) { 
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
            }
        }
        if (reject_map.size() > 0) {
            list<ASI_MFM_Plan__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_Plan__c where id in :reject_map.keySet()];
            for (ASI_MFM_Plan__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
    } 
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        // The prefix must be for plan
        // The prefix must be valid for the owner
        // Start date and end date must be within the fiscal year
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_Plan__c> plan_list = new list<ASI_MFM_Plan__c>();
        // Changed by KF Leung (Introv) 2014-04-26, Retrieve RecordTypeId from Global Cache
        //Map<String,id> MRecType = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        Long time2 = DateTime.now().getTime();
        Long time3;
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c')){
            time3 = DateTime.now().getTime();
            MRecType.put(rec.developername,rec.id);
        }
        // end of Changes
        String CNRecType = MRecType.get('ASI_MFM_CN_Plan');
        String CNRecTypeRO = MRecType.get('ASI_MFM_CN_Plan_Read_Only');//20161114 Elufa
        String TRRecType = MRecType.get('ASI_MFM_TR_Plan');
        Set<Id> teamSet = new Set<Id>();//20161114 Elufa
        List<ASI_MFM_Plan__c> CNPlanList = new List<ASI_MFM_Plan__c>();//20161115 Elufa 
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
        list<ASI_MFM_Exchange_Rate__c> xr_list =new list<ASI_MFM_Exchange_Rate__c>();
        // For PH Use Only
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
            for (ASI_MFM_Plan__c p:trigger_new) {
                ccy_set.add(p.ASI_MFM_Currency__c);
                last_effective_date=p.ASI_MFM_Start_Date__c;
            }
            
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            
            
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_PH_DF')){
                country = 'SG';
            }
            
            
            
            xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                       where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :trigger_new[0].ASI_MFM_Sys_Local_Currency__c and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                       order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
        }
        
        
        for (ASI_MFM_Plan__c p:trigger_new) {
            if(p.ASI_MFM_Currency__c != null && p.ASI_MFM_Exchange_Rate__c==null && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH')){
                if(p.ASI_MFM_Currency__c!=p.ASI_MFM_Sys_Local_Currency__c && !xr_list.isEmpty()){
                    for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                        p.ASI_MFM_Exchange_Rate__c=xr.ASI_MFM_Exchange_Rate__c;
                    }
                }else{
                    p.ASI_MFM_Exchange_Rate__c=1;
                }
            }
            
            if(p.ASI_MFM_Currency__c != null && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH')){
                if(p.ASI_MFM_Currency__c==p.ASI_MFM_Sys_Local_Currency__c) p.ASI_MFM_Exchange_Rate__c=1;
            }
            
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                plan_list.add(p);
            }
            //20161114 Elufa
            if((p.recordtypeid == CNRecType || p.recordtypeid == CNRecTypeRO)){
                
                if(p.ASI_MFM_Project_Team__c != Null)
                    teamSet.add(p.ASI_MFM_Project_Team__c);
                
                CNPlanList.add(p);
            }
            //20161114 End
            
            if (p.recordtypeid == CNRecType && p.ASI_MFM_Fiscal_year__c != null) {
                string fiscal_year = '20' + p.ASI_MFM_Fiscal_year__c.substring(2, 4);
                
                if (fiscal_year.isNumeric()) {
                    date fiscal_start_date = date.newInstance(integer.valueOf(fiscal_year), 7, 1);
                    date fiscal_end_date = date.newInstance(integer.valueOf(fiscal_year) + 1, 6, 30);
                    p.ASI_MFM_Start_Date__c = fiscal_start_date;
                    p.ASI_MFM_End_Date__c = fiscal_end_date;       
                }
            }
        }
        
        //20161114 Elufa
        Map<Id, Set<Id>> mapTeamMember = new Map<Id, Set<Id>>();//20161114 Elufa
        if(teamSet.size() > 0){
            for(ASI_MFM_Team_Member__c obj : [SELECT id, ASI_MFM_Team__c, ASI_MFM_Team_Member__c FROM ASI_MFM_Team_Member__c WHERE ASI_MFM_Team__c IN : teamSet]){
                
                Set<Id> tmpSet = new Set<Id>();
                
                if(mapTeamMember.containsKey(obj.ASI_MFM_Team__c)){
                    tmpSet = mapTeamMember.get(obj.ASI_MFM_Team__c);
                }
                
                tmpSet.add(obj.ASI_MFM_Team_Member__c);
                
                mapTeamMember.put(obj.ASI_MFM_Team__c, tmpSet);
            }
        }
        
        for(ASI_MFM_Plan__c cnp : CNPlanList){
            
            user PlanOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cnp.OwnerId);
            user PlanBudgetOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(cnp.ASI_MFM_Budget_Owner__c);
            UserRole currentUserRole = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUserRole(userInfo.getUserId());
            
            if(PlanOwner != NULL && PlanBudgetOwner != NULL && PlanOwner.ASI_MFM_Team__c != PlanBudgetOwner.ASI_MFM_Team__c 
               && PlanOwner.ASI_MFM_Team__c != 'Finance'
               && currentUserRole != NULL && currentUserRole.DeveloperName != 'ASI_FOC_Financial_Controller' && currentUserRole.DeveloperName != 'ASI_FOC_IT_Applier' ){
                   
                   if(mapTeamMember.containsKey(cnp.ASI_MFM_Project_Team__c)){
                       if(!mapTeamMember.get(cnp.ASI_MFM_Project_Team__c).contains(cnp.OwnerId) || !mapTeamMember.get(cnp.ASI_MFM_Project_Team__c).contains(cnp.ASI_MFM_Budget_Owner__c)){
                           cnp.ASI_MFM_Budget_Owner__c.addError('You are NOT allowed to created plan for budget owner not in your team');
                           Break;
                       }
                   }else{
                       cnp.ASI_MFM_Budget_Owner__c.addError('You are NOT allowed to created plan for budget owner not in your team');
                       Break;
                   }
               }
        }
        
        //20161114 End
        
        
        if (plan_list.size() > 0 && !Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_KR')) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select Plan_Type__c, (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                                                                                    from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Plan']);
            for (ASI_MFM_Plan__c p:plan_list) {
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for plan' + p.ASI_MFM_Prefix__c);
                }
                else {
                    string owner_role = owner_map.get(p.ownerId).userRole.DeveloperName;
                    boolean valid_prefix = false;               
                    for (ASI_MFM_Role_Prefix_Relationship__c pr:prefix_map.get(p.ASI_MFM_Prefix__c).ASI_MFM_Role_Prefix_Relationships__r) {
                        if (pr.ASI_MFM_Role_Name__c == owner_role) {
                            valid_prefix = true;
                            break;
                        }
                    }
                    if (!valid_prefix && !Global_RecordTypeCache.getRt(p.RecordTypeId).developerName.contains('ASI_CRM_CN_TP')) {
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                    }
                }
            }
        }       
    }   
    
    private static void setOwnerLink(ASI_MFM_Plan__c p) {
        p.ASI_MFM_Owner_Link__c = p.ownerId;
    } 
}