trigger EUR_CRM_Store_Audit_Item_AfterUpdate on EUR_CRM_Store_Audit_Item__c (after update) {
    
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
        //new EUR_JB_AuditedVolumeMatchingHandler(),
        new EUR_CRM_VolumeTrackerContractVol()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }    
}