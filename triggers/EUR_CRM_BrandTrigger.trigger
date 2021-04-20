trigger EUR_CRM_BrandTrigger on EUR_CRM_Brand__c (after update) {

    new EUR_CRM_BrandTriggerHandler().run();

}