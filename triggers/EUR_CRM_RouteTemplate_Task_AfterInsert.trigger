trigger EUR_CRM_RouteTemplate_Task_AfterInsert on Task (after insert) {
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
        new EUR_CRM_RouteTemplateTaskHandler()
    };
    
    List<Task> recordToProcessList = new List<Task>();
    Map<Id, Task> recordToProcessMap = new Map<Id, Task>();
    
    for (Task task: Trigger.new){
        if (task.EUR_CRM_Route_Template__c != null){
            recordToProcessList.add(task);  
            recordToProcessMap.put(task.Id, task);
        }
    }
    
    if (recordToProcessList.size()>0){
        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, recordToProcessList, recordToProcessMap, trigger.oldMap);
        }   
    }

}