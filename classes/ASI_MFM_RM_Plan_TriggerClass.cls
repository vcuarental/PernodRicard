public without sharing class ASI_MFM_RM_Plan_TriggerClass {
    
    public static void routineBeforeDelete (list<ASI_MFM_Plan__c> trigger_old) {
        // Not allowed to delete final plan
        Set<id> pid_set = new Set<id>();
        
        for (ASI_MFM_Plan__c plan : trigger_old){           
            
            if (plan.ASI_MFM_Status__c == 'Final'|| plan.ASI_MFM_Status__c == 'Complete'){
                 plan.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
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
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Prefix__c')){
            MRecType.put(rec.developername,rec.id);
        }
        
        // Update by Michael Yip (Introv) 2 Feb 2014 to add FY for plan with cn record type prefix
        for (ASI_MFM_Plan__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(2, 5);
                
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
        for (ASI_MFM_Plan__c p:trigger_new) {
            setOwnerLink(p);
            
            
            
            if (p.ASI_MFM_Plan_Amount__c != null) {
               
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
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Sequence__c];


            for (ASI_MFM_Plan__c p:trigger_new) { 

                
                integer approver_count = 0;
                
          
                if (pid_set.contains(p.id) && !SPID.contains(p.id)) {
                    
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
        */
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
            //System.debug(LoggingLevel.ERROR, 'Loop Time: '+(time3-time2)+'ms');
        }
        // end of Changes        
        
          
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
                
        
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