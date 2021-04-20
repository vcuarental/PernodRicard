public with sharing class EUR_CRM_PRS_QuestionTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void afterInsert() {
        new EUR_CRM_PRS_QuestionActionService().handleAction(Trigger.new);
    }

    override protected void afterUpdate() {
        new EUR_CRM_PRS_QuestionActionService().handleAction(Trigger.new, (Map<Id, EUR_CRM_PRS_Question__c>)Trigger.oldMap);
    }

}