trigger ASI_CRM_ExchangeOrderItem_AfterAll on ASI_CRM_Exchange_Order_Item__c (after insert, after update, after delete) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Exchange_Order_Item')){ 
        ASI_CRM_HK_ExOrderItem_TriggerClass.routineAfterAll (trigger.new,null);
    }
}