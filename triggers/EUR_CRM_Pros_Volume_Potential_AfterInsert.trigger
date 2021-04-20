trigger EUR_CRM_Pros_Volume_Potential_AfterInsert on EUR_CRM_Pros_Volume_Potential__c (after insert) {
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
        new EUR_CRM_VolPotentialHandler(),
        new EUR_CRM_DeleteOldProsImageVolPotHandler()
    };

    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
    }
  
}