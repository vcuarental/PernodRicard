/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */

public with sharing class EUR_CRM_WebhookTriggerService {

    public void handleWebhookInTrigger(List<EUR_CRM_Webhook__c> webhooks) {
        for (EUR_CRM_Webhook__c webhook : webhooks) {
            System.debug('webhook in loop: ' + webhook);
            EUR_CRM_WebhookHandlers__mdt mdtHandler = getClassHandler(webhook.EUR_CRM_Source_System__c, webhook
                    .EUR_CRM_Affiliate__c, webhook.EUR_CRM_Entity__c);
            handleWebhook(mdtHandler.EUR_CRM_Handler__c, webhook.Id);
        }
    }
    @Future(Callout=true)
    private static void handleWebhook(String handlerName, Id webhookId) {
        EUR_CRM_IWebhookHandler handler = (EUR_CRM_IWebhookHandler)Type.forName(handlerName).newInstance();
        List<EUR_CRM_Webhook__c> webhooksToUpdate = new List<EUR_CRM_Webhook__c>();
        try {
            handler.handleWebhook();
            webhooksToUpdate.add(createWebhookWithIdAndStatus(webhookId, 'Processed'));
        } catch (Exception ex) {
            System.debug('Exception in API processing - ' + ex.getMessage());
            webhooksToUpdate.add(createWebhookWithIdAndStatus(webhookId, 'Error'));
        }
        update webhooksToUpdate;
    }

    private EUR_CRM_WebhookHandlers__mdt getClassHandler(String sourceSystem, String affiliate, String entity) {
        return [
                SELECT EUR_CRM_Handler__c
                FROM EUR_CRM_WebhookHandlers__mdt
                WHERE EUR_CRM_Source_System__c = :sourceSystem AND
                EUR_CRM_Affiliate__c = :affiliate AND EUR_CRM_Entity__c = :entity
                LIMIT 1
        ];
    }

    private static EUR_CRM_Webhook__c createWebhookWithIdAndStatus(Id id, String status) {
        return new EUR_CRM_Webhook__c(
                Id = id,
                EUR_CRM_Status__c = status
        );
    }
}