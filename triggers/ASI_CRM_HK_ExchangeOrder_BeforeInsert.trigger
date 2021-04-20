trigger ASI_CRM_HK_ExchangeOrder_BeforeInsert on ASI_CRM_Exchange_Order__c (before insert) {
   if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Exchange_Order')){ 
        ASI_CRM_HK_ExchangeOrder_TriggerClass.routineBeforeInsert(trigger.new, trigger.oldMap);
    }
}