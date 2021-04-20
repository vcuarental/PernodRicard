trigger ASI_CRM_OrderForm_BeforeInsert on ASI_CRM_Order_Form__c (before Insert) {

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_OrderFormTriggerClass.beforeUpsertMethod(trigger.new);
    }
}