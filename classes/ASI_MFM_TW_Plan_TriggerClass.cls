public without sharing class ASI_MFM_TW_Plan_TriggerClass {    

    public static void routineBeforeDelete (list<ASI_MFM_Plan__c> trigger_old) {
        // Not allowed to delete final plan
        Set<id> pid_set = new Set<id>();
        
        for (ASI_MFM_Plan__c plan : trigger_old){
            //Added by Twinkle (Introv) @20170116 for TW CRM3 - Not allow to delete Submitted Plan
            if(Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_TW')){
                if (plan.ASI_MFM_Status__c == 'Submitted')
                    plan.addError('Not allowed to delete Plan in \'Submitted\' status'); 
                if (plan.ASI_MFM_Status__c == 'Cancel')
                    plan.addError('Not allowed to delete Plan in \'Cancel\' status');  
                if (plan.ASI_MFM_Status__c == 'Final'|| plan.ASI_MFM_Status__c == 'Complete'){
                    plan.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
                }  
            }                                                       
        }
        
        map<id, ASI_MFM_Plan__c> p_map = new map<id, ASI_MFM_Plan__c>([select (select id from POs__r) from ASI_MFM_Plan__c where id in :pid_set]);
        for (ASI_MFM_Plan__c p:trigger_old) {
            if (p_map.containsKey(p.id) && p_map.get(p.id).POs__r.size() > 0) {
                system.debug('PO count: ' + p_map.get(p.id).POs__r.size());
                p.addError('Not allowed to delete because the plan is contain PO');
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

    public static void routineAfterUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        Set<Id> setPlanToUpdatePAFStatus = new Set<Id>(); //Added by Twinkle (Introv) @20170113 for TW CRM3
        List<ASI_HK_CRM_Pre_Approval_Form__c> listPAFtoUpdate = new List<ASI_HK_CRM_Pre_Approval_Form__c>(); //Added by Twinkle (Introv) @20170113 for TW CRM3
        Map<Id, ASI_MFM_Plan__c> mapPlan = new Map<Id, ASI_MFM_Plan__c>(); //Added by Twinkle (Introv) @20170113 for TW CRM3
        
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c')){
            MRecType.put(rec.developername,rec.id);
        }
        // Added by Alan Wong (Elufa) 25Feb2015
        // Mass submit for approval SG/TH
        for(ASI_MFM_Plan__c plan : trigger_new){
            //Added by Twinkle (Introv) @20170113 for TW CRM3 - Copy Plan Status to PAF if Plan Status is Complete OR Complete -> Draft/Final
            if(Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_TW')){
                if(plan.ASI_MFM_Status__c == 'Complete'||
                   plan.ASI_MFM_Status__c == 'Cancel'||
                   (trigger_oldMap.get(plan.Id).ASI_MFM_Status__c == 'Complete' && (plan.ASI_MFM_Status__c == 'Draft' || plan.ASI_MFM_Status__c == 'Final'))){
                    mapPlan.put(plan.Id, plan);
                    setPlanToUpdatePAFStatus.add(plan.Id);                
                }
            }
        }
        
        //Added by Twinkle (Introv) @20170113 for TW CRM3 - Copy Plan Status to PAF if Plan Status is Complete OR Complete -> Draft/Final
        listPAFtoUpdate = [SELECT Id, ASI_CRM_Commitment_No__c, ASI_HK_CRM_PAF_Status__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_CRM_Commitment_No__c IN: setPlanToUpdatePAFStatus];
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : listPAFtoUpdate){
            paf.ASI_HK_CRM_PAF_Status__c = mapPlan.get(paf.ASI_CRM_Commitment_No__c).ASI_MFM_Status__c;
        }
        system.debug('PAF To Update :'+listPAFtoUpdate);
        
        update listPAFtoUpdate;
        
      //  System.debug(LoggingLevel.ERROR, 'Start Time: ' + DateTime.now().getTime(););
    }

    public static void routineBeforeInsert(list<ASI_MFM_Plan__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Plan__c plan:trigger_new) {
            setOwnerLink(plan);
            if (plan.asi_mfm_prefix__c != null) {
                px_set.add(plan.asi_mfm_prefix__c);
            }
            
            plan.ASI_MFM_TW_Actual_Amount_AnD__c=0;
            plan.ASI_MFM_TW_Actual_Amount_AnP__c=0;
            plan.ASI_CRM_TW_FOC_Amount_A_D__c=0;
            plan.ASI_CRM_FOC_Amount_w_o_A_D__c=0;
            plan.ASI_MFM_TW_TnE_A_D_Amount__c=0;
            plan.ASI_MFM_TnE_Non_A_D_Amount__c=0;
            plan.ASI_MFM_TnE_Amount__c=0;
            plan.ASI_MFM_Total_Draft_PO_Amount__c=0;
            plan.ASI_MFM_TW_Total_Draft_PO_Amount_AnD__c=0;
            plan.ASI_MFM_TW_Total_Draft_PO_Amount_AnP__c=0;
            plan.ASI_MFM_Total_PO_Amount__c=0;
            plan.ASI_MFM_TW_PO_AD_Amount__c=0;
            plan.ASI_MFM_TW_PO_AP_Amount__c=0;
            plan.ASI_MFM_Total_without_PO_Actual_Amount__c=0;
            plan.ASI_MFM_TW_Actual_without_PO_AnD__c=0;
            plan.ASI_MFM_TW_Actual_without_PO_AnP__c=0;
            plan.ASI_MFM_TW_Payment_AD_Amount__c=0;
            plan.ASI_MFM_TW_Payment_AP_Amount__c=0;
            plan.ASI_CRM_Total_FOC_Amount__c=0;
            plan.ASI_MFM_Total_PO_Amount__c=0;
            plan.ASI_MFM_Total_Draft_PO_Amount__c=0;
            plan.ASI_MFM_Actual_Amount__c=0;
        }
        
// Set the plan ID for new plan 
// set fiscal year  
// Set plan type    
// Update by Steve Wan(Introv) 28 Apr 2014 to add FY for plan with tr record type prefix       
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c, ASI_MFM_Fiscal_year__c, Plan_Type__c, recordtypeid,ASI_MFM_TR_Rec_Type__c, 
                                                                            ASI_MFM_Location__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'Plan' and id in :px_set for update]);
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Prefix__c')){
            MRecType.put(rec.developername,rec.id);
        }
                      
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {               
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                if (p.ASI_MFM_Fiscal_year__c == null) {
                    p.ASI_MFM_Fiscal_year__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Fiscal_year__c;
                }   
                p.ASI_MFM_Sys_Plan_Type__c = px_map.get(p.asi_mfm_prefix__c).Plan_Type__c;
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values()); 
                
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        // Set the owner link     System.debug('ASI_MFM_Plan_TriggerClass:routineBeforeUpdate: start()');
        // Set the approvers for the plan based on the routing rule objects                         System.debug('Number of Queries used in this Apex code so far: ' + Limits.getQueries());
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        
        set<id> setPid_TW = new set<id>(); // Added by Twinkle (Introv) @20161219
        
        set<string> STeam = new set<string>();
        // Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment       
        Set<id> SPID = new Set<id>();
        for (ASI_MFM_Plan__c p:trigger_new) {
            setOwnerLink(p);
            
            //Added by Twinkle (Introv) @20161205 for TW CRM3 - Not allow to edit specific fields of PAF Convert Plan
            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW')){
                setPid_TW.add(p.id);
            }
        }
        
        //Added by Twinkle (Introv) @20161219 for TW CRM3
        if (setPid_TW.size() > 0) { 
            Map<Id, ASI_HK_CRM_Pre_Approval_Form__c> mapPafByPlan = new Map<Id, ASI_HK_CRM_Pre_Approval_Form__c>();
            Boolean isAdmin = false;
            
            //get current user permission sets
            List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment
                                               WHERE AssigneeId = :Userinfo.getUserId()];
            
            for(PermissionSetAssignment permission : listCurrentUserPerSet){
                //Updated by Introv @20170725; Added 'ASI_CRM_TW_Finance_BA_Users' condition.
                if(permission.PermissionSet.Name == 'ASI_CRM_TW_IT_Admin' || permission.PermissionSet.Name=='ASI_CRM_TW_Finance_BA_Users')
                    isAdmin = true;
            }
                                               
            for(ASI_HK_CRM_Pre_Approval_Form__c paf : [SELECT Id, ASI_CRM_Commitment_No__c, ASI_CRM_Customer__c, ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_CRM_Commitment_No__c IN: setPid_TW]){
                mapPafByPlan.put(paf.ASI_CRM_Commitment_No__c, paf);
            }
            
            for(ASI_MFM_Plan__c plan : trigger_new){
                if(Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_TW')){
                    if(!isAdmin){
                        //Cancelled Plan cannot be updated 
                        if(trigger_oldMap.get(plan.Id).ASI_MFM_Status__c == 'Cancel')
                            plan.addError('\'Cancel\' Plan cannot be updated anymore.');
                        
                        //Only IT Admin can update Plan Status, Final->Draft / Complete->Final / Complete->Draft, 
                        if(trigger_oldMap.get(plan.Id).ASI_MFM_Status__c != plan.ASI_MFM_Status__c && plan.ASI_MFM_Status__c != 'Cancel'){
                            
                            if(trigger_oldMap.get(plan.Id).ASI_MFM_Status__c == 'Final' && plan.ASI_MFM_Status__c == 'Draft')
                                plan.addError('You are not allowed to update status from \'Final\' to \'Draft\'.');
                            else if(trigger_oldMap.get(plan.Id).ASI_MFM_Status__c == 'Complete')
                                plan.addError('You are not allowed to update status of \'Complete\' Plan.');
                        }
                    }
                    
                    //Not allow to edit specific fields of PAF Convert Plan
                    if(plan.ASI_CRM_Converted_Date__c != null){
                        if(trigger_oldMap.get(plan.id).ASI_MFM_Account__c != plan.ASI_MFM_Account__c && mapPafByPlan.get(plan.id).ASI_CRM_Customer__c != plan.ASI_MFM_Account__c){
                            plan.addError('Cannot change \'Account\' of converted Plan.');
                        }
                        if(trigger_oldMap.get(plan.id).ASI_MFM_Start_Date__c != plan.ASI_MFM_Start_Date__c && mapPafByPlan.get(plan.id).ASI_HK_CRM_PAF_Start_Date__c != plan.ASI_MFM_Start_Date__c){
                            plan.addError('Cannot change \'Start Date\' of converted Plan.');
                        }
                        if(trigger_oldMap.get(plan.id).ASI_MFM_End_Date__c != plan.ASI_MFM_End_Date__c && mapPafByPlan.get(plan.id).ASI_HK_CRM_PAF_End_Date__c != plan.ASI_MFM_End_Date__c){
                            plan.addError('Cannot change \'End Date\' of converted Plan.');
                        }
                        if(trigger_oldMap.get(plan.id).ASI_MFM_Plan_Raised_Date__c != plan.ASI_MFM_Plan_Raised_Date__c){
                            plan.addError('Cannot change \'Plan Raised Date\' of converted Plan.');
                        }
                        if(trigger_oldMap.get(plan.id).Owner != plan.Owner){
                            plan.addError('Cannot change \'Owner\' of converted Plan.');
                        }
                    } 
                    
                    // Added by 2018-08-09 Linus@Introv
                    // Set Complete Date when status is "Complete"                    
                    if(trigger_oldMap.get(plan.Id).ASI_MFM_Status__c != plan.ASI_MFM_Status__c && plan.ASI_MFM_Status__c == 'Complete'){
                        plan.ASI_MFM_Complete_Date__c = system.today();
                    }
                    // END - Linus
                                        
                }
            }
        }
        
        

        // The related PO must be in Complete status before a plan can be set to Complete status
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (p.ASI_MFM_Status__c == 'Complete' && p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c) {
                pid_set.add(p.id);
            }
        }
        if (pid_set.size() > 0) {
            map<id, ASI_MFM_Plan__c> p_map = new map<id, ASI_MFM_Plan__c>([select (select id from POs__r where ASI_MFM_Status__c != 'Complete') from ASI_MFM_Plan__c where id in :pid_set]);
            for (ASI_MFM_Plan__c p:trigger_new) {
                if (p_map.containsKey(p.id) && p_map.get(p.id).POs__r.size() > 0) {
                    system.debug('PO count: ' + p_map.get(p.id).POs__r.size());
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
            System.debug(LoggingLevel.ERROR, 'Loop Time: '+(time3-time2)+'ms');
        }
        // end of Changes
                
          
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
         list<ASI_MFM_Exchange_Rate__c> xr_list =new list<ASI_MFM_Exchange_Rate__c>();
        
        
        
        for (ASI_MFM_Plan__c p:trigger_new) {
            
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                plan_list.add(p);
            }
            System.debug(p.ASI_MFM_Fiscal_year__c);
            System.debug(p.recordtypeid);

            
        }
        
        if (plan_list.size() > 0 ) {
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
                    if (!valid_prefix) {
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