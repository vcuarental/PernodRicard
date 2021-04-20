trigger EUR_CRM_PRS_AnswerTrigger on EUR_CRM_PRS_Answer__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	new EUR_CRM_PrsAnswerTriggerHandler().run();

}