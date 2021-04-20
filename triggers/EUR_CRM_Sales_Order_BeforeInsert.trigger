trigger EUR_CRM_Sales_Order_BeforeInsert on EUR_CRM_Sales_Order__c (before insert) {
	
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
//        new EUR_CRM_SalesOrderAssignAutoNumber(),
        new EUR_CRM_SalesOrderAssignPreferredDate(),
        new EUR_CRM_SalesOrderUpdateInfo()
    };
    new EUR_CRM_SalesOrderAssignInfo().onBeforeInsert(Trigger.new);

    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
    }
}