public without sharing class ASI_MFM_SC_Plan_TriggerClass {

    public static void routineBeforeDelete (list<ASI_MFM_Plan__c> trigger_old) {
        // Not allowed to delete final plan
        Set<id> pid_set = new Set<id>();
        for (ASI_MFM_Plan__c plan : trigger_old){
            pid_set.add(plan.id);
            if (plan.ASI_MFM_Status__c == 'Final' || plan.ASI_MFM_Status__c == 'Complete')
                 plan.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
        }
        
        if (pid_set.size() > 0) {
            map<id, ASI_MFM_Plan__c> p_map = new map<id, ASI_MFM_Plan__c>([select (select id from POs__r) from ASI_MFM_Plan__c where id in :pid_set]);
            for (ASI_MFM_Plan__c p:trigger_old) {
                if (p_map.containsKey(p.id) && p_map.get(p.id).POs__r.size() > 0) {
                    system.debug('PO count: ' + p_map.get(p.id).POs__r.size());
                    p.addError('Not allowed to delete because the plan contains PO');
                }
            }
        }
    }
        

    public static void routineBeforeInsert(list<ASI_MFM_Plan__c> trigger_new) {
        list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
        set<id> px_set = new set<id>();
        
        for (ASI_MFM_Plan__c p:trigger_new) {
                px_set.add(p.ASI_MFM_Prefix__c);                                                       
        }       
          
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c, ASI_MFM_Fiscal_year__c, Plan_Type__c, recordtypeid,ASI_MFM_TR_Rec_Type__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'Plan' and id in :px_set for update]);
        
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);               
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
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<id> owner_set = new set<id>();
        set<id> submitter_set = new set<id>();
        
        pid_set.clear();
        for (ASI_MFM_Plan__c p:trigger_new) {
            px_set.add(p.ASI_MFM_Prefix__c);
            owner_set.add(p.ownerid);
            submitter_set.add(p.asi_mfm_submitter__c); 
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
        
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Plan__c> reject_map = new map<id, ASI_MFM_Plan__c>();
        for (ASI_MFM_Plan__c p:trigger_new) { 
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c != 'Draft') {
                reject_map.put(p.id, p);
            }
            
            if(p.ASI_MFM_Exchange_Rate__c==null || p.ASI_MFM_Exchange_Rate__c==0 || !p.ASI_MFM_Currency__c.equalsIgnoreCase(trigger_oldMap.get(p.id).ASI_MFM_Currency__c)){
                if(p.ASI_MFM_Currency__c.equalsIgnoreCase('HKD'))
                    p.ASI_MFM_Exchange_Rate__c=1.0;
                else{
                    List<ASI_MFM_Exchange_Rate__c> exList=[select Id, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Counter_Currency__c= :p.ASI_MFM_Currency__c and ASI_MFM_Base_Currency__c ='HKD' and ASI_MFM_Country__c='HK' and ASI_MFM_Application__c='MFM' and ASI_MFM_Effective_Date__c >=last_n_days:180 and ASI_MFM_Effective_Date__c<= :p.ASI_MFM_Plan_Raised_Date__c order by ASI_MFM_Effective_Date__c desc];
                    if(exList.size()>0)
                        p.ASI_MFM_Exchange_Rate__c =exList.get(0).ASI_MFM_Exchange_Rate__c;
                    else
                        p.ASI_MFM_Exchange_Rate__c=1.0;    
                }               
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
        
        populateApprovers(trigger_new, px_set,owner_set,submitter_set);

    } 
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan__c> trigger_new, map<id, ASI_MFM_Plan__c> trigger_oldMap) {
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_Plan__c> plan_list = new list<ASI_MFM_Plan__c>();
                
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                plan_list.add(p);
            }
            System.debug(p.ASI_MFM_Fiscal_year__c);
            System.debug(p.recordtypeid);
        }
        
        if (plan_list.size() > 0) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select Plan_Type__c, (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Plan']);
            for (ASI_MFM_Plan__c p:plan_list) {
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for plan');
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

public static void populateApprovers(list<ASI_MFM_Plan__c> trigger_new, set<id> px_set,set<id> owner_set,set<id> submitter_set) {       
        list<ASI_MFM_Brand_Route_Type_Map__c> brm_list =  [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c from ASI_MFM_Brand_Route_Type_Map__c where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and ASI_MFM_Responsible_By__c in :owner_set order by ASI_MFM_Prefix__c desc];
               
        set<id> rt_set = new set<id>();     
            
        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
            rt_set.add(brm.ASI_MFM_Route_Type__c);
        }     
        
    list<ASI_MFM_Route_Rule_Detail__c> rule_list = new list<ASI_MFM_Route_Rule_Detail__c>();
    if (rt_set.size() > 0)
      rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,asi_mfm_hkd__c from ASI_MFM_Route_Rule_Detail__c where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c,ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c];
    
        for (ASI_MFM_Plan__c plan : trigger_new){
            id rtid;
            
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                if (brm.ASI_MFM_Prefix__c == plan.ASI_MFM_Prefix__c) {
                    rtid = brm.ASI_MFM_Route_Type__c;
                    break;
                }
            }
                
            integer approver_count = 0;
            if (rtid != null) {
                for (ASI_MFM_Route_Rule_Detail__c routeDetail:rule_list) {
                    
                    if (routeDetail.ASI_MFM_Route_Type__c == rtid) {
                        if(routeDetail.asi_mfm_hkd__c>plan.ASI_MFM_Plan_Amount__c*plan.ASI_MFM_Exchange_Rate__c || submitter_set.contains(routeDetail.ASI_MFM_Approver__c))
                            continue;
                        if (approver_count == 0) {
                            plan.ASI_MFM_Approver_1__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 1) {                                 
                            plan.ASI_MFM_Approver_2__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 2) {                                 
                            plan.ASI_MFM_Approver_3__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 3) {                                 
                            plan.ASI_MFM_Approver_4__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 4) {                                 
                            plan.ASI_MFM_Approver_5__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 5) {                                 
                            plan.ASI_MFM_Approver_6__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 6) {                                 
                            plan.ASI_MFM_Approver_7__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 7) {                                 
                            plan.ASI_MFM_Approver_8__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 8) {                                 
                            plan.ASI_MFM_Approver_9__c = routeDetail.ASI_MFM_Approver__c;
                        }
                        else if (approver_count == 9) {                                 
                            plan.ASI_MFM_Approver_10__c = routeDetail.ASI_MFM_Approver__c;
                        }                                                                                                    
                        approver_count++;
                    }
                }
            }
        }
    }
}