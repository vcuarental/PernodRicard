trigger LAT_ClientByRegionTrigger on LAT_ClientByRegion__c (before insert, before update, after insert, after update) {
	if (trigger.isBefore) {
		LAT_ClientByRegionHandler.assignRegionalManager(trigger.new);
		// if(trigger.isInsert){
		// 	LAT_ClientByRegionHandler.assingMechanic(trigger.new);
		// }
	}
	if (trigger.isAfter) {
		LAT_ClientByRegionHandler.shareRecords(trigger.new);
		//LAT_ClientByRegionHandler.assignAccountInActions(trigger.new);
		LAT_ClientByRegionHandler.posttoChatterWhenApproved(trigger.new, trigger.oldMap);
		if (trigger.isUpdate) {
			LAT_ClientByRegionHandler.manageStatus(trigger.new, trigger.oldMap);
		}
	}
}