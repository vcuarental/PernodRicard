trigger EUR_CRM_ContractTrigger on EUR_CRM_Contract__c (before insert, before update, before delete, after insert, after update, after delete) {

    new EUR_CRM_ContractTriggerHandler().run();

}