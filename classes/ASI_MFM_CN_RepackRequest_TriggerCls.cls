public without sharing class ASI_MFM_CN_RepackRequest_TriggerCls {
    
    Private Static Final Id FIX_APPROVAL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
    Private Static Map<String, ASI_CRM_Fix_Approval_Route__c> G_MAP_FixApproval = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
    Private Static Final Map<String, Schema.SObjectField> FIX_APPROVAL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> RRF_FIELD_MAP = Schema.SObjectType.ASI_MFM_POSM_Return_Request__c.fields.getMap();    
    Private Static Final String G_STR_MapFix = 'RepackRequestForm';
    
    public static void routineBeforeInsert(list<ASI_MFM_POSM_Return_Request__c> trigger_new){
        generateNameWRunningNum(trigger_new);
        fetchInfo(trigger_new);
        assignApprovers(trigger_new);
    }
    public static void routineAfterInsert(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){
        sharingToApprovers(trigger_new, trigger_oldMap);
        
    }
    public static void routineAfterUpdate(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){
        sharingToApprovers(trigger_new, trigger_oldMap);
        
    }
    public static void routineBeforeUpsert(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap){
        setNullApprovers(trigger_new);
        assignApprovers(trigger_new);
        if (trigger_oldMap != null) {
            updateEmailAlert(trigger_new, trigger_oldMap);
        }
    }

    // Added by Jack Yuan BLS 20201016
    public static void updateEmailAlert(list<ASI_MFM_POSM_Return_Request__c> trigger_new, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap) {
        Set<Id> pend4DayReq = new Set<Id>();
        Map<Id,Id> workItemMap = new Map<Id,Id>();
        for(ASI_MFM_POSM_Return_Request__c req:trigger_new) {
            if(!trigger_oldMap.get(req.id).ASI_MFM_CN_Repack_Already_4_Days__c && req.ASI_MFM_CN_Repack_Already_4_Days__c){
                pend4DayReq.add(req.Id);
            }
        }
        if(pend4DayReq.size() > 0) {
            List<ProcessInstanceWorkitem> workItemList 
                = new List<ProcessInstanceWorkitem>([Select ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: pend4DayReq]);
            if(workItemList.size()>0){
                for(ProcessInstanceWorkitem item: workItemList){
                    workItemMap.put(item.ProcessInstance.TargetObjectId, item.ActorId);
                }
            }
        }
        if(workItemMap.size() > 0){
            for(ASI_MFM_POSM_Return_Request__c req:trigger_new) {
                if(workItemMap.containsKey(req.Id)){
                    req.ASI_MFM_CN_Repack_Current_Approver__c = workItemMap.get(req.id);
                    req.ASI_MFM_CN_Repack_Send_Reminder_Email__c = true;
                }
            }
        }
        
    }
    
    private static void generateNameWRunningNum(list<ASI_MFM_POSM_Return_Request__c> trigger_new){
        //format: VAP-YYYYMMDD-00
        string sFormat = 'VAP-{0}-{1}';
        
        List<aggregateResult> maxRunning = [
            SELECT MAX(ASI_MFM_Repack_Request_Running_Number__c) max
            FROM ASI_MFM_POSM_Return_Request__c                                                                      
            WHERE CreatedDate = TODAY
            AND RecordType.Name LIKE '%CN Repack Request Form%'
        ];
        
        Integer running;
        if (maxRunning[0].get('max') == null) {
            running = 0;
        }
        else{
            running = Integer.valueOf(maxRunning[0].get('max')) + 1;
        }
        
        for(ASI_MFM_POSM_Return_Request__c oRequest : trigger_new) {
            List<string> ltParam = new List<string>();
            ltParam.add(Datetime.now().format('yyyyMMdd'));
            ltParam.add(string.valueOf(running + 100).right(2));
            oRequest.name = string.format(sFormat, ltParam);
            oRequest.ASI_MFM_Repack_Request_Running_Number__c = running;
            running++;
        }
    }
    
    private static void setNullApprovers(List<ASI_MFM_POSM_Return_Request__c> triggerNew) {
        for(ASI_MFM_POSM_Return_Request__c rc : triggerNew) {
            rc.ASI_MFM_Approver_1__c  = NULL;
            rc.ASI_MFM_Approver_2__c  = NULL;
            rc.ASI_MFM_Approver_3__c  = NULL;
            rc.ASI_MFM_Approver_4__c  = NULL;
            rc.ASI_MFM_Approver_5__c  = NULL;
            rc.ASI_MFM_Approver_6__c  = NULL;
            rc.ASI_MFM_Approver_7__c  = NULL;
            rc.ASI_MFM_Approver_8__c  = NULL;
            rc.ASI_MFM_Approver_9__c  = NULL;
            rc.ASI_MFM_Approver_10__c  = NULL;
        }
    }
    
    private Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;

        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
    }    
    
    private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
    
    private static void setFixApproval() {
        for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FIX_APPROVAL_FIELD_MAP, ' WHERE RecordTypeId = \'' + FIX_APPROVAL_RECORD_TYPE_ID + '\' AND ASI_CRM_CN_Type__c LIKE \'Repack Request Form\'')){
            G_MAP_FixApproval.put(G_STR_MapFix, obj);
        }
    }

    private static void sharingToApprovers(list<ASI_MFM_POSM_Return_Request__c> ltHeader, map<id, ASI_MFM_POSM_Return_Request__c> trigger_oldMap) {
        List<ASI_MFM_POSM_Return_Request__Share> sharingList = new List<ASI_MFM_POSM_Return_Request__Share>();
        for(ASI_MFM_POSM_Return_Request__c oHeader : ltHeader) {
            if ( (Trigger.isInsert || (Trigger.isUpdate && oHeader.OwnerId != trigger_oldMap.get(oHeader.Id).OwnerId)) 
                    && String.isNotBlank(oHeader.ASI_MFM_Owner_ManagerId__c) ) {
                ASI_MFM_POSM_Return_Request__Share rorequest = new ASI_MFM_POSM_Return_Request__Share();
                rorequest.ParentId = oHeader.Id;
                rorequest.UserOrGroupId = oHeader.ASI_MFM_Owner_ManagerId__c;
                rorequest.AccessLevel = 'Read';
                rorequest.RowCause = 'Manual';
                sharingList.add(rorequest);
            }
        }
        if (!sharingList.isEmpty()) {
            System.debug(LoggingLevel.INFO, '*** sharingList: ' + sharingList);
            insert sharingList;
        }
    }      
    private static void assignApprovers(List<ASI_MFM_POSM_Return_Request__c> triggerNew) {
        setFixApproval();
        
        Integer iMaxCount = 10;
        
        for(ASI_MFM_POSM_Return_Request__c rc : triggerNew) {
            if (G_MAP_FixApproval.containsKey(G_STR_MapFix)) {
                ASI_CRM_Fix_Approval_Route__c oFixApproval = G_MAP_FixApproval.get(G_STR_MapFix);
                
                Integer i = 1;
                Integer j = 1;
                String fixApprover = 'asi_crm_cn_approver_' + i + '__c';
                String approver = 'asi_mfm_approver_' + j + '__c';
                
                While(RRF_FIELD_MAP.containsKey(approver) && FIX_APPROVAL_FIELD_MAP.containsKey(fixApprover) && (i<=iMaxCount) && (j<=iMaxCount)) {            
                    if (j==2 && !rc.ASI_MFM_Logistic_Application__c) {
                        rc.put(approver, rc.ASI_MFM_Owner_ManagerId__c);
                        rc.ASI_MFM_CN_Repack_Manager_NoLogistic__c = rc.ASI_MFM_Owner_ManagerId__c;
                        j = 3;
                        approver = 'asi_mfm_approver_' + j + '__c';
                    }
                    
                    if ((i != 1 && rc.ASI_MFM_Logistic_Application__c) || !rc.ASI_MFM_Logistic_Application__c) {
                      rc.put(approver, oFixApproval.get(fixApprover));
                      j++;
                    }
                    i++;
                    
                    fixApprover = 'ASI_CRM_CN_Approver_' + i + '__c';
                    approver = 'ASI_MFM_Approver_' + j + '__c';
                }
            }
        }
    }

    private static void fetchInfo(List<ASI_MFM_POSM_Return_Request__c> trigger_new) {
        Set<Id> s_newItemCodesIds = new Set<Id>();
        Set<Id> s_oldItemCodesIds = new Set<Id>();
        Set<Id> s_materialItemCodesIds = new Set<Id>();
        Map<Id, ASI_MFM_SKU_Code__c> m_itemCodes = new Map<Id, ASI_MFM_SKU_Code__c>();
        
        for(ASI_MFM_POSM_Return_Request__c rc : trigger_new) {
            if(rc.ASI_MFM_Item_Code_After_Repack__c != null)
                s_newItemCodesIds.add(rc.ASI_MFM_Item_Code_After_Repack__c);
            if(rc.ASI_MFM_Item_Code_Before_Repack__c != null)
                s_oldItemCodesIds.add(rc.ASI_MFM_Item_Code_Before_Repack__c);            
        }
        
        if(!s_newItemCodesIds.isEmpty()
           || !s_oldItemCodesIds.isEmpty()
           || !s_materialItemCodesIds.isEmpty()){
               m_itemCodes = new Map<Id, ASI_MFM_SKU_Code__c>([
                   SELECT Id
                   , ASI_MFM_SKU_Description__c
                   , ASI_FOC_SKU_Chinese_Description__c
                   , ASI_FOC_Packing_Description__c
                   , ASI_FOC_List_Price__c
                   , ASI_MFM_SKU_Code__c
                   , ASI_CRM_Bottle_Barcode__c
                   FROM ASI_MFM_SKU_Code__c
                   WHERE (Id IN :s_newItemCodesIds
                          OR Id IN :s_oldItemCodesIds
                          OR Id IN :s_materialItemCodesIds)
               ]);
           }
        
        for(ASI_MFM_POSM_Return_Request__c rc : trigger_new) {
            //s_newItemCodesIds
            if(rc.ASI_MFM_Item_Code_After_Repack__c != null 
               && m_itemCodes.containsKey(rc.ASI_MFM_Item_Code_After_Repack__c)){
                   ASI_MFM_SKU_Code__c sku = m_itemCodes.get(rc.ASI_MFM_Item_Code_After_Repack__c);
                   
                   if(rc.ASI_MFM_English_Name__c == '' || rc.ASI_MFM_English_Name__c == null)
                       rc.ASI_MFM_English_Name__c = sku.ASI_MFM_SKU_Description__c;
                   if(rc.ASI_MFM_Chinese_Name__c == '' || rc.ASI_MFM_Chinese_Name__c == null)
                       rc.ASI_MFM_Chinese_Name__c = sku.ASI_FOC_SKU_Chinese_Description__c;
                   if(rc.ASI_MFM_Carton_Spec__c == '' || rc.ASI_MFM_Carton_Spec__c == null)
                       rc.ASI_MFM_Carton_Spec__c = sku.ASI_FOC_Packing_Description__c;
                   if(rc.ASI_MFM_T1_Price__c == null)
                       rc.ASI_MFM_T1_Price__c = sku.ASI_FOC_List_Price__c;
                   if(rc.ASI_MFM_New_Item_Code_After_Repack__c == '' || rc.ASI_MFM_New_Item_Code_After_Repack__c == null)
                       rc.ASI_MFM_New_Item_Code_After_Repack__c = sku.ASI_MFM_SKU_Code__c;
                   if(rc.ASI_MFM_New_Item_English_Name__c == '' || rc.ASI_MFM_New_Item_English_Name__c == null)
                       rc.ASI_MFM_New_Item_English_Name__c = sku.ASI_MFM_SKU_Description__c;
                   if(rc.ASI_MFM_New_Item_Carton_Spec__c == '' || rc.ASI_MFM_New_Item_Carton_Spec__c == null)
                       rc.ASI_MFM_New_Item_Carton_Spec__c = sku.ASI_FOC_Packing_Description__c;
                   if(rc.ASI_MFM_New_Item_Bottle_Barcode__c == '' || rc.ASI_MFM_New_Item_Bottle_Barcode__c == null)
                       rc.ASI_MFM_New_Item_Bottle_Barcode__c = sku.ASI_CRM_Bottle_Barcode__c;
               }
            
            if(rc.ASI_MFM_Item_Code_Before_Repack__c != null && m_itemCodes.containsKey(rc.ASI_MFM_Item_Code_Before_Repack__c)){
                ASI_MFM_SKU_Code__c sku = m_itemCodes.get(rc.ASI_MFM_Item_Code_Before_Repack__c);
                
                if(rc.ASI_MFM_Old_Item_English_Name__c == '' || rc.ASI_MFM_Old_Item_English_Name__c == null)
                    rc.ASI_MFM_Old_Item_English_Name__c = sku.ASI_MFM_SKU_Description__c;
                if(rc.ASI_MFM_Old_Item_Carton_Spec__c == '' || rc.ASI_MFM_Old_Item_Carton_Spec__c == null)
                    rc.ASI_MFM_Old_Item_Carton_Spec__c = sku.ASI_FOC_Packing_Description__c;
                if(rc.ASI_MFM_Old_Item_Bottle_Barcode__c == '' || rc.ASI_MFM_Old_Item_Bottle_Barcode__c == null)
                    rc.ASI_MFM_Old_Item_Bottle_Barcode__c = sku.ASI_CRM_Bottle_Barcode__c;
            }
            
            
        }
    }
}