/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */

trigger EUR_CRM_WebhookTrigger on EUR_CRM_Webhook__c (after insert) {
    new EUR_CRM_WebhookTriggerHandler().run();
}