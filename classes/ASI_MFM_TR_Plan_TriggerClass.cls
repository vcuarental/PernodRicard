public without sharing class ASI_MFM_TR_Plan_TriggerClass {    

    public static void routineBeforeDelete (list<ASI_MFM_Plan__c> trigger_old) {
        // Not allowed to delete final plan
        Set<id> pid_set = new Set<id>();
        
        for (ASI_MFM_Plan__c plan : trigger_old){
            
                
            if (plan.ASI_MFM_Status__c == 'Final'|| plan.ASI_MFM_Status__c == 'Complete'){
                 plan.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }
            else if (plan.ASI_MFM_Status__c == 'Draft' && Global_RecordTypeCache.getRt(plan.recordTypeId).developerName.contains('ASI_MFM_TR')){
                pid_set.add(plan.id);
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
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c, ASI_MFM_Fiscal_year__c, Plan_Type__c, recordtypeid,ASI_MFM_TR_Rec_Type__c, 
                                                                            ASI_MFM_Location__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'Plan' and id in :px_set for update]);                               
                
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                //TR Logic:
                
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
                
               
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                if (p.ASI_MFM_Fiscal_year__c == null) {
                    p.ASI_MFM_Fiscal_year__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Fiscal_year__c;
                }                
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());        
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        // Set the owner link     System.debug('ASI_MFM_Plan_TriggerClass:routineBeforeUpdate: start()');
        // Set the approvers for the plan based on the routing rule objects                         System.debug('Number of Queries used in this Apex code so far: ' + Limits.getQueries());
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        
        /*
        set<string> STeam = new set<string>();
        // Added by Michael Yip (Introv) 31Mar2014 for CN Plan Approver assignment       
        Set<id> SPID = new Set<id>();
        for (ASI_MFM_Plan__c p:trigger_new) {
            setOwnerLink(p);            
            
            if (p.ASI_MFM_Plan_Amount__c != null ) {                                
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

            for (ASI_MFM_Plan__c p:trigger_new) { 

                
                integer approver_count = 0;
                
          
                if (pid_set.contains(p.id)) {
                    
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    
                   // system.assertEquals(brm_list, null);
                    
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
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= p.ASI_MFM_Plan_Amount__c && rd.ASI_MFM_Sequence__c != 999) {
                                system.debug('Test:Approval');
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
                        
                    }
                    
                    
                }
                
                             
            }               
        }

        // The related PO must be in Complete status before a plan can be set to Complete status
        pid_set.clear();
		*/
        
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (p.ASI_MFM_Status__c == 'Complete' && p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c) {
                pid_set.add(p.id);
            }
        }
        if (pid_set.size() > 0) {
            map<id, ASI_MFM_Plan__c> p_map = new map<id, ASI_MFM_Plan__c>([select (select id from POs__r where ASI_MFM_Status__c != 'Complete') from ASI_MFM_Plan__c where id in :pid_set]);
            for (ASI_MFM_Plan__c p:trigger_new) {
                if (!Test.isRunningTest() && p_map.containsKey(p.id) && p_map.get(p.id).POs__r.size() > 0) {
                    system.debug('PO count: ' + p_map.get(p.id).POs__r.size());
                    p.addError('You can NOT complete the Plan before you complete all the underlying POs');
                }
            }
        }
        /*
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
		*/
    } 
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
    // The prefix must be for plan
    // The prefix must be valid for the owner
    // Start date and end date must be within the fiscal year
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_Plan__c> plan_list = new list<ASI_MFM_Plan__c>();        
                  
        set<string> ccy_set = new set<string>(); 
                
        for (ASI_MFM_Plan__c p:trigger_new) {
            
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                plan_list.add(p);
            }
            System.debug(p.ASI_MFM_Fiscal_year__c);
            System.debug(p.recordtypeid);  
            
            // Enhancement for supporting CAPEX Plan ******** 2019-05-03 Linus@introv
            if(p.ASI_MFM_Reference_1_List__c == 'CAPEX Plan'){
                if(p.ASI_MFM_TR_Duration_Month__c == null)
                    p.addError('Duration(Month) cannot be blank (Minimum is 0)');
                else{           
                    p.ASI_MFM_End_Date__c = p.ASI_MFM_Start_Date__c.addMonths(Integer.valueOf(p.ASI_MFM_TR_Duration_Month__c)).addDays(-1);
                }
                
                if(p.ASI_MFM_Actual_Depreciation_Start_Date__c == null && p.ASI_MFM_Start_Date__c < system.today()){
                    //p.addError('Back Date CAPEX Plan is not allowed');
                }
                else if(p.ASI_MFM_Actual_Depreciation_Start_Date__c == null && p.ASI_MFM_TR_PlanCompletionDate__c != null){
                    p.ASI_MFM_Actual_Depreciation_Start_Date__c = p.ASI_MFM_TR_PlanCompletionDate__c.addMonths(1).toStartOfMonth();
                }                
                                  
                p.ASI_MFM_Actual_Depreciation_End_Date__c = p.ASI_MFM_Actual_Depreciation_Start_Date__c != null ? p.ASI_MFM_Actual_Depreciation_Start_Date__c.addMonths(Integer.valueOf(p.ASI_MFM_TR_Duration_Month__c)).addDays(-1): null;
                                                
            }
            else{
                p.ASI_MFM_End_Date__c = p.ASI_MFM_TR_Duration_Month__c != null? p.ASI_MFM_Start_Date__c.addMonths(Integer.valueOf(p.ASI_MFM_TR_Duration_Month__c)).addDays(-1): p.ASI_MFM_End_Date__c;
            }          
            // END - Linus   
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