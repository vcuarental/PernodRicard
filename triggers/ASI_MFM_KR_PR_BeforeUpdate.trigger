trigger ASI_MFM_KR_PR_BeforeUpdate on ASI_MFM_Purchase_Request__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_PR_TriggerClass.BeforeUpsertMethod(trigger.new, trigger.oldMap);
    }
}