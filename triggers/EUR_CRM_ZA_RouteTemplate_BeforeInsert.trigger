trigger EUR_CRM_ZA_RouteTemplate_BeforeInsert on EUR_CRM_Route_Template__c (before insert) {
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
        new EUR_CRM_ZA_Validate_RT_Start_Date() };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses){
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
    }
}