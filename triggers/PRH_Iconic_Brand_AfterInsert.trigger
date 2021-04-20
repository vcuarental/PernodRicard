trigger PRH_Iconic_Brand_AfterInsert on PRH_Brand_Luxury_Brand__c (after insert) {
    List<PRH_TriggerAbstract> triggerClasses = new List<PRH_TriggerAbstract> {
        new PRH_Iconic_Brand_Creation()
    };
    
    for (PRH_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(PRH_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
}