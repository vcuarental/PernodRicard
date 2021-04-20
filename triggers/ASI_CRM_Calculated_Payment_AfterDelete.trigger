trigger ASI_CRM_Calculated_Payment_AfterDelete on ASI_CRM_Calculated_Payment__c (after delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_MY_')){
        ASI_CRM_MY_CalculatedPayment_TriggerCls.routineBeforeDelete(trigger.oldMap);
    }
}