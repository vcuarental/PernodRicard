trigger ASI_CRM_Price_Set_Generation_Log_Detail_BeforeInsert on ASI_CRM_Price_Set_Generation_Log_Detail__c (Before Insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Price_Set')){ 
        ASI_CRM_HK_PriceSetLogLi_TriggerClass.routineBeforeUpSert(trigger.new);
    }
}