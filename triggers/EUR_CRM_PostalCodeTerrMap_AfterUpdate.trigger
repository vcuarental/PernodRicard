trigger EUR_CRM_PostalCodeTerrMap_AfterUpdate on EUR_CRM_Postal_Code_Territory_Mapping__c (after update) {
  
   List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
     new EUR_CRM_PostalCodeTerrMapChangedHandler()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}