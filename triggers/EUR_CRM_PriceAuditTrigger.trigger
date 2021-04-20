/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

trigger EUR_CRM_PriceAuditTrigger on EUR_CRM_Price_Audit__c (before insert, before update) {
    new EUR_CRM_PriceAuditTriggerHandler().run();
}