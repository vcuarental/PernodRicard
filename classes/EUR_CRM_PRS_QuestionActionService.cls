public with sharing class EUR_CRM_PRS_QuestionActionService {

    @TestVisible
    private static final String NEED_UPDATE = 'Need Update';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleAction(List<EUR_CRM_PRS_Question__c> questions) {
        Set<Id> questionSetIdsToUpdate = this.getQuestionSetIdsToUpdate(questions);
        System.debug('\n\n questionSetIdsToUpdate => ' + JSON.serializePretty(questionSetIdsToUpdate) + '\n');
        if (questionSetIdsToUpdate.isEmpty()) { return ; }

        this.updateQuestionSets(questionSetIdsToUpdate);
    }

    public void handleAction(List<EUR_CRM_PRS_Question__c> questions, Map<Id, EUR_CRM_PRS_Question__c> oldQuestionById) {
        Set<Id> questionSetIdsToUpdate = this.getQuestionSetIdsToUpdate(questions, oldQuestionById);
        System.debug('\n\n questionSetIdsToUpdate => ' + JSON.serializePretty(questionSetIdsToUpdate) + '\n');
        if (questionSetIdsToUpdate.isEmpty()) { return ; }

        this.updateQuestionSets(questionSetIdsToUpdate);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateQuestionSets(Set<Id> questionSetIds) {
        List<EUR_CRM_PRS_Question_Set__c> questionSets = selectQuestionSetsWhereIds(questionSetIds);
        System.debug('\n\n questionSets => ' + JSON.serializePretty(questionSets) + '\n');
        if (questionSets.isEmpty()) { return ; }

        for (EUR_CRM_PRS_Question_Set__c criteriaSet : questionSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = true;
        }
        update questionSets;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<Id> getQuestionSetIdsToUpdate(List<EUR_CRM_PRS_Question__c> questions) {
        Set<Id> questionSetIds = new Set<Id>();
        for (EUR_CRM_PRS_Question__c criteriaThreshold : questions) {
            questionSetIds.add(criteriaThreshold.EUR_CRM_PRS_Question_Set__c);
        }
        return questionSetIds;
    }

    private Set<Id> getQuestionSetIdsToUpdate(List<EUR_CRM_PRS_Question__c> questions, Map<Id, EUR_CRM_PRS_Question__c> oldQuestionById) {
        Set<Id> questionSetIds = new Set<Id>();
        for (EUR_CRM_PRS_Question__c criteriaThreshold : questions) {
            if (this.isParentCriteriaSetShouldBeUpdated(criteriaThreshold, oldQuestionById)) {
                questionSetIds.add(criteriaThreshold.EUR_CRM_PRS_Question_Set__c);
            }
        }
        return questionSetIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isParentCriteriaSetShouldBeUpdated(EUR_CRM_PRS_Question__c criteriaThreshold, Map<Id, EUR_CRM_PRS_Question__c> oldQuestionById) {
        return criteriaThreshold.EUR_CRM_ActionPROS__c == NEED_UPDATE
            && oldQuestionById.get(criteriaThreshold.Id).EUR_CRM_ActionPROS__c != NEED_UPDATE
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_PRS_Question_Set__c> selectQuestionSetsWhereIds(Set<Id> questionSetIds) {
        return [
            SELECT Id
            ,   EUR_CRM_IsQuestionsUpdated__c
            FROM EUR_CRM_PRS_Question_Set__c
            WHERE Id IN :questionSetIds
                AND EUR_CRM_IsQuestionsUpdated__c = FALSE
        ];
    }


}