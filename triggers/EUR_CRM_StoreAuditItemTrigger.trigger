/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

trigger EUR_CRM_StoreAuditItemTrigger on EUR_CRM_Store_Audit_Item__c (before insert) {
    EUR_CRM_StoreAuditItemTriggerHandler handler = new EUR_CRM_StoreAuditItemTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }
    }
}