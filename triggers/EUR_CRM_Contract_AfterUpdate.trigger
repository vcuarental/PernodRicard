trigger EUR_CRM_Contract_AfterUpdate on EUR_CRM_Contract__c (after update) {
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
        //new EUR_CRM_GB_ContractAccountMapHandler(),
        //new EUR_CRM_PRS_ContractAccountMapHandler(),
        new EUR_CRM_PT_ContractCreateVolumeHandler()
    };
    
    for(EUR_CRM_TriggerAbstract triggerClass: triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}