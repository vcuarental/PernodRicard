trigger ASI_CRM_ContractCost_BeforeUpdate on ASI_CRM_Contract_Cost__c (before update) {
    if (trigger.new[0].recordTypeId != null) {
    	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_MO')){
        	ASI_CRM_MO_ContractCost_TriggerCls.routineBeforeUpsert(trigger.new);
    	}
    }
}