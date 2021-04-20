trigger EUR_CRM_AccountInTargetGroupTrigger on EUR_CRM_Account_in_Target_Group__c (after insert, before delete, after undelete) {
	new EUR_CRM_AccountInATGTriggerHandler().run();
}