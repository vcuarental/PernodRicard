public with sharing class EUR_CRM_ContractProductItemHandler extends EUR_CRM_TriggerHandler{

	protected override void beforeInsert() {
		new EUR_CRM_CPIbeforeInsertService().updateQuantity(Trigger.new);

	}

	protected override void afterInsert() {
		new EUR_CRM_ContractPaymentPlanPeriodHandler().onAfterInsert(Trigger.new);
		new EUR_CRM_CPIbeforeInsertService().updateTotalSpentFreeCases(Trigger.new, new Map<Id, EUR_CRM_Contract_Product_Item__c>());
	}

	protected override void beforeUpdate() {
		new EUR_CRM_CPIbeforeInsertService().updateTotalSpentFreeCases(Trigger.new, (Map<Id, EUR_CRM_Contract_Product_Item__c>) Trigger.oldMap);
	}

	protected override void afterUpdate() {
		new EUR_CRM_ContractPaymentPlanPeriodHandler().onAfterUpdate(Trigger.new, (Map<Id, EUR_CRM_Contract_Product_Item__c>) Trigger.oldMap);
	}


}