public with sharing class EUR_CRM_SizeTriggerHandler extends EUR_CRM_TriggerHandler {

    protected override void afterUpdate() {
        new EUR_CRM_BBQBQS_ImageDownloaderService().download(Trigger.new, (Map<Id, EUR_CRM_Size__c>)Trigger.oldMap);
    }

}