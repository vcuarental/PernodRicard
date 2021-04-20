public with sharing class EUR_CRM_TemplateLineTriggerHandler {

    public void onAfterInsert(Map<Id, EUR_CRM_JB_Template_Line__c> templateLines) {
        updateTemplate(templateLines);
    }
    public void onAfterUpdate(Map<Id, EUR_CRM_JB_Template_Line__c> templateLines) {
        updateTemplate(templateLines);
    }
    public void onAfterDelete(Map<Id, EUR_CRM_JB_Template_Line__c> templateLines) {
        updateTemplate(templateLines);
    }

    private void updateTemplate(Map<Id, EUR_CRM_JB_Template_Line__c> templateLines) {
        Set<Id> templateIds = new Set<Id>();
        for (EUR_CRM_JB_Template_Line__c templateLine : templateLines.values()) {
            templateIds.add(templateLine.EUR_JB_CRM_Template__c);
        }
        update [SELECT Id FROM EUR_CRM_JB_Template__c WHERE Id IN :templateIds];
    }


}