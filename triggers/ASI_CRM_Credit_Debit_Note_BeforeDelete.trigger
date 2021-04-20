trigger ASI_CRM_Credit_Debit_Note_BeforeDelete on ASI_CRM_Credit_Debit_Note__c (before delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_CRM_SG_Contract_Margin')
        || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_CRM_SG_Prompt_Payment')
        || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_CRM_SG_Back_Rebate')
                || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Credit_Note')        //WL 1.0
                    || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Debit_Note')){   //WL 1.0
            
          ASI_CRM_SG_CreditNote_TriggerClass.validationBeforeDelete(trigger.old);
      }
}