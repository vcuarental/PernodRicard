trigger EUR_CRM_FI_Contract_AfterUpdate on EUR_CRM_Contract__c (after update) {
//    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
//        new EUR_CRM_FI_ContractAccountMapHandler() };
//
//    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses){
//        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
//    }
    new EUR_CRM_ContractAccountMapHandler().handleContracts(Trigger.new, Trigger.oldMap);
}