trigger ASI_MFM_Event_AfterDelete on ASI_MFM_Event__c(after delete) {
    if (trigger.old[0].recordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName == 'ASI_CRM_CN_TP_Outlet'){
        ASI_CRM_CN_TP_Event_TriggerClass.routineAfterDelete(Trigger.old); 
    }
}