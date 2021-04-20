trigger EUR_CRM_QualityTrigger on EUR_CRM_Quality__c (after update) {

    new EUR_CRM_QualityTriggerHandler().run();

}