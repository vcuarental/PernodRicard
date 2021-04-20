trigger EUR_CRM_AccountTargetGroupTrigger on EUR_CRM_Account_Target_Group__c (before insert, after insert, before update, after update) {

    new EUR_CRM_AccountTargetGroupTriggerHandler().run();

}