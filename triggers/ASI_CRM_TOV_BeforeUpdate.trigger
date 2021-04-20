trigger ASI_CRM_TOV_BeforeUpdate on ASI_CRM_TOV__c (before update) {
	if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TOV')) {
        ASI_CRM_CN_TOV_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }
}