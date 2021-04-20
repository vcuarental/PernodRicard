trigger PRH_Iconic_Brand_AfterUpdate on PRH_Brand_Luxury_Brand__c (after update) {
	List<PRH_TriggerAbstract> triggerClasses = new List<PRH_TriggerAbstract> {
        new PRH_Iconic_Brand_Update()
    };
    
    for (PRH_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(PRH_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}