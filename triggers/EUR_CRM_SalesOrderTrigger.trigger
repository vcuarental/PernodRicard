trigger EUR_CRM_SalesOrderTrigger on EUR_CRM_Sales_Order__c (before insert, before update, after update) {

    new EUR_CRM_SalesOrderTriggerHandler().run();

}