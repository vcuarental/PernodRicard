trigger EUR_CRM_RouteTemplate_Task_AfterUpdate on Task (after update) {
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
        new EUR_CRM_RouteTemplateTaskHandler()
    };
    
    List<Task> recordToProcessList = new List<Task>();
    Map<Id, Task> recordToProcessMap = new Map<Id, Task>();
    
    for (Task task: Trigger.new){
        if (task.EUR_CRM_Route_Template__c != Trigger.oldMap.get(task.Id).EUR_CRM_Route_Template__c){
            recordToProcessList.add(task);  
            recordToProcessMap.put(task.Id, task);
        }
    }
    
    if (recordToProcessList.size()>0){
        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, recordToProcessList, recordToProcessMap, trigger.oldMap);
        }   
    }

}