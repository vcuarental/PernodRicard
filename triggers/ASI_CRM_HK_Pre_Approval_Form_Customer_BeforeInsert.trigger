trigger ASI_CRM_HK_Pre_Approval_Form_Customer_BeforeInsert on ASI_CRM_HK_Pre_Approval_Form_Customer__c (before Insert) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
        ASI_CRM_TW_PAF_Customer_TriggerCls.routineBeforeUpsert(trigger.new, null);
    }
}