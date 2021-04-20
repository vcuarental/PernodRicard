trigger EUR_CRM_DE_Contract_BeforeInsert on EUR_CRM_Contract__c (before insert) {
	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
		new EUR_CRM_DE_ContractAutoNumberHandler()
	}; 
	
	for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses){
		triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
	}
}