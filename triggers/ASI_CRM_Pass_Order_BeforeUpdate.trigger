trigger ASI_CRM_Pass_Order_BeforeUpdate on ASI_CRM_Pass_Order__c (before update) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM
        ASI_CRM_TW_Pass_Order_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
    }
}