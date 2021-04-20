trigger EUR_CRM_GB_ObjectiveTrigger on EUR_CRM_GB_Objective__c (before insert, after insert, before update) {

    new EUR_CRM_GB_ObjectiveTriggerHandler().run();

}