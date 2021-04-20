trigger ASI_eForm_IT_Change_Request_Item_BeforeDelete on ASI_eForm_IT_Change_Request_Item__c (before delete) {

    Set<Id> headerIds = new Set<Id>();
    
    for(ASI_eForm_IT_Change_Request_Item__c itChangeRequestItem : Trigger.old)
    {
      headerIds.add(itChangeRequestItem.ASI_eForm_IT_Change_Request__c);         
    }   
     
    Map<Id,ASI_eForm_IT_Change_Request__c> headerMap = 
     new Map<Id,ASI_eForm_IT_Change_Request__c>([Select Id, ASI_eForm_Status__c 
      from ASI_eForm_IT_Change_Request__c Where RecordType.DeveloperName 
      like '%ASI_eForm_HK_IT_Change_Request%' and id in :headerIds]);

  ASI_eForm_GenericTriggerClass.validateDetailStatus(Trigger.old, headerMap, 
         'ASI_eForm_Status__c', 'ASI_eForm_IT_Change_Request__c', new Set<String>{'Complete','Final'},'ASI_eForm_IT_Action__c'); 
}