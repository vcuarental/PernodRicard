trigger LAT_Receipt_Range on LAT_Receipt_Range__c (before insert, after insert, before update, after update) {

	if (trigger.isBefore && trigger.isUpdate) {
		AP01_Receipt_AR.validateMobileRange(trigger.new);
	}

}