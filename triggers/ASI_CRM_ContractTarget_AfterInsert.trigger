trigger ASI_CRM_ContractTarget_AfterInsert on ASI_CRM_ContractTarget__c (After Insert) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')){
        ASI_CRM_SG_ContractTarget_TriggerClass.routineAfterUpsert(trigger.new, null);
    }
	else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')){
        ASI_CRM_PH_ContractTarget_TriggerClass.routineAfterUpsert(trigger.new, null);
    }
}