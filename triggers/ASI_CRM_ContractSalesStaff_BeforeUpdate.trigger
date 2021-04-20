trigger ASI_CRM_ContractSalesStaff_BeforeUpdate on ASI_CRM_ContractSalesStaffIncentive__c(before update){
    if(trigger.new[0].recordTypeId != NULL && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_MY')){
        ASI_CRM_MY_ContractSalesStaff_TriggerCls.routineBeforeUpsert(trigger.new);
    }  
}