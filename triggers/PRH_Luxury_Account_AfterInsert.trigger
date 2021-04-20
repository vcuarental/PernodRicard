trigger PRH_Luxury_Account_AfterInsert on PRH_Luxury_Accounts__c (after insert) {
    
    List<PRH_TriggerAbstract> triggerClasses = new List<PRH_TriggerAbstract> {
        new PRH_Share_Luxury_Account()
        
    };
    
    for (PRH_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(PRH_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
    

}