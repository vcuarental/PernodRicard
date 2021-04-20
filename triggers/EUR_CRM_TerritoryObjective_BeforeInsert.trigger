trigger EUR_CRM_TerritoryObjective_BeforeInsert on EUR_CRM_GB_Territory_Objective__c (before insert) {
	
	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
         new EUR_CRM_TerritoryObjectiveHandler()
    };

    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
    }
}