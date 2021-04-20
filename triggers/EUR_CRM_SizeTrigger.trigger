trigger EUR_CRM_SizeTrigger on EUR_CRM_Size__c (after update) {

    new EUR_CRM_SizeTriggerHandler().run();

}