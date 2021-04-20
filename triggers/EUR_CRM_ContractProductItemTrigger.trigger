trigger EUR_CRM_ContractProductItemTrigger on EUR_CRM_Contract_Product_Item__c (before insert, after insert, before update, after update) {
		new EUR_CRM_ContractProductItemHandler().run();
}