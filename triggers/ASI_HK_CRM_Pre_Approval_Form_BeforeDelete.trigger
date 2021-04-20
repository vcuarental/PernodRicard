trigger ASI_HK_CRM_Pre_Approval_Form_BeforeDelete on ASI_HK_CRM_Pre_Approval_Form__c (before delete) {
     if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
        ASI_CRM_TW_PAF_TriggerCls.routineBeforeDelete(trigger.old);
    }
}