trigger ASI_CRM_ContractPP_BeforeInsert on ASI_CRM_PromoterPlacement__c (before insert) {
    if(trigger.new[0].recordTypeId != NULL && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_MY')){
        ASI_CRM_MY_ContractPP_TriggerCls.routineBeforeInsert(trigger.new);
        ASI_CRM_MY_ContractPP_TriggerCls.routineBeforeUpsert(trigger.new);
    }  
}