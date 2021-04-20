trigger EUR_CRM_PRS_QuestionTrigger on EUR_CRM_PRS_Question__c (after insert, after update) {

    new EUR_CRM_PRS_QuestionTriggerHandler().run();

}