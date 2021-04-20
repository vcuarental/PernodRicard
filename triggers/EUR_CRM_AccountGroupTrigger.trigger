trigger EUR_CRM_AccountGroupTrigger on EUR_CRM_AccountGroup__c (before delete) {

    new EUR_CRM_AccountGroupTriggerHandler().run();

}