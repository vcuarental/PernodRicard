trigger ASI_eForm_CN_IT_Change_Request_AfterInsert on ASI_eForm_IT_Change_Request__c (after insert) {

     List<ASI_eForm_IT_Change_Request__c> newCNRecordTypeList = new List<ASI_eForm_IT_Change_Request__c>();
     RecordType cnRecordType = [SELECT Id from RecordType Where DeveloperName = 'ASI_eForm_CN_IT_Change_Request' and sObjectType='ASI_eForm_IT_Change_Request__c' LIMIT 1]; 
     for (ASI_eForm_IT_Change_Request__c itChangeRequest : trigger.new)
     {
       if (itChangeRequest.RecordTypeId == cnRecordType.Id)
       {
        newCNRecordTypeList.add(itChangeRequest); 
       }     
     }
     /*
     ASI_eForm_GenericTriggerClass.assignRecordPermission(newCNRecordTypeList, 'ASI_eForm_IT_Change_Request__Share', 
                                                            'ASI_eForm_IT_Change_Manager_Access__c', 
                                                            'ASI_eForm_Preview_Approver__c', null);  
     */  
}