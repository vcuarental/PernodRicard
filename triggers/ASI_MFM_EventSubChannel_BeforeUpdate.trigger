trigger ASI_MFM_EventSubChannel_BeforeUpdate on ASI_MFM_Event_Sub_Channel__c (before update) {
	ASI_MFM_EventSubChannel_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
}