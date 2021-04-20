trigger ASI_MFM_Plan_AfterDelete on ASI_MFM_Plan__c (after delete) {

    if (!Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP')  
         && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SC_')){
        ASI_MFM_Plan_TriggerClass.routineAfterDelete(trigger.old);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_CAP_Plan_TriggerClass.routineAfterDelete(trigger.old);
    }
    
}