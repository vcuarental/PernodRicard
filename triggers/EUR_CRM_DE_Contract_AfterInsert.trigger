trigger EUR_CRM_DE_Contract_AfterInsert on EUR_CRM_Contract__c (after insert) {
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
        new EUR_CRM_ContractBudgetLinkHandler(),
        new EUR_CRM_ContractPaymentPlanHandler()
    }; 
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses){
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
}