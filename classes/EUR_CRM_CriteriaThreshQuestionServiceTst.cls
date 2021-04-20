@IsTest (IsParallel = true)
private class EUR_CRM_CriteriaThreshQuestionServiceTst {

    private static final String NEED_UPDATE = EUR_CRM_CriteriaThreshQuestionService.NEED_UPDATE;
    private static final Integer COUNT_OF_RECORDS = 5;


    /* ======================================================================================== */
    /*     Create one EUR_CRM_Criteria_Threshold__c to one EUR_CRM_Criteria_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void createOneCriteriaThresholdWithStatusNewPerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, 'New');

        Test.startTest();
        insert criteriaThreshold;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createOneCriteriaThresholdWithStatusNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, NEED_UPDATE);

        Test.startTest();
        insert criteriaThreshold;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createOneCriteriaThresholdWithStatusNoNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, 'No Need Update');

        Test.startTest();
        insert criteriaThreshold;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Create many EUR_CRM_Criteria_Threshold__c to one EUR_CRM_Criteria_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void createManyCriteriaThresholdsWithStatusNewPerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, 'New');

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createManyCriteriaThresholdsWithStatusNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, NEED_UPDATE);

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void createManyCriteriaThresholdsWithStatusNoNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, 'No Need Update');

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Create many EUR_CRM_Criteria_Threshold__c to many EUR_CRM_Criteria_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void createManyCriteriaThresholdsWithStatusNewPerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'New'));
        }

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void createManyCriteriaThresholdsWithStatusNeedUpdatePerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, NEED_UPDATE));
        }

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void createManyCriteriaThresholdsWithStatusNoNeedUpdatePerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'No Need Update'));
        }

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void createManyCriteriaThresholdsWithDifferentStatusesPerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.add(makeCriteriaThreshold(criteriaSet.Id, 'New'));
            criteriaThresholds.add(makeCriteriaThreshold(criteriaSet.Id, NEED_UPDATE));
            criteriaThresholds.add(makeCriteriaThreshold(criteriaSet.Id, 'No Need Update'));
        }

        Test.startTest();
        insert criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }


    /* ======================================================================================== */
    /*     Update one EUR_CRM_Criteria_Threshold__c to one EUR_CRM_Criteria_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void updateOneCriteriaThresholdToStatusNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, 'New');
        insert criteriaThreshold;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update criteriaSet;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        criteriaThreshold.EUR_CRM_ActionPROS__c = NEED_UPDATE;
        update criteriaThreshold;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void updateOneCriteriaThresholdToStatusNoNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        EUR_CRM_Criteria_Threshold__c criteriaThreshold = makeCriteriaThreshold(criteriaSet.Id, 'New');
        insert criteriaThreshold;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update criteriaSet;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        criteriaThreshold.EUR_CRM_ActionPROS__c = 'No Need Update';
        update criteriaThreshold;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Update many EUR_CRM_Criteria_Threshold__c to one EUR_CRM_Criteria_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void updateManyCriteriaThresholdsToStatusNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, 'New');
        insert criteriaThresholds;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update criteriaSet;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            criteriaThreshold.EUR_CRM_ActionPROS__c = NEED_UPDATE;
        }

        update criteriaThresholds;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }

    @IsTest
    private static void updateManyCriteriaThresholdsToStatusNoNeedUpdatePerOneCriteriaSetTest() {
        EUR_CRM_Criteria_Set__c criteriaSet = makeCriteriaSet();
        insert criteriaSet;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = makeCriteriaThresholds(criteriaSet.Id, 'New');
        insert criteriaThresholds;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        update criteriaSet;

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);

        Test.startTest();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            criteriaThreshold.EUR_CRM_ActionPROS__c = 'No Need Update';
        }

        update criteriaThresholds;
        Test.stopTest();

        criteriaSet = selectCriteriaSets()[0];
        System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
    }


    /* ======================================================================================== */
    /*     Update many EUR_CRM_Criteria_Threshold__c to many EUR_CRM_Criteria_Set__c
    /* ======================================================================================== */
    @IsTest
    private static void updateManyCriteriaThresholdsWithStatusNeedUpdatePerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'New'));
        }
        insert criteriaThresholds;

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }
        update criteriaSets;

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        Test.startTest();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            criteriaThreshold.EUR_CRM_ActionPROS__c = NEED_UPDATE;
        }

        update criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void updateManyCriteriaThresholdsWithStatusNoNeedUpdatePerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'New'));
        }
        insert criteriaThresholds;

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }
        update criteriaSets;

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        Test.startTest();
        for (EUR_CRM_Criteria_Threshold__c criteriaThreshold : criteriaThresholds) {
            criteriaThreshold.EUR_CRM_ActionPROS__c = 'No Need Update';
        }

        update criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }
    }

    @IsTest
    private static void updateManyCriteriaThresholdsToDifferentStatusesPerManyCriteriaSetsTest() {
        List<EUR_CRM_Criteria_Set__c> criteriaSets = makeCriteriaSets();
        insert criteriaSets;

        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholds = new List<EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaThresholds.addAll(makeCriteriaThresholds(criteriaSet.Id, 'New'));
        }
        insert criteriaThresholds;

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            criteriaSet.EUR_CRM_IsQuestionsUpdated__c = false;
        }
        update criteriaSets;

        criteriaSets = selectCriteriaSets();
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(false, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
        }

        Test.startTest();
        for (Integer i = 0; i < criteriaSets.size(); i++) {
            criteriaThresholds[i * COUNT_OF_RECORDS].EUR_CRM_ActionPROS__c = NEED_UPDATE;
            criteriaThresholds[i * COUNT_OF_RECORDS + 1].EUR_CRM_ActionPROS__c = 'No Need Update';
        }

        update criteriaThresholds;
        Test.stopTest();

        criteriaSets = selectCriteriaSets();
        System.assertEquals(COUNT_OF_RECORDS, criteriaSets.size());
        for (EUR_CRM_Criteria_Set__c criteriaSet : criteriaSets) {
            System.assertEquals(true, criteriaSet.EUR_CRM_IsQuestionsUpdated__c);
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

}