trigger ASI_CRM_PriceSetLog_AfterUpdate on ASI_CRM_Price_Set_Generation_Log__c (after update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')){ 
        ASI_CRM_HK_PriceSetLog_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
}