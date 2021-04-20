trigger ASI_MFM_Budget_BeforeUpdate on ASI_MFM_Budget__c (before update) {
     if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_Budget_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);  
    }
}