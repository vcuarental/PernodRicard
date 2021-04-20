public with sharing class EUR_CRM_AccountGroupTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeDelete() {
        new EUR_CRM_AccountGroupDeletionHandler().handleDeletion(Trigger.old);
    }

}