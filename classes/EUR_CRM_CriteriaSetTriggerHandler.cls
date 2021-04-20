public with sharing class EUR_CRM_CriteriaSetTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void afterUpdate() {
        new EUR_CRM_CriteriaSetIsQuestUpdService().handleIsQuestionsUpdateCheckbox(Trigger.new, (Map<Id, EUR_CRM_Criteria_Set__c>)Trigger.oldMap);
    }

}