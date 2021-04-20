trigger ASI_HK_CRM_PreApprovalForm_AfterInsert on ASI_HK_CRM_Pre_Approval_Form__c (after insert) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
        ASI_CRM_TW_PAF_TriggerCls.routineAfterInsert(trigger.new, null);   
    }
}