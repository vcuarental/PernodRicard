trigger EUR_CRM_PRS_QuestionSetTrigger on EUR_CRM_PRS_Question_Set__c (after update) {

    new EUR_CRM_PRS_QuestionSetTriggerHandler().run();

}