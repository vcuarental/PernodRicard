trigger ASI_CRM_TOV_BeforeInsert on ASI_CRM_TOV__c (Before Insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TOV')){
        ASI_CRM_CN_TOV_TriggerClass.routineBeforeInsert(trigger.new);
    }
    //2019/10/27 CanterDuan
    ASI_CRM_CN_TOV_TriggerClass.GetTaxRate(trigger.new);
    //2019/10/27 END
}