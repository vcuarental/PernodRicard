trigger ASI_CRM_EOL_BeforeUpdate on ASI_CRM_EOL__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_EOL_TriggerClass.executeBeforeUpdateTriggerAction(trigger.new, trigger.oldMap);
    }
}