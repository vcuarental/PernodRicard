trigger ASI_CRM_IGCP_BeforeUpdate on ASI_CRM_Item_Group_Customer_Price__c (before Update) {

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_IGCP_TriggerClass.beforeUpsertMethod(trigger.new);
    }
}