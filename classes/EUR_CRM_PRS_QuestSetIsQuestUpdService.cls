public with sharing class EUR_CRM_PRS_QuestSetIsQuestUpdService {

    @TestVisible
    private static final String NEED_UPDATE = 'Need Update';
    @TestVisible
    private static final String NO_NEED_UPDATE = 'No Need Update';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleIsQuestionsUpdateCheckbox(List<EUR_CRM_PRS_Question_Set__c> questionSets, Map<Id, EUR_CRM_PRS_Question_Set__c> oldQuestionSetById) {
        Set<Id> questionSetIds = this.getQuestionSetIdsToUpdateQuestions(questionSets, oldQuestionSetById);
        System.debug('\n\n questionSetIds => ' + JSON.serializePretty(questionSetIds) + '\n');
        if (questionSetIds.isEmpty()) { return ; }

        this.updateQuestions(questionSetIds);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateQuestions(Set<Id> questionSetIds) {
        List<EUR_CRM_PRS_Question__c> questions = this.selectQuestionWhereCriteriaSet(questionSetIds);
        System.debug('\n\n questions => ' + JSON.serializePretty(questions) + '\n');
        if (questions.isEmpty()) { return ; }

        for (EUR_CRM_PRS_Question__c question : questions) {
            question.EUR_CRM_ActionPROS__c = NO_NEED_UPDATE;
        }

        update questions;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<Id> getQuestionSetIdsToUpdateQuestions(List<EUR_CRM_PRS_Question_Set__c> questionSets, Map<Id, EUR_CRM_PRS_Question_Set__c> oldQuestionSetById) {
        Set<Id> questionSetIds = new Set<Id>();
        for (EUR_CRM_PRS_Question_Set__c questionSet : questionSets) {
            if (this.isQuestionsUpdateChanged(questionSet, oldQuestionSetById)) {
                questionSetIds.add(questionSet.Id);
            }
        }
        return questionSetIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isQuestionsUpdateChanged(EUR_CRM_PRS_Question_Set__c questionSet, Map<Id, EUR_CRM_PRS_Question_Set__c> oldQuestionSetById) {
        return questionSet.EUR_CRM_IsQuestionsUpdated__c == false
            && oldQuestionSetById.get(questionSet.Id).EUR_CRM_IsQuestionsUpdated__c == true
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_PRS_Question__c> selectQuestionWhereCriteriaSet(Set<Id> questionSetIds) {
        return [
            SELECT Id
            ,   EUR_CRM_ActionPROS__c
            FROM EUR_CRM_PRS_Question__c
            WHERE EUR_CRM_PRS_Question_Set__c IN :questionSetIds
                AND EUR_CRM_ActionPROS__c = :NEED_UPDATE
        ];
    }

}