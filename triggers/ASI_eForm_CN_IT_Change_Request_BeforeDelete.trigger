trigger ASI_eForm_CN_IT_Change_Request_BeforeDelete on ASI_eForm_IT_Change_Request__c (before delete) {
    
     List<ASI_eForm_IT_Change_Request__c> oldCNRecordTypeList = new List<ASI_eForm_IT_Change_Request__c>();
     Map<Id,RecordType> cnRecordTypeMap = new
       Map<Id,RecordType>([SELECT Id from RecordType Where DeveloperName like '%ASI_eForm_CN_IT_Change_Request%' 
       and sObjectType='ASI_eForm_IT_Change_Request__c' LIMIT 1]); 
       
     for (ASI_eForm_IT_Change_Request__c itChangeRequest : trigger.old)
     {
       if (cnRecordTypeMap.containsKey(itChangeRequest.RecordTypeId))
       {
        oldCNRecordTypeList.add(itChangeRequest); 
       }     
     }
    
    
    ASI_eForm_GenericTriggerClass.validateHeaderStatus(oldCNRecordTypeList,'ASI_eForm_Status__c', new Set<String>{'Complete','Final'});
    
}