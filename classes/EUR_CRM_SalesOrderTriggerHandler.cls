public with sharing class EUR_CRM_SalesOrderTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeInsert() {
        new EUR_CRM_SalesOrderAutoNumber().setupAutonumber(Trigger.new);
    }

    override protected void beforeUpdate() {
        new EUR_CRM_SalesOrderApprovalProcessRunner().validateToRunApprovalProcess(Trigger.new, (Map<Id,EUR_CRM_Sales_Order__c>) Trigger.oldMap);
    }

    override protected void afterUpdate() {
        new EUR_CRM_SalesOrderApprovalProcessRunner().runApprovalProcess(Trigger.new, (Map<Id,EUR_CRM_Sales_Order__c>) Trigger.oldMap);
        new EUR_CRM_SalesOrderToStockItemHandler().onAfterUpdate(Trigger.new, (Map<Id,EUR_CRM_Sales_Order__c>) Trigger.oldMap);
    }

}