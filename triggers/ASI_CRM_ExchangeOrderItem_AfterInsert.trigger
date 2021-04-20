trigger ASI_CRM_ExchangeOrderItem_AfterInsert on ASI_CRM_Exchange_Order_Item__c (after insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Exchange_Order_Item')){ 
        ASI_CRM_HK_ExOrderItem_TriggerClass.routineAfterInsert(trigger.new);
    }
}