trigger ASI_CRM_ContractTarget_AfterUpdate on ASI_CRM_ContractTarget__c (After Update) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')){
        ASI_CRM_SG_ContractTarget_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
    }
	else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')){
        ASI_CRM_PH_ContractTarget_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
    }
}