trigger EUR_CRM_CriteriaSetTrigger on EUR_CRM_Criteria_Set__c (after update) {

    new EUR_CRM_CriteriaSetTriggerHandler().run();

}