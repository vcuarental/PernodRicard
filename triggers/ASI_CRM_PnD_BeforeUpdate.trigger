trigger ASI_CRM_PnD_BeforeUpdate on ASI_CRM_Price_And_Discount__c (before Update) {
     // CN CRM
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_PnD_TriggerClass.beforeUpdateMedthod(trigger.new, trigger.OldMap);
    }
}