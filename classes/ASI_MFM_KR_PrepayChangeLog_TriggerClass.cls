Public Without Sharing class ASI_MFM_KR_PrepayChangeLog_TriggerClass {

    Private Final Static Map<String, Schema.SObjectField> prepaymentChangeLog_FIELD_MAP = Schema.SObjectType.ASI_MFM_Prepayment_Proposal_Change_Log__c.fields.getMap();
    Private Final Static Map<String, Schema.SObjectField> FixApproval_FIELD_MAP = Schema.SObjectType.ASI_MFM_Fix_Approval_Route__c.fields.getMap();
    
    Public Static Void beforeUpdateMethod(List<ASI_MFM_Prepayment_Proposal_Change_Log__c> triggerNew, Map<Id, ASI_MFM_Prepayment_Proposal_Change_Log__c> triggerOldMap){
        
        Map<String, ASI_MFM_Fix_Approval_Route__c> mapFixApproval = new Map<String, ASI_MFM_Fix_Approval_Route__c>();
        Set<id> ownerIdSet = new Set<Id>();
        Set<id> LogIdSet = new Set<Id>();
        Set<id> doclistIdSet = new Set<Id>();
        Map<Id, User> mapRecordOwner = new Map<Id, User>();
        String whereClause = ' Where ASI_MFM_Module__c Like \'Prepayment Proposal Change Log\' AND RecordType.DeveloperName Like \'ASI_MFM_KR_Fix_Approval_Route\'';
        
        for(ASI_MFM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FixApproval_FIELD_MAP, whereClause)){
            mapFixApproval.put(obj.ASI_MFM_Team__c, obj);
        }
        
        for(ASI_MFM_Prepayment_Proposal_Change_Log__c obj : triggerNew){
            
	        /* 20180201 Introv
            if(obj.ASI_MFM_Status__c =='Submitted' && triggerOldMap.get(obj.id).ASI_MFM_Status__c =='Draft'){
            	LogIdSet.add(obj.id);
            }
			*/
            
            if(obj.ASI_MFM_Requested_By__c != Null)
                ownerIdSet.add(obj.ASI_MFM_Requested_By__c);
        }
        
        /* 20180201 Introv
        if(LogIdSet.size()>0){
            for(attachment att : [select parentid from attachment where parentid in :LogIdSet]){
                if(!doclistIdSet.contains(att.parentid)){
                    doclistIdSet.add(att.parentid);
                }
            }
        }
		*/
        
        if(ownerIdSet.size() > 0)
            mapRecordOwner = new Map<Id, User>([SELECT id, ASI_MFM_Team__c, ManagerId FROM User WHERE Id IN : ownerIdSet]);
        
        for(ASI_MFM_Prepayment_Proposal_Change_Log__c obj : triggerNew){
            
            /* 20180201 Introv
            if(LogIdSet.contains(obj.id) && !doclistIdSet.contains(obj.Id)){
                obj.addError('Attachment is required.');
            }
            */
            
            setApproverToNull(obj);
            
            if(mapRecordOwner.containsKey(obj.ASI_MFM_Requested_By__c) && mapFixApproval.containsKey(mapRecordOwner.get(obj.ASI_MFM_Requested_By__c).ASI_MFM_Team__c)){
                obj.ASI_MFM_Sys_Approver_1__c = mapRecordOwner.get(obj.ASI_MFM_Requested_By__c).ManagerId;
                setFixApprover(obj, mapFixApproval.get(mapRecordOwner.get(obj.ASI_MFM_Requested_By__c).ASI_MFM_Team__c));
            }
        }
    }
    
    @TestVisible
    Private Static Void setFixApprover(ASI_MFM_Prepayment_Proposal_Change_Log__c logObj, ASI_MFM_Fix_Approval_Route__c fixApproval){
        
        Integer i = 1;
        Integer j = 1;
        String fieldname = 'asi_mfm_sys_approver_' + i + '__c';
        String fixApprover = 'asi_mfm_corporate_approver_' + j + '__c';
        
        while(prepaymentChangeLog_FIELD_MAP.containsKey(fieldname) && FixApproval_FIELD_MAP.containsKey(fixApprover)){
            
            if(logObj.get(fieldname) != Null){
                i++;
                fieldname = 'asi_mfm_sys_approver_' + i + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) == Null){
                j++;
                fixApprover = 'asi_mfm_corporate_approver_' + j + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) != Null){
            	logObj.put(fieldname, fixApproval.get(fixApprover));
            }
            
            i++;
            j++;
            
            fieldname = 'asi_mfm_sys_approver_' + i + '__c';
            fixApprover = 'asi_mfm_corporate_approver_' + j + '__c';
        }
    }
    
    @TestVisible
    Private Static Void setApproverToNull(ASI_MFM_Prepayment_Proposal_Change_Log__c logObj){
        
        Integer i = 1;
        String fieldname = 'asi_mfm_sys_approver_' + i + '__c';
        
        while(prepaymentChangeLog_FIELD_MAP.containsKey(fieldname)){
            
            logObj.put(fieldname, null);
            i++;
            fieldname = 'asi_mfm_sys_approver_' + i + '__c';
        }
    }
    
    @TestVisible
    Private Static List<ASI_MFM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_MFM_Fix_Approval_Route__c ' + whereClause;
        
        List<ASI_MFM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_MFM_Fix_Approval_Route__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_MFM_Fix_Approval_Route__c>();
    }
    
    @TestVisible
    Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}