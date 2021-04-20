trigger LAT_BR_TAATrigger on LAT_BR_TAA__c (after insert, after update) {
	if (trigger.isInsert || trigger.isUpdate) {
		LAT_BR_TAAActions.copyObjectivesToVisit(trigger.new);
		LAT_BR_TAAActions.TAAsendConfirmationEmail(trigger.new);
	}
}