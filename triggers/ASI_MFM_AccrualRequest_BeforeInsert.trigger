trigger ASI_MFM_AccrualRequest_BeforeInsert on ASI_MFM_Accrual_Request__c (before insert) {
    
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MKTEXP')){
        ASI_MFM_AccrualRequest_TriggerClass.routineBeforeUpsert(trigger.New, null);
    }
}