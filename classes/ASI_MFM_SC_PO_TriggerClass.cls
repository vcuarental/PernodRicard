public without sharing class ASI_MFM_SC_PO_TriggerClass {
    

    public static void routineAfterAll (list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
// Update Total PO Amount in Plan object        
        set<id> pid_set = new set<id>();
        if (trigger_new != null) {
            for (ASI_MFM_PO__c po:trigger_new) {
                pid_set.add(po.ASI_MFM_Plan__c);
            }
        }
        if (trigger_oldMap != null) {
            for (ASI_MFM_PO__c po:trigger_oldMap.values()) {
                pid_set.add(po.ASI_MFM_Plan__c);
            }           
        }
        if (pid_set.size() > 0) {
            list<ASI_MFM_Plan__c> p_list = [select ASI_MFM_Currency__c, (select ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c from POs__r) from ASI_MFM_Plan__c where id in :pid_set for update];
            recordType rt;
            if(trigger_new != null) {
                rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
            }
            else {
                rt = Global_RecordTypeCache.getRt(trigger_oldMap.values()[0].recordTypeId);
            }
            // end of Changes
            for (ASI_MFM_Plan__c p:p_list) {
                p.ASI_MFM_Total_PO_Amount__c = 0;
                for (ASI_MFM_PO__c po:p.POs__r) {
                    if(po.ASI_MFM_Exchange_Rate__c ==null || po.ASI_MFM_Exchange_Rate__c ==0)
                        po.ASI_MFM_Exchange_Rate__c =1;
                    if (po.ASI_MFM_Exchange_Rate__c > 0) {
                        p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(2, roundingmode.half_up);                   
                    }
                }
            }
            update p_list;
        }
    }

    public static void routineAfterDelete(list<ASI_MFM_PO__c> trigger_old) {
// Delete PO in Data Warehouse
        if (!ASI_MFM_Function.bypassCallouts()) {
            list<id> pid_list = new list<id>();
            for (ASI_MFM_PO__c p:trigger_old) {
                pid_list.add(p.id);
            }
        }
// Update Total PO Amount in Plan object        
        set<id> pid_set = new set<id>();
            for (ASI_MFM_PO__c po:trigger_old) {
                if(po.ASI_MFM_Plan__c != null)
                    pid_set.add(po.ASI_MFM_Plan__c);
            }
            if(pid_set.size() >0 )
            {
            list<ASI_MFM_Plan__c> p_list = [select ASI_MFM_Currency__c, (select ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c from POs__r) from ASI_MFM_Plan__c where id in :pid_set for update];
            for (ASI_MFM_Plan__c p:p_list) {
                p.ASI_MFM_Total_PO_Amount__c = 0;
                for (ASI_MFM_PO__c po:p.POs__r) {
                    // DC - 01/18/2016 - Added null check on PO Amount and Exchange Rate fields before calculating
                    // Total PO Amount on parent plan.
                    Decimal poAmount = (po.ASI_MFM_PO_Amount__c != NULL) ? po.ASI_MFM_PO_Amount__c : 0.0;
                    Decimal exchangeRate = (po.ASI_MFM_Exchange_Rate__c != NULL) ? po.ASI_MFM_Exchange_Rate__c : 0.0;
                    p.ASI_MFM_Total_PO_Amount__c += (poAmount * exchangeRate).setScale(2, roundingmode.half_up);
                }
            }
            if(p_list.size() > 0)
                update p_list;    
          }
    }


    public static void routineAfterUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
// Populate the exchange rate to PO line items
        map<id, decimal> xrate_map = new map<id, decimal>();
        for (ASI_MFM_PO__c p:trigger_new) { 
            if (p.ASI_MFM_Exchange_Rate__c != trigger_oldMap.get(p.id).ASI_MFM_Exchange_Rate__c) {
                xrate_map.put(p.id, p.ASI_MFM_Exchange_Rate__c);
            }
        } 
        if (xrate_map.size() > 0) {
            list<ASI_MFM_PO_Line_Item__c> pol_list = [select ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :xrate_map.keySet() for update]; 
            for (ASI_MFM_PO_Line_Item__c pol:pol_list) {
                pol.ASI_MFM_Exchange_Rate__c = xrate_map.get(pol.ASI_MFM_PO__c);
            }
            update pol_list;
        }            
    }
    
    public static void routineBeforeDelete(list<ASI_MFM_PO__c> trigger_old) {
// Not allowed to delete if the PO has related payment line items       
        set<id> po_set = new set<id>();
        for (ASI_MFM_PO__c p:trigger_old) { 

            if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete')
                p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');

            po_set.add(p.id);
        }
        list<ASI_MFM_Payment_Line_Item__c> pi_list = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c 
            where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c in :po_set order by ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c];
        map<id, integer> pi_map = new map<id, integer>();
        id current_pid;
        integer pi_count = 0;
        for (ASI_MFM_Payment_Line_Item__c pi:pi_list) {
            if (pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c != current_pid) {
                pi_map.put(current_pid, pi_count);
                current_pid = pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c;
                pi_count = 1;
            }
            else {
                pi_count++;
            }
        }
        if (current_pid != null) {
            pi_map.put(current_pid, pi_count);
        }
        for (ASI_MFM_PO__c p:trigger_old) { 
            if (pi_map.get(p.id) > 0) {
                p.addError('Not allowed to delete because it has related payment line items');
            }
        }
    }

    public static void routineBeforeInsert(list<ASI_MFM_PO__c> trigger_new) {
        set<id> px_set = new set<id>();
        List<ASI_MFM_PO_Date_Range__c> pr = new List<ASI_MFM_PO_Date_Range__c>();

            
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'PO' and id in :px_set for update]);
            
        for (ASI_MFM_PO__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);                             
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }
        update pr;
        ASI_MFM_Function.updatePrefix(px_map.values());   
        
    }//End routineBeforeInsert method
    
    
    public static void clearApprover(ASI_MFM_PO__c po) {
        po.ASI_MFM_Sys_Approver_1__c = null;
        po.ASI_MFM_Sys_Approver_2__c = null;
        po.ASI_MFM_Sys_Approver_3__c = null;
        po.ASI_MFM_Sys_Approver_4__c = null;
        po.ASI_MFM_Sys_Approver_5__c = null;
        po.ASI_MFM_Sys_Approver_6__c = null;
        po.ASI_MFM_Sys_Approver_7__c = null;
        po.ASI_MFM_Sys_Approver_8__c = null;
        po.ASI_MFM_Sys_Approver_9__c = null;
        po.ASI_MFM_Sys_Approver_10__c = null;
	}
    
    public static void populateApprovers(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap, set<id> px_set, set<id> owner_set, set<id> submitter_set) {  
  System.debug(px_set);
  System.debug(owner_set);          
        list<ASI_MFM_Brand_Route_Type_Map__c> brm_list =  [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c from ASI_MFM_Brand_Route_Type_Map__c where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and ASI_MFM_Responsible_By__c in :owner_set order by ASI_MFM_Prefix__c desc];
               
        set<id> rt_set = new set<id>();     
            
        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
            rt_set.add(brm.ASI_MFM_Route_Type__c);
        }     
        
 System.debug(brm_list.size());       
        
    list<ASI_MFM_Route_Rule_Detail__c> rule_list = new list<ASI_MFM_Route_Rule_Detail__c>();
    if (rt_set.size() > 0)
      rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c, asi_mfm_hkd__c, ASI_MFM_Route_Type__c from ASI_MFM_Route_Rule_Detail__c 
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c];
    
        for (ASI_MFM_PO__c po : trigger_new){
            
            integer approver_count = 0;

            if (trigger_oldMap != null) {
                ASI_MFM_PO__c old = trigger_oldMap.get(po.id);

                if (po.ASI_MFM_Route_Type__c != null && po.OwnerId == old.OwnerId) {
                    
                    clearApprover(po);

                    List<ASI_MFM_Route_Rule_Detail__c> routeRuleDetails = [
                        SELECT ASI_MFM_Approver__c, asi_mfm_hkd__c 
                        FROM ASI_MFM_Route_Rule_Detail__c 
                        WHERE ASI_MFM_Route_Type__c = :po.ASI_MFM_Route_Type__c
                        ORDER BY ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c
                    ];
    
                    for (ASI_MFM_Route_Rule_Detail__c detail : routeRuleDetails) {
                        if (po.ASI_MFM_HK_PO_Amount_HKD__c >= detail.asi_mfm_hkd__c){
                        if (approver_count == 0) po.ASI_MFM_Sys_Approver_1__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 1) po.ASI_MFM_Sys_Approver_2__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 2) po.ASI_MFM_Sys_Approver_3__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 3) po.ASI_MFM_Sys_Approver_4__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 4) po.ASI_MFM_Sys_Approver_5__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 5) po.ASI_MFM_Sys_Approver_6__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 6) po.ASI_MFM_Sys_Approver_7__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 7) po.ASI_MFM_Sys_Approver_8__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 8) po.ASI_MFM_Sys_Approver_9__c = detail.ASI_MFM_Approver__c;
                        if (approver_count == 9) po.ASI_MFM_Sys_Approver_10__c = detail.ASI_MFM_Approver__c;
                        approver_count++;
                        }
                    }
                    
                    continue;
                }

                if (po.ASI_MFM_Prefix__c == old.ASI_MFM_Prefix__c && po.OwnerId == old.OwnerId) {
                    continue;
                }
            }

            id rtid;
            
            clearApprover(po);
            
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                if (brm.ASI_MFM_Prefix__c == po.ASI_MFM_Prefix__c) {
                    rtid = brm.ASI_MFM_Route_Type__c;
                    break;
                }
            }
            
            if (rtid != null) {
                
                po.ASI_MFM_Route_Type__c = rtid;
                
                for (ASI_MFM_Route_Rule_Detail__c routeDetail:rule_list) {
                    if(submitter_set.contains(routeDetail.ASI_MFM_Approver__c))
                        continue;
                    if (routeDetail.ASI_MFM_Route_Type__c == rtid && po.ASI_MFM_HK_PO_Amount_HKD__c >= routeDetail.asi_mfm_hkd__c) {
                        if (approver_count == 0) po.ASI_MFM_Sys_Approver_1__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 1) po.ASI_MFM_Sys_Approver_2__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 2) po.ASI_MFM_Sys_Approver_3__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 3) po.ASI_MFM_Sys_Approver_4__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 4) po.ASI_MFM_Sys_Approver_5__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 5) po.ASI_MFM_Sys_Approver_6__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 6) po.ASI_MFM_Sys_Approver_7__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 7) po.ASI_MFM_Sys_Approver_8__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 8) po.ASI_MFM_Sys_Approver_9__c = routeDetail.ASI_MFM_Approver__c;
                        else if (approver_count == 9) po.ASI_MFM_Sys_Approver_10__c = routeDetail.ASI_MFM_Approver__c;                                                                                                    
                        approver_count++;
                    }
                }
            }
        }
    }
    
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
// Set the approvers for the PO based on the routing rule objects           
        set<id> pid_set = new set<id>();
        set<id> pr_set = new set<id>();
        boolean isJP = false;
        boolean isTRLogic = false;
        id overrideRouteTypeId =  null;
        for (ASI_MFM_PO__c p:trigger_new) {
            
        }
        
// Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_PO__c> reject_map = new map<id, ASI_MFM_PO__c>();
        for (ASI_MFM_PO__c p:trigger_new) { 
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
            }
        }
        if (reject_map.size() > 0) {
            list<ASI_MFM_PO__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_PO__c where id in :reject_map.keySet()];
            for (ASI_MFM_PO__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
   
    } 

    
    public static void routineBeforeUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Retrieve exchange rate if no input 
        set<id> po_set = new set<id>();
         set<id> acc_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        set<id> plan_set = new set<id>();
        
        date last_effective_date;

       
        for (ASI_MFM_PO__c po:trigger_new) {
            plan_set.add(po.ASI_MFM_Plan__c);       
            if (po.ASI_MFM_Exchange_Rate__c == null) {
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }  
            if(po.asi_mfm_status__c.equals('Draft'))
                po.ASI_MFM_Supplier_Name__c=po.ASI_MFM_SC_Supplier_Name__c;          
        }
        
        map<id, asi_mfm_plan__c> plan_map = new map<id, asi_mfm_plan__c>([select id,ASI_MFM_Plan_Type__c from asi_mfm_plan__c where id in :plan_set]);
        for (ASI_MFM_PO__c po:trigger_new) {
            if(plan_map.containskey(po.asi_mfm_plan__c)){
                po.ASI_MFM_PO_Type__c=plan_map.get(po.asi_mfm_plan__c).ASI_MFM_Plan_Type__c;    
                
                asi_mfm_plan__c p =plan_map.get(po.asi_mfm_plan__c);     
            }
            
            if(po.ASI_MFM_Exchange_Rate__c==null || po.ASI_MFM_Exchange_Rate__c==0 || (trigger_oldMap!=null && trigger_oldMap.get(po.id)!=null && !po.ASI_MFM_Currency__c.equalsIgnoreCase(trigger_oldMap.get(po.id).ASI_MFM_Currency__c))){
                if(po.ASI_MFM_Currency__c.equalsIgnoreCase('HKD'))
                    po.ASI_MFM_Exchange_Rate__c=1.0;
                else{
                    List<ASI_MFM_Exchange_Rate__c> exList=[select Id, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Counter_Currency__c= :po.ASI_MFM_Currency__c and ASI_MFM_Base_Currency__c ='HKD' and ASI_MFM_Country__c='HK' and ASI_MFM_Application__c='MFM' and ASI_MFM_Effective_Date__c >=last_n_days:180 and ASI_MFM_Effective_Date__c<= :po.ASI_MFM_Po_Raised_Date__c order by ASI_MFM_Effective_Date__c desc];
                    if(exList.size()>0)
                        po.ASI_MFM_Exchange_Rate__c =exList.get(0).ASI_MFM_Exchange_Rate__c;
                    else
                        po.ASI_MFM_Exchange_Rate__c=1.0;    
                }               
            }
        }
               
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        set<id> submitter_set = new set<id>();
        
        list<ASI_MFM_PO__c> PO_list = new list<ASI_MFM_PO__c>();
        for (ASI_MFM_PO__c p:trigger_new) {
            prefix_set.add(p.ASI_MFM_Prefix__c);
            owner_set.add(p.ownerId); 
            submitter_set.add(p.asi_mfm_submitter__c); 
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                           
                PO_list.add(p);
            }
        }
        if (PO_list.size() > 0) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'PO']);
             for (ASI_MFM_PO__c p:PO_list) {
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for PO');
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
      
        populateApprovers(trigger_new, trigger_oldMap, prefix_set, owner_set, submitter_set);            
    } 
}