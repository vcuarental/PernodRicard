trigger EUR_CRM_Sales_Order_BeforeUpdate on EUR_CRM_Sales_Order__c (before update) {

	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
        new EUR_CRM_SalesOrderAssignPreferredDate(),
        new EUR_CRM_SalesOrderUpdateInfo(),
        new EUR_CRM_StockUpdateFromSO()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }

}