trigger ASI_HK_CRM_Contact_AfterUndelete on Contact (after undelete) {
	
	List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
		new ASI_HK_CRM_ContactUpdateAcctMainContact()
	};
	
	for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
		triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UNDELETE, trigger.new, trigger.newMap, null);
	}

}