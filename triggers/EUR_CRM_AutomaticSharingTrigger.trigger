trigger EUR_CRM_AutomaticSharingTrigger on EUR_CRM_Automatic_Sharing__c (before update) {
	new EUR_CRM_AutomaticSharingTriggerHandler().run();
}