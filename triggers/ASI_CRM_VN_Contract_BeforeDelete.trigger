trigger ASI_CRM_VN_Contract_BeforeDelete on ASI_CRM_VN_Contract__c (before delete) {
	new ASI_CRM_VN_ContractCheckDelete().executeTrigger(Trigger.new, Trigger.oldMap);
}