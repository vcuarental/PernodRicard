public without sharing class ASI_CRM_TW_FreeGoodsRequest_TriggerCls{

    Private Static Final Map<String, Schema.SObjectField> Free_Goods_Request_FIELD_MAP = Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> CRM_Fix_Approval_Route_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    
    //20200319:AM - CR on FOC/POSM approval start
    Private Static Final List<ASI_CRM_Dynamic_Approval_Route__c> G_AppRoute_Dynamic = [SELECT Id, ASI_CRM_Type__c, ASI_CRM_User__c, ASI_CRM_Manager_ID__c, ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Skip_to_Next_Level__c 
                                                                                   FROM ASI_CRM_Dynamic_Approval_Route__c 
                                                                                   WHERE RecordType.DeveloperName = 'ASI_CRM_TW_Dynamic_Approval_Route' AND ASI_CRM_Type__c IN ('FOC','POSM')];
    Private Static Final List<ASI_CRM_Fix_Approval_Route__c> G_AppRoute_Fix = [SELECT Id, ASI_CRM_CN_Type__c, ASI_CRM_Department__c, ASI_CRM_Finance_Approver__c, ASI_CRM_Brand__r.ASI_MFM_Brand_Code__c, ASI_CRM_Channel__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_CN_Region_Area_Channel__c, ASI_CRM_Company__c, ASI_CRM_CN_Entry_Limit__c
                                                                               		, ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c, ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c, ASI_CRM_CN_Approver_7__c, ASI_CRM_CN_Approver_8__c, ASI_CRM_CN_Approver_9__c, ASI_CRM_CN_Approver_10__c, ASI_CRM_CN_Approver_11__c, ASI_CRM_CN_Approver_12__c, ASI_CRM_CN_Approver_13__c
                                                                               		, ASI_CRM_CN_Approval_Limit_1__c, ASI_CRM_CN_Approval_Limit_2__c, ASI_CRM_CN_Approval_Limit_3__c, ASI_CRM_CN_Approval_Limit_4__c, ASI_CRM_CN_Approval_Limit_5__c, ASI_CRM_CN_Approval_Limit_6__c, ASI_CRM_CN_Approval_Limit_7__c, ASI_CRM_CN_Approval_Limit_8__c, ASI_CRM_CN_Approval_Limit_9__c, ASI_CRM_CN_Approval_Limit_10__c, ASI_CRM_CN_Approval_Limit_11__c, ASI_CRM_CN_Approval_Limit_12__c, ASI_CRM_CN_Approval_Limit_13__c
                                                                               FROM ASI_CRM_Fix_Approval_Route__c 
                                                                               WHERE RecordType.DeveloperName = 'ASI_CRM_TW_Fix_Approval_Route' AND ASI_CRM_CN_Type__c IN ('FOC','POSM')];
    Private Static Final List<ASI_CRM_TW_Field_Mapping__mdt> G_MDT_FieldMap = [SELECT Id, ASI_CRM_Type__c, ASI_CRM_From_Value__c, ASI_CRM_To_Value__c, ASI_CRM_Channel__c
                                                                                FROM ASI_CRM_TW_Field_Mapping__mdt 
                                                                            	WHERE ASI_CRM_Type__c IN ('Department','Account Type')];
    
    Private Static Final Id G_FOC_RT_TW_FOC = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request');
    Private Static Final Id G_FOC_RT_TW_FOC_RO = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request_Read_Only');
    Private Static Final Id G_FOC_RT_TW_POSM = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request');
    Private Static Final Id G_FOC_RT_TW_POSM_RO = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request_Read_Only');
    //20200319:AM - CR on FOC/POSM approval end

    //Bypass user from specific validation
    private static Boolean isBypassByCurrentUser() {
        Boolean isByPass = false;
        ID curUserId = UserInfo.getUserId();
        List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :curUserId];
        if (users.size() > 0 && users[0].BypassTriggers__c != null) {
            if (users[0].BypassTriggers__c.contains('ASI_CRM_TW_FreeGoodsRequest_TriggerCls')){
                isByPass = true;
        }
    }
        return isByPass;
    }
    
    public static void routineBeforeInsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new) {
        Set<id> setPlanId = new Set<Id>();
        for (ASI_FOC_Free_Goods_Request__c fgr : trigger_new) {
			setPlanId.add(fgr.ASI_CRM_Plan__c);
        }
        Map<Id, ASI_MFM_Plan__c> oMapPlan = new Map<Id, ASI_MFM_Plan__c>([SELECT Id,ASI_MFM_Prefix__c,ASI_MFM_Prefix__r.ASI_MFM_Trade__c FROM ASI_MFM_Plan__c WHERE Id IN :setPlanId]);
        for (ASI_FOC_Free_Goods_Request__c fgr : trigger_new) {
            if (oMapPlan.containsKey(fgr.ASI_CRM_Plan__c)) {
                ASI_MFM_Plan__c oPlan = oMapPlan.get(fgr.ASI_CRM_Plan__c);
				fgr.ASI_CRM_Trade__c = oPlan.ASI_MFM_Prefix__r.ASI_MFM_Trade__c != NULL ? oPlan.ASI_MFM_Prefix__r.ASI_MFM_Trade__c : FALSE;
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        Set<Id> setDeliveryToId = new Set<Id>();
        Map<Id, Account> mapDeliveryTo = new Map<Id, Account>();
        
        for(ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
            if(fgr.ASI_CRM_Delivery_To__c != NULL)
                setDeliveryToId.add(fgr.ASI_CRM_Delivery_To__c);
            else
                setDeliveryToId.add(fgr.ASI_CRM_Target_Outlet__c);
        }
        
        for(Account acc : [SELECT ASI_HK_CRM_Address__c, Phone, RecordType.developername, ASI_MFM_Address_Line_4__c, 
                            (select id, ASI_CRM_TW_Invoice_Address__c, ASI_CRM_WHAddress__c, ASI_CRM_TW_Warehouse_Address__c 
                            from ASI_CRM_Accounts_Additional_Fields__r), (select id, firstname, lastname from contacts)
                            FROM Account 
                            WHERE Id 
                            IN: setDeliveryToId]){
            mapDeliveryTo.put(acc.id, acc);
        }
        
        for(ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
            if(fgr.ASI_CRM_Requester__c == NULL){
                fgr.ASI_CRM_Requester__c = UserInfo.getUserId();
            }
            if(fgr.ASI_CRM_Delivery_To__c == NULL){
                fgr.ASI_CRM_Delivery_To__c = fgr.ASI_CRM_Target_Outlet__c;
            }
            if(mapDeliveryTo != NULL && mapDeliveryTo.size() > 0){
                Account tempacc = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c);
                if(!tempacc.RecordType.developername.contains('ASI_MFM_TW_Supplier'))
                {
                    if(mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r.size() > 0)
                    {
                        if(mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c != null)
                        {
                            fgr.ASI_CRM_SG_Delivery_Address__c = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c;
                        }
                        else 
                        {
                            fgr.ASI_CRM_SG_Delivery_Address__c = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                        }
                    }
                    else 
                    {
                        fgr.ASI_CRM_SG_Delivery_Address__c = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                    }
                }
                else 
                {
                    fgr.ASI_CRM_SG_Delivery_Address__c = tempacc.ASI_MFM_Address_Line_4__c;
                }
                fgr.ASI_CRM_Delivery_Tel__c = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).Phone;
                if(mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).contacts.size() >0)
                {
                    fgr.ASI_CRM_Receiver__c = (mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).contacts[0].LastName == null ? '' : mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).contacts[0].LastName) + ' ' + (mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).contacts[0].FirstName == null ? '' : mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).contacts[0].FirstName);
                }
                /*if(fgr.ASI_CRM_SG_Delivery_Address__c == NULL){
                    fgr.ASI_CRM_SG_Delivery_Address__c = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                }
                if(fgr.ASI_CRM_Delivery_Tel__c == NULL){
                    fgr.ASI_CRM_Delivery_Tel__c = mapDeliveryTo.get(fgr.ASI_CRM_Delivery_To__c).Phone;
                }*/
            }
        }
        
        Map<String, ASI_FOC_Route_Type__c> mapFOCRT = new Map<String, ASI_FOC_Route_Type__c>();
        for(ASI_FOC_Route_Type__c focRt : [SELECT RecordTypeId, ASI_FOC_Logistic_Approver__c
                                             FROM ASI_FOC_Route_Type__c 
                                             WHERE recordTypeId =: Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_FOC_Route_Type') OR 
                                             recordTypeId =: Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_POSM_Route_Type')
                                             ORDER BY CreatedDate ASC]){
            if(focRt.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_FOC_Route_Type'))
                mapFOCRT.put('FOC', focRt);    
            else if(focRt.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_POSM_Route_Type'))
                mapFOCRT.put('POSM', focRt);    
        }

                                               
        for(ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
            if(mapFOCRT != null && mapFOCRT.size() > 0){
                if(fgr.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'))
                    fgr.ASI_FOC_Logistic_Approver__c = mapFOCRT.get('FOC').ASI_FOC_Logistic_Approver__c;
                else if(fgr.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'))
                    fgr.ASI_FOC_Logistic_Approver__c = mapFOCRT.get('POSM').ASI_FOC_Logistic_Approver__c;
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        Boolean isAdmin = false;
        Set<Id> setRequestId = new Set<Id>();
        Set<id> setPlanId = new Set<Id>();
        
        //get current user permission sets
        if(!Test.isRunningTest())
        {
            for(PermissionSetAssignment permission : [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()]){
                if(permission.PermissionSet.Name == 'ASI_CRM_TW_IT_Admin')
                    isAdmin = true;
            }
        }
        
        map<id, ASI_FOC_Free_Goods_Request__c> reject_map = new map<id, ASI_FOC_Free_Goods_Request__c>();
        
        for(ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
            
            
            if(Test.isRunningTest() || !isAdmin){
                
                if(trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c == 'Cancel'){
                    fgr.addError('You are not allowed to edit \'Cancel\' Request.');
                }
                else if(trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c.contains('Complete')){
                    fgr.addError('You are not allowed to  edit \'Complete\' Request.');
                }
                
                //OP Team User can only update Final Request Header to Approved/Cancel, cannot update non-Draft Request to Draft
                if(trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c == 'Final' && 
                   (fgr.ASI_FOC_Request_Status__c != 'Final' && 
                    fgr.ASI_FOC_Request_Status__c != 'Approved' && 
                    fgr.ASI_FOC_Request_Status__c != 'Cancel') &&
                    !Test.isRunningTest()){
                    fgr.addError('You can update \'Final\' Request to \'Approved\' or \'Cancel\' only.');
                }
                else if((trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c != 'Draft' && 
                         trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c != 'Submitted') &&
                         fgr.ASI_FOC_Request_Status__c == 'Draft' &&
                         !Test.isRunningTest()){
                    fgr.addError('You cannot update Request to \'Draft\' status.');
                }
                else if(trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c == 'Draft' && !Test.isRunningTest()){
                    if(fgr.ASI_FOC_Request_Status__c == 'Approved')
                        fgr.addError('You cannote update \'Draft\' Request to \'Approved\'.');
                    else if(fgr.ASI_FOC_Request_Status__c == 'Final')
                        fgr.addError('You cannote update \'Draft\' Request to \'Final\'');
                }
            }
            
            //Update record type to be Read-Only if Status is 'Approved' or 'Final' or 'Completed' or 'Cancel'
            if(fgr.ASI_FOC_Request_Status__c == 'Approved' || fgr.ASI_FOC_Request_Status__c.contains('Complete') || fgr.ASI_FOC_Request_Status__c == 'Final' || fgr.ASI_FOC_Request_Status__c == 'Cancel'){
                if(fgr.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'))
                    fgr.recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request_Read_Only');
                else if(fgr.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'))
                    fgr.recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request_Read_Only');
            }
            
            //Update record type to non Read-Only if Status is 'Draft'
            if(fgr.ASI_FOC_Request_Status__c == 'Draft'){
                if(fgr.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request_Read_Only'))
                    fgr.recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request');
                else if(fgr.recordTypeId == Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request_Read_Only'))
                    fgr.recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request');
            }
            
            // Added by 2018-07-06 Linus@introv
            if(fgr.ASI_FOC_Request_Status__c == 'Draft'&& trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c != 'Draft'){
                setPlanId.add(fgr.ASI_CRM_Plan__c); 
                setRequestId.add(fgr.Id);      
                if (fgr.ASI_FOC_Request_Status__c == 'Draft' && trigger_oldMap.get(fgr.id).ASI_FOC_Request_Status__c == 'Submitted') {
                    reject_map.put(fgr.id, fgr);
                }
            }
        }
        
         if (reject_map.size() > 0) {
            list<ASI_FOC_Free_Goods_Request__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_FOC_Free_Goods_Request__c where id in :reject_map.keySet()];
            for (ASI_FOC_Free_Goods_Request__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    System.debug('Rejected Payment ProcessSteps: ' + r.processSteps + ' ProcessStep0: ' + r.processSteps[0]);
                    //reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_FOC_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
        
        //20200319:AM - CR on FOC/POSM approval start
        setApprovers(trigger_new);
        //return;
        //20200319:AM - CR on FOC/POSM approval end
        
/*
        // Determine Approvers
        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicRouteFOC = new List<ASI_CRM_Dynamic_Approval_Route__c>();
        dynamicRouteFOC = [Select Id, ASI_CRM_User__c, ASI_CRM_Manager_ID__c, ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Skip_to_Next_Level__c From ASI_CRM_Dynamic_Approval_Route__c Where ASI_CRM_Type__c = 'FOC' And RecordType.DeveloperName = 'ASI_CRM_TW_Dynamic_Approval_Route'];
        Map<Id, ASI_CRM_Dynamic_Approval_Route__c> dynamicRouteFOCmap = new Map<Id, ASI_CRM_Dynamic_Approval_Route__c>();
        for(ASI_CRM_Dynamic_Approval_Route__c item: dynamicRouteFOC)
        {
            dynamicRouteFOCmap.put(item.ASI_CRM_User__c, item);
        }
        
        List<ASI_CRM_Dynamic_Approval_Route__c> dynamicRoutePOSM = new List<ASI_CRM_Dynamic_Approval_Route__c>();
        dynamicRoutePOSM = [Select Id, ASI_CRM_User__c, ASI_CRM_Manager_ID__c, ASI_CRM_End_of_Dynamic_Route__c, ASI_CRM_Skip_to_Next_Level__c From ASI_CRM_Dynamic_Approval_Route__c Where ASI_CRM_Type__c = 'POSM' And RecordType.DeveloperName = 'ASI_CRM_TW_Dynamic_Approval_Route'];
        Map<Id, ASI_CRM_Dynamic_Approval_Route__c> dynamicRoutePOSMmap = new Map<Id, ASI_CRM_Dynamic_Approval_Route__c>();
        for(ASI_CRM_Dynamic_Approval_Route__c item: dynamicRoutePOSM)
        {
            dynamicRoutePOSMmap.put(item.ASI_CRM_User__c, item);
        }
        
        List<ASI_CRM_TW_Field_Mapping__mdt> departmentMapping = new List<ASI_CRM_TW_Field_Mapping__mdt>();
        departmentMapping = [Select Id, ASI_CRM_From_Value__c, ASI_CRM_To_Value__c From ASI_CRM_TW_Field_Mapping__mdt Where ASI_CRM_Type__c = 'Department'];
        Map<String, String> departmentConvertMap = new Map<String, String>();
        for(ASI_CRM_TW_Field_Mapping__mdt item: departmentMapping) 
        {
            departmentConvertMap.put(item.ASI_CRM_From_Value__c, item.ASI_CRM_To_Value__c);
        }
        
        List<ASI_CRM_TW_Field_Mapping__mdt> accTypeMapping = new List<ASI_CRM_TW_Field_Mapping__mdt>();
        accTypeMapping = [Select Id, ASI_CRM_From_Value__c, ASI_CRM_To_Value__c From ASI_CRM_TW_Field_Mapping__mdt Where ASI_CRM_Type__c = 'Account Type'];
        Map<String, String> accTypeConvertMap = new Map<String, String>();
        for(ASI_CRM_TW_Field_Mapping__mdt item: accTypeMapping) 
        {
            accTypeConvertMap.put(item.ASI_CRM_From_Value__c, item.ASI_CRM_To_Value__c);
        }
        
        List<Id> focOwnerIdList = new List<Id>();
        for(ASI_FOC_Free_Goods_Request__c foc: trigger_new) focOwnerIdList.add(foc.OwnerId);
        Map<ID, User> focOwnerMap = new Map<ID, User>([Select Id, Department, ASI_MFM_Department__c	,ManagerId, ASI_Line_Manager__c, ASI_MFM_Direct_Report__c From User Where Id in: focOwnerIdList]);
        
        List<ASI_CRM_Fix_Approval_Route__c> fixRouteFOC = new List<ASI_CRM_Fix_Approval_Route__c>();
        fixRouteFOC = [Select Id, ASI_CRM_Department__c, ASI_CRM_Finance_Approver__c, ASI_CRM_Brand__r.ASI_MFM_Brand_Code__c, ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c, ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c, ASI_CRM_CN_Approver_7__c, ASI_CRM_CN_Approver_8__c, ASI_CRM_CN_Approver_9__c, ASI_CRM_CN_Approver_10__c, ASI_CRM_CN_Approver_11__c, ASI_CRM_CN_Approver_12__c, ASI_CRM_CN_Approver_13__c From ASI_CRM_Fix_Approval_Route__c Where RecordType.DeveloperName = 'ASI_CRM_TW_Fix_Approval_Route' and ASI_CRM_CN_Type__c = 'FOC'];
        List<String> TMKTapproverIdList = new List<String>();
        List<String> FINapproverIdList = new List<String>();
        List<String> DeliverToApproverIdList = new List<String>();
        List<String> OPapproverIdList = new List<String>();
        Map<String, String> brandCodeApproverIdMap = new Map<String, String>();
        for(ASI_CRM_Fix_Approval_Route__c item : fixRouteFOC)
        {
            if(item.ASI_CRM_Department__c == 'TMKT')
            {
                TMKTapproverIdList.addAll(getCRMFixApprovalList(item));
            }
            else if(item.ASI_CRM_Department__c == 'FIN') 
            {
                FINapproverIdList.addAll(getCRMFixApprovalList(item));
                DeliverToApproverIdList.add(item.ASI_CRM_Finance_Approver__c);
            }
            else if(item.ASI_CRM_Department__c == 'OP')
            {
                OPapproverIdList.addAll(getCRMFixApprovalList(item));
            }
            else if(item.ASI_CRM_Department__c == 'MKT')
            {
                brandCodeApproverIdMap.put(item.ASI_CRM_Brand__r.ASI_MFM_Brand_Code__c, item.ASI_CRM_CN_Approver_1__c);
            }
        }
        
        List<ASI_CRM_Fix_Approval_Route__c> fixRoutePOSM = new List<ASI_CRM_Fix_Approval_Route__c>();
        fixRoutePOSM = [Select Id, ASI_CRM_Department__c, ASI_CRM_Finance_Approver__c, ASI_CRM_Brand__r.ASI_MFM_Brand_Code__c, ASI_CRM_Channel__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_CN_Approver_1__c, ASI_CRM_CN_Approver_2__c, ASI_CRM_CN_Approver_3__c, ASI_CRM_CN_Approver_4__c, ASI_CRM_CN_Approver_5__c, ASI_CRM_CN_Approver_6__c, ASI_CRM_CN_Approver_7__c, ASI_CRM_CN_Approver_8__c, ASI_CRM_CN_Approver_9__c, ASI_CRM_CN_Approver_10__c, ASI_CRM_CN_Approver_11__c, ASI_CRM_CN_Approver_12__c, ASI_CRM_CN_Approver_13__c From ASI_CRM_Fix_Approval_Route__c Where RecordType.DeveloperName = 'ASI_CRM_TW_Fix_Approval_Route' and ASI_CRM_CN_Type__c = 'POSM'];

        Map<Id, ASI_FOC_Free_Goods_Request__c> focDetailsMap = new Map<Id, ASI_FOC_Free_Goods_Request__c>([Select Id, ASI_CRM_Delivery_To__c, ASI_CRM_Target_Outlet__r.ASI_HK_CRM_Channel_Detail__c, ASI_CRM_Delivery_To__r.ASI_HK_CRM_Channel_Detail__c, (Select Id, ASI_FOC_SKU__r.ASI_TH_CRM_Brand_Code__c, ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c, ASI_FOC_SKU__r.ASI_CRM_Department__c From ASI_FOC_Request_Items__r) From ASI_FOC_Free_Goods_Request__c Where id in: trigger_new]);
        
        List<String> focDeliveryToIdList = new List<String>();
        for(ASI_FOC_Free_Goods_Request__c foc: trigger_new)
        {
            focDeliveryToIdList.add(foc.ASI_CRM_Delivery_To__c);
        }

        Map<Id, Account> accChannelMap = new Map<Id, Account>([Select Id, ASI_HK_CRM_Channel_Detail__c From Account Where id in: focDeliveryToIdList]);

        List<RecordType> CRMTWRecordTypeList = [Select Id, DeveloperName From RecordType Where SobjectType = 'ASI_FOC_Free_Goods_Request__c' and DeveloperName Like 'ASI_CRM_TW%'];
        String focRequestRTId = '';
        String focRequestReadOnlyRTId = '';
        String POSMRequestRTId = '';
        String POSMRequestReadOnlyRTId = '';
        for(RecordType rt: CRMTWRecordTypeList)
        {
            if(rt.DeveloperName == 'ASI_CRM_TW_FOC_Request')                focRequestRTId = rt.Id;
            if(rt.DeveloperName == 'ASI_CRM_TW_FOC_Request_Read_Only')      focRequestReadOnlyRTId = rt.Id;
            if(rt.DeveloperName == 'ASI_CRM_TW_POSM_Request')               POSMRequestRTId = rt.Id;
            if(rt.DeveloperName == 'ASI_CRM_TW_POSM_Request_Read_Only')     POSMRequestReadOnlyRTId = rt.Id;
        }
        for(ASI_FOC_Free_Goods_Request__c foc: trigger_new)
        {
            if(foc.ASI_FOC_Request_Status__c == 'Draft' || foc.ASI_FOC_Request_Status__c == 'Submitted')
            {
                String ownerDepartment = '';
                if(focOwnerMap.get(foc.OwnerId).ASI_MFM_Department__c != null && departmentConvertMap.get(focOwnerMap.get(foc.OwnerId).ASI_MFM_Department__c) != null)
                {
                    ownerDepartment =  departmentConvertMap.get(focOwnerMap.get(foc.OwnerId).ASI_MFM_Department__c);
                }
                //FOC
                if(foc.RecordTypeId == focRequestRTId || foc.RecordTypeId == focRequestReadOnlyRTId)
                {
                    setApproverToNull(foc);
                    List<String> approverIdList = new List<String>();
                    Boolean endOfRoute = false;
                    Id currentApprover = focOwnerMap.get(foc.OwnerId).ASI_Line_Manager__c;
                    System.debug('+++++currentApprover: ' + currentApprover);
                    System.debug('+++++endOfRoute: ' + endOfRoute);
                    System.debug('+++++ownerDepartment: ' + ownerDepartment);
                    if(focOwnerMap.get(foc.OwnerId).ASI_MFM_Direct_Report__c)
                    {
                        approverIdList.add(currentApprover);
                        endOfRoute = true;
                    }
                    while(!endOfRoute)
                    {
                        if(dynamicRouteFOCmap.get(currentApprover) != null)
                        {
                            if(ownerDepartment == 'Sales' || ownerDepartment == 'MKT')
                            {
                                if(!dynamicRouteFOCmap.get(currentApprover).ASI_CRM_Skip_to_Next_Level__c)
                                {
                                    approverIdList.add(currentApprover);
                                }
                            }
                            else
                            {
                                approverIdList.add(currentApprover);
                            }
                            endOfRoute = dynamicRouteFOCmap.get(currentApprover).ASI_CRM_End_of_Dynamic_Route__c;
                            currentApprover = dynamicRouteFOCmap.get(currentApprover).ASI_CRM_Manager_ID__c;
                        }
                        else endOfRoute =true;
                    }
                    if(ownerDepartment == 'Sales') 
                    {
                        Boolean hasTradeAP = false;
                        Boolean hasMKTAP = false;
                        if(foc.Id != null && focDetailsMap.get(foc.Id) != null)
                        {
                            for(ASI_FOC_Request_Item__c requestItem: focDetailsMap.get(foc.Id).ASI_FOC_Request_Items__r)
                            {
                                if(requestItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c != null)
                                {
                                    if(accTypeConvertMap.containsKey(requestItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c))
                                    {
                                        if(accTypeConvertMap.get(requestItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c) == 'Trade A&P') 
                                        {
                                            hasTradeAP = true;
                                        }
                                        if(accTypeConvertMap.get(requestItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c) == 'MKT A&P')
                                        {
                                            hasMKTAP = true;
                                        }
                                    }
                                }
                            }
                        }
                        if(hasTradeAP)
                        {
                            approverIdList.addAll(TMKTapproverIdList);
                        }
                        if(hasMKTAP)
                        {
                            Set<String> mktApproverIdList = new Set<String>();
                            for(ASI_FOC_Request_Item__c requestItem: focDetailsMap.get(foc.Id).ASI_FOC_Request_Items__r)
                            {
                                if(brandCodeApproverIdMap.get(requestItem.ASI_FOC_SKU__r.ASI_TH_CRM_Brand_Code__c)!= null)
                                {
                                    mktApproverIdList.add(brandCodeApproverIdMap.get(requestItem.ASI_FOC_SKU__r.ASI_TH_CRM_Brand_Code__c));
                                }
                            }
                            approverIdList.addAll(mktApproverIdList);
                        }
                        approverIdList.addAll(FINapproverIdList);
                        if(foc.ASI_CRM_Delivery_To__c != null && accChannelMap.get(foc.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Channel_Detail__c == 'PRT')
                        {
                            approverIdList.addAll(DeliverToApproverIdList);
                        }
                        approverIdList.addAll(OPapproverIdList);
                    }
                    else if(ownerDepartment == 'MKT')
                    {
                        approverIdList.addAll(FINapproverIdList);
                        if(foc.ASI_CRM_Delivery_To__c != null && accChannelMap.get(foc.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Channel_Detail__c == 'PRT')
                        {
                            approverIdList.addAll(DeliverToApproverIdList);
                        }
                        approverIdList.addAll(OPapproverIdList);
                    }
                    setApprover(foc, approverIdList);
                }
                //POSM
                else if(foc.RecordTypeId == POSMRequestRTId || foc.RecordTypeId == POSMRequestReadOnlyRTId)
                {
                    setApproverToNull(foc);
                    List<String> approverIdList = new List<String>();
                    Boolean endOfRoute = false;
                    Id currentApprover = focOwnerMap.get(foc.OwnerId).ASI_Line_Manager__c;
                    System.debug('+++++currentApprover: ' + currentApprover);
                    if(focOwnerMap.get(foc.OwnerId).ASI_MFM_Direct_Report__c)
                    {
                        approverIdList.add(currentApprover);
                        endOfRoute = true;
                    }
                    while(!endOfRoute)
                    {
                        if(dynamicRoutePOSMmap.get(currentApprover) != null)
                        {
                            if(ownerDepartment == 'Sales')
                            {
                                if(!dynamicRoutePOSMmap.get(currentApprover).ASI_CRM_Skip_to_Next_Level__c)
                                {
                                    approverIdList.add(currentApprover);
                                }
                            }
                            endOfRoute = dynamicRoutePOSMmap.get(currentApprover).ASI_CRM_End_of_Dynamic_Route__c;
                            currentApprover = dynamicRoutePOSMmap.get(currentApprover).ASI_CRM_Manager_ID__c;
                        }
                        else endOfRoute =true;
                    }
                    Boolean hasTMKT = false;
                    Boolean hasMKT = false;
                    Boolean hasPO = false;
                    Boolean hasOP = false;
                    Boolean hasHR = false;
                    if(foc.Id != null && focDetailsMap.get(foc.Id) != null)
                    {
                        for(ASI_FOC_Request_Item__c requestItem: focDetailsMap.get(foc.Id).ASI_FOC_Request_Items__r)
                        {
                            if(requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'CVS' || requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'HYP' || requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'SUP' || requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'HBR' || requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'TOT' || requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'LS' || requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'NBD') hasTMKT = true;
                            if(requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'MKT') hasMKT = true;
                            if(requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'PO') hasPO = true;
                            if(requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'OP') hasOP = true;
                            if(requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'HR') hasHR = true;
                        }
                    }
                    if(hasTMKT)
                    {
                        System.debug('++++hasTMKT: ' + hasTMKT);
                        set<String> tmktApproverList = new set<String>();
                        for(ASI_FOC_Request_Item__c requestItem: focDetailsMap.get(foc.Id).ASI_FOC_Request_Items__r)
                        {
                            for(ASI_CRM_Fix_Approval_Route__c item: fixRoutePOSM)
                            {
                                if(item.ASI_CRM_Channel__c != null && item.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c == requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c)
                                {
                                    tmktApproverList.addAll(getCRMFixApprovalList(item));
                                }
                            }
                        }
                        approverIdList.addAll(tmktApproverList);
                    }
                    System.debug('++++approverIdList1: ' + approverIdList);
                    if(hasMKT)
                    {
                        System.debug('++++hasMKT: ' + hasMKT);
                        Set<String> MKTapproverIdList = new Set<String>();
                        for(ASI_FOC_Request_Item__c requestItem: focDetailsMap.get(foc.Id).ASI_FOC_Request_Items__r)
                        {
                            for(ASI_CRM_Fix_Approval_Route__c item: fixRoutePOSM)
                            {
                                if(item.ASI_CRM_Department__c == 'MKT' && requestItem.ASI_FOC_SKU__r.ASI_CRM_Department__c == 'MKT' && item.ASI_CRM_Brand__r.ASI_MFM_Brand_Code__c == requestItem.ASI_FOC_SKU__r.ASI_TH_CRM_Brand_Code__c)
                                {
                                    MKTapproverIdList.addAll(getCRMFixApprovalList(item));
                                }
                            }  
                        }
                        approverIdList.addAll(MKTapproverIdList);
                    }
                    System.debug('++++approverIdList2: ' + approverIdList);
                    if(hasPO)
                    {
                        for(ASI_CRM_Fix_Approval_Route__c item: fixRoutePOSM)
                        {
                            if(item.ASI_CRM_Department__c == 'PO')
                            {
                                approverIdList.addAll(getCRMFixApprovalList(item));
                            }
                        }
                    }
                    if(hasOP)
                    {
                        for(ASI_CRM_Fix_Approval_Route__c item: fixRoutePOSM)
                        {
                            if(item.ASI_CRM_Department__c == 'OP')
                            {
                                approverIdList.addAll(getCRMFixApprovalList(item));
                            }
                        }
                    }
                    if(hasHR)
                    {
                        for(ASI_CRM_Fix_Approval_Route__c item: fixRoutePOSM)
                        {
                            if(item.ASI_CRM_Department__c == 'HR')
                            {
                                approverIdList.addAll(getCRMFixApprovalList(item));
                            }
                        }                        
                    }
                    setApprover(foc, approverIdList);                    
                }
            }
        }
*/
    }
    
    public static void routineBeforeDelete(list<ASI_FOC_Free_Goods_Request__c> trigger_old) {
        
        Boolean isBypass = isBypassByCurrentUser();
        Set<Id> setRequestId = new Set<Id>();
        Map<Id, ProcessInstance> mapApproval = new Map<Id, ProcessInstance>();
        
        for(ASI_FOC_Free_Goods_Request__c request : trigger_old){
            setRequestId.add(request.Id);
        }
        
        List<ProcessInstance> listApproval = [SELECT Id, Status, TargetObjectId,
                                              (SELECT Id, ActorId, ProcessInstanceId FROM Workitems) 
                                              FROM ProcessInstance WHERE TargetObjectId IN: setRequestId];
        
        for(ProcessInstance app : listApproval){
            mapApproval.put(app.TargetObjectId, app);
        }
        
        for(ASI_FOC_Free_Goods_Request__c request : trigger_old){
            // Modified by 2018-04-17 Linus@introv
            if(request.ASI_FOC_Request_Status__c != 'Draft' && isBypass//|| (request.ASI_FOC_Request_Status__c == 'Draft' && mapApproval != null && mapApproval.get(request.id) != null)
              ){
                  request.addError('You are not allowed to delete this request.');
              }
        }
        
    } 
    
    public static void routineAfterAll(List<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap){
        Set<Id> setRequestId = new Set<Id>();
        Set<id> setPlanId = new Set<Id>();
        List<ASI_MFM_Plan__c> updatePlanList = new List<ASI_MFM_Plan__c>();
        system.debug('Start After All');
        for(ASI_FOC_Free_Goods_Request__c fgr : trigger_new){
            // Added by 2018-07-06 Linus@introv
            if((fgr.ASI_FOC_Request_Status__c == 'Draft'&& trigger_oldMap.get(fgr.Id).ASI_FOC_Request_Status__c != 'Draft') || 
               (fgr.ASI_FOC_Request_Status__c != 'Draft'&& trigger_oldMap.get(fgr.id).ASI_FOC_Request_Status__c == 'Draft')){ 
                setPlanId.add(fgr.ASI_CRM_Plan__c); 
                setRequestId.add(fgr.Id);                                                                                                          
            }
        }
        
        List<ASI_FOC_Request_Item__c> AllFOC = [SELECT Id, ASI_CRM_TW_Amount__c , ASI_FOC_Request_Order__r.ASI_CRM_Plan__c, ASI_CRM_A_D_or_A_P__c ,
                     ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c,ASI_FOC_Request_Order__r.ASI_CRM_Plan__r.Name,
                      ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c
                      FROM ASI_FOC_Request_Item__c 
                      WHERE recordtype.developerName like '%TW_FOC%' 
                      and (not ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c in ('Draft','Cancel'))
                      and ASI_FOC_Request_Order__r.ASI_CRM_Plan__c IN: setPlanId ];        
        System.debug('AllFOC size: ' + allFOC.size());
        for(Id planId: setPlanId){
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c();
            plan.id = planId;
            
            plan.ASI_CRM_Total_FOC_Amount__c = 0;
            plan.ASI_CRM_FOC_Amount_w_o_A_D__c = 0;
            plan.ASI_CRM_TW_FOC_Amount_A_D__c=0;
            
            for(ASI_FOC_Request_Item__c FOC : AllFOC){
                
                if(FOC.ASI_FOC_Request_Order__r.ASI_CRM_Plan__c == plan.Id && FOC.ASI_CRM_TW_Amount__c != null){
                    plan.ASI_CRM_Total_FOC_Amount__c += FOC.ASI_CRM_TW_Amount__c;
                    plan.ASI_CRM_FOC_Amount_w_o_A_D__c += (FOC.ASI_CRM_A_D_or_A_P__c == 'A&P' && FOC.ASI_FOC_Request_Order__r.ASI_CRM_Plan__r.Name.subString(0,1)!='D'? FOC.ASI_CRM_TW_Amount__c : 0);
                    plan.ASI_CRM_TW_FOC_Amount_A_D__c += (FOC.ASI_CRM_A_D_or_A_P__c == 'A&D' ? FOC.ASI_CRM_TW_Amount__c : 0);
                    system.debug('FOC Amount: '+plan.ASI_CRM_Total_FOC_Amount__c);
                    system.debug('FOC Amount (A&P): '+plan.ASI_CRM_FOC_Amount_w_o_A_D__c);
                    system.debug('FOC Amount (A&D): '+plan.ASI_CRM_TW_FOC_Amount_A_D__c);
                }
                
            }
            
            updatePlanList.add(plan);
            
        }
        if(!Test.isRunningTest() && updatePlanList.size()>0)
            update updatePlanList;
    }

    //Michael Add 2019/07/22
    // H1 command for e approval deployment
    public static void SetDeliveryInstruction(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap){
        set<id> DeliveryToId_set = new set<id>();
        map<Id, list<ASI_CRM_AccountsAdditionalField__c>> AccId_Customer_map = new map<Id, list<ASI_CRM_AccountsAdditionalField__c>>();

        for(ASI_FOC_Free_Goods_Request__c FGR : trigger_new)
        {
            DeliveryToId_set.add(FGR.ASI_CRM_Delivery_To__c);
        }

        for(Account acc : [select id, (select ASI_TH_CRM_OperatingHoursFrom__c, ASI_TH_CRM_OperatingHoursTo__c from ASI_CRM_Accounts_Additional_Fields__r limit 1) from account where id in: DeliveryToId_set])
        {
            AccId_Customer_map.put(acc.id, acc.ASI_CRM_Accounts_Additional_Fields__r);
        }

        system.debug('++++AccId_Customer_map: '+AccId_Customer_map);

        for(ASI_FOC_Free_Goods_Request__c FGR : trigger_new)
        {
            list<ASI_CRM_AccountsAdditionalField__c> tempAAF = AccId_Customer_map.get(FGR.ASI_CRM_Delivery_To__c);
            system.debug('++1');
            system.debug('++tempAAF: ' + tempAAF);
            if(tempAAF != null)
            {
                system.debug('++2');
                if(tempAAF.size() > 0)
                {
                    system.debug('++3');
                    if(FGR.ASI_CRM_SG_Delivery_Instructions__c == null || FGR.ASI_CRM_SG_Delivery_Instructions__c == '')
                    {
                        system.debug('++4');
                        FGR.ASI_CRM_SG_Delivery_Instructions__c = tempAAF[0].ASI_TH_CRM_OperatingHoursFrom__c + ' - ' + tempAAF[0].ASI_TH_CRM_OperatingHoursTo__c;
                    }
                }
            }
        }
    }

    //Michael Add 2019/08/19
    public static void SetReceiver(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap){
        set<id> DeliveryToId_set = new set<id>();
        map<Id, list<contact>> AccId_Contact_map = new map<Id, list<contact>>();
        map<string, Account> Id_Acc_map = new map<string, Account>();
 
        for(ASI_FOC_Free_Goods_Request__c FGR : trigger_new)
        {
            DeliveryToId_set.add(FGR.ASI_CRM_Delivery_To__c);
        }
 
        for(Account acc : [select id, (select id, FirstName, LastName from Contacts where ASI_HK_CRM_Main_Contact__c = true limit 1), RecordTypeid from account where id in: DeliveryToId_set])
        {
            AccId_Contact_map.put(acc.id, acc.Contacts);
            Id_Acc_map.put(acc.id, acc);
        }
 
        for(ASI_FOC_Free_Goods_Request__c FGR : trigger_new)
        {
            system.debug('+++1');
            list<Contact> tempC = AccId_Contact_map.containsKey(FGR.ASI_CRM_Delivery_To__c) ? AccId_Contact_map.get(FGR.ASI_CRM_Delivery_To__c) : null;
            system.debug('+++tempC: '+tempC);

            if(AccId_Contact_map.containskey(FGR.ASI_CRM_Delivery_To__c))
            {
                system.debug('+++Id_Acc_map.get(FGR.ASI_CRM_Delivery_To__c).RecordTypeid: '+Id_Acc_map.get(FGR.ASI_CRM_Delivery_To__c).RecordTypeid);
                system.debug('+++id: '+Global_RecordTypeCache.getRTId('ASI_CRM_TW_Outlet'));
                if(Id_Acc_map.get(FGR.ASI_CRM_Delivery_To__c).RecordTypeid == Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Outlet'))
                {
                    if(tempC.size() > 0)
                    {
                        if(FGR.ASI_CRM_Receiver__c == null || FGR.ASI_CRM_Receiver__c == '')
                        {
                            FGR.ASI_CRM_Receiver__c = (tempC[0].LastName == null ? '' : tempC[0].LastName) + ' ' + (tempC[0].FirstName == null ? '' : tempC[0].FirstName);
                        }
                    }
                }

                //User fill manually
                //if(Id_Acc_map.get(FGR.ASI_CRM_Delivery_To__c).recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_TW_Supplier'))
                //{

                //}
            }

            /*if(tempC != null)
            {
                system.debug('+++tempC2: '+tempC);
                if(tempC.size() > 0)
                {
                    system.debug('+++tempC3: '+tempC);
                    if(FGR.ASI_CRM_Receiver__c == null || FGR.ASI_CRM_Receiver__c == '')
                    {
                        system.debug('+++tempC[0].LastName: '+tempC[0].LastName);
                        system.debug('+++tempC[0].FirstName: '+tempC[0].FirstName);
                        system.debug('++aaaa: '+tempC[0].LastName == null ? '' : tempC[0].LastName + ' ' + tempC[0].FirstName == null ? '' : tempC[0].FirstName);
                        FGR.ASI_CRM_Receiver__c = (tempC[0].LastName == null ? '' : tempC[0].LastName) + ' ' + (tempC[0].FirstName == null ? '' : tempC[0].FirstName);
                        system.debug('++++FGR.ASI_CRM_Receiver__c: '+FGR.ASI_CRM_Receiver__c);
                    }
                }
            }*/
        }
    }
    
    @TestVisible
    Private Static void setApprover(ASI_FOC_Free_Goods_Request__c foc, List<String> approverIdList){
        Integer i = 1;
        String currentApprover = 'ASI_FOC_Approver_' + i + '__c';
        Set<String> approverIdSet = new Set<String>();
        for(String s : approverIdList)
        {
            approverIdSet.add(s);
        }
        approverIdList = new List<String>();
        for(String s : approverIdSet)
        {
            approverIdList.add(s);
        }
        While(Free_Goods_Request_FIELD_MAP.containsKey(currentApprover) && i <= approverIdList.size()){
            foc.put(currentApprover, approverIdList[i - 1]);
            i++;
            currentApprover = 'ASI_FOC_Approver_' + i + '__c';
        }
    }
    
    @TestVisible
    Private Static void setApproverToNull(ASI_FOC_Free_Goods_Request__c foc){
        Integer i = 1;
        String currentApprover = 'ASI_FOC_Approver_' + i + '__c';
        While(Free_Goods_Request_FIELD_MAP.containsKey(currentApprover)){
            foc.put(currentApprover, null);
            i++;
            currentApprover = 'ASI_FOC_Approver_' + i + '__c';
        }
    }

    @TestVisible
    Private Static List<String> getCRMFixApprovalList(ASI_CRM_Fix_Approval_Route__c item)
    {
        Integer i = 1;
        String currentField = 'ASI_CRM_CN_Approver_' + i + '__c';
        List<String> returnList = new List<String>();
        While(CRM_Fix_Approval_Route_FIELD_MAP.containsKey(currentField))
        {
            if(item.get(currentField)!=null) returnList.add(String.valueof(item.get(currentField)));
            i++;
            currentField = 'ASI_CRM_CN_Approver_' + i + '__c';
        }
        return returnList;
    }
    
    //20200319:AM - CR on FOC/POSM approval start
/*
 * POSM: POSM Department
 * 
 * FOC:
 * HR: 			HR -> FIN
 * FIN:			FIN
 * MKT:			MKT_DYN -> MKT_FIX -> FIN
 * SALES-T:		FIX -> SD -> M_TYPE(1M) -> MKT_FIX -> FIN
 * SALES-NT:	DYN -> SD -> M_TYPE(1M) -> MKT_FIX -> FIN
 */
    private static void setApprovers(List<ASI_FOC_Free_Goods_Request__c> trigger_new) {
        Map<Id, ASI_CRM_Dynamic_Approval_Route__c> oDynRoute_FOC = new Map<Id, ASI_CRM_Dynamic_Approval_Route__c>();
        Map<Id, ASI_CRM_Dynamic_Approval_Route__c> oDynRoute_POSM = new Map<Id, ASI_CRM_Dynamic_Approval_Route__c>();
        
        List<ASI_CRM_Fix_Approval_Route__c> oFixRoute_FOC = new List<ASI_CRM_Fix_Approval_Route__c>();
        List<ASI_CRM_Fix_Approval_Route__c> oFixRoute_POSM = new List<ASI_CRM_Fix_Approval_Route__c>();
        
        Map<String,String> oFieldMap_Dept = new Map<String,String>();
        Map<String,String> oFieldMap_Channel = new Map<String,String>();
        Map<String,String> oFieldMap_AccType = new Map<String,String>();
        
        Map<Id, ASI_FOC_Free_Goods_Request__c> oMap_Header = new Map<Id, ASI_FOC_Free_Goods_Request__c>([
            SELECT Id, ASI_CRM_Delivery_To__c, ASI_CRM_Target_Outlet__r.ASI_HK_CRM_Channel_Detail__c, ASI_CRM_Delivery_To__r.ASI_HK_CRM_Channel_Detail__c
            	, (SELECT Id, ASI_FOC_SKU__r.ASI_TH_CRM_Brand_Code__c, ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c, ASI_FOC_SKU__r.ASI_CRM_Department__c FROM ASI_FOC_Request_Items__r) 
            FROM ASI_FOC_Free_Goods_Request__c 
            WHERE Id IN :trigger_new]);
        
        //setup dynamic route
        for(ASI_CRM_Dynamic_Approval_Route__c oRoute : G_AppRoute_Dynamic)
        {
            if (oRoute.ASI_CRM_Type__c == 'FOC') oDynRoute_FOC.put(oRoute.ASI_CRM_User__c, oRoute);
            if (oRoute.ASI_CRM_Type__c == 'POSM') oDynRoute_POSM.put(oRoute.ASI_CRM_User__c, oRoute);
        }
        
        //setup fix route
        for(ASI_CRM_Fix_Approval_Route__c oRoute : G_AppRoute_Fix)
        {
            if (oRoute.ASI_CRM_CN_Type__c == 'FOC') oFixRoute_FOC.add(oRoute);
            if (oRoute.ASI_CRM_CN_Type__c == 'POSM') oFixRoute_POSM.add(oRoute);
        }
        
        //setup field mapping
        for(ASI_CRM_TW_Field_Mapping__mdt oFieldMap : G_MDT_FieldMap) 
        {
            if (oFieldMap.ASI_CRM_Type__c == 'Department') oFieldMap_Dept.put(oFieldMap.ASI_CRM_From_Value__c, oFieldMap.ASI_CRM_To_Value__c);
            if (oFieldMap.ASI_CRM_Type__c == 'Department') oFieldMap_Channel.put(oFieldMap.ASI_CRM_From_Value__c, oFieldMap.ASI_CRM_Channel__c);
            if (oFieldMap.ASI_CRM_Type__c == 'Account Type') oFieldMap_AccType.put(oFieldMap.ASI_CRM_From_Value__c, oFieldMap.ASI_CRM_To_Value__c);
        }
        
        //setup Owner - check owner department
        //setup DeliveryTo - check PRT OFFICE
        List<Id> ltDeliveryToId = new List<Id>();
        List<Id> ltOwnerId = new List<Id>();
        for(ASI_FOC_Free_Goods_Request__c oHeader: trigger_new) {
            ltDeliveryToId.add(oHeader.ASI_CRM_Delivery_To__c);
            ltOwnerId.add(oHeader.OwnerId);
        }
        Map<Id, Account> oMap_AccChannel = new Map<Id, Account>([SELECT Id,ASI_HK_CRM_Channel_Detail__c FROM Account WHERE id IN :ltDeliveryToId]);
        Map<ID, User> oMap_Owner = new Map<ID, User>([SELECT Id,Department,ASI_MFM_Department__c,ManagerId,ASI_Line_Manager__c,ASI_MFM_Direct_Report__c FROM User WHERE Id IN :ltOwnerId]);
        
        /*
        //setup fix route for FOC
        Map<String, Decimal> oFOCRoute_FIN = new Map<String, Decimal>();
        Id oFINDirector = NULL;
        Map<String, Decimal> oFOCRoute_HR = new Map<String, Decimal>();
        Map<String, Decimal> oFOCRoute_MKT = new Map<String, Decimal>();
        Map<String,Map<String, Decimal>> oFOCRoute_Sales = new Map<String,Map<String, Decimal>>();
        
        for(ASI_CRM_Fix_Approval_Route__c oRoute : oFixRoute_FOC)
        {
            switch on oRoute.ASI_CRM_Department__c {
                when 'FIN' {
                    oFOCRoute_FIN = getFixApproversWLimit(oRoute);
                    oFINDirector = oRoute.ASI_CRM_Finance_Approver__c;
                }
                when 'HR' {
                    oFOCRoute_HR = getFixApproversWLimit(oRoute);
                }
                when 'MKT' {
                    if (oRoute.ASI_CRM_Brand__c == NULL) oFOCRoute_MKT = getFixApproversWLimit(oRoute);
                }
                when 'Sales' {
                    if (oRoute.ASI_CRM_CN_Region_Area_Channel__c != NULL) {
                        Map<String, Decimal> oFOCRoute_Temp = getFixApproversWLimit(oRoute);
                        oFOCRoute_Sales.put(oRoute.ASI_CRM_CN_Region_Area_Channel__c, oFOCRoute_Temp);
                    }
                }
            }
        }
		*/
        
        //set approvers
        for(ASI_FOC_Free_Goods_Request__c oHeader : trigger_new) {
            string sStatus = oHeader.ASI_FOC_Request_Status__c;
            Id id_RT = oHeader.RecordTypeId;
            
            if(sStatus == 'Draft' || sStatus == 'Submitted') {
                if (id_RT == G_FOC_RT_TW_FOC || id_RT == G_FOC_RT_TW_FOC_RO) {
                    /*
                    setApprovers4FOC(oHeader,oMap_Header,oDynRoute_FOC
                                     ,oMap_Owner,oFOCRoute_Sales,oFOCRoute_MKT
                                     ,oFOCRoute_HR,oFOCRoute_FIN,oFINDirector,oMap_AccChannel
                                     ,oFieldMap_Dept,oFieldMap_Channel,oFieldMap_AccType);
					*/
                    setApprovers4FOC(oHeader,oMap_Header,oDynRoute_FOC
                                     ,oMap_Owner,oFixRoute_FOC,oMap_AccChannel
                                     ,oFieldMap_Dept,oFieldMap_Channel,oFieldMap_AccType);
				}
                if (id_RT == G_FOC_RT_TW_POSM || id_RT == G_FOC_RT_TW_POSM_RO) {
                    setApprovers4POSM(oHeader,oMap_Header,oDynRoute_POSM,oFixRoute_POSM,oMap_Owner);
                }
            }
        }

    }
    
    private static void setApprovers4FOC(
	ASI_FOC_Free_Goods_Request__c oHeader, Map<Id, ASI_FOC_Free_Goods_Request__c> oMap_Header, Map<Id, ASI_CRM_Dynamic_Approval_Route__c> oDynRoute
	, Map<ID, User> oMap_Owner, List<ASI_CRM_Fix_Approval_Route__c> oFixRoute_FOC, Map<Id, Account> oMap_AccChannel
	, Map<String,String> oFieldMap_Dept, Map<String,String> oFieldMap_Channel, Map<String,String> oFieldMap_AccType) {

        setApproverToNull(oHeader);
		Set<String> oSet_Approver = new Set<String>();

        Boolean bIsTrade = oHeader.ASI_CRM_Trade__c;
        
        Decimal dCheckAmount = oHeader.ASI_CRM_FOC_Amount__c;
		dCheckAmount = dCheckAmount.setScale(2, RoundingMode.HALF_UP);

		String sOwnerDept = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerDept = oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);
        String sOwnerChannel = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerChannel = oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);
        
        //assign fix route
        Map<String, Decimal> oFOCRoute_DEPT = new Map<String, Decimal>();
        Id oFINDirector = NULL;
        Decimal dFINDirector_Limit = 0.00;
        
        for(ASI_CRM_Fix_Approval_Route__c oRoute : oFixRoute_FOC) {
            if (
                (oRoute.ASI_CRM_Department__c == sOwnerDept)
                &&
            	((bIsTrade && oRoute.ASI_CRM_Company__c == 'TRADE') || (!bIsTrade && oRoute.ASI_CRM_Company__c == 'NON-TRADE'))
            )
            {
                if (sOwnerDept == 'Sales') {
                    if ((sOwnerChannel != '') && (sOwnerChannel != NULL) && (oRoute.ASI_CRM_CN_Region_Area_Channel__c != NULL) && (oRoute.ASI_CRM_CN_Region_Area_Channel__c == sOwnerChannel)) {
                        oFOCRoute_DEPT = getFixApproversWLimit(oRoute);
                    }
                } else {
                    oFOCRoute_DEPT = getFixApproversWLimit(oRoute);
                }
                oFINDirector = oRoute.ASI_CRM_Finance_Approver__c;
                dFINDirector_Limit = oRoute.ASI_CRM_CN_Entry_Limit__c;
            }
        }

        if (!bIsTrade) {
            Set<String> oSet_Approver_Dynamic = setDynamicApprovers(oHeader.OwnerId, oDynRoute, oMap_Owner, TRUE);
            if (oSet_Approver_Dynamic.size()>0) oSet_Approver.addAll(oSet_Approver_Dynamic);
        }
        
        Set<String> oSet_Approver_Fix = setApprovers_CheckLimit(dCheckAmount, oFOCRoute_DEPT);
		if (oSet_Approver_Fix.size()>0) oSet_Approver.addAll(oSet_Approver_Fix);
        
        if (oFINDirector != NULL) {
            //1) check FOC amount
            boolean bCheckFD = (dCheckAmount>=dFINDirector_Limit);

            //2) check delivery to
            if (bCheckFD == FALSE) {
                if(oHeader.ASI_CRM_Delivery_To__c != NULL && oMap_AccChannel.get(oHeader.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Channel_Detail__c == 'PRT') {
                    bCheckFD = TRUE;
                }
            }
            
            if (bCheckFD) oSet_Approver.add(oFINDirector);
        }

        //assign approvers
        if (oSet_Approver.size()>0) {
            List<String> ltFinalApprover = new List<String>();
            ltFinalApprover.addAll(oSet_Approver);
            setApprover(oHeader, ltFinalApprover);
        }
    }
    
    /*
    private static void setApprovers4FOC(ASI_FOC_Free_Goods_Request__c oHeader, Map<Id, ASI_FOC_Free_Goods_Request__c> oMap_Header, Map<Id, ASI_CRM_Dynamic_Approval_Route__c> oDynRoute
		, Map<ID, User> oMap_Owner, Map<String,Map<String, Decimal>> oFOCRoute_Sales, Map<String, Decimal> oFOCRoute_MKT
		, Map<String, Decimal> oFOCRoute_HR, Map<String, Decimal> oFOCRoute_FIN, Id oFINDirector, Map<Id, Account> oMap_AccChannel
		, Map<String,String> oFieldMap_Dept, Map<String,String> oFieldMap_Channel, Map<String,String> oFieldMap_AccType) {

    	setApproverToNull(oHeader);
		Set<String> oSet_Approver = new Set<String>();

        Decimal dCheckAmount = oHeader.ASI_CRM_FOC_Amount__c;
		dCheckAmount = dCheckAmount.setScale(2, RoundingMode.HALF_UP);

		String sOwnerDept = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerDept = oFieldMap_Dept.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);
        String sOwnerChannel = '';
        if(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c != NULL && oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c) != NULL)
			sOwnerChannel = oFieldMap_Channel.get(oMap_Owner.get(oHeader.OwnerId).ASI_MFM_Department__c);

		boolean bHas_FINRoute = FALSE;
		switch on sOwnerDept {
            when 'HR' {
                Set<String> oSet_Approver_HR = setApprovers_CheckLimit(dCheckAmount, oFOCRoute_HR);
        		if (oSet_Approver_HR.size()>0) oSet_Approver.addAll(oSet_Approver_HR);
                bHas_FINRoute = TRUE;
            }
            when 'FIN' {
                bHas_FINRoute = TRUE;
            }
            when 'MKT' {
                Set<String> oSet_Approver_Dynamic = setDynamicApprovers(oHeader.OwnerId, oDynRoute, oMap_Owner, TRUE);
                if (oSet_Approver_Dynamic.size()>0) oSet_Approver.addAll(oSet_Approver_Dynamic);
                
                Set<String> oSet_Approver_MKT = setApprovers_CheckLimit(dCheckAmount, oFOCRoute_MKT);
        		if (oSet_Approver_MKT.size()>0) oSet_Approver.addAll(oSet_Approver_MKT);
				bHas_FINRoute = TRUE;
			}
            when 'Sales' {
                //1) check trade
                //2) if trade, fix route (check channel)
                //3) if non-trade, dynamic route
                //4) SD
                //5) M Type / MKT Type
                
                boolean bCheck_Trade_Type = FALSE;
                boolean bCheck_MKT_Type = FALSE;
                
                if (oHeader.Id != NULL && oMap_Header.get(oHeader.Id) != NULL) {
                    for (ASI_FOC_Request_Item__c oItem : oMap_Header.get(oHeader.Id).ASI_FOC_Request_Items__r) {
                        if (oItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c != NULL) {
                            if (oFieldMap_AccType.containsKey(oItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c)) {
                                if (oFieldMap_AccType.get(oItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c) == 'Trade A&P') bCheck_Trade_Type = true;
                                if (oFieldMap_AccType.get(oItem.ASI_CRM_Plan_Line_Item__r.ASI_CRM_AC_Code_Reporting_Category__c) == 'MKT A&P') bCheck_MKT_Type = true;
                            }
                        }
                    }
                }
                
                if (bCheck_Trade_Type) {
                    if ((sOwnerChannel != '') && (sOwnerChannel != NULL) && (oFOCRoute_Sales.containsKey(sOwnerChannel))) {
                        Map<String, Decimal> oFOCRoute_Sales_Channel = oFOCRoute_Sales.get(sOwnerChannel);
                        
                        Set<String> oSet_Approver_Sales = setApprovers_CheckLimit(dCheckAmount, oFOCRoute_Sales_Channel);
                        if (oSet_Approver_Sales.size()>0) oSet_Approver.addAll(oSet_Approver_Sales);
                    }
                }
                else {
                    Set<String> oSet_Approver_Dynamic = setDynamicApprovers(oHeader.OwnerId, oDynRoute, oMap_Owner, TRUE);
                	if (oSet_Approver_Dynamic.size()>0) oSet_Approver.addAll(oSet_Approver_Dynamic);
                }
                
                //SD
                string sSalesDirectorValue = 'SD';
                if ((sSalesDirectorValue != '') && (sSalesDirectorValue != NULL) && (oFOCRoute_Sales.containsKey(sSalesDirectorValue))) {
                    Map<String, Decimal> oFOCRoute_Sales_SD = oFOCRoute_Sales.get(sSalesDirectorValue);
                    Set<String> oSet_Approver_SD = setApprovers_CheckLimit(dCheckAmount, oFOCRoute_Sales_SD);
					if (oSet_Approver_SD.size()>0) oSet_Approver.addAll(oSet_Approver_SD);
                }

                //M Type / MKT Type             
                if ((bCheck_MKT_Type) && (dCheckAmount >= 1000000)) {
                    if (oFOCRoute_MKT.size() > 0) {
                        for (string sApproverId : oFOCRoute_MKT.keySet()) {
                            oSet_Approver.add(sApproverId);
                        }
                    }
                }
                
                bHas_FINRoute = TRUE;
            }
        }
                                             
		//FINANCE [fix]
		if (bHas_FINRoute) {
			Set<String> oSet_Approver_FIN = setApprovers4FOC_FIN(oHeader, dCheckAmount, oFOCRoute_FIN, oFINDirector, oMap_AccChannel);
        	if (oSet_Approver_FIN.size()>0) oSet_Approver.addAll(oSet_Approver_FIN);
		}

        //assign approvers
        if (oSet_Approver.size()>0) {
            List<String> ltFinalApprover = new List<String>();
            ltFinalApprover.addAll(oSet_Approver);
            setApprover(oHeader, ltFinalApprover);
        }
    }

    private static Set<String> setApprovers4FOC_FIN(ASI_FOC_Free_Goods_Request__c oHeader, Decimal dCheckAmount, Map<String, Decimal> oFOCRoute_FIN, Id oFINDirector, Map<Id, Account> oMap_AccChannel) {
        Set<String> oSet_Approver = new Set<String>();
        
        Set<String> oSet_Approver_FIN = setApprovers_CheckLimit(dCheckAmount, oFOCRoute_FIN);
        if (oSet_Approver_FIN.size()>0) oSet_Approver.addAll(oSet_Approver_FIN);

        if (oFINDirector != NULL) {
            //1) check FOC amount
            boolean bCheckFD = (dCheckAmount>=1000000);

            //2) check delivery to
            if (bCheckFD == FALSE) {
                if(oHeader.ASI_CRM_Delivery_To__c != NULL && oMap_AccChannel.get(oHeader.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Channel_Detail__c == 'PRT') {
                    bCheckFD = TRUE;
                }
            }
            
            if (bCheckFD) oSet_Approver.add(oFINDirector);
        }
        
        return oSet_Approver;
    }
    */
    
    @TestVisible
    private static void setApprovers4POSM(ASI_FOC_Free_Goods_Request__c oHeader, Map<Id, ASI_FOC_Free_Goods_Request__c> oMap_Header, Map<Id, ASI_CRM_Dynamic_Approval_Route__c> oDynRoute, List<ASI_CRM_Fix_Approval_Route__c> oFixRoute, Map<ID, User> oMap_Owner) {
    	setApproverToNull(oHeader);
		Set<String> oSet_Approver = new Set<String>();
        
        //dynamic route - do nothing

        //fix route
        if (oHeader.Id != NULL && oMap_Header.get(oHeader.Id) != NULL) {
            for(ASI_FOC_Request_Item__c oItem : oMap_Header.get(oHeader.Id).ASI_FOC_Request_Items__r)
            {
                string sPOSMDept = oItem.ASI_FOC_SKU__r.ASI_CRM_Department__c;
                string sPOSMBrand = oItem.ASI_FOC_SKU__r.ASI_TH_CRM_Brand_Code__c;
    
                for(ASI_CRM_Fix_Approval_Route__c oSingleRoute : oFixRoute)
                {
                    if ((oSingleRoute.ASI_CRM_Department__c != 'MKT' && sPOSMDept != 'MKT' && oSingleRoute.ASI_CRM_CN_Region_Area_Channel__c == sPOSMDept)
                        || (oSingleRoute.ASI_CRM_Department__c != 'MKT' && sPOSMDept != 'MKT' && oSingleRoute.ASI_CRM_Channel__c != NULL && oSingleRoute.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c == sPOSMDept)
                        || (oSingleRoute.ASI_CRM_Department__c == 'MKT' && sPOSMDept == 'MKT' && oSingleRoute.ASI_CRM_Brand__r.ASI_MFM_Brand_Code__c == sPOSMBrand)
                       )
                    {
                        oSet_Approver.addAll(getCRMFixApprovalList(oSingleRoute));
                    }
                }  
            }
        }
        
        //assign approvers
        if (oSet_Approver.size()>0) {
            List<String> ltFinalApprover = new List<String>();
            //ltFinalApprover.addAll(oSet_Approver);
            Set<String> oSet_FinalApprover = setApprovers_CheckOwner(oHeader.OwnerId, oSet_Approver, oMap_Owner);
            ltFinalApprover.addAll(oSet_FinalApprover);
            setApprover(oHeader, ltFinalApprover);
        }
    }
    
    @TestVisible
    private static Set<String> setApprovers_CheckOwner(Id idRecordOwner, Set<String> oSet_Approver, Map<ID, User> oMap_Owner) {
        Set<String> oSet_FinalApprover = new Set<String>();
        for(String sApprover : oSet_Approver) {
            boolean bNeedLineMgr = FALSE;
            if (sApprover == idRecordOwner) {
                User oOwner = oMap_Owner.get(sApprover);
                if (oOwner.ASI_Line_Manager__c != NULL) {
                    oSet_FinalApprover.add(oOwner.ASI_Line_Manager__c);
                    bNeedLineMgr = TRUE;
                }
            }
            if (bNeedLineMgr == FALSE) oSet_FinalApprover.add(sApprover);
        }
        return oSet_FinalApprover;
    }
    
    @TestVisible
    private static Set<String> setApprovers_CheckLimit(Decimal dCheckAmount, Map<String, Decimal> oRouteWLimit) {
		Set<String> oSet_Approver = new Set<String>();
        
        if (oRouteWLimit.size() > 0) {
            for (String sApproverID : oRouteWLimit.keySet()){
                Decimal dTmpLimit = oRouteWLimit.get(sApproverID);
                if (dCheckAmount>=dTmpLimit) oSet_Approver.add(sApproverID);
            }
        }
        
        return oSet_Approver;
    }
    
    @TestVisible
    private static Set<String> setDynamicApprovers(Id oOwnerId, Map<Id, ASI_CRM_Dynamic_Approval_Route__c> oDynRoute, Map<ID, User> oMap_Owner, Boolean bCheckSkip2Next) {
        Set<String> oSet_Approver = new Set<String>();

        Id oCurApprover = oMap_Owner.get(oOwnerId).ASI_Line_Manager__c;
        if (oMap_Owner.get(oOwnerId).ASI_MFM_Direct_Report__c) {
            oSet_Approver.add(oCurApprover);
        }
        else {
            Boolean bEndRoute = FALSE;
            while (!bEndRoute)
            {
                if (oDynRoute.get(oCurApprover) != NULL)
                {
                    if (bCheckSkip2Next)
                    {
                        if (!oDynRoute.get(oCurApprover).ASI_CRM_Skip_to_Next_Level__c)
                        {
                            oSet_Approver.add(oCurApprover);
                        }
                    }
                    else
                    {
                        oSet_Approver.add(oCurApprover);
                    }
                    bEndRoute = oDynRoute.get(oCurApprover).ASI_CRM_End_of_Dynamic_Route__c;
                    oCurApprover = oDynRoute.get(oCurApprover).ASI_CRM_Manager_ID__c;
                }
                else bEndRoute = TRUE;
            }
        }
        
        return oSet_Approver;
    }
    
    @TestVisible
    private static Map<String, Decimal> getFixApproversWLimit(ASI_CRM_Fix_Approval_Route__c oRoute) {
        Map<String, Decimal> oApprovers = new Map<String, Decimal>();
        
        Integer i = 1;
        String sApproverField = 'ASI_CRM_CN_Approver_' + i + '__c';
        String sLimitField = 'ASI_CRM_CN_Approval_Limit_' + i + '__c';

        While(CRM_Fix_Approval_Route_FIELD_MAP.containsKey(sApproverField))
        {
            Id idTmpApprover = NULL;
            Decimal dTmpLimit = 0;
            if (oRoute.get(sApproverField) != NULL) idTmpApprover = String.valueof(oRoute.get(sApproverField));
            if (oRoute.get(sLimitField) != NULL) dTmpLimit = Decimal.valueof(String.valueof(oRoute.get(sLimitField)));
            
            dTmpLimit = dTmpLimit.setScale(2, RoundingMode.HALF_UP);
            if (idTmpApprover != NULL) oApprovers.put(idTmpApprover, dTmpLimit);

            i++;
            sApproverField = 'ASI_CRM_CN_Approver_' + i + '__c';
            sLimitField = 'ASI_CRM_CN_Approval_Limit_' + i + '__c';
        }
        
        return oApprovers;
    }
    //20200319:AM - CR on FOC/POSM approval end
}