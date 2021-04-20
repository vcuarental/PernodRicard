trigger EUR_CRM_AccountTrigger on EUR_CRM_Account__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    EUR_CRM_AccountTriggerHandler handler = new EUR_CRM_AccountTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }

        if (Trigger.isDelete) {
            handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new, Trigger.newMap);
        }

        if (Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }

        if (Trigger.isDelete) {
            handler.onAfterDelete(Trigger.old, Trigger.oldMap);
        }

        if (Trigger.isUndelete) {
            handler.onAfterUndelete(Trigger.old);
        }
    }

}