public with sharing class EUR_CRM_CriteriaSetIsQuestUpdService {

    @TestVisible
    private static final String NEED_UPDATE = 'Need Update';
    @TestVisible
    private static final String NO_NEED_UPDATE = 'No Need Update';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleIsQuestionsUpdateCheckbox(List<EUR_CRM_Criteria_Set__c> criteriaSets, Map<Id, EUR_CRM_Criteria_Set__c> oldCriteriaSetById) {
        Set<Id> criteriaSetIds = this.getCriteriaSetIdsToUpdateCriteriaThresholds(criteriaSets, oldCriteriaSetById);
        System.debug('\n\n criteriaSetIds => ' + JSON.serializePretty(criteriaSetIds) + '\n');
        if (criteriaSetIds.isEmpty()) { return ; }

        this.updateCriteriaThresholds(criteriaSetIds);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateCriteriaThresholds(Set<Id> criteriaSetIds) {
        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = this.selectCriteriaThresholdWhereCriteriaSet(criteriaSetIds);
        System.debug('\n\n criteriaThresholds => ' + JSON.serializePretty(criteriaThresholds) + '\n');
        if (criteriaThresholds.isEmpty()) { return ; }

        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            criteriaThreshold.EUR_CRM_ActionPROS__c = NO_NEED_UPDATE;
        }

        update criteriaThresholds;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<Id> getCriteriaSetIdsToUpdateCriteriaThresholds(List<EUR_CRM_Criteria_Set__c> criteriaSets, Map<Id, EUR_CRM_Criteria_Set__c> oldCriteriaSetById) {
        Set<Id> criteriaSetIds = new Set<Id>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            if (this.isQuestionsUpdateChanged(criteriaSet, oldCriteriaSetById)) {
                criteriaSetIds.add(criteriaSet.Id);
            }
        }
        return criteriaSetIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isQuestionsUpdateChanged(EUR_CRM_Criteria_Set__c criteriaSet, Map<Id, EUR_CRM_Criteria_Set__c> oldCriteriaSetById) {
        return criteriaSet.EUR_CRM_IsQuestionsUpdated__c == false
            && oldCriteriaSetById.get(criteriaSet.Id).EUR_CRM_IsQuestionsUpdated__c == true
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Criteria_Threshold__c> selectCriteriaThresholdWhereCriteriaSet(Set<Id> criteriaSetIds) {
        return [
            SELECT Id
            ,   EUR_CRM_ActionPROS__c
            FROM EUR_CRM_Criteria_Threshold__c
            WHERE EUR_CRM_Criteria_Set__c IN :criteriaSetIds
                AND EUR_CRM_ActionPROS__c = :NEED_UPDATE
        ];
    }

}