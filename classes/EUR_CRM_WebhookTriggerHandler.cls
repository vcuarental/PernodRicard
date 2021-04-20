/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */

public with sharing class EUR_CRM_WebhookTriggerHandler extends EUR_CRM_TriggerHandler {

    protected override void afterInsert() {
        new EUR_CRM_WebhookTriggerService().handleWebhookInTrigger(Trigger.new);
    }
}