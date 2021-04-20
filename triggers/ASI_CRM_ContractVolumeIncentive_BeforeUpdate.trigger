trigger ASI_CRM_ContractVolumeIncentive_BeforeUpdate on ASI_CRM_ContractVolumeIncentive__c (before update) {
    if(trigger.new[0].recordTypeId != NULL && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_MY')){
        ASI_CRM_MY_ContractVolume_TriggerCls.routineBeforeUpsert(trigger.new);
    }  
}