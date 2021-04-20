public with sharing class EUR_CRM_SalesOrderItemTriggerHandler extends EUR_CRM_TriggerHandler {

    @TestVisible
    private static String forTest() {
        return '';
    }
//    override protected void beforeInsert() {
//        new EUR_CRM_SalesOrderItemStockUpdate().onBeforeInsert(Trigger.new);
//    }
//
//    override protected void afterInsert() {
//        new EUR_CRM_SalesOrderItemStockUpdate().onAfterInsert(Trigger.new);
//    }
//
//    override protected void afterUpdate() {
//        new EUR_CRM_SalesOrderItemStockUpdate().onAfterUpdate(Trigger.new, (Map<Id, EUR_CRM_Sales_Order_Items__c>) Trigger.oldMap);
//    }
//
//    override protected void beforeDelete() {
//        new EUR_CRM_SalesOrderItemStockUpdate().onBeforeDelete(Trigger.old);
//    }
}