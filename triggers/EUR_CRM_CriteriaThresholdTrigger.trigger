trigger EUR_CRM_CriteriaThresholdTrigger on EUR_CRM_Criteria_Threshold__c (after insert, after update) {

    new EUR_CRM_CriteriaThresholdTriggerHandler().run();
    
}