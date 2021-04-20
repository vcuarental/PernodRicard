trigger ASI_eForm_CN_IT_Change_Request_Item_AfterUpdate on ASI_eForm_IT_Change_Request_Item__c (after update) {

    Set<Id> itcrIds = new Set<Id>();

    for (ASI_eForm_IT_Change_Request_Item__c  itcrItem : Trigger.new)
    {
        itcrIds.add(itcrItem.ASI_eForm_IT_Change_Request__c);   
    }
    
    Map<Id,ASI_eForm_IT_Change_Request__c> itcrMap = new Map<Id,ASI_eForm_IT_Change_Request__c>(
    [Select Id, RecordType.DeveloperName, ASI_eForm_Status__c, ASI_eForm_IT_Action__c from ASI_eForm_IT_Change_Request__c
    Where Id in :itcrIds
    and RecordType.DeveloperName like '%ASI_eForm_CN_IT_Change_Request%'
    and ASI_eForm_Status__c = 'Final']);
    
    if (itcrMap.size() > 0 )
    {
       //Issue #5 20140905 Enable Items IT Action's to be changed from Complete to WIP or IT Acknowledged
       if(itcrMap.values().get(0).ASI_eForm_IT_Action__c == 'Complete')
           ASI_eForm_GenericTriggerClass.reverseCompleteITAction(itcrMap, trigger.new, trigger.oldmap, 'ASI_eForm_IT_Change_Request__c;ASI_eForm_IT_Action__c', 'ASI_eForm_IT_Action__c;ASI_eForm_Status__c'); 
       else
           ASI_eForm_ITChangeRequestHandler.processITChangeRequestItemHeaders(itcrMap); 
       //End of fix
    }
    

}