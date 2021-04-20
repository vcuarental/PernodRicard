trigger EUR_CRM_Store_Audit_Items_AfterInsert on EUR_CRM_Store_Audit_Item__c (after insert) {

    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
        //new EUR_JB_Achievement_Creation(),
        new EUR_CRM_VolumeTrackerContractVol()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
    }

}