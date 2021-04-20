trigger ASI_HK_CRM_Contact_AfterUpdate on Contact (after update) {
	
	List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
		new ASI_HK_CRM_ContactUpdateAcctMainContact()
	};
	
	for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
		triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
	}

}