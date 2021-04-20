/*
*    Description    :    After Update trigger on EUR_CRM_Sales_Order__c
*
*    Version    Author        Date            Description
*    1.0        Sid           12/30/2015      Initial Draft
*/

trigger EUR_CRM_Sales_Order_AfterUpdate on EUR_CRM_Sales_Order__c (after update) {

	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
        new EUR_CRM_ZA_SalesOrderCallout(),
        new EUR_CRM_DE_CreateSalesOrderCase()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}