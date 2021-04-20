trigger ASI_MFM_EventSubChannel_BeforeInsert on ASI_MFM_Event_Sub_Channel__c (before insert) {
	ASI_MFM_EventSubChannel_TriggerClass.routineBeforeUpsert(trigger.new, null);
}