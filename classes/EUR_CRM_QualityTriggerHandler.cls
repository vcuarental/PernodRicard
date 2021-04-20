public with sharing class EUR_CRM_QualityTriggerHandler extends EUR_CRM_TriggerHandler {

    protected override void afterUpdate() {
        new EUR_CRM_BQCpiUpdateService().updateCpiTotalSpentFreeCases(Trigger.new, (Map<Id, EUR_CRM_Quality__c>)Trigger.oldMap);
        new EUR_CRM_BBQBQS_ImageDownloaderService().download(Trigger.new, (Map<Id, EUR_CRM_Quality__c>)Trigger.oldMap);
    }

}