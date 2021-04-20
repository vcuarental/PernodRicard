trigger PRH_Brand_Criteria_AfterUpdate on PRH_Brand_Criteria__c (after update) {
    List<PRH_TriggerAbstract> triggerClasses = new List<PRH_TriggerAbstract> {
        new PRH_Luxury_Account_Full_Active()
        
    };
    
    for (PRH_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(PRH_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}