trigger EUR_CRM_ZA_POSMOrder_BeforeInsert on EUR_CRM_POSM_Order__c (before insert) {

	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
        new EUR_CRM_ZA_AssignWarehouseMangrHandler()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
    }
}