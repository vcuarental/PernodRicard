public with sharing class EUR_CRM_PrsAnswerTriggerHandler extends EUR_CRM_TriggerHandler{

	protected override void afterInsert() {
		new EUR_CRM_PrsAnswerAccUpdateServ().onAfterInsert(Trigger.new);
	}

	protected override void afterUpdate() {
		new EUR_CRM_PrsAnswerAccUpdateServ().onAfterUpdate(Trigger.new, (Map<Id, EUR_CRM_PRS_Answer__c>) Trigger.oldMap);
	}


}