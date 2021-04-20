trigger EUR_CRM_VisitActionTrigger on EUR_CRM_Visit_Action__c (before insert, before update, after insert) {

    EUR_CRM_VisitActionTriggerHandler handler = new EUR_CRM_VisitActionTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new, Trigger.newMap);
        }

//        if (Trigger.isUpdate) {
//            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
//        }
    }

}