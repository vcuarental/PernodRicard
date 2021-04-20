@IsTest (IsParallel = true)
private class EUR_CRM_VisitActionSuccessfulServiceTest {

    private static final String CLASS_NAME = 'EUR_CRM_VisitActionSuccessfulService';
    private static final Map<String, Set<String>> RECORD_TYPES_BY_STATUS = new Map<String, Set<String>> {
        'Yes' => new Set<String> {
            'EUR_DE_OFF_2nd_PL_Do_TMKT_Doc'
            ,   'DE_OFF_Ad_hoc_Agree_To_Buy'
            ,   'EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty'
            ,   'EUR_DE_OFF_Tasting_Discussion'
        }
        ,   'Participating' => new Set<String> {
            'EUR_DE_ON_TMKT_Promo_Confirm_Participation'
        }
        ,   'Presented' => new Set<String> {
            'EUR_DE_ON_TMKT_Promo_Presentation'
        }
        ,   'Listed' => new Set<String> {
            'EUR_DE_OFF_Dist_Drive_Listing_Check'
        }
        ,   'Qty Confirmed' => new Set<String> {
            'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Carton'
            ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Gondelkopf'
            ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Promo_Display'
            ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Razz_Fazz'
            ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Standard'
            ,   'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Theme'
            ,   'EUR_DE_OFF_Ad_Hoc_Sell_In_Qty'
            ,   'EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty'
            ,   'EUR_DE_OFF_Sales_Drive_SKU_Bottles_Sell_In_Qty'
            ,   'EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty'
            ,   'EUR_DE_OFF_Sales_Drive_Sell_In_Qty'
            ,   'EUR_DE_OFF_Tasting_Sell_In_Qty'
            ,   'EUR_DE_OFF_Trade_Fair_Sell_In_Qty'
            ,   'EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty'
            ,   'EUR_DE_OFF_2nd_PL_Present_Theme'
        }
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtMultivalueMapsForTest
            .addAll(EUR_CRM_RecordTypeHelper_v2.makeMultivalueMapsForTest(CLASS_NAME, 'RECORD_TYPES_BY_STATUS', RECORD_TYPES_BY_STATUS));
    }


    @TestSetup
    private static void setupMethod() {
        EUR_CRM_Account__c account = makeAccount();
        insert account;
    }


    /* ========================================================= */
    /*     Create Single Visit Action
    /* ========================================================= */
    @IsTest
    private static void createSingleVisitActionValidRecordTypeTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', visit, 'Yes');
        Test.startTest();
        insert va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
    }

    @IsTest
    private static void createSingleVisitActionInvalidRecordTypeTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty', visit, 'Yes');
        Test.startTest();
        insert va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
    }


    @IsTest
    private static void createSingleVisitActionInvalidRecordAndDifferentStatusTypeTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty', visit, 'Different Status');
        va.EUR_CRM_Is_Successful__c = true;
        Test.startTest();
        insert va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
    }

    @IsTest
    private static void createSingleVisitActionValidRecordAndDifferentStatusTypeTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', visit, 'Different Status');
        va.EUR_CRM_Is_Successful__c = true;
        Test.startTest();
        insert va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
    }

    @IsTest
    private static void createSingleVisitActionMismatchRecordTypeTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_ON_TMKT_Promo_Confirm_Participation', visit, 'Yes');
        Test.startTest();
        insert va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
    }


    /* ========================================================= */
    /*     Create Multiple Visit Actions
    /* ========================================================= */
    @IsTest
    private static void createMultipleYesVisitActionsTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Yes'), visit, 'Yes');
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultipleParticipatingVisitActionsTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Participating'), visit, 'Participating');
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultiplePresentedVisitActionsTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Presented'), visit, 'Presented');
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultipleListedVisitActionsTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Listed'), visit, 'Listed');
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultipleQtyConfirmedVisitActionsTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Qty Confirmed'), visit, 'Qty Confirmed');
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultipleAllVisitActionsPositiveTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Yes'), visit, 'Yes'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Participating'), visit, 'Participating'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Presented'), visit, 'Presented'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Listed'), visit, 'Listed'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Qty Confirmed'), visit, 'Qty Confirmed'));
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultipleAllVisitActionsNegativeTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Yes'), visit, 'Participating'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Participating'), visit, 'Yes'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Presented'), visit, 'Listed'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Listed'), visit, 'Presented'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Qty Confirmed'), visit, 'Listed'));
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void createMultipleVisitActionsMixedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', visit, 'Participating'));
        visitActions.add(makeVisitAction('DE_OFF_Ad_hoc_Agree_To_Buy', visit, 'Yes'));
        visitActions.add(makeVisitAction('EUR_DE_ON_TMKT_Promo_Confirm_Participation', visit, 'Yes'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_Dist_Drive_Listing_Check', visit, 'Present'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Sell_In_Qty_Carton', visit, 'Yes'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Sell_In_Qty_Gondelkopf', visit, 'Qty Confirmed'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty', visit, 'Present'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Present_Theme', visit, 'Qty Confirmed'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_Tasting_Discussion', visit, 'Yes'));
        Test.startTest();
        insert visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assertEquals(false, visitActions[0].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[1].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[2].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[3].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[4].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[5].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[6].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[7].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[8].EUR_CRM_Is_Successful__c);
    }


    /* ========================================================= */
    /*     Update Single Visit Action
    /* ========================================================= */
    @IsTest
    private static void updateSingleVisitActionToParticipatingTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', visit, 'Yes');
        insert va;

        va = selectVisitActions()[0];
        System.assertEquals(true, va.EUR_CRM_Is_Successful__c);

        va.EUR_CRM_Status__c = 'Participating';
        Test.startTest();
        update va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
    }

    @IsTest
    private static void updateSingleVisitActionToDifferentStatusTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', visit, 'Yes');
        insert va;

        va = selectVisitActions()[0];
        System.assertEquals(true, va.EUR_CRM_Is_Successful__c);

        va.EUR_CRM_Status__c = 'Different Status';
        Test.startTest();
        update va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
    }

    @IsTest
    private static void updateSingleVisitActionToQtyConfirmedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        EUR_CRM_Visit_Action__c va = makeVisitAction('EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty', visit, 'Yes');
        insert va;

        va = selectVisitActions()[0];
        System.assertEquals(true, va.EUR_CRM_Is_Successful__c);

        va.EUR_CRM_Status__c = 'Qty Confirmed';
        Test.startTest();
        update va;
        Test.stopTest();

        va = selectVisitActions()[0];
        System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
    }


    /* ========================================================= */
    /*     Update Multiple Visit Actions
    /* ========================================================= */
    @IsTest
    private static void updateMultipleYesVisitActionsToListedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Yes'), visit, 'Yes');
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }

        for (EUR_CRM_Visit_Action__c visitAction : visitActions) {
            visitAction.EUR_CRM_Status__c = 'Listed';
        }
        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultipleParticipatingVisitActionsToListedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Participating'), visit, 'Participating');
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }

        for (EUR_CRM_Visit_Action__c visitAction : visitActions) {
            visitAction.EUR_CRM_Status__c = 'Listed';
        }
        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultiplePresentedVisitActionsToListedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Presented'), visit, 'Presented');
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }

        for (EUR_CRM_Visit_Action__c visitAction : visitActions) {
            visitAction.EUR_CRM_Status__c = 'Listed';
        }
        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultipleListedVisitActionsToPresentedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Listed'), visit, 'Listed');
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }

        for (EUR_CRM_Visit_Action__c visitAction : visitActions) {
            visitAction.EUR_CRM_Status__c = 'Presented';
        }
        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultipleQtyConfirmedVisitActionsToListedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = makeVisitActions(RECORD_TYPES_BY_STATUS.get('Qty Confirmed'), visit, 'Qty Confirmed');
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }

        for (EUR_CRM_Visit_Action__c visitAction : visitActions) {
            visitAction.EUR_CRM_Status__c = 'Listed';
        }
        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultipleAllVisitActionsToNewStatusTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Yes'), visit, 'Yes'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Participating'), visit, 'Participating'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Presented'), visit, 'Presented'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Listed'), visit, 'Listed'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Qty Confirmed'), visit, 'Qty Confirmed'));
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }

        for (EUR_CRM_Visit_Action__c visitAction : visitActions) {
            visitAction.EUR_CRM_Status__c = 'New status';
        }
        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultipleAllMismatchedVisitActionsToMatchedStatusTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Yes'), visit, 'Participating'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Participating'), visit, 'Yes'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Presented'), visit, 'Listed'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Listed'), visit, 'Presented'));
        visitActions.addAll(makeVisitActions(RECORD_TYPES_BY_STATUS.get('Qty Confirmed'), visit, 'Listed'));
        insert visitActions;

        visitActions = selectVisitActions();
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(false, va.EUR_CRM_Is_Successful__c);
        }

        Integer count = 0;
        for (Integer i = count; i < RECORD_TYPES_BY_STATUS.get('Yes').size(); i++) {
            visitActions[i].EUR_CRM_Status__c = 'Yes';
        }
        count += RECORD_TYPES_BY_STATUS.get('Yes').size();

        for (Integer i = count; i < count + RECORD_TYPES_BY_STATUS.get('Participating').size(); i++) {
            visitActions[i].EUR_CRM_Status__c = 'Participating';
        }
        count += RECORD_TYPES_BY_STATUS.get('Participating').size();

        for (Integer i = count; i < count + RECORD_TYPES_BY_STATUS.get('Presented').size(); i++) {
            visitActions[i].EUR_CRM_Status__c = 'Presented';
        }
        count += RECORD_TYPES_BY_STATUS.get('Presented').size();

        for (Integer i = count ; i < count + RECORD_TYPES_BY_STATUS.get('Listed').size(); i++) {
            visitActions[i].EUR_CRM_Status__c = 'Listed';
        }
        count += RECORD_TYPES_BY_STATUS.get('Listed').size();

        for (Integer i = count; i < count + RECORD_TYPES_BY_STATUS.get('Qty Confirmed').size(); i++) {
            visitActions[i].EUR_CRM_Status__c = 'Qty Confirmed';
        }

        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assert( ! visitActions.isEmpty());
        for (EUR_CRM_Visit_Action__c va : visitActions) {
            System.assertEquals(true, va.EUR_CRM_Is_Successful__c);
        }
    }

    @IsTest
    private static void updateMultipleVisitActionsMixedTest() {
        initCMT();

        EUR_CRM_Visit__c visit = makeVisit();
        insert visit;

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Do_TMKT_Doc', visit, 'Participating'));
        visitActions.add(makeVisitAction('DE_OFF_Ad_hoc_Agree_To_Buy', visit, 'Yes'));
        visitActions.add(makeVisitAction('EUR_DE_ON_TMKT_Promo_Confirm_Participation', visit, 'Yes'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_Dist_Drive_Listing_Check', visit, 'Present'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Sell_In_Qty_Carton', visit, 'Yes'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Sell_In_Qty_Gondelkopf', visit, 'Qty Confirmed'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty', visit, 'Present'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_2nd_PL_Present_Theme', visit, 'Qty Confirmed'));
        visitActions.add(makeVisitAction('EUR_DE_OFF_Tasting_Discussion', visit, 'Yes'));
        insert visitActions;

        visitActions = selectVisitActions();
        System.assertEquals(false, visitActions[0].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[1].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[2].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[3].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[4].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[5].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[6].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[7].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[8].EUR_CRM_Is_Successful__c);

        visitActions[0].EUR_CRM_Status__c = 'Yes';
        visitActions[1].EUR_CRM_Status__c = 'Participating';
        visitActions[2].EUR_CRM_Status__c = 'Presented';
        visitActions[3].EUR_CRM_Status__c = 'Listed';
        visitActions[4].EUR_CRM_Status__c = 'Listed';
        visitActions[5].EUR_CRM_Status__c = 'Listed';
        visitActions[6].EUR_CRM_Status__c = 'Participating';
        visitActions[7].EUR_CRM_Status__c = 'Participating';
        visitActions[8].EUR_CRM_Status__c = 'Participating';

        Test.startTest();
        update visitActions;
        Test.stopTest();

        visitActions = selectVisitActions();
        System.assertEquals(true, visitActions[0].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[1].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[2].EUR_CRM_Is_Successful__c);
        System.assertEquals(true, visitActions[3].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[4].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[5].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[6].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[7].EUR_CRM_Is_Successful__c);
        System.assertEquals(false, visitActions[8].EUR_CRM_Is_Successful__c);
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Visit_Action__c> makeVisitActions(Set<String> rtDevNames, EUR_CRM_Visit__c visit, String status) {
        List<RecordType> recordTypes = selectVisitActionRecordTypeIdsWhereDeveloperNames(rtDevNames);

        List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
        for (RecordType rt : recordTypes) {
            visitActions.add(makeVisitAction(rt.Id, visit, status));
        }
        return visitActions;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_Visit__c makeVisit() {
        return makeVisit(selectAccounts()[0].Id);
    }

    private static EUR_CRM_Visit__c makeVisit(Id accId) {
        EUR_CRM_Visit__c visit = makeVisitSkeleton(accId);
        visit.RecordTypeId = selectVisitRecordTypeIdWhereDeveloperName('EUR_CH_Visit');
        return visit;
    }

    private static EUR_CRM_Visit__c makeVisitSkeleton(Id accId) {
        return new EUR_CRM_Visit__c(
            EUR_CRM_Account__c = accId
        ,   EUR_CRM_Start_Datetime__c = Datetime.now()
        ,   EUR_CRM_End_Datetime__c = Datetime.now().addHours(1)
        );
    }

    private static EUR_CRM_Visit_Action__c makeVisitAction(String rtDevName, EUR_CRM_Visit__c visit, String status) {
        EUR_CRM_Visit_Action__c va = makeVisitActionSkeleton(visit, status);
        va.RecordTypeId = selectVisitActionRecordTypeIdWhereDeveloperName(rtDevName);
        return va;
    }

    private static EUR_CRM_Visit_Action__c makeVisitAction(Id rtId, EUR_CRM_Visit__c visit, String status) {
        EUR_CRM_Visit_Action__c va = makeVisitActionSkeleton(visit, status);
        va.RecordTypeId = rtId;
        return va;
    }

    private static EUR_CRM_Visit_Action__c makeVisitActionSkeleton(EUR_CRM_Visit__c visit, String status) {
        return new EUR_CRM_Visit_Action__c(
            EUR_CRM_Account__c = visit.EUR_CRM_Account__c
        ,   EUR_CRM_Visit_ID__c = visit.Id
        ,   EUR_CRM_Status__c = status
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_CRM_Last_Visit_Date__c
            FROM EUR_CRM_Account__c
        ];
    }

    private static Id selectVisitRecordTypeIdWhereDeveloperName(String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :devName
                AND SobjectType = 'EUR_CRM_Visit__c'
            LIMIT 1
        ][0].Id;
    }

    private static Id selectVisitActionRecordTypeIdWhereDeveloperName(String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :devName
                AND SobjectType = 'EUR_CRM_Visit_Action__c'
            LIMIT 1
        ][0].Id;
    }

    private static List<RecordType> selectVisitActionRecordTypeIdsWhereDeveloperNames(Set<String> devNames) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName IN :devNames
                AND SobjectType = 'EUR_CRM_Visit_Action__c'
        ];
    }

    private static List<EUR_CRM_Visit_Action__c> selectVisitActions() {
        return [
            SELECT Id
            ,   EUR_CRM_Is_Successful__c
            FROM EUR_CRM_Visit_Action__c
        ];
    }

}