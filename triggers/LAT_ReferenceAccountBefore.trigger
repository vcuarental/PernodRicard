trigger LAT_ReferenceAccountBefore on LAT_ReferenceAccount__c (before insert, before update) {
	LAT_ReferenceAccount.AssignAccountName(trigger.new);
	LAT_ReferenceAccount.UniqueAccount(trigger.new, trigger.oldMap, trigger.isUpdate);
	LAT_ReferenceAccount.AssignValues(trigger.new);
}