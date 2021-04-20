trigger ASI_eForm_IT_Change_Request_AfterInsert on ASI_eForm_IT_Change_Request__c (after insert) {

     List<ASI_eForm_IT_Change_Request__c> newHKRecordTypeList = new List<ASI_eForm_IT_Change_Request__c>();
     RecordType hkRecordType = [SELECT Id from RecordType Where DeveloperName = 'ASI_eForm_HK_IT_Change_Request' and sObjectType='ASI_eForm_IT_Change_Request__c' LIMIT 1]; 
     for (ASI_eForm_IT_Change_Request__c itChangeRequest : trigger.new)
     {
       if (itChangeRequest.RecordTypeId == hkRecordType.Id)
       {
        newHKRecordTypeList.add(itChangeRequest); 
       }     
     }

     map<String, String> mappedApproverAccessLevel = new Map<String, String>();
     mappedApproverAccessLevel.put('ASI_eForm_Preview_Approver__c', 'read');
     mappedApproverAccessLevel.put('ASI_eForm_Further_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_High_Level_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_Change_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_CN_Change_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_Project_Implementer__c','edit');
     
     ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_IT_Change_Request__Share', 
                                                            'ASI_eForm_IT_Change_Manager_Access__c', 
                                                            new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Further_Authorizer__c',
                                                                            'ASI_eForm_High_Level_Authorizer__c', 'ASI_eForm_Change_Authorizer__c', 
                                                                            'ASI_eForm_Project_Implementer__c', 'ASI_eForm_CN_Change_Authorizer__c'}, 
                                                            null, mappedApproverAccessLevel);  

}