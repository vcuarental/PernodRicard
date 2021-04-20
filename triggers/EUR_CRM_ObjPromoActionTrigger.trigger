trigger EUR_CRM_ObjPromoActionTrigger on EUR_CRM_ObjPromo_Action__c (before insert, before update) {

    EUR_CRM_ObjPromoActionTriggerHandler handler = new EUR_CRM_ObjPromoActionTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

//    if (Trigger.isAfter) {
//        if (Trigger.isInsert) {
//            handler.onAfterInsert(Trigger.new);
//        }
//
//        if (Trigger.isUpdate) {
//            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
//        }
//    }

}