public with sharing class EUR_CRM_AccountGroupUserTriggerHandler extends EUR_CRM_TriggerHandler {

    protected override void beforeUpdate() {
        new EUR_CRM_AccountGroupUserService().handleAccessLevelChange((Map<Id, EUR_CRM_AccountGroupUser__c>) Trigger.newMap, (Map<Id, EUR_CRM_AccountGroupUser__c>) Trigger.oldMap);
    }

    override protected void beforeDelete() {
        new EUR_CRM_AccountGroupUserDeletionHandler().handleDeletion(Trigger.old);
    }


}