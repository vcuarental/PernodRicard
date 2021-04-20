trigger ASI_eForm_IT_Change_Request_BeforeDelete on ASI_eForm_IT_Change_Request__c (before delete) {
    
    List<ASI_eForm_IT_Change_Request__c> oldHKRecordTypeList = new List<ASI_eForm_IT_Change_Request__c>();
    Map<Id,RecordType> hkRecordTypeMap = new 
       Map<Id,RecordType>([SELECT Id from RecordType Where DeveloperName like '%ASI_eForm_HK_IT_Change_Request%' 
     and sObjectType='ASI_eForm_IT_Change_Request__c']);
      
     for (ASI_eForm_IT_Change_Request__c itChangeRequest : Trigger.old)
     {
       if (hkRecordTypeMap.containsKey(itChangeRequest.RecordTypeId))
       {
        oldHKRecordTypeList.add(itChangeRequest); 
       }     
     }
    
    
    ASI_eForm_GenericTriggerClass.validateHeaderStatus(oldHKRecordTypeList,'ASI_eForm_Status__c', new Set<String>{'Complete','Final'});
    
}