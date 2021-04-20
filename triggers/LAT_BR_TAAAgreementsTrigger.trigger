trigger LAT_BR_TAAAgreementsTrigger on LAT_BR_TAAAgreement__c (after update, after insert) {
	LAT_BR_TAAActions.TAAAgreementAccompaniment(trigger.new, trigger.oldMap);
	if (trigger.isUpdate) {
		LAT_BR_TAAActions.DeleteAgreements(trigger.new);
	}
}