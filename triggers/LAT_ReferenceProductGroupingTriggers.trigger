trigger LAT_ReferenceProductGroupingTriggers on LAT_ReferenceProductGrouping__c (before insert, before update) {
	LAT_ReferenceProductGrouping.setExternalId(trigger.new);
}