trigger ASI_MFM_Event_Outlet_BeforeUpdate on ASI_MFM_Event_Outlet__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
		ASI_MFM_EventOutlet_TriggerClass.routineBeforeUpsert(Trigger.New, trigger.oldMap);
    }
}