public without sharing class EUR_CRM_BudgetTransactionTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void afterInsert() {
        EUR_ISP_ContractTransactionsServiceDE.deleteWrongTransaction((List<EUR_CRM_Budget_Transaction__c>)Trigger.new);
    }

}