/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | Plan Trigger Class                                                                       
|     - Description     |                            
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 11/5/2015 11:09 AM                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/

public class ASI_MFM_KR_Plan_TriggerClass{
    private static void setOwnerLink(ASI_MFM_Plan__c p) {
        p.ASI_MFM_Owner_Link__c = p.ownerId;
    }
    
    public static void routineBeforeInsert(list<ASI_MFM_Plan__c> trigger_new) {
        
        set<id> px_set = new set<id>();
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (p.ASI_MFM_cloned_plan_id__c != null) {
                p.ASI_MFM_Original_Plan_No__c=p.ASI_MFM_cloned_plan_id__c;
            }
            if(p.ASI_MFM_Plan_External_ID_Upload__c!=null){
                if(p.ASI_MFM_Plan_External_ID_Upload__c.contains('Do No change 1')){
                    p.ASI_MFM_KR_Included_Initial_Plan_Amount__c=true;
                }else p.ASI_MFM_KR_Included_Initial_Plan_Amount__c = false;
            }
            setOwnerLink(p);
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        
        
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c, ASI_MFM_Fiscal_year__c, Plan_Type__c, recordtypeid,ASI_MFM_TR_Rec_Type__c, 
                                                                            ASI_MFM_Location__c from asi_mfm_prefix__c 
                                                                            where asi_mfm_module__c = 'Plan' and id in :px_set for update]);
        
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Prefix__c')){
            MRecType.put(rec.developername,rec.id);
        }
        
        String KRRecTypeID = MRecType.get('ASI_MFM_KR_Prefix');
        
        boolean SGChangeCurrency =false;
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_SG_Plan')){
            SGChangeCurrency=ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_SG_ChangeLAMMCurrency','SG');
            
        }
        
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                if(px_map.get(p.asi_mfm_prefix__c).recordtypeid == KRRecTypeID ){
                    p.name = px_map.get(p.asi_mfm_prefix__c).name +  string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    P.ASI_MFM_Promotion_Code__c=p.name;
                }
                else{
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                }
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                if (p.ASI_MFM_Fiscal_year__c == null) {
                    p.ASI_MFM_Fiscal_year__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Fiscal_year__c;
                }
               
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());        
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
        
        // Set cloned plan ID to the new plan ID and Set the status to Draft for cloned plan       
        if (pid_set.size() > 0) {
            list<ASI_MFM_plan__c> plan_list = [select ASI_MFM_cloned_plan_id__c from ASI_MFM_plan__c where id in :pid_set for update];
            for (ASI_MFM_plan__c p:plan_list) {
                if (p.ASI_MFM_cloned_plan_id__c != null) {
                    p.ASI_MFM_Status__c = 'Draft';
                  // p.ASI_MFM_Original_Plan_No__c=p.ASI_MFM_cloned_plan_id__c;
                }else{
                    p.ASI_MFM_cloned_plan_id__c = p.id;
                }
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
                    pi.ASI_MFM_Actual_Spending_Amount__c=0;
                    pi.ASI_MFM_Plan_Line_Item_External_IDUpload__c = null; 
                    pi.ASI_MFM_Plan_Line_Item_External_ID__c = null;
                    pi_list.add(pi);
                }
            }
            insert pi_list;
        }       
    } 
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap){
        boolean IsDraft=false;
        Set<Id> planId = new Set<Id>(); //store current header(s) Id 
        
        Set<Id> InitialPlanId = new Set<Id>(); 
        Map<Id, Id> ReCalInitialPlanMap = new Map<Id, Id>();
        
        for(ASI_MFM_Plan__c plan: trigger_new){
            planId.add(plan.Id);
            if(plan.ASI_MFM_Status__c=='Draft' || plan.ASI_MFM_Status__c=='Submitted'){
                IsDraft=true;
            }
            
            if(plan.ASI_MFM_KR_Included_Initial_Plan_Amount__c &&  plan.ASI_MFM_Cloned_Plan_ID__c!=null){
                InitialPlanId.add(plan.ASI_MFM_Cloned_Plan_ID__c);
                ReCalInitialPlanMap.put(plan.Id,plan.ASI_MFM_Cloned_Plan_ID__c );
            }
            
            if(!trigger_oldMap.get(plan.Id).ASI_MFM_KR_Included_Initial_Plan_Amount__c && plan.ASI_MFM_KR_Included_Initial_Plan_Amount__c &&  plan.ASI_MFM_Cloned_Plan_ID__c!=null ){//avoid users changed the included inital plan amount from false to true
                 ReCalInitialPlanMap.put(plan.Id,plan.ASI_MFM_Cloned_Plan_ID__c );
              }
        
            
        }
        
        if(IsDraft){
            Map<Id,Decimal> ParentPlanMap = new Map<Id,Decimal>();
            if(InitialPlanId.size()>0){
                List<ASI_MFM_Plan__c> RelatedPlanList= [select Id,ASI_MFM_Cloned_Plan_ID__c,ASI_MFM_Plan_Amount__c,
                                                        ASI_MFM_KR_Included_Initial_Plan_Amount__c FROM ASI_MFM_Plan__c 
                                                        WHERE RecordType.DeveloperName LIKE :'ASI_MFM_KR%' 
                                                        AND (
                                                        ( ASI_MFM_Cloned_Plan_ID__c IN : InitialPlanId 
                                                        AND ASI_MFM_KR_Included_Initial_Plan_Amount__c = true)
                                                        OR
                                                        Id  IN : InitialPlanId)  AND Id NOT IN: ReCalInitialPlanMap.keyset()
                                                        AND ASI_MFM_Status__c!='Rejected' AND ASI_MFM_Plan_Amount__c !=NULL ];
                 
                for(ASI_MFM_Plan__c Plan:RelatedPlanList){

                    if(Plan.ASI_MFM_KR_Included_Initial_Plan_Amount__c ||  InitialPlanId.contains(Plan.Id) ){
                        
                        Id relatedId = InitialPlanId.contains(Plan.Id)?Plan.Id: Plan.ASI_MFM_Cloned_Plan_ID__c;
                        
                        if(!ParentPlanMap.containsKey(relatedId)){
                            ParentPlanMap.put(relatedId, Plan.ASI_MFM_Plan_Amount__c);
                        }else{
                            decimal  PlanAmount=0.0;
                            PlanAmount=Plan.ASI_MFM_Plan_Amount__c+ParentPlanMap.get(relatedId);
                            ParentPlanMap.remove(relatedId);
                            ParentPlanMap.put(relatedId, PlanAmount);
                        }
                    }
                    
                   
                } 
                
            }
            
            
            
            Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, Name, ManagerID, UserRole.Id, UserRole.DeveloperName,ASI_MFM_Team__c FROM User WHERE ASI_MFM_Country__c = 'KR' ]); //get all Korea User
            //Fix Approval Route
            Map<String,ASI_MFM_Fix_Approval_Route__c> FARMap  =new Map<String,ASI_MFM_Fix_Approval_Route__c>();
            List<ASI_MFM_Fix_Approval_Route__c> FARList = new List<ASI_MFM_Fix_Approval_Route__c>([SELECT Id,ASI_MFM_Module__c, ASI_MFM_KR_Sub_Category__c,ASI_MFM_Team__c,ASI_MFM_Need_Brand_Marketing__c,  ASI_MFM_KR_Grand_Category__c,ASI_MFM_BA__c, ASI_MFM_Approval_Limit_BA__c, ASI_MFM_Approval_Limit_CA1__c,ASI_MFM_Approval_Limit_CA2__c,ASI_MFM_Approval_Limit_CA3__c, ASI_MFM_Approval_Limit_CA4__c,ASI_MFM_Approval_Limit_CA5__c,ASI_MFM_Approval_Limit_CA6__c,ASI_MFM_Approval_Limit_CA7__c,ASI_MFM_Approval_Limit_CA8__c,ASI_MFM_Approval_Limit_CA9__c,ASI_MFM_Approval_Limit_CA10__c,ASI_MFM_Approval_Limit_CA11__c,ASI_MFM_Approval_Limit_CA12__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c,ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Corporate_Approver_4__c,ASI_MFM_Corporate_Approver_5__c,ASI_MFM_Corporate_Approver_6__c,ASI_MFM_Corporate_Approver_7__c,ASI_MFM_Corporate_Approver_8__c,ASI_MFM_Corporate_Approver_9__c,ASI_MFM_Corporate_Approver_10__c,ASI_MFM_Corporate_Approver_11__c,ASI_MFM_Corporate_Approver_12__c  FROM ASI_MFM_Fix_Approval_Route__c WHERE RecordType.DeveloperName LIKE 'ASI_MFM_KR_Fix_Approval_Route' AND ASI_MFM_Module__c LIKE 'Plan' AND ASI_MFM_Inactive__c = false ]);
            for(ASI_MFM_Fix_Approval_Route__c FAR: FARList){
                FARMap.put(FAR.ASI_MFM_Team__c, FAR);//
            }//end for: loop approval route list
            
            //  Modified by 2018-02-28 Linus@introv
            // Dynamic Approval Route
            Map<String,ASI_MFM_Dynamic_Approval_Route__c> DARMap  =new Map<String,ASI_MFM_Dynamic_Approval_Route__c>();
            /*List<ASI_MFM_Dynamic_Approval_Route__c> DARList   = new List<ASI_MFM_Dynamic_Approval_Route__c>([SELECT id,ASI_MFM_Type__c,  ASI_MFM_User__c, ASI_MFM_Approval_Limit__c,ASI_MFM_End_of_1st_Route__c FROM ASI_MFM_Dynamic_Approval_Route__c WHERE RecordType.DeveloperName LIKE 'ASI_MFM_KR_Dynamic_Approval_Route'  AND ASI_MFM_Type__c LIKE 'Plan' and ASI_MFM_Inactive__c=false ]);
            for(ASI_MFM_Dynamic_Approval_Route__c DAR: DARList){
                DARMap.put(DAR.ASI_MFM_User__c, DAR);
            }*/
            
            List<ASI_MFM_Plan_Line_Item__c> planLine  = new List<ASI_MFM_Plan_Line_Item__c>([SELECT Id, ASI_MFM_Plan__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Manager__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Marketing_Leader__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Code__c FROM ASI_MFM_Plan_Line_Item__c WHERE RecordType.DeveloperName LIKE: 'ASI_MFM_KR_Plan_Line_Item' AND ASI_MFM_Plan__c IN: planId]);                                               
            Map<String,ASI_MFM_Plan_Line_Item__c> planLineMap  =new Map<String,ASI_MFM_Plan_Line_Item__c>();
            
            for(ASI_MFM_Plan_Line_Item__c line: planLine){ //put planLine into planLineMap
                if(!planLineMap.containsKey(line.ASI_MFM_Plan__c)  && line.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Manager__c!=null){
                    planLineMap.put(line.ASI_MFM_Plan__c,line);
                }//Map<plan id, plan line>
            }//end for: loop plan line list
            
            for(ASI_MFM_Plan__c plan: trigger_new){
                
                if(plan.ASI_MFM_KR_Included_Initial_Plan_Amount__c && plan.ASI_MFM_Cloned_Plan_ID__c!=null && ParentPlanMap.containsKey(plan.ASI_MFM_Cloned_Plan_ID__c)){
                    plan.ASI_MFM_Total_FI_Amount__c=ParentPlanMap.get(plan.ASI_MFM_Cloned_Plan_ID__c)+Plan.ASI_MFM_Plan_Amount__c;
                }else{
                    plan.ASI_MFM_Total_FI_Amount__c=Plan.ASI_MFM_Plan_Amount__c;
                }
                
                if(plan.ASI_MFM_Status__c=='Draft' || plan.ASI_MFM_Status__c=='Submitted'){
                    setApprover(plan,planLineMap,mapUser,FARMap,DARMap);
                }
            } 
            
        }
    }
    
    
    
    
    
    private static void setApprover(ASI_MFM_Plan__c plan,map<String,ASI_MFM_Plan_Line_Item__c> planLineMap,Map<ID, User> mapUser,Map<String, ASI_MFM_Fix_Approval_Route__c> FARMap, Map<String, ASI_MFM_Dynamic_Approval_Route__c> DARMap){
        ASI_MFM_Fix_Approval_Route__c CurrentFAR= new ASI_MFM_Fix_Approval_Route__c();
        if(mapUser.containsKey(plan.OwnerId)){
            if(mapUser.get(plan.OwnerId).ASI_MFM_Team__c!=null && FARMap.containsKey(mapUser.get(plan.OwnerId).ASI_MFM_Team__c)){
                setApproverToNull(plan); 
                CurrentFAR= FARMap.get(mapUser.get(plan.OwnerId).ASI_MFM_Team__c);
                boolean EndFindManager=false;
                integer CurrApproverNum=1;
                ID approverID = mapUser.get(plan.OwnerId).ManagerID;
                
                //Find BA user First  ASI_MFM_Approval_Limit_BA__c
                if(CurrentFAR.ASI_MFM_BA__c!=null){
                    
                    plan.put('ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c',CurrentFAR.ASI_MFM_BA__c);// system.debug('FindBAApprover Loop1: '+'ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c'+ CurrentFAR.ASI_MFM_BA__c );
                    CurrApproverNum++;
                }
                if(CurrentFAR.ASI_MFM_Approval_Limit_BA__c!=null && mapUser.containsKey(CurrentFAR.ASI_MFM_BA__c) && mapUser.get(CurrentFAR.ASI_MFM_BA__c).ManagerID !=NULL && plan.ASI_MFM_Total_FI_Amount__c>  Double.valueOf(CurrentFAR.ASI_MFM_Approval_Limit_BA__c)){
                    plan.put('ASI_MFM_First_Approver_1__c',mapUser.get(CurrentFAR.ASI_MFM_BA__c).ManagerID);  //CurrApproverNum++;    ASI_MFM_First_Approver_1__c   //system.debug('FindBAApprover Loop2: '+'ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c'+ mapUser.get(CurrentFAR.ASI_MFM_BA__c).ManagerID );//plan.put('ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c',mapUser.get(CurrentFAR.ASI_MFM_BA__c).ManagerID);
                }
                
                if(plan.ASI_MFM_Total_FI_Amount__c==0.0 || plan.ASI_MFM_Total_FI_Amount__c==NULL){
                    EndFindManager=true;
                }
                // Modified by 2018-02-28 Linus@introv
                /*//Find normal approver
                for(integer i = 1 ; i <= 12 ; i++){ //20160822,edited by Leo, 9->12
                    string sysApprover = 'ASI_MFM_Approver_' + string.valueOf(CurrApproverNum)  + '__c';
                    string fixApprover = 'ASI_MFM_Corporate_Approver_'+ i +'__c';
                    string approvalLimit = 'ASI_MFM_Approval_Limit_CA' + i + '__c';
                    if(CurrentFAR.get(fixApprover)!=null   ){ // && EndFindManager==false
                        //compare amount get manager  system.debug(plan.ASI_MFM_Total_FI_Amount__c+'est get manager '+Double.valueOf(CurrentFAR.get(approvalLimit)));
                        if(CurrentFAR.get(approvalLimit)==NULL || (CurrentFAR.get(approvalLimit)!=NULL && plan.ASI_MFM_Total_FI_Amount__c>Double.valueOf(CurrentFAR.get(approvalLimit)))){//system.debug('FindFixApprover Loop: '+sysApprover+ CurrentFAR.get(fixApprover));
                            plan.put(sysApprover,CurrentFAR.get(fixApprover));//   
                            CurrApproverNum++;
                        }
                        EndFindManager=true;
                    }else{
                        if(CurrentFAR.ASI_MFM_Need_Brand_Marketing__c!=null && CurrentFAR.ASI_MFM_Need_Brand_Marketing__c==string.valueOf(i) && planLineMap.containsKey(plan.id) && planLineMap.get(plan.id).ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Marketing_Leader__c !=null ){  //(CurrentFAR.ASI_MFM_Need_Brand_Marketing__c==null || CurrentFAR.ASI_MFM_Need_Brand_Marketing__c!=null && CurrentFAR.ASI_MFM_Need_Brand_Marketing__c) &&
                            
                            CurrApproverNum=FindDynamicApprover(plan,planLineMap.get(plan.id).ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand_Marketing_Leader__c,mapUser,DARMap,CurrApproverNum);
                        }else if( approverID!=null && EndFindManager==false ){ //  && (CurrentFAR.ASI_MFM_Need_Brand_Marketing__c==null || (CurrentFAR.ASI_MFM_Need_Brand_Marketing__c!=null && CurrentFAR.ASI_MFM_Need_Brand_Marketing__c==string.valueOf(i) ) )
                            if(!DARMap.containsKey(plan.OwnerId) || (DARMap.containsKey(plan.OwnerId)&& !DARMap.get(plan.OwnerId).ASI_MFM_End_of_1st_Route__c)){
                                CurrApproverNum=FindDynamicApprover(plan,approverID,mapUser,DARMap,CurrApproverNum);
                            }
                            
                        }
                        
                    }
                }*/
                
            }
        }
    }
    
    /*   Modified by 2018-02-28 Linus@introv
    private static integer FindDynamicApprover(ASI_MFM_Plan__c plan,Id CurrentManagerId, Map<ID, User> mapUser, Map<String, ASI_MFM_Dynamic_Approval_Route__c> DARMap, integer CurrApproverNum){
        boolean proceed = true;
        id currentUserid = CurrentManagerId;
        while(proceed){
            if(DARMap.containsKey(currentUserid)){
                
                if(plan.ASI_MFM_Total_FI_Amount__c >DARMap.get(currentUserid).ASI_MFM_Approval_Limit__c){//system.debug('FindDynamicApprover Loop: '+'ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c'+ currentUserid);
                    plan.put('ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c',currentUserid);
                    CurrApproverNum++;
                    if(DARMap.get(currentUserid).ASI_MFM_End_of_1st_Route__c ){
                        proceed = false;
                    }
                    
                }else if(DARMap.get(currentUserid).ASI_MFM_End_of_1st_Route__c || !mapUser.containsKey(currentUserid) || (mapUser.containsKey(currentUserid) && mapUser.get(currentUserid).ManagerID==null) ){//contain user but manager is null
                    proceed = false;
                }
                
                if(mapUser.containsKey(currentUserid) && mapUser.get(currentUserid).ManagerID!=null){
                    currentUserid=mapUser.get(currentUserid).ManagerID;
                }
                
                
            }else{// system.debug('FindDynamicApprover Loop2: '+'ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c'+ currentUserid);
                plan.put('ASI_MFM_Approver_' + string.valueOf(CurrApproverNum) + '__c',currentUserid);
                CurrApproverNum++;
                if(mapUser.containsKey(currentUserid)){
                    currentUserid=mapUser.get(currentUserid).ManagerID;
                }
                
                if(!mapUser.containsKey(currentUserid) || (mapUser.containsKey(currentUserid) && mapUser.get(currentUserid).ManagerID==null)){
                    proceed = false;
                }
            }
            //
        }// end of while
        
        return CurrApproverNum;
    }*/
    
    public static void routineAfterUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
      
        
    }
    
    //clear sys approvers record
    public static void setApproverToNull(ASI_MFM_Plan__c plan)
    {
        String sysApprover;
        
        for(integer i = 1 ; i <=14 ; i++) //20160822,edited by Leo, 10->14
        {
            sysApprover = 'ASI_MFM_Approver_' + i + '__c';
            plan.put(sysApprover,null);
        }//end for
        plan.put('ASI_MFM_First_Approver_1__c',null);
    }//end method: setApproverToNull
    
    
}//end class: ASI_MFM_KR_Plan_TriggerClass