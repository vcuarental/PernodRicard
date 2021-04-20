trigger ASI_CRM_Calculated_Payment_AfterUpdate on ASI_CRM_Calculated_Payment__c (after update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
        ASI_CRM_MY_CalculatedPayment_TriggerCls.routineAfterUpsert(trigger.new);
        ASI_CRM_MY_CalculatedPayment_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldmap);
    }
}