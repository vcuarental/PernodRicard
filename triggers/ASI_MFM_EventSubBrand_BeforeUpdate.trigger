trigger ASI_MFM_EventSubBrand_BeforeUpdate on ASI_MFM_Event_Sub_Brand__c (before update) {
	ASI_MFM_EventSubBrand_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
}