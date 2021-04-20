trigger ASI_CRM_EOL_BeforeInsert on ASI_CRM_EOL__c (before Insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_EOL_TriggerClass.executeBeforeUpdateTriggerAction(trigger.new, Null);
    }
}