public without sharing class ASI_MFM_GF_PO_TriggerClass {
    
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
            
                                    
        }  
        
        //Updated by Introv 20170731 added prefix to include "Accrual PO" type
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name,ASI_MFM_Company__c, asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c, ASI_MFM_TW_Delivery_Address__c from asi_mfm_prefix__c where ( asi_mfm_module__c = 'PO' or asi_mfm_module__c = 'Direct PO' or asi_mfm_module__c='Accrual PO')and id in :px_set for update]);
        
        for (ASI_MFM_PO__c p:trigger_new) {
            
            
            
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                
                //20161230 Wilken, Gulf Duty Free uses 5 characters prefix
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }
                    else if (px_map.get(p.asi_mfm_prefix__c).name.length() == 4){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    }
                }
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }
        update pr;
        ASI_MFM_Function.updatePrefix(px_map.values());        
    }

    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
// Set the approvers for the PO based on the routing rule objects           
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<id> pr_set = new set<id>();
        boolean isJP = false;
        boolean isTRLogic = false;
        
        id overrideRouteTypeId =  null;
        Set<id> poIDSet = new Set<id>();
        Map<id,ASI_MFM_PO__c> gfPOMap = new Map<id,ASI_MFM_PO__c>();
        Set<id> owner_set = new Set<id>();
        
        //Add by Introv 20170721 Only IT Admin can edit "Accrual PO" Records (check through permission set):
        /**
        if(!system.isBatch()){
            Boolean isAdmin = false;
            //get current user permission sets
            List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment
                                                                   WHERE AssigneeId = :Userinfo.getUserId()];
            
            for(PermissionSetAssignment permission : listCurrentUserPerSet){
                if(permission.PermissionSet.Name == 'ASI_MFM_TW_Plan_PO_Admin_User' || permission.PermissionSet.Name == 'ASI_CRM_TW_System_Admin' ){
                    isAdmin = true;
                    break;
                }
            }
            if(!isAdmin){
                for(ASI_MFM_PO__c po: trigger_new){
                    if(po.ASI_MFM_Accrual_PO__c && (po.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only') || po.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_TW_PO') )){
                        po.addError('Only IT Admin can edit accrual PO.');
                    }
                }
            }            
        }
        **/
        
        
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
            
            //GF Logic: For Final PO, do not allow changing to a greater amount
            if (Global_RecordTypeCache.getRt(p.recordTypeID).DeveloperName.contains('ASI_MFM_GF')){
                //Comment out By Elufa 20151215
               // System.debug('Original Amount: ' + trigger_oldMap.get(p.id).ASI_MFM_PO_Amount__c + ' New Amount:' + p.ASI_MFM_PO_Amount__c + ' Status: ' + p.ASI_MFM_Status__c);
               // if (p.ASI_MFM_Is_Direct_Payment__c == false && p.ASI_MFM_Status__c == 'Final' && p.ASI_MFM_PO_Amount__c > trigger_oldMap.get(p.id).ASI_MFM_PO_Amount__c){
              //      p.addError('PO amount cannot be increased after approval.');
             //   }
                
                //Wilken 20150324, validate no outstanding payment and receipt when complete PO
                if (p.ASI_MFM_Status__c == 'Complete' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final'){
                    poIDSet.add(p.id);
                }
                gfPOMap.put(p.id, p);  
                
                owner_set.add(p.OwnerId);             
            }            
        }       
        
        //if (poIDSet != null){
        if (!poIDSet.isEmpty()){           
            for (ASI_MFM_PO_Receipt_Item__c receiptLine:[select ASI_MFM_PO_Receipt__r.Name, ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c, ASI_MFM_PO__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO__c = :poIDSet]){
                if (receiptLine.ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c != 'Final'){
                    gfPOMap.get(receiptLine.ASI_MFM_PO__c).addError('Cannot complete PO, Receipt ' + receiptLine.ASI_MFM_PO_Receipt__r.Name + ' is not final yet');
                }
            }           
                        
            List<ASI_MFM_Payment_Line_Item__c> paymentLineList = new List<ASI_MFM_Payment_Line_Item__c>([select ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_Payment__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :poIDSet]);
            
            System.debug('Payment Line Query by PO ID: ' + paymentLineList);
            
            for (ASI_MFM_Payment_Line_Item__c paymentLine:paymentLineList){
                System.debug('PO Complete Validation, Payment Status: ' + paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c);
                if (paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c != 'Final'){
                    gfPOMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c).addError('Cannot complete PO, Payment ' + paymentLine.ASI_MFM_Payment__r.Name + ' is not approved yet');
                }
            }
            
        }
        
        if (pid_set.size() > 0) {       
            System.debug('Start assign approver');
            
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
            // Modified by 2018-01-04 Linus@introv 
            // Add filter if Responsible by is not null
                brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c, ASI_MFM_Responsible_by__c from ASI_MFM_Brand_Route_Type_Map__c 
                where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set
                order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];
            
             System.debug('brm_list: ' + brm_list);
            set<id> rt_set = new set<id>();    
            Boolean IsDutyFree = false;    
            for(ASI_MFM_PO__c p:trigger_new){
                // Modified by 2018-01-05 Linus@introv
                // Add logic to define route type with respect to Responsible by if prefix is Duty Free
                for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                    if(brm.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c != 'Duty Free'){
                        rt_set.add(brm.ASI_MFM_Route_Type__c);
                    }else{
                        if(brm.ASI_MFM_Responsible_by__c != null && brm.ASI_MFM_Responsible_by__c == p.OwnerId){
                            rt_set.add(brm.ASI_MFM_Route_Type__c);
                            IsDutyFree = true;
                        }
                    }
                }    
                      
            }           
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];
              
            
            for (ASI_MFM_PO__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {

                    id rtid;
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c ) {
                            
                            rtid = brm.ASI_MFM_Route_Type__c;
                            System.debug('rtid_in: ' + rtid);
                            
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
                                if ((rd.ASI_MFM_Route_Type__c == rtid || IsDutyFree) && rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
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
                                
                                else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                    break;
                                }
                            }

                            
                        }
                    } 
                    else {
                        System.debug('No rt id' );
                        //If the Responsible by is changed, need check the line item.
                         
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
        
        String GFSupplierDefault;
        
        boolean SGChangeCurrency =false;
        
        
        //20171024 Introv added to retrieve Original PO Status
        
        Set<Id> originalPOSet = new Set<Id>();
        Set<Id> POIdSet = new Set<Id>();
        //20171024 End
        
        
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            
            if(Setting.name == 'GF_EventFOC_VAPFOC_Supplier__c' && Setting.Country__c == 'GF'){
                    GFSupplierDefault = Setting.ASI_MFM_value__c;
            }
        }
        
        for (ASI_MFM_PO__c po:trigger_new) {
            
            if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_GF_PO')){
                if(po.ASI_MFM_Supplier_Name__c == null &&  GFSupplierDefault != null && GFSupplierDefault != '' && (po.ASI_MFM_PO_Type__c == 'VAP FOC' || po.ASI_MFM_PO_Type__c == 'Event FOC')){
                     po.ASI_MFM_Supplier_Name__c = GFSupplierDefault;
                }
            }           
            
            // Check if there was an input in the decimal number output error
            boolean isDecimal = (ASI_MFM_Function.containsDecimalValue(po.ASI_MFM_PO_Original_Amount__c) || ASI_MFM_Function.containsDecimalValue(po.ASI_MFM_PO_Amount__c)) && po.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                po.addError(' You Cannot input a decimal number for a TWD currency.');
            System.debug('ASI_MFM_Exchange_Rate__c '+po.ASI_MFM_Exchange_Rate__c);
            if (po.ASI_MFM_Exchange_Rate__c == null) {
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }
            //ATR MFM Follows standard exchange rate logic, only fill in if the field is empty
            /*else if (Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_TR_PO')){ //TR Logic: Cal. Exchange rate all the time
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }*/
            else if (Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_GF_PO')){ //GF Logic: Cal. Exchange rate all the time
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }
            
        }
        
        
         System.debug('po_set_size '+po_set.size());
        if (po_set.size() > 0){
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            

            //Steve Wan 20140527 Edit for special handling in TR
            System.debug('country '+country );

            
            
            
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
                                if (xr.ASI_MFM_Counter_Currency__c == po.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= po.ASI_MFM_PO_Raised_Date__c && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
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
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)&& !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
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
                    if (!valid_prefix && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                    }
                }
            }
        }
        
//Added by Wilken on 20140311, Clone for adjust PO should not allow user to change PO currency      
        //Modified by Wilken 20140317, reduce SOQL usage
        //map<id, recordType> rt_map = new map<id, recordType>([select id, developerName from recordType where sobjectType = 'ASI_MFM_PO__c']);
        
        
    }

}