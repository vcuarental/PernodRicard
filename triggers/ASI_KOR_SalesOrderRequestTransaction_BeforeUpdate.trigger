trigger ASI_KOR_SalesOrderRequestTransaction_BeforeUpdate on ASI_KOR_Sales_Order_Transaction__c (before update) {

    
    //For CN
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_SalesOrder_Item')){
        ASI_CRM_CN_SalesOrderItem_TriggerClass.beforeUpsertMethod(trigger.new);
    }
}