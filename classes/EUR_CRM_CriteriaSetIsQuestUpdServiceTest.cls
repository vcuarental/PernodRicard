@IsTest (IsParallel = true)
private class EUR_CRM_CriteriaSetIsQuestUpdServiceTest {

    private static final Integer COUNT_OF_RECORDS = 5;
    private static final String NEED_UPDATE = EUR_CRM_CriteriaSetIsQuestUpdService.NEED_UPDATE;
    private static final String NO_NEED_UPDATE = EUR_CRM_CriteriaSetIsQuestUpdService.NO_NEED_UPDATE;


    /* ============================================================================================== */
    /*     Update one EUR_CRM_Criteria_Set__c with one EUR_CRM_Criteria_Threshold__c
    /* ============================================================================================== */
    @IsTest
    private static void updateOneCriteriaSetToFalseIsQuestionUpdateForOneCriteriaThresholdWithNewActionTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, 'New');
        insert criteriaThreshold;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update criteriaSet;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaThreshold = selectCriteriaThresholds()[0];
        System.assertEquals('New', criteriaThreshold.EUR_CRM_ActionPROS__c);
    }

    @IsTest
    private static void updateOneCriteriaSetToFalseIsQuestionUpdateForOneCriteriaThresholdWithNeedUpdateActionTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, NEED_UPDATE);
        insert criteriaThreshold;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update criteriaSet;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaThreshold = selectCriteriaThresholds()[0];
        System.assertEquals(NO_NEED_UPDATE, criteriaThreshold.EUR_CRM_ActionPROS__c);
    }


    /* ============================================================================================== */
    /*     Update one EUR_CRM_Criteria_Set__c with many EUR_CRM_Criteria_Threshold__c
    /* ============================================================================================== */
    @IsTest
    private static void updateOneCriteriaSetToFalseIsQuestionUpdateForManyCriteriaThresholdsWithNewActionTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, 'New');
        insert criteriaThresholds;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update criteriaSet;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaThresholds = selectCriteriaThresholds();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            System.assertEquals('New', criteriaThreshold.EUR_CRM_ActionPROS__c);
        }
    }

    @IsTest
    private static void updateOneCriteriaSetToFalseIsQuestionUpdateForManyCriteriaThresholdsWithNeedUpdateActionTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, NEED_UPDATE);
        insert criteriaThresholds;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;

        Test.startTest();
        update criteriaSet;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaThresholds = selectCriteriaThresholds();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            System.assertEquals(NO_NEED_UPDATE, criteriaThreshold.EUR_CRM_ActionPROS__c);
        }
    }


    /* ============================================================================================== */
    /*     Update many EUR_CRM_Criteria_Set__c with many EUR_CRM_Criteria_Threshold__c
    /* ============================================================================================== */
    @IsTest
    private static void updateManyCriteriaSetToFalseIsQuestionUpdateForManyCriteriaThresholdsWithNewActionTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'New'));
        }
        insert criteriaThresholds;

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }

        Test.startTest();
        update criteriaSets;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        criteriaThresholds = selectCriteriaThresholds();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            System.assertEquals('New', criteriaThreshold.EUR_CRM_ActionPROS__c);
        }
    }

    @IsTest
    private static void updateManyCriteriaSetToFalseIsQuestionUpdateForManyCriteriaThresholdsWithNeedUpdateActionTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, NEED_UPDATE));
        }
        insert criteriaThresholds;

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }

        Test.startTest();
        update criteriaSets;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        criteriaThresholds = selectCriteriaThresholds();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            System.assertEquals(NO_NEED_UPDATE, criteriaThreshold.EUR_CRM_ActionPROS__c);
        }
    }

    @IsTest
    private static void updateManyCriteriaSetToFalseIsQuestionUpdateForManyCriteriaThresholdsWithNewAndNeedUpdateActionsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'New'));
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, NEED_UPDATE));
        }
        insert criteriaThresholds;

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }

        Test.startTest();
        update criteriaSets;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        criteriaThresholds = selectCriteriaThresholds();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            System.assertNotEquals(NEED_UPDATE, criteriaThreshold.EUR_CRM_ActionPROS__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Criteria_Set__c> makeCriteriaSets() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = new List<EUR_CRM_Criteria_Set__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            criteriaSets.add(makeCriteriaSet());
        }
        return criteriaSets;
    }

    private static List<EUR_CRM_Criteria_Threshold__c> makeCriteriaThresholds(Id criteriaSetId, String actionPros) {
        List<EUR_CRM_Criteria_Threshold__c> thresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            thresholds.add(makeCriteriaThreshold(criteriaSetId, actionPros));
        }
        return thresholds;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Criteria_Set__c makeCriteriaSet() {
        return new EUR_CRM_Criteria_Set__c(
            EUR_CRM_IsQuestionsUpdated__c = false
        );
    }

    private static EUR_CRM_Criteria_Threshold__c makeCriteriaThreshold(Id criteriaSetId, String actionPros) {
        return new EUR_CRM_Criteria_Threshold__c(
            EUR_CRM_Criteria_Set__c = criteriaSetId
        ,   EUR_CRM_ActionPROS__c = actionPros
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Criteria_Set__c> selectCriteriaSets() {
        return [
            SELECT Id
            ,   EUR_CRM_IsQuestionsUpdated__c
            FROM EUR_CRM_Criteria_Set__c
        ];
    }

    private static List<EUR_CRM_Criteria_Threshold__c> selectCriteriaThresholds() {
        return [
            SELECT Id
            ,   EUR_CRM_ActionPROS__c
            FROM EUR_CRM_Criteria_Threshold__c
        ];
    }

}