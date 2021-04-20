trigger ASI_CRM_PriceSetLog_BeforeUpdate on ASI_CRM_Price_Set_Generation_Log__c (Before Update) {
   if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')){ 
        ASI_CRM_HK_PriceSetLog_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }
}