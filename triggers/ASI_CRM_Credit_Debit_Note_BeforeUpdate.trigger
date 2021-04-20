trigger ASI_CRM_Credit_Debit_Note_BeforeUpdate on ASI_CRM_Credit_Debit_Note__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Manual')){
        ASI_CRM_SG_CreditNote_TriggerClass.retrieveExchangeRate(trigger.new, trigger.oldMap);
        ASI_CRM_SG_CreditNote_TriggerClass.validateGLDateChange(trigger.new, trigger.oldMap);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG')){
        ASI_CRM_SG_CreditNote_TriggerClass.calculateGST(trigger.new, trigger.oldMap);
    }
}