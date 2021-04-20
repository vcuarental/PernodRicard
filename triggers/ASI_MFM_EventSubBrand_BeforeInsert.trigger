trigger ASI_MFM_EventSubBrand_BeforeInsert on ASI_MFM_Event_Sub_Brand__c (before insert) {
	ASI_MFM_EventSubBrand_TriggerClass.routineBeforeUpsert(trigger.new, null);
}