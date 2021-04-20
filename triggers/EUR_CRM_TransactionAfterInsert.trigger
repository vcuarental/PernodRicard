trigger EUR_CRM_TransactionAfterInsert  on EUR_CRM_Budget_Transaction__c (after insert) {
  List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
        new EUR_CRM_BudgetCarryForwardHandler()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
    }

    new EUR_CRM_BudgetTransactionTriggerHandler().run();
}