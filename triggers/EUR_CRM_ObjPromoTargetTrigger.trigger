trigger EUR_CRM_ObjPromoTargetTrigger on EUR_CRM_ObjPromo_Target__c (after insert, after update) {

    EUR_CRM_ObjPromoTargetTriggerHandler handler = new EUR_CRM_ObjPromoTargetTriggerHandler();

//    if (Trigger.isBefore) {
//        if (Trigger.isInsert) {
//            handler.onBeforeInsert(Trigger.new);
//        }
//
//        if (Trigger.isUpdate) {
//            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
//        }
//    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}