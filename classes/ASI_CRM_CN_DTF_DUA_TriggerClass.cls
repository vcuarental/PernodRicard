public without sharing class ASI_CRM_CN_DTF_DUA_TriggerClass {
    
    Private Static Final Id FIX_APPROVAL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
    
    Private Static Final Map<String, Schema.SObjectField> DTF_FIELD_MAP = Schema.SObjectType.ASI_CRM_DTF__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> FIX_APPROVAL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    
    Private Static Map<String, ASI_CRM_Fix_Approval_Route__c> G_MAP_FixApproval = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
    
    public static void beforeInsertMethod(List<ASI_CRM_DTF__c> triggerNew) {
        assignApprovers(triggerNew);
        assignLevel0Approvers(triggerNew);
    }
    
    public static void beforeUpdateMethod(List<ASI_CRM_DTF__c> triggerNew, Map<Id, ASI_CRM_DTF__c> triggerOldMap) {
        setNullApprovers(triggerNew);
        assignApprovers(triggerNew);
        assignLevel0Approvers(triggerNew);
    }

    private static void assignLevel0Approvers(List<ASI_CRM_DTF__c> triggerNew) {
        Id idLevel0Approver1 = getPublicGroupUserIDByGroupName('ASI CRM CN DUA Level0 Approver1');
        Id idLevel0Approver2 = getPublicGroupUserIDByGroupName('ASI CRM CN DUA Level0 Approver2');
        
        for(ASI_CRM_DTF__c oDTF : triggerNew) {
            if (oDTF.ASI_CRM_CN_Level0_Approver_1__c == NULL) oDTF.ASI_CRM_CN_Level0_Approver_1__c = idLevel0Approver1;
            if (oDTF.ASI_CRM_CN_Level0_Approver_2__c == NULL) oDTF.ASI_CRM_CN_Level0_Approver_2__c = idLevel0Approver2;
        }
    }
    
    private static Id getPublicGroupUserIDByGroupName(String name){
        String userType = Schema.SObjectType.User.getKeyPrefix();
        List<Group> publicGroup = [Select Id From Group Where Name = :name Limit 1];
        if(publicGroup.size() > 0){
            List<GroupMember> member = [Select UserOrGroupId From GroupMember Where GroupId = :publicGroup[0].Id Limit 1];
            
            if(member.size() > 0){
                if (((String)member[0].UserOrGroupId).startsWith(userType)){
                    return member[0].UserOrGroupId;
                }
                else {
                    return null;
                }
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    private static void setNullApprovers(List<ASI_CRM_DTF__c> triggerNew) {
        for(ASI_CRM_DTF__c oDTF : triggerNew) {
            oDTF.ASI_CRM_CN_SysApprover1__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover2__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover3__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover4__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover5__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover6__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover7__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover8__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover9__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover10__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover11__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover12__c = NULL;
            oDTF.ASI_CRM_CN_SysApprover13__c = NULL;
        }
    }
    
    private static void assignApprovers(List<ASI_CRM_DTF__c> triggerNew) {
        setFixApproval();
        
        Integer iMaxCount = 13;
        
        for(ASI_CRM_DTF__c oDTF : triggerNew) {
            string sChannel = oDTF.ASI_CRM_Channel__c;

            if (G_MAP_FixApproval.containsKey(sChannel)) {
                ASI_CRM_Fix_Approval_Route__c oFixApproval = G_MAP_FixApproval.get(sChannel);
                
                Integer i = 1;
                Integer j = 1;
                String sysApprover = 'asi_crm_cn_sysapprover' + i + '__c';
                String fixApprover = 'asi_crm_cn_approver_' + j + '__c';
                
                While(DTF_FIELD_MAP.containsKey(sysApprover) && FIX_APPROVAL_FIELD_MAP.containsKey(fixApprover) && (i<=iMaxCount) && (j<=iMaxCount)) {            
                    if(oDTF.get(sysApprover) != Null){
                        i++;
                        sysApprover = 'ASI_CRM_CN_SysApprover' + i + '__c';
                        continue;
                    }
                    
                    if(oFixApproval.get(fixApprover) == Null){
                        j++;
                        fixApprover = 'ASI_CRM_CN_Approver_' + j + '__c';
                        continue;
                    }
                    
                    oDTF.put(sysApprover, oFixApproval.get(fixApprover));
                    
                    i++;
                    sysApprover = 'ASI_CRM_CN_SysApprover' + i + '__c';
                    
                    j++;
                    fixApprover = 'ASI_CRM_CN_Approver_' + j + '__c';
                }
            }
        }
    }
    
    private static void setFixApproval() {
        for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FIX_APPROVAL_FIELD_MAP, ' WHERE RecordTypeId = \'' + FIX_APPROVAL_RECORD_TYPE_ID + '\' AND ASI_CRM_CN_Type__c LIKE \'Data Usage Application\'')){
            G_MAP_FixApproval.put(obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
        }
    }
    
    Private Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;
        
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
    }
    
    Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
    
}