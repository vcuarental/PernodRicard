public with sharing class EUR_CRM_CriteriaThreshQuestionService {

    @TestVisible
    private static final String NEED_UPDATE = 'Need Update';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleQuestions(List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds) {
        Set<Id> criteriaSetIdsToUpdate = this.getCriteriaSetIdsToUpdate(criteriaThresholds);
        System.debug('\n\n criteriaSetIdsToUpdate => ' + JSON.serializePretty(criteriaSetIdsToUpdate) + '\n');
        if (criteriaSetIdsToUpdate.isEmpty()) { return ; }

        this.updateCriteriaSets(criteriaSetIdsToUpdate);
    }

    public void handleQuestions(List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds, Map<Id, EUR_CRM_Criteria_Threshold__c> oldCriteriaThresholdById) {
        Set<Id> criteriaSetIdsToUpdate = this.getCriteriaSetIdsToUpdate(criteriaThresholds, oldCriteriaThresholdById);
        System.debug('\n\n criteriaSetIdsToUpdate => ' + JSON.serializePretty(criteriaSetIdsToUpdate) + '\n');
        if (criteriaSetIdsToUpdate.isEmpty()) { return ; }

        this.updateCriteriaSets(criteriaSetIdsToUpdate);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateCriteriaSets(Set<Id> criteriaSetIds) {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = selectCriteriaSetsWhereIds(criteriaSetIds);
        System.debug('\n\n criteriaSets => ' + JSON.serializePretty(criteriaSets) + '\n');
        if (criteriaSets.isEmpty()) { return ; }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = true;
        }
        update criteriaSets;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<Id> getCriteriaSetIdsToUpdate(List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds) {
        Set<Id> criteriaSetIds = new Set<Id>();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            criteriaSetIds.add(criteriaThreshold.EUR_CRM_Criteria_Set__c);
        }
        return criteriaSetIds;
    }

    private Set<Id> getCriteriaSetIdsToUpdate(List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds, Map<Id, EUR_CRM_Criteria_Threshold__c> oldCriteriaThresholdById) {
        Set<Id> criteriaSetIds = new Set<Id>();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            if (this.isParentCriteriaSetShouldBeUpdated(criteriaThreshold, oldCriteriaThresholdById)) {
                criteriaSetIds.add(criteriaThreshold.EUR_CRM_Criteria_Set__c);
            }
        }
        return criteriaSetIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isParentCriteriaSetShouldBeUpdated(EUR_CRM_Criteria_Threshold__c criteriaThreshold, Map<Id, EUR_CRM_Criteria_Threshold__c> oldCriteriaThresholdById) {
        return criteriaThreshold.EUR_CRM_ActionPROS__c == NEED_UPDATE
            && oldCriteriaThresholdById.get(criteriaThreshold.Id).EUR_CRM_ActionPROS__c != NEED_UPDATE
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Criteria_Set__c> selectCriteriaSetsWhereIds(Set<Id> criteriaSetIds) {
        return [
            SELECT Id
            ,   EUR_CRM_IsQuestionsUpdated__c
            FROM EUR_CRM_Criteria_Set__c
            WHERE Id IN :criteriaSetIds
                AND EUR_CRM_IsQuestionsUpdated__c = FALSE
        ];
    }

}