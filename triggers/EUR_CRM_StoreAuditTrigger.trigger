/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

trigger EUR_CRM_StoreAuditTrigger on EUR_CRM_Store_Audit__c (before insert, before update) {
    new EUR_CRM_StoreAuditTriggerHandler().run();
}