trigger ASI_KOR_Contact_AfterInsert on Contact (after insert) {
	
	List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
		new ASI_KOR_ContactUpdateAccountMainContact()
	};
	
	for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
		triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
	}
	
}