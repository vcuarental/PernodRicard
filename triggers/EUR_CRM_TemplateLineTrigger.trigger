trigger EUR_CRM_TemplateLineTrigger on EUR_CRM_JB_Template_Line__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    EUR_CRM_TemplateLineTriggerHandler handler = new EUR_CRM_TemplateLineTriggerHandler();

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.newMap);
        } else if (Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.newMap);
        } else if (Trigger.isDelete) {
            handler.onAfterDelete(Trigger.oldMap);
        }
    }
}