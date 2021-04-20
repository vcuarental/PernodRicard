trigger ASI_CRM_VN_Contract_Expenditure_BeforeDelete on ASI_CRM_VN_Contract_Expenditure__c (before delete) {
	new ASI_CRM_VN_ContractExpendCheckDelete().executeTrigger(Trigger.new, Trigger.oldMap);
}