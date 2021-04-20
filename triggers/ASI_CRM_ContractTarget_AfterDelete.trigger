trigger ASI_CRM_ContractTarget_AfterDelete on ASI_CRM_ContractTarget__c (After Delete) {
    if(trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')){
        ASI_CRM_SG_ContractTarget_TriggerClass.routineAfterDelete(trigger.old);
    }
	else if(trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')){
        ASI_CRM_PH_ContractTarget_TriggerClass.routineAfterDelete(trigger.old);
    }
}