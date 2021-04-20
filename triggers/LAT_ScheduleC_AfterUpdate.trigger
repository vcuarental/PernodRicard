trigger LAT_ScheduleC_AfterUpdate on LAT_ScheduleC__c (before update) {
	LAT_ScheduleC_Trigger.validateScheduleObject(trigger.oldmap, trigger.newmap );   
}