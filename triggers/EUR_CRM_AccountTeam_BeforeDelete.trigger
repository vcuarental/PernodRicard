trigger EUR_CRM_AccountTeam_BeforeDelete on EUR_CRM_Account_Team__c (before delete) {
	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
		new EUR_CRM_EUAccountTeamHandler()
	};

	for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
    	triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, trigger.oldMap);
    }
}