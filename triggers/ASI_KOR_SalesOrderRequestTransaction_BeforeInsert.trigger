trigger ASI_KOR_SalesOrderRequestTransaction_BeforeInsert on ASI_KOR_Sales_Order_Transaction__c (before insert) {
    //For CN
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_SalesOrder_Item')){
        // 2019/11/6 CanterDuan start
        ASI_CRM_CN_SalesOrderItem_TriggerClass.GetTaxRate(trigger.new);
        //2019/11/6 CanterDuan end
        // 20190725 Wilson Chow start
        ASI_CRM_CN_SalesOrderItem_TriggerClass.beforeInsertMethod(trigger.new);
        // 20190725 Wilson Chow end
        ASI_CRM_CN_SalesOrderItem_TriggerClass.beforeUpsertMethod(trigger.new);
    }
}