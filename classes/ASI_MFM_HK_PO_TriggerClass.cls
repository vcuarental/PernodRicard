public class ASI_MFM_HK_PO_TriggerClass {
    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        
        System.debug('Start HK MFM PO routineBeforeUpdate');
        // Set the approvers for the PO based on the routing rule objects           
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        for (ASI_MFM_PO__c p:trigger_new) {
            if(p.ASI_MFM_Exchange_Rate__c==null)
                p.ASI_MFM_Exchange_Rate__c=1;
                
            if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0 
                    && (!(p.ASI_MFM_Status__c == 'Final' && trigger_oldmap !=null && trigger_oldmap.get(p.id).ASI_MFM_Status__c == 'Complete'))) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);
                if(p.ASI_MFM_Status__c == 'Draft'){
                    p.ASI_MFM_Sys_Approver_1__c = null;
                    p.ASI_MFM_Sys_Approver_2__c = null;
                    p.ASI_MFM_Sys_Approver_3__c = null;
                    p.ASI_MFM_Sys_Approver_4__c = null;
                    p.ASI_MFM_Sys_Approver_5__c = null;                                                                     
                    p.ASI_MFM_Sys_Approver_6__c = null;                                                                     
                    p.ASI_MFM_Sys_Approver_7__c = null;                                                                     
                    p.ASI_MFM_Sys_Approver_8__c = null;                                                                     
                    p.ASI_MFM_Sys_Approver_9__c = null;      
                }                                                              
            }
        }
        
        // [SH] 2019-03-20 Set Default BU from Prefix
        if (pid_set.size() > 0) {
            Map<id,ASI_MFM_Prefix__c> px_map = new Map<id, ASI_MFM_Prefix__c>([Select id, ASI_MFM_Default_BU__c from ASI_MFM_Prefix__c where id IN:px_set ]);
            for(ASI_MFM_PO__c p: trigger_new){
                if(p.ASI_MFM_BU_Code__c == null)
                    p.ASI_MFM_BU_Code__c = px_map.get(p.ASI_MFM_Prefix__c).ASI_MFM_Default_BU__c;
            }
        // END - [SH]
        // 
            System.debug('HK MFM pid Set: ' + pid_set);
      
            map<id, id> sb_map = new map<id, id>();
            for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_PO_Line_Item__c 
                                             where ASI_MFM_PO__c in :pid_set order by name desc]) {
                                                 sb_map.put(pi.ASI_MFM_PO__c, pi.ASI_MFM_Sub_brand_Code__c);
                                             }
            
            //Modified by Wilken on 20130828 for HK MFM Sales PO Approval Process            
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c, ASI_MFM_Route_Type__r.ASI_MFM_ByPassThreshold__c,
                                                              ASI_MFM_Route_Type__r.ASI_MFM_Sales_Route_Type_Amount_From__c, ASI_MFM_Route_Type__r.ASI_MFM_Sales_Route_Type_Amount_To__c, ASI_MFM_Route_Type__r.ASI_MFM_Backup_Approver__c from ASI_MFM_Brand_Route_Type_Map__c 
                                                              where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) 
                                                              order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];
            set<id> rt_set = new set<id>();     
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }           
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c from ASI_MFM_Route_Rule_Detail__c 
                                                            where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];
            
            for (ASI_MFM_PO__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    id backupApproverID;
                    //Modified by Mark on 20170515, if PO is an Adjustment PO, use original PO amount to check flow
                    decimal local_amount = p.ASI_MFM_PO_Amount__c * p.ASI_MFM_Exchange_Rate__c; 
                    
                    if (p.ASI_MFM_Original_PO_for_Adjustment__c != null){
                        ASI_MFM_PO__c originalPO = [select ASI_MFM_PO_Amount__c , ASI_MFM_Exchange_Rate__c from ASI_MFM_PO__c where id = :p.ASI_MFM_Original_PO_for_Adjustment__c limit 1];
                        local_amount=originalPO.ASI_MFM_PO_Amount__c * originalPO.ASI_MFM_Exchange_Rate__c;
                    }
                    
                    //Normal PO Approval Logic
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        //Modified by Wilken on 20130828 for HK MFM Sales PO Approval Process
                        System.debug('SalesByPass: ' + brm.ASI_MFM_Route_Type__r.ASI_MFM_ByPassThreshold__c + ' local amount: ' + local_amount);
                        
                        if (brm.ASI_MFM_Route_Type__r.ASI_MFM_ByPassThreshold__c){
                            if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null) &&
                                local_amount > brm.ASI_MFM_Route_Type__r.ASI_MFM_Sales_Route_Type_Amount_From__c && local_amount <= brm.ASI_MFM_Route_Type__r.ASI_MFM_Sales_Route_Type_Amount_To__c ) {
                                    rtid = brm.ASI_MFM_Route_Type__c;
                                    backupApproverID = brm.ASI_MFM_Route_Type__r.ASI_MFM_Backup_Approver__c;
                                    break;
                                }
                            else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                                break;
                            }                       
                        }
                        else {
                            //End Modification on 20130828
                            if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null)) {
                                rtid = brm.ASI_MFM_Route_Type__c;
                                break;
                            }
                            else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                                break;
                            }                       
                        }
                    }
                    //Howard@Introv 7/1/2020 HK PO Trigger approver update logic only update on 'Draft' status
                    if(p.ASI_MFM_Status__c == 'Draft')
                    {
                        if (rtid != null) {
                            for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {                      
                                if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
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
                                    approver_count++;                                                                                                                               
                                }
                                else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                    break;
                                }
                            }
                            //If there are only 1 approver and approver is PO owner, assign Backup Approver (defined in Route Type) as approver
                            if (p.ASI_MFM_Sys_Approver_1__c == p.ownerID && p.ASI_MFM_Sys_Approver_2__c == null && p.ASI_MFM_Sys_Approver_3__c == null && p.ASI_MFM_Sys_Approver_4__c == null
                                && p.ASI_MFM_Sys_Approver_5__c == null && p.ASI_MFM_Sys_Approver_6__c == null && p.ASI_MFM_Sys_Approver_7__c == null && p.ASI_MFM_Sys_Approver_8__c == null && p.ASI_MFM_Sys_Approver_9__c == null){
                                    
                                    p.ASI_MFM_Sys_Approver_1__c = backupApproverID;
                                }
                            
                            //If there are more than one approver and first approver is the same as PO owner, skip the first approver
                            if (p.ASI_MFM_Sys_Approver_1__c == p.ownerID && (p.ASI_MFM_Sys_Approver_2__c != null || p.ASI_MFM_Sys_Approver_3__c != null || p.ASI_MFM_Sys_Approver_4__c != null || p.ASI_MFM_Sys_Approver_5__c != null || p.ASI_MFM_Sys_Approver_6__c != null || p.ASI_MFM_Sys_Approver_7__c != null || p.ASI_MFM_Sys_Approver_8__c != null || p.ASI_MFM_Sys_Approver_9__c != null)){
                                p.ASI_MFM_Sys_Approver_1__c = p.ASI_MFM_Sys_Approver_2__c;
                                p.ASI_MFM_Sys_Approver_2__c = p.ASI_MFM_Sys_Approver_3__c;
                                p.ASI_MFM_Sys_Approver_3__c = p.ASI_MFM_Sys_Approver_4__c;
                                p.ASI_MFM_Sys_Approver_4__c = p.ASI_MFM_Sys_Approver_5__c;
                                p.ASI_MFM_Sys_Approver_5__c = p.ASI_MFM_Sys_Approver_6__c;
                                p.ASI_MFM_Sys_Approver_6__c = p.ASI_MFM_Sys_Approver_7__c;
                                p.ASI_MFM_Sys_Approver_7__c = p.ASI_MFM_Sys_Approver_8__c;
                                p.ASI_MFM_Sys_Approver_8__c = p.ASI_MFM_Sys_Approver_9__c;
                            }
                            
                            //Assign Backup Approver into Budget Owner lookup field, for HK FOC to set as approver in case MFM PO do not have approver 2
                            p.ASI_MFM_Budget_Owner__c = backupApproverID;
                        }  
                    }
                }               
            }     
        }
    } 
    
    
    public static void routineAfterUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Added by Alan Wong(Elufa) 20150520 - Populate the exchange rate to PO line items
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
        //Modified by Wilken on 20131021, when an Adjustment PO is approved, update Amount to Adjusted Amount, append line item to Original PO
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                if (p.ASI_MFM_Status__c == 'Final' && (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft' || trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') && p.ASI_MFM_Original_PO_for_Adjustment__c != null){
                    String soql = getCreatableFieldsSOQL('ASI_MFM_PO_Line_Item__c','ASI_MFM_PO__c= \'' + p.id + '\'');
                    System.debug('SOQL: ' + soql);
                    List<ASI_MFM_PO_Line_Item__c> plList = (List<ASI_MFM_PO_Line_Item__c>)Database.query(soql);
                    List<ASI_MFM_PO_Line_Item__c> pLineListInsert = new List<ASI_MFM_PO_Line_Item__c>();
                    List<ASI_MFM_PO_Line_Item__c> pLineListUpdate = new List<ASI_MFM_PO_Line_Item__c>();
                    
                    for (ASI_MFM_PO_Line_Item__c pl : plList){
                        ASI_MFM_PO_Line_Item__c pl2 = pl.clone(false, true);
                        pl2.ASI_MFM_PO__c = p.ASI_MFM_Original_PO_for_Adjustment__c;
                        pl2.ASI_MFM_Adjust_PO_Number__c = p.id;
                        pLineListInsert.add(pl2);
                        
                        pl.ASI_MFM_Adjusted_Amount__c = pl.ASI_MFM_Amount__c;
                        pl.ASI_MFM_Amount__c = 0;
                        pl.ASI_MFM_JDE_Status__c = 'Paid';
                        pLineListUpdate.add(pl);
                    }
                    update pLineListUpdate;
                    insert pLineListInsert;                    
                }
            }
        }
        
        // Added by 2017-12-21 Linus@introv
        // When status is 'Final', PDF will be auto-generated and save as attachment in PO                
        for(ASI_MFM_PO__c po: trigger_new){
            if(po.ASI_MFM_Status__c == 'Final' && trigger_oldmap.get(po.id).ASI_MFM_Status__c != 'Final'&& trigger_oldmap.get(po.id).ASI_MFM_Status__c != 'Complete'){
                ASI_MFM_SavePDFAsAttachment.savePDF(po.id, po.Name, 'HK');
            }
            
        }
        
    }
    
    public static void routineAfterAll (list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        Id userId=userinfo.getUserId();
        Boolean bypass = false;
        for(User u: [Select Id,BypassTriggers__c  from User where Id=:userId]){
            bypass = (u.BypassTriggers__c!=null && u.BypassTriggers__c.contains('ASI_MFM_HK_BypassTrigger'))? true:false;
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
            list<ASI_MFM_Plan__c> p_list = [select ASI_MFM_Plan_Balance__c, ASI_MFM_Plan_Amount__c, ASI_MFM_Currency__c, (select Name, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c from POs__r) from ASI_MFM_Plan__c where id in :pid_set for update];
            
            // end of Changes
            for (ASI_MFM_Plan__c p:p_list) {
                ASI_MFM_Plan__c plan = p;
                p.ASI_MFM_Total_PO_Amount__c = 0;
                for (ASI_MFM_PO__c po:p.POs__r) {
                    if (po.ASI_MFM_Exchange_Rate__c > 0) {
                        System.Debug('Plan Total PO Amt: ' +  p.ASI_MFM_Total_PO_Amount__c + 'PO No.: ' + po.Name + ' PO Amt: ' + po.ASI_MFM_PO_Amount__c + ' Ex Rate: ' + po.ASI_MFM_Exchange_Rate__c);  
                        p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(2, roundingmode.half_up);
                    }
                }
                
                System.Debug('ASI_MFM_Total_PO_Amount__c = ' + p.ASI_MFM_Total_PO_Amount__c );  
                
                if (p.ASI_MFM_Plan_Type__c != 'A&D' && p.ASI_MFM_Total_PO_Amount__c > p.ASI_MFM_Plan_Amount__c && !bypass)
                    plan.addError('Total PO amount exceeds the available plan balance. Plan Amount: ' + p.ASI_MFM_Plan_Amount__c + ' Total PO Amount: ' + p.ASI_MFM_Total_PO_Amount__c);
            }
            if(!Test.isRunningTest())
                update p_list;
        }
    }
    
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        
    }
}