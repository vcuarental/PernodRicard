trigger ASI_CRM_TOV_AfterUpdate on ASI_CRM_TOV__c (after update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TOV')){
        ASI_CRM_CN_TOV_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }       
}