trigger PRH_Iconic_Brand_BeforeDelete on PRH_Brand_Luxury_Brand__c (before delete) {
    List<PRH_TriggerAbstract> triggerClasses = new List<PRH_TriggerAbstract> {
        new PRH_Iconic_Brand_Deletion()
    };
    
    for (PRH_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(PRH_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, trigger.newMap, trigger.oldMap);
    }
}