trigger EUR_CRM_TerritoryTrigger on EUR_CRM_Territory__c (before update, after update) {
	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>();
	EUR_CRM_TriggerAbstract.TriggerAction tAction = (trigger.isUpdate && trigger.isBefore)? EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE:
		(trigger.isUpdate && trigger.isAfter)? EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE: EUR_CRM_TriggerAbstract.TriggerAction.NONE;

	if(trigger.isUpdate && (trigger.isBefore || trigger.isAfter)){
		triggerClasses.add(new EUR_CRM_TerritoryOwnerChanged());
	}

	for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
    	triggerClass.executeTriggerAction(tAction, trigger.new, trigger.newMap, trigger.oldMap);
    }

}