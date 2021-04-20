/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

trigger EUR_CRM_PosmAuditTrigger on EUR_CRM_POSM_Audit__c (before insert, before update) {
    new EUR_CRM_PosmAuditTriggerHandler().run();
}