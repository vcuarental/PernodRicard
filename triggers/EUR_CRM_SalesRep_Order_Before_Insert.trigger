trigger EUR_CRM_SalesRep_Order_Before_Insert on EUR_CRM_SalesRep_Order__c (before insert) {

    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
        new EUR_CRM_SalesRepOrderAssignAutoNumber(),
        new EUR_CRM_SalesRepOrderAssignManager()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}