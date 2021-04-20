trigger EUR_CRM_Image_Level_Threshold_BeforeUpdate on EUR_CRM_Image_Level_Threshold__c (before update) {
  
  List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
     new EUR_CRM_ImageLevelThresholdChanged()
  };

  for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
      triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
  }
}