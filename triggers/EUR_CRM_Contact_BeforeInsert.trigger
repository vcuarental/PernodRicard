trigger EUR_CRM_Contact_BeforeInsert on Contact (before insert) {
	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
		new EUR_CRM_ContactEUAccountLinkHandler()
	};

	for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
    	triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
    }
}