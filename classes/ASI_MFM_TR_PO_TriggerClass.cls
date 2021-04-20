public without sharing class ASI_MFM_TR_PO_TriggerClass {
    
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
            
            system.debug('Linus: Cloned PO ID(Before INsert): ' + p.ASI_MFM_Cloned_PO_ID__c);                        
        }          
        
        //Updated by Introv 20170731 added prefix to include "Accrual PO" type, //20180115 Introv added Dummy PO
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name,ASI_MFM_Company__c, ASI_MFM_Parent_Prefix__c, asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c, ASI_MFM_TW_Delivery_Address__c from asi_mfm_prefix__c where ( asi_mfm_module__c = 'PO' or asi_mfm_module__c = 'Direct PO' or asi_mfm_module__c='Accrual PO' or asi_mfm_module__c='Dummy PO')and id in :px_set for update]);
        
        for (ASI_MFM_PO__c p:trigger_new) {
            
            
            
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TR_PO')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 4){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    }else { //else == 2
                        p.name = px_map.get(p.asi_mfm_prefix__c).name +  string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000000).substring(1, 7);
                    }
                    
                }
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }

        ASI_MFM_Function.updatePrefix(px_map.values());        
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        set<id> acc_set = new set<id>();
        set<id> po_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
        
        for(ASI_MFM_PO__c po: trigger_new){
            if( !(po.ASI_MFM_Status__c == 'Final' && trigger_oldmap !=null && trigger_oldmap.get(po.id).ASI_MFM_Status__c == 'Complete')){
                System.debug('po.ASI_MFM_Supplier_Name__c' + po.ASI_MFM_Supplier_Name__c);
                acc_set.add(po.ASI_MFM_Supplier_Name__c);
                
                ccy_set.add(po.ASI_MFM_Currency__c);
                
                last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
            }
            
        }
        
        //Steve Wan 20140619 Edit for special handling in TR
        list<account> acc_list = new list<account>();
        if (acc_set.size() > 0){
            acc_list = [select id, ASI_HK_CRM_Type__c from account 
                                    where id in :acc_set];
            for (ASI_MFM_PO__c po:trigger_new){
                
                System.debug('acc_list' + acc_list);
                if (acc_list.size() > 0 ){
                    for (account ac :acc_list){
                        if (po.ASI_MFM_Supplier_Name__c == ac.id && ac.ASI_HK_CRM_Type__c != po.ASI_MFM_TR_Rec_Type__c){
                            po.ASI_MFM_Supplier_Name__c.addError('The Supplier is not valid for this PO.');
                        }
                    }
                }                                
            }
        }
        Boolean  EXnull = false;
        for(ASI_MFM_PO__c po: trigger_new){
            //TR Logic: Cal. Exchange rate all the time if CAPEX PO
            if( po.ASI_MFM_TR_Rec_Type__c == 'JDF'){
                po.ASI_MFM_Sys_Local_Currency__c = 'JPY';
                
            }
            else{
                po.ASI_MFM_Sys_Local_Currency__c = 'HKD';
                
            }
            country = 'TR';
            
            if(po.ASI_MFM_Exchange_Rate__c == null || po.ASI_MFM_Reference_2__c == 'CAPEX')
                EXnull = true;
        }
        if(EXnull == true){
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;         
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                                                      where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                                                      order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            
            System.debug(country+'/'+base_ccy+'/'+ccy_set+'/'+last_effective_date);
            
            for (ASI_MFM_PO__c po:trigger_new) {
                
                if (po.ASI_MFM_Currency__c == po.ASI_MFM_Sys_Local_Currency__c) {
                    po.ASI_MFM_Exchange_Rate__c = 1;
                }
                else {
                    if (po.ASI_MFM_Currency__c != null && po.ASI_MFM_PO_Raised_Date__c != null ) {                                                                           
                        for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                            if (xr.ASI_MFM_Counter_Currency__c == po.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= po.ASI_MFM_PO_Raised_Date__c ) {
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
       //****** Enhancement for supporting CAPEX Plan (MFM ATR)  Added by 2017-05-18 Linus@Introv 
       
       for(ASI_MFM_PO__c po: trigger_new){
               // Check Test Class      
            Boolean isTest = Test.isRunningTest() ? True : false;
            if( !(po.ASI_MFM_Status__c == 'Final' && trigger_oldmap !=null && trigger_oldmap.get(po.id).ASI_MFM_Status__c == 'Complete')){                
                // For CAPEX Plan & Bracket Plan only                
                id planid = po.ASI_MFM_Plan__c;
                ASI_MFM_Plan__c getPlan = [select id, name, ASI_MFM_Reference_1_List__c, ASI_MFM_Start_Date__c, ASI_MFM_End_Date__c, ASI_MFM_TR_Duration_Month__c from ASI_MFM_Plan__c where id = :planid limit 1];
                system.debug('getplan: ' + getplan.ASI_MFM_Reference_1_List__c);                
                if(getPlan != null){
                    if(getPlan.ASI_MFM_Reference_1_List__c == 'CAPEX Plan'){
                        // Reference 2 will be auto-filled 'CAPEX'
                        po.ASI_MFM_Reference_2__c = 'CAPEX';
                        
                        // Defualt A&P
                        po.ASI_MFM_AP_AD__c = 'A&P';
                        
                    }else if(getPlan.ASI_MFM_Reference_1_List__c == 'Bracket Plan'){
                        // Reference 2 will be auto-filled 'Bracket'
                        po.ASI_MFM_Reference_2__c = 'Bracket';
                    }
                        
                    // Auto-calculate PO End Date with Duration(Month)                          
                    // if Duration(Month) is 0, PO End Date is equal to PO Start Date
                    if(getplan.ASI_MFM_Reference_1_List__c != 'CAPEX Plan'){
                        if(Integer.valueOf(po.ASI_MFM_TR_Duration_Month__c) == 0 ){
                            po.ASI_MFM_PO_End_Date__c = po.ASI_MFM_PO_Start_Date__c;
                        }else{
                            po.ASI_MFM_PO_End_Date__c = po.ASI_MFM_TR_Duration_Month__c != null? po.ASI_MFM_PO_Start_Date__c.addMonths(Integer.valueOf(po.ASI_MFM_TR_Duration_Month__c)).addDays(-1): po.ASI_MFM_PO_End_Date__c;
                        }
                    }else{
                        po.ASI_MFM_PO_Start_Date__c = getPlan.ASI_MFM_Start_Date__c;
                        po.ASI_MFM_PO_End_Date__c = getPlan.ASI_MFM_End_Date__c;
                        po.ASI_MFM_TR_Duration_Month__c = getPlan.ASI_MFM_TR_Duration_Month__c;
                    }                                                                        
                }
       }    }
      //****** END - Enhancement for supporting CAPEX Plan (MFM ATR)  Added by 2017-05-18 Linus@Introv                          
    }
    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Set the approvers for the PO based on the routing rule objects    
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<id> pr_set = new set<id>();
        set<id> planid_set = new set<id>();
        boolean isBracket = false;     // Added by 2017-07-24 Linus@Introv
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if( !(p.ASI_MFM_Status__c == 'Final' && trigger_oldmap !=null && trigger_oldmap.get(p.id).ASI_MFM_Status__c == 'Complete')){
                if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                    pid_set.add(p.id);
                    px_set.add(p.ASI_MFM_Prefix__c);
                    planid_set.add(p.ASI_MFM_Plan__c);
                    isBracket=p.ASI_MFM_TR_Is_Bracket__c;
                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TR_PO')){
                        if (p.ASI_MFM_Responsible_By__c != null){
                            //p.OwnerId = p.ASI_MFM_Responsible_By__c; // Modified By 2017-07-03 Linus@Introv 
                            pr_set.add(p.ASI_MFM_Responsible_By__c);
                        }
                        
                        p.ASI_MFM_Sys_Approver_1__c = null;
                        p.ASI_MFM_Sys_Approver_2__c = null;
                        p.ASI_MFM_Sys_Approver_3__c = null;
                        p.ASI_MFM_Sys_Approver_4__c = null;
                        p.ASI_MFM_Sys_Approver_5__c = null;
                    }
                }
            }
        }// end of for loop
        
        // 'Start assign approver' 
        if (pid_set.size() > 0) {
            map<id, id> sb_map = new map<id, id>();
            map<id, ASI_MFM_Plan__c> plan_map = new map<id, ASI_MFM_Plan__c>();
            
            // Added by 2017-07-24 Linus@Introv
            Map<string, string> bracket_map = new Map<string, string>();
            for(ASI_MFM_TR_BracketPO_Market__c bracket : [Select id, name, ASI_MFM_TR_Region__c, ASI_MFM_TR_Market__c from ASI_MFM_TR_BracketPO_Market__c]){
                bracket_map.put(bracket.name, bracket.ASI_MFM_TR_Region__c);
            }            
            system.debug('Linus: Get Bracket Map: ' + bracket_map);
            
            for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :pid_set order by name desc]) {
                sb_map.put(pi.ASI_MFM_PO__c, pi.ASI_MFM_Sub_brand_Code__c);
            }
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list =[select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                                                             where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Responsible_By__c in :pr_set) 
                                                             order by ASI_MFM_Prefix__c, ASI_MFM_Responsible_By__c, ASI_MFM_Route_Type__r.name ];   //Added Route type name as ordering 2017-09-18  Linus@introv
            set<id> rt_set = new set<id>();    
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }     
            system.debug('Linus: get route type:'+rt_set);
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = isBracket == false ? [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                                                            where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c]:
                                                            [Select id, ASI_MFM_Approver__c, ASI_MFM_Route_Type__c, ASI_MFM_Region__c, ASI_MFM_Minimum_Amount__c from ASI_MFM_Route_Rule_Detail__c
                                                             where ASI_MFM_Route_Type__c in :rt_set and ASI_MFM_Region__c != null order by ASI_MFM_Route_Type__c ];   // Added by 2017-07-24 Linus@Introv
                                                             
            system.debug('Linus: Get Rout Rule Detail: ' + rule_list);
            Map<Id, ASI_MFM_Prefix__c> px_map = new Map<Id,ASI_MFM_Prefix__c>([Select id, name, ASI_MFM_Location__c from ASI_MFM_Prefix__c where id IN :px_set ]);
            
            List<ASI_MFM_Plan__c> plan_list = [Select id, ASI_MFM_Plan_Balance__c From ASI_MFM_Plan__c where id =: planid_set];
            for (ASI_MFM_PO__c p:trigger_new){
                for(ASI_MFM_Plan__c plan: plan_list){
                  if(p.ASI_MFM_Plan__c == plan.id)
                        plan_map.put(p.id, plan);
                }                
            }
            
            for (ASI_MFM_PO__c p:trigger_new) {
                integer approver_count = 0;
                Boolean isOverBalance = plan_map.get(p.id).ASI_MFM_Plan_Balance__c < 0 ? true: false;
                //Boolean isOverBalance = p.ASI_MFM_TR_Over_Plan_Balance__c;  // Added by 2017-09-20 Linus@introv
                id sbid = sb_map.get(p.id);
                id rtid;
                if (pid_set.contains(p.id)) {
                    if (p.ASI_MFM_Route_Type__c != null && (trigger_oldMap.get(p.id).ASI_MFM_Route_Type__c != null ) && (p.ASI_MFM_Route_Type__c != trigger_oldMap.get(p.id).ASI_MFM_Route_Type__c || p.ASI_MFM_Overrided_Route_Type__c) ) {
                        rtid =  p.ASI_MFM_Route_Type__c;//overrideRouteTypeId = p.ASI_MFM_Route_Type__c;    
                        p.ASI_MFM_Overrided_Route_Type__c = true  ;   system.debug('Overrider Route Type'); system.debug(rtid);
                        /*
                        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                            if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null) &&  p.ASI_MFM_Route_Type__c == brm.ASI_MFM_Route_Type__c) {
                                p.ASI_MFM_Overrided_Route_Type__c = false;
                            }
                        }*/
                    }else{
                        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                            if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null)) {
                                
                                if ( p.ASI_MFM_Overrided_Route_Type__c){
                                    rtid = p.ASI_MFM_Route_Type__c;
                                }else
                                {
                                    rtid = brm.ASI_MFM_Route_Type__c;
                                }
                                break;
                            }
                            else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                                break;
                            }                       
                        }
                    }//End else
                    
                    if (rtid != null) {
                        system.debug('Linus: CP1');  system.debug('isOverBalance: ' + isOverBalance);
                        boolean validSubBrand = false;
                        
                        decimal local_amount = p.ASI_MFM_PO_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                        system.debug('Linus: local amount: ' + local_amount);
                        p.ASI_MFM_Route_Type__c = rtid  ;  
                        for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {   system.debug('Linus: CP2: ' + rd);
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount && !isBracket && (rd.ASI_MFM_Region__c == null || (isOverBalance && rd.ASI_MFM_Region__c == 'Finance'))) {   
                            if(rd.ASI_MFM_Region__c == 'Finance') system.debug('Finance Approver');   // Debug Linus@introv
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
                            }
                            // Added by 2017-07-28 Linus@Introv
                                else if(rd.ASI_MFM_Route_Type__c == rtid && isBracket){   system.debug(bracket_map.get(px_map.get(p.ASI_MFM_Prefix__c).name));
                                    if(rd.ASI_MFM_Region__c == bracket_map.get(px_map.get(p.ASI_MFM_Prefix__c).name)){
                                        p.ASI_MFM_Sys_Approver_1__c = rd.ASI_MFM_Approver__c;  system.debug('Bracket Approver: ' + rd.ASI_MFM_Approver__c);
                                    }
                                }
                            else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                //break;   
                            }
                            
                        }
                    } 
                    else {
                        if ((trigger_oldMap == null 
                             || ((p.ASI_MFM_Source_of_A_D__c == null || p.ASI_MFM_Source_of_A_D__c == '') && (p.ASI_MFM_Responsible_By__c != trigger_oldMap.get(p.id).ASI_MFM_Responsible_By__c || rtid == null))) 
                            && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')){
                            p.adderror('The responsible by has no route type set up');
                        }
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
    // 2017-08-24 Linus@introv
    public static void routineAfterUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {        
        
        Set<Id> POId = new Set<Id>();
        
        // Added by 2017-12-21 Linus@introv
        // When status is 'Final', PDF will be auto-generated and save as attachment in PO     
        if(trigger_oldmap != null){   
            for(ASI_MFM_PO__c po: trigger_new){ system.debug('Linus: save: ' + trigger_oldmap.get(po.id).ASI_MFM_Status__c);
                if(po.ASI_MFM_Status__c == 'Final' && trigger_oldmap.get(po.id).ASI_MFM_Status__c != 'Final' && trigger_oldmap.get(po.id).ASI_MFM_Status__c != 'Complete'){
                    ASI_MFM_SavePDFAsAttachment.savePDF(po.id, po.Name, 'TR');
                }                
                if( !(po.ASI_MFM_Status__c == 'Final' && trigger_oldmap !=null && trigger_oldmap.get(po.id).ASI_MFM_Status__c == 'Complete'))
                    POId.add(po.id);
            }
            
            // Update PO line GL Date for CAPEX PO only    ********* 2017-08-24 Linus@Introv
            if(trigger_new[0].ASI_MFM_Reference_2__c == 'CAPEX' && !Test.isRunningTest())
                update [Select id from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c IN: POId]; 
        }
        
        List<ASI_MFM_PO__Share> newShare = new List<ASI_MFM_PO__Share>();
        Set<ID> shareIDs = new Set<ID>();
        for (ASI_MFM_PO__c po : trigger_new){
            if( !(po.ASI_MFM_Status__c == 'Final' && trigger_oldmap !=null && trigger_oldmap.get(po.id).ASI_MFM_Status__c == 'Complete'))
                shareIDs.add(po.ID);
        }

        if (shareIDs.size()>0){
            Map<ID, ASI_MFM_PO__Share> existShare = new Map<ID, ASI_MFM_PO__Share>([
              select ParentId, UserOrGroupId
              from ASI_MFM_PO__Share where ParentId in :shareIDs
            ]);

                for (ASI_MFM_PO__c po : trigger_new)
                {
                    if (po.ASI_MFM_Responsible_By__c == null || po.OwnerID == po.ASI_MFM_Responsible_By__c)
                    {
                        continue;
                    }
                    
              ASI_MFM_PO__Share share = existShare.get(po.ID);

              if (share == null)
              {
                share = new ASI_MFM_PO__Share(
                  ParentId = po.ID,
                  UserOrGroupId = po.ASI_MFM_Responsible_By__c,
                  AccessLevel = 'Edit',
                  RowCause = Schema.ASI_MFM_PO__Share.RowCause.Manual
                );
                newShare.add(share);
              }
              else if (share.UserOrGroupId != po.ASI_MFM_Responsible_By__c)
              {
                share.UserOrGroupId = po.ASI_MFM_Responsible_By__c;
                newShare.add(share);
              }
            }

            if (newShare.size() > 0)
            {
              upsert newShare;
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_MFM_PO__c> trigger_old) {
// Not allowed to delete if the PO has related payment line items       
        set<id> po_set = new set<id>();
        list<ASI_MFM_Payment_Line_Item__c> pi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        for (ASI_MFM_PO__c p:trigger_old) {                                               
            if (p.ASI_MFM_Status__c != 'Draft' && !Test.isRunningTest())
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
            if (pi_map.get(p.id) > 0 && !Test.isRunningTest()) {
                p.addError('Not allowed to delete because it has related payment line items');
            }
        }
    }
}