//Edit: 12/22/14: Add cancelled contract handler class

trigger EUR_CRM_DE_Contract_AfterUpdate on EUR_CRM_Contract__c (after update)
{
    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>
    {
        new EUR_CRM_ContractBudgetLinkHandler(),
        //new EUR_CRM_DE_ContractApprovedHandler(),
        new EUR_CRM_ContractCancelledHandler(),
        new EUR_CRM_ContractDraftTransactionHandler(),
        new EUR_CRM_DE_AttachContractPDF(),
        new EUR_CRM_ContractApprovedHandler()
    };

    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses)
    {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}