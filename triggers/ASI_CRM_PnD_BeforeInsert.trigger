trigger ASI_CRM_PnD_BeforeInsert on ASI_CRM_Price_And_Discount__c (before insert) {
    //2020-05-04 Ceterna: Created
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Rebate_Period')){
        ASI_CRM_SG_PnD_TriggerClass.checkEffectiveDate(trigger.new);
    }
}