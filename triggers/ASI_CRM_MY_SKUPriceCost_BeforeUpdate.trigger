trigger ASI_CRM_MY_SKUPriceCost_BeforeUpdate on ASI_CRM_MY_SKUPriceCost__c (before update) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW'))    
        ASI_CRM_TW_SKUPriceCost_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
}