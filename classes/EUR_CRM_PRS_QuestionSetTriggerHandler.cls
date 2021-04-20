public with sharing class EUR_CRM_PRS_QuestionSetTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void afterUpdate() {
        new EUR_CRM_PRS_QuestSetIsQuestUpdService().handleIsQuestionsUpdateCheckbox(Trigger.new, (Map<Id, EUR_CRM_PRS_Question_Set__c>)Trigger.oldMap);
    }

}