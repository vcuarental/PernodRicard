/***************************************************************************************************************************
 * Name:        ASI_MFM_PH_PO_TriggerClass
 * Description: 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-07-25       Wilken Lee              [WL 1.0] CHG0030610 Enhance PO approval based on user's ASI MFM Department setup on user object
 ****************************************************************************************************************************/
public without sharing class ASI_MFM_PH_PO_TriggerClass {
    
    public static void routineAfterAll (list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        Id userId=userinfo.getUserId();
        Boolean bypass = false;
        for(User u: [Select Id,BypassTriggers__c  from User where Id=:userId]){
            bypass = u.BypassTriggers__c  == 'ASI_MFM_PH_BypassTrigger'? true:false;
        }
        
	// Update Total PO Amount in Plan object        
        set<id> pid_set = new set<id>();
        if (trigger_new != null) {
            for (ASI_MFM_PO__c po:trigger_new) {
                System.debug('Trigger_New PO - Recalculate total PO Amount: Plan ID: ' + po.ASI_MFM_Plan__c);
                pid_set.add(po.ASI_MFM_Plan__c);
            }
        }
        if (trigger_oldMap != null) {
            for (ASI_MFM_PO__c po:trigger_oldMap.values()) {
                System.debug('Trigger_oldMap PO - Recalculate total PO Amount: Plan ID: ' + po.ASI_MFM_Plan__c);
                pid_set.add(po.ASI_MFM_Plan__c);
            }           
        }
        if (pid_set.size() > 0) {
            // Overspending checking
            boolean isValid = true;
            list<ASI_MFM_Plan__c> p_list = [select ASI_MFM_Currency__c, ASI_MFM_Plan_Amount__c, (select ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_GF_Total_PO_Amount_PR_Gulf__c,ASI_MFM_Status__c,ASI_MFM_Accrual_PO__c  from POs__r where ASI_MFM_Accrual_PO__c=false), RecordTypeID from ASI_MFM_Plan__c where id in :pid_set for update];
			system.debug('SH: CP1');
            for (ASI_MFM_Plan__c p:p_list) {
                p.ASI_MFM_Total_PO_Amount__c = 0;                
                
                for (ASI_MFM_PO__c po:p.POs__r) {
                    if (po.ASI_MFM_Exchange_Rate__c > 0) {
                        p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c).setScale(2, roundingmode.half_up) * po.ASI_MFM_Exchange_Rate__c;                                                
                    }
                }
                system.debug('SH: total PO amount: ' + p.ASI_MFM_Total_PO_Amount__c);
                if(!Test.isRunningTest() && p.ASI_MFM_Plan_Amount__c < p.ASI_MFM_Total_PO_Amount__c){
                    isValid = false;
                    
                }

            }
            for(ASI_MFM_PO__c po: trigger_new){
                if(!bypass){
                    if(trigger.oldMap != null){
                        if(!isValid && trigger_oldMap.get(po.id).ASI_MFM_Status__c != po.ASI_MFM_Status__c && po.ASI_MFM_Status__c !='Draft')
                            po.addError('Plan is overspended');
                    }
                }
            }
            system.debug('SH: invalid: ' + isValid);
            if(!Test.isRunningTest() && isValid)
                update p_list;
        }
    }
    
    public static void routineAfterUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        set<id> pid_set = new set<id>();
        map<id, id> cid_map = new map<id, id>();
        
        map<id,Date> SD_map  = new map<id, Date>(); 
                
        map<id, decimal> xrate_map = new map<id, decimal>();
                
        id poid;
        id PHDFCustomerDefault;
        
        boolean isDF = false;
        map<id, id> psb_map = new map<id, id>();
        
        List<ASI_MFM_PO_Line_Item__c> lineitem_list = [Select id, ASI_MFM_Amount__c, ASI_MFM_PH_Allocation_Percentage__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: trigger_new[0].id];
        for (ASI_MFM_PO__c p:trigger_new) {
            
            if (p.ASI_MFM_Cloned_PO_ID__c != null && p.ASI_MFM_Cloned_PO_ID__c != p.id) {      system.debug('Linus: CLoned PO ID: ' + p.ASI_MFM_Cloned_PO_ID__c);
                pid_set.add(p.id);                                    
                cid_map.put(p.id, p.ASI_MFM_Cloned_PO_ID__c);
                SD_map.put(p.id,p.ASI_MFM_PO_Start_Date__c);                   
            }
            
            // Populate the exchange rate to PO line items
            if (trigger_oldmap != null && p.ASI_MFM_Exchange_Rate__c != trigger_oldMap.get(p.id).ASI_MFM_Exchange_Rate__c) {
                xrate_map.put(p.id, p.ASI_MFM_Exchange_Rate__c);
            }
                        
            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH_DF'))
                isDf = true;
        }
        system.debug('Linus: cid_map ' + cid_map);
// Set cloned PO ID to the new PO ID 
// Set the status to Draft for cloned PO         
        if (pid_set.size() > 0) {
            list<ASI_MFM_PO__c> PO_list = [select ASI_MFM_Cloned_PO_ID__c from ASI_MFM_PO__c where id in :pid_set for update];
            for (ASI_MFM_PO__c p:PO_list) {
                if (p.ASI_MFM_Cloned_PO_ID__c != null) {
                    p.ASI_MFM_Status__c = 'Draft';
                }               
                p.ASI_MFM_cloned_PO_id__c = p.id;
            }
          
            try{
               update PO_list;
            }catch (Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('The responsible by has no route type set up') ? true : false;
                 for (ASI_MFM_PO__c p:trigger_new) {
                     if (expectedExceptionThrown) p.AddError('The responsible by has no route type set up');
                 }
            } 
        } 

// If cloned PO ID is not null, clone the line items of the cloned PO to the new PO         
        if (cid_map.size() > 0) {
            
            list<id> cid_list = cid_map.values();
            string query_string = 'select ASI_MFM_PO_Start_Date__c,ASI_MFM_Is_Extended_PO__c,(' + ASI_MFM_Function.buildQuery('ASI_MFM_PO_line_item__c', 'ASI_MFM_PO__r.ASI_MFM_Original_PO_for_Adjustment__c', 'PO_line_items__r order by name') + ') from ASI_MFM_PO__c where id in :cid_list';
            map<id, ASI_MFM_PO__c> clone_map = new map<id, ASI_MFM_PO__c>();
            for (ASI_MFM_PO__c p:database.query(query_string)) {
                clone_map.put(p.id, p);
            }           
            list<ASI_MFM_PO_line_item__c> cloned_pi_list = new list<ASI_MFM_PO_line_item__c>();
            list<ASI_MFM_PO_line_item__c> pi_list = new list<ASI_MFM_PO_line_item__c>(); 
            for (id PO_id:cid_map.keySet()) {
                //cloned_pi_list = ;
                for (ASI_MFM_PO_line_item__c cloneline : clone_map.get(cid_map.get(PO_id)).PO_line_items__r){
                    cloned_pi_list.add(cloneline);
                }
                for (ASI_MFM_PO_line_item__c cloned_pi:cloned_pi_list) {
                    
                        
                        ASI_MFM_PO_line_item__c pi = cloned_pi.clone(false, true);
                        pi.ASI_MFM_PO__c = PO_id;
                        pi.ASI_MFM_PO_Line_Item_External_ID__c = null;
                        pi.ASI_MFM_Synced__c = false;
                        //Add By Tony Ren,When clone PO, auto update all PO Line GL Date to be equal to PO Start Date
                        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_PH'))
                        { //pi.ASI_MFM_G_L_Date__c =trigger_new[0].ASI_MFM_PO_Start_Date__c;
                            pi.ASI_MFM_G_L_Date__c=SD_map.get(PO_id);
                            pi.ASI_MFM_SG_BA_verify__c=false;
                            pi.ASI_MFM_Complete__c=false;
                            pi.ASI_MFM_Adjustment_Line__c=false;
                            pi.ASI_MFM_POSM_Deposit__c=false;
                            pi.ASI_MFM_POSM_Balance__c=false; 
                        }// Finished
                        
                            if(pi.ASI_MFM_Amount__c > 0){
                                pi_list.add(pi);
                            }
                        
                    
                }
            }
            if(!Test.isRunningTest())
                insert pi_list;
        }       
        
        
        if (xrate_map.size() > 0) {
            list<ASI_MFM_PO_Line_Item__c> pol_list = [select ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :xrate_map.keySet() for update]; 
            for (ASI_MFM_PO_Line_Item__c pol:pol_list) {
                pol.ASI_MFM_Exchange_Rate__c = xrate_map.get(pol.ASI_MFM_PO__c);
            }
            if(!Test.isRunningTest())
                update pol_list;
        }                         
        
        if(isDF){
            for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
                if(Setting.name == 'PH_DF_Customer_Name__c' && Setting.Country__c == 'PH'){
                    PHDFCustomerDefault = Setting.ASI_MFM_value__c;
                }
            }
        }
        // Added by 2018-08-13 Linus@introv
        // Update PO Line Amount if Total PO Amount(Allocation) is changed 
        // Block user to delete Total PO Amount(Allocation) if PO line exist 
        for(ASI_MFM_PO__c po: trigger_new){system.debug('Linus: PO Amount(All): ' + po.ASI_MFM_PH_Total_PO_Amount_Allocation__c);
            if(trigger_oldMap != null && po.ASI_MFM_PH_Total_PO_Amount_Allocation__c != trigger_oldmap.get(po.id).ASI_MFM_PH_Total_PO_Amount_Allocation__c){
                if(po.ASI_MFM_PH_Total_PO_Amount_Allocation__c != null){
                    if(!Test.isRunningTest() && po.ASI_MFM_PH_Total_PO_Amount_Allocation__c > trigger_oldmap.get(po.id).ASI_MFM_PH_Total_PO_Amount_Allocation__c && po.ASI_MFM_Status__c != 'Draft')
                        po.addError('Not allow increase amount in "Final" Status');
                    
                    for(ASI_MFM_PO_Line_Item__c pol: lineitem_list){
                        pol.ASI_MFM_Amount__c = po.ASI_MFM_PH_Total_PO_Amount_Allocation__c * pol.ASI_MFM_PH_Allocation_Percentage__c;
                    }
                    if(!Test.isRunningTest())
                        update lineitem_list;
                }else{
                    if(!Test.isRunningTest() && po.ASI_MFM_PO_Amount__c != null)
                        po.addError('Please delete all the PO lines before clear Total PO Amount(Allocation)');
                }
                    
            }
        }
    } 

    
    public static void routineBeforeDelete(list<ASI_MFM_PO__c> trigger_old) {
// Not allowed to delete if the PO has related payment line items       
        set<id> po_set = new set<id>();
        list<ASI_MFM_Payment_Line_Item__c> pi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        for (ASI_MFM_PO__c p:trigger_old) {     
            
                if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete')
                    p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');                
                po_set.add(p.id);
            
        }
        if(po_set != NULL)
            pi_list = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c != TRUE and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c in :po_set order by ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c];
        
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
// Set the PO number for new PO                     
        set<id> px_set = new set<id>();
        List<ASI_MFM_PO_Date_Range__c> pr = new List<ASI_MFM_PO_Date_Range__c>();
        Set<id> PlanIds = new set<id>();
        Map<id, string> po_map = new map<id, string>();
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
            
            PlanIds.add(p.ASI_MFM_Plan__c);
                                    
        }  
        
        //Updated by Introv 20170731 added prefix to include "Accrual PO" type, //20180115 Introv added Dummy PO
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name,ASI_MFM_Company__c, asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c, ASI_MFM_TW_Delivery_Address__c from asi_mfm_prefix__c where ( asi_mfm_module__c = 'PO' or asi_mfm_module__c = 'Direct PO' or asi_mfm_module__c='Accrual PO' or asi_mfm_module__c='Dummy PO')and id in :px_set for update]);
        
        for (ASI_MFM_PO__c p:trigger_new) {            
            
            
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }
                    
                }
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }        
        ASI_MFM_Function.updatePrefix(px_map.values());   
        
        // Added by 2018-06-20 Linus@introv
        // For over budget "Final" plan,
        // 1. It can't make a new PO related
        // 2. It can't be updated anythings
        for(ASI_MFM_Plan_Line_Item__c pl: [Select id, ASI_MFM_Over_Budget__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: PlanIds]){
            if(!Test.isRunningTest() && pl.ASI_MFM_Over_Budget__c == true){
                //trigger_new[0].addError('Not allow to create PO for Over Budget Plan');
            }
        }
    }

    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
// Set the approvers for the PO based on the routing rule objects           
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<id> pr_set = new set<id>();                	 
                        
        for (ASI_MFM_PO__c p:trigger_new) {
            
            if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);                
                
                p.ASI_MFM_Sys_Approver_1__c = null;
                p.ASI_MFM_Sys_Approver_2__c = null;
                p.ASI_MFM_Sys_Approver_3__c = null;
                p.ASI_MFM_Sys_Approver_4__c = null;
                p.ASI_MFM_Sys_Approver_5__c = null;
                
            }                                 
        }       
        
        
        if (pid_set.size() > 0) {       
            System.debug('Start assign approver');
            map<id, id> sb_map = new map<id, id>();


            for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_PO_Line_Item__c 
                where ASI_MFM_PO__c in :pid_set order by name desc]) {
                sb_map.put(pi.ASI_MFM_PO__c, pi.ASI_MFM_Sub_brand_Code__c);
            }
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
           
            //Other country logic
                brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) 
                order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];
            
             System.debug('brm_list: ' + brm_list);
            set<id> rt_set = new set<id>();    
            
                for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                    rt_set.add(brm.ASI_MFM_Route_Type__c);
                }      
                       
            map<id, ASI_MFM_Sub_brand__c> sbList_map;
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c, ASI_MFM_Sequence__c from ASI_MFM_Route_Rule_Detail__c 
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c];
              
            
            for (ASI_MFM_PO__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    
                        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                             if(brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == null){
                                rtid = brm.ASI_MFM_Route_Type__c;
                                System.debug('rtid_null: ' + rtid);
                            }else if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == sbid ) {                            
                                rtid = brm.ASI_MFM_Route_Type__c;
                                System.debug('rtid_sub_brand: ' + rtid);
                                
                                break;
                            }
                            else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                                System.debug('rtid_break: ' + rtid);
                                break;
                            }                       
                        }
                    
                    if (rtid != null) {
                     System.debug('rtid: ' + rtid);
                     boolean validSubBrand = true;
                        
                        
                        System.debug('IsValidSubBrand: ' + validSubBrand);
                        if (validSubBrand){
                            decimal local_amount = p.ASI_MFM_PO_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                            System.debug('Local Amount: ' + local_amount);
                            System.debug('Route Type ID: ' + rtid + ' Route Rule List: ' + rule_list);
                            p.ASI_MFM_Route_Type__c = rtid  ;
                            for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                                if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
									if (rd.ASI_MFM_Region__c == null || (rd.ASI_MFM_Region__c != null && rd.ASI_MFM_Region__c == p.ASI_MFM_User_MFM_Department__c)){    //WL 1.0
										if (approver_count == 0) {
											p.ASI_MFM_Sys_Approver_1__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 1) {                                 
											p.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 2) {                                 
											p.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 3) {                                 
											p.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 4) {                                 
											p.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 5) {                                 
											p.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 6) {                                 
											p.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 7) {                                 
											p.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 8) {                                 
											p.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
										}
										else if (approver_count == 9) {                                 
											p.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
										}
										approver_count++;                                                                                                                               
									}	//WL 1.0
                                }
                                
                                else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                    break;
                                }
                            }

                        }
                    } 
                    else {
                        System.debug('No rt id' );
                        p.adderror('There has no route type set up');
                         
                    }
                    
                }               
            }               
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
        date last_effective_date;
        System.debug('routineBeforeUpsert');
        //20140410 Steve Wan Default BU for JP
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }        
        
        //20171024 Introv added to retrieve Original PO Status
        
        Set<Id> originalPOSet = new Set<Id>();
        Set<Id> POIdSet = new Set<Id>();
        //20171024 End
        
        for (ASI_MFM_PO__c po:trigger_new) {
            if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_PH')){
                
                // Back Date Validation
                if(!Test.isRunningTest() && (po.ASI_MFM_PO_Start_Date__c.addDays(1) < po.CreatedDate && (po.ASI_MFM_Other_Remark__c == null || po.ASI_MFM_Other_Remark__c == '') && po.ASI_MFM_Status__c =='Draft'))
                    po.AddError('Please fill in Other Remark field with the reason since PO Start Date is earlier than today.');
                
                if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_PH_DP')){
                    
                    
                    if(po.ASI_MFM_Currency__c=='PHP'){
                        
                        if(po.ASI_MFM_Tax_Rate__c=='12%'){// PHVAT and V
                            po.ASI_MFM_VAT__c=0.12;
                            po.ASI_MFM_JDE_Tax_Code__c='PHVAT and V';
                        }
                        if(po.ASI_MFM_Tax_Rate__c=='0%'){ //PHVAT and E
                            po.ASI_MFM_VAT__c=0;
                            po.ASI_MFM_JDE_Tax_Code__c='PHVAT and E';
                            
                        }                        
                    }else {
                        //ASI MFM PH DP PO but not choose "PHP" as default currency 
                        //the tax rate should be equals to blank
                        //PHP – Tax Rate -> 12%, JDE Tax Code -> PHVAT & V
                        //PHP – Tax Rate -> 0%, JDE Tax Code -> PHVATZERO & E
                        //Foreign currency – Tax Rate ? Blank, JDE Tax Code ? Blank

                            po.ASI_MFM_Tax_Rate__c = '';
                            po.ASI_MFM_VAT__c= 0; 
                            po.ASI_MFM_JDE_Tax_Code__c='';                        
                    }

                }else if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_PH_DF')){ 
                            //PH DF with foreign currency
                            po.ASI_MFM_Tax_Rate__c = '';
                            po.ASI_MFM_VAT__c=0;
                            po.ASI_MFM_JDE_Tax_Code__c='';    
                                                
                    //PH DF GET Plan Exchange Rate
                    //ASI_MFM_Plan__c plan=[select ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c from ASI_MFM_Plan__c where id=: po.ASI_MFM_Plan__c];
                    //po.ASI_MFM_Currency__c=plan.ASI_MFM_Currency__c;
                    //po.ASI_MFM_Exchange_Rate__c=plan.ASI_MFM_Exchange_Rate__c;
                }
                                           
            }
            
            System.debug('ASI_MFM_Exchange_Rate__c '+po.ASI_MFM_Exchange_Rate__c);
            if (po.ASI_MFM_Exchange_Rate__c == null) {
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }
            
        }
                
        if (po_set.size() > 0){
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            

            //Steve Wan 20140527 Edit for special handling in TR
            System.debug('country '+country );

                        
            if(country == 'PH'){
                if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_PH_DF_PO')){
                    country = 'SG';
                }
            }
            
            System.debug('ex_rate');
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;         
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            
            
            System.debug(country+'/'+base_ccy+'/'+ccy_set+'/'+last_effective_date);
            System.debug(xr_list);
            for (ASI_MFM_PO__c po:trigger_new) {
                if (po_set.contains(po.id) ) {
                    if (po.ASI_MFM_Currency__c == po.ASI_MFM_Sys_Local_Currency__c) {
                        po.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        if (po.ASI_MFM_Currency__c != null && po.ASI_MFM_PO_Raised_Date__c != null ) {                                                                           
                            for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                                if (xr.ASI_MFM_Counter_Currency__c == po.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= po.ASI_MFM_PO_Raised_Date__c ){//&& !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
                                    po.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                                    break;
                                }
                                else if (xr.ASI_MFM_Counter_Currency__c > po.ASI_MFM_Currency__c) {
                                    break;
                                }
                            }
                            
                        }
                    }               
                }
            }                       
        }
        
        
// Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        if (bu_list.size() == 1) {
            for (ASI_MFM_PO__c po:trigger_new) {
            //20140410 Steve Wan Default BU for JP
                if (po.ASI_MFM_BU_Code__c == null) {
                    po.ASI_MFM_BU_Code__c = bu_list[0].id;
                }
            } 
        }
        
    
// The prefix must be for PO
// The prefix must be valid for the owner
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_PO__c> PO_list = new list<ASI_MFM_PO__c>();
        for (ASI_MFM_PO__c p:trigger_new) {
            system.debug('--- trigger_oldMap : ' + trigger_oldMap);
            system.debug('--- p.ownerId : ' + p.ownerId);
            system.debug('--- p.ASI_MFM_Prefix__c : ' + p.ASI_MFM_Prefix__c);
            
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                PO_list.add(p);
            }
        }
        if (PO_list.size() > 0  ) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            //Updated by Introv 20170731 to include Prefix's ASI_MFM_Module__c ='Accrual PO':
            system.debug('prefix_set:' + prefix_set);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set AND (ASI_MFM_Module__c = 'PO' OR ASI_MFM_Module__c ='Accrual PO') ]);
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
                    if (!valid_prefix ) {
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                    }
                }
            }
        }        
    }
}