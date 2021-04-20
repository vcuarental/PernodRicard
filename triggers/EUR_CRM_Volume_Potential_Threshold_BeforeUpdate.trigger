trigger EUR_CRM_Volume_Potential_Threshold_BeforeUpdate  on EUR_CRM_Volume_Potential_Threshold__c (before update) {
  
  List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
     new EUR_CRM_VolumePotentialThresholdChanged()
  };

  for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
      triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
  }
}