@IsTest
private class EUR_CRM_AccRelObjSharingServiceTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @TestSetup
    private static void setupTest() {
        insert makeUser('EUR DK ON Trade SR', 'EUR_DK_OnTrade_SalesRep', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
        insert makeUser('EUR DK OFF Trade SR', 'EUR_DK_OffTrade_SalesRep', 'test.userB@mail.com', 'test.userB@mail.com', 'LastNameB');
    }


    /* ========================================================= */
    /*     Single Creation
    /* ========================================================= */
    @IsTest
    private static void oneAccount_createOneCompetitorPromoTrackingTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        EUR_CRM_Competitor_Promo_Tracking__c competitorPromoTracking = makeCompetitorPromoTracking(euAccount.Id);
        insert competitorPromoTracking;
        Test.stopTest();

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, competitorPromoTrackingShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(1, competitorPromoTrackings.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(1, competitorPromoTrackings.size());
        }
    }

    @IsTest
    private static void oneAccount_createOneBrandSecurityInfringementTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        EUR_CRM_Brand_Security_Infringement__c brandSecurityInfringement = makeBrandSecurityInfringement(euAccount.Id);
        insert brandSecurityInfringement;
        Test.stopTest();

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, brandSecurityInfringementShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(1, brandSecurityInfringements.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(1, brandSecurityInfringements.size());
        }
    }

    @IsTest
    private static void oneAccount_createOneVisitTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        EUR_CRM_Visit__c visit = makeVisit(euAccount.Id);
        insert visit;
        Test.stopTest();

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, visitShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(1, visits.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(1, visits.size());
        }
    }

    @IsTest
    private static void oneAccount_createObjPromoAccountMappingTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromo;

        EUR_CRM_ObjPromo_Account_Mapping__c objPromoMapping = makeObjPromoAccountMapping(euAccount.Id, objPromo.Id);
        insert objPromoMapping;
        Test.stopTest();

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, objPromoShares.size());

        System.runAs(user1) {
            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(1, objPromos.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(1, objPromos.size());
        }
    }

    @IsTest
    private static void oneAccount_createObjectiveTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        EUR_CRM_GB_Objective__c objective = makeObjective(euAccount.Id);
        insert objective;
        Test.stopTest();

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, objectiveShares.size());

        System.runAs(user1) {
            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(1, objectives.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(1, objectives.size());
        }
    }

    @IsTest
    private static void oneAccount_createOneContractTrackerTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        EUR_CRM_Contract_Tracker__c contractTracker = makeContractTracker(euAccount.Id);
        insert contractTracker;
        Test.stopTest();

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, contractTrackerShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(1, contractTrackers.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(1, contractTrackers.size());
        }
    }

    @IsTest
    private static void oneAccount_createOneOfEachRelatedListTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user1.Id, 'Read'));
        accountGroupUsers.add(makeAccountGroupUser(accountGroup.Id, user2.Id, 'Read'));
        insert accountGroupUsers;

        List<SObject> sObjects = new List<SObject>();

        EUR_CRM_Competitor_Promo_Tracking__c competitorPromoTracking = makeCompetitorPromoTracking(euAccount.Id);
        sObjects.add((SObject)competitorPromoTracking);

        EUR_CRM_Brand_Security_Infringement__c brandSecurityInfringement = makeBrandSecurityInfringement(euAccount.Id);
        sObjects.add((SObject)brandSecurityInfringement);

        EUR_CRM_Visit__c visit = makeVisit(euAccount.Id);
        sObjects.add((SObject)visit);

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromo;

        EUR_CRM_ObjPromo_Account_Mapping__c objPromoMapping = makeObjPromoAccountMapping(euAccount.Id, objPromo.Id);
        sObjects.add((SObject)objPromoMapping);

        EUR_CRM_GB_Objective__c objective = makeObjective(euAccount.Id);
        sObjects.add((SObject)objective);

        EUR_CRM_Contract_Tracker__c contractTracker = makeContractTracker(euAccount.Id);
        sObjects.add((SObject)contractTracker);

        insert sObjects;
        Test.stopTest();

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, competitorPromoTrackingShares.size());

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, brandSecurityInfringementShares.size());

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, visitShares.size());

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, objPromoShares.size());

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, objectiveShares.size());

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Set<Id> { euAccount.Id }, new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2, contractTrackerShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(1, competitorPromoTrackings.size());

            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(1, brandSecurityInfringements.size());

            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(1, visits.size());

            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(1, objPromos.size());

            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(1, objectives.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(1, contractTrackers.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(1, competitorPromoTrackings.size());

            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(1, brandSecurityInfringements.size());

            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(1, visits.size());

            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(1, objPromos.size());

            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(1, objectives.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(1, contractTrackers.size());
        }
    }


    /* ========================================================= */
    /*     Multiple Creation
    /* ========================================================= */
    @IsTest
    private static void manyAccounts_createManyCompetitorPromoTrackingsTest() {
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
        insert competitorPromoTrackings;
        Test.stopTest();

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackingShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings_1 = selectCompetitorPromoTracking();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackings_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings_2 = selectCompetitorPromoTracking();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackings_2.size());
        }
    }

    @IsTest
    private static void manyAccounts_createManyBrandSecurityInfringementsTest() {
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
        insert brandSecurityInfringements;
        Test.stopTest();

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringementShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements_1 = selectBrandSecurityInfringements();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringements_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements_2 = selectBrandSecurityInfringements();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringements_2.size());
        }
    }

    @IsTest
    private static void manyAccounts_createManyVisitsTest() {
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
        insert visits;
        Test.stopTest();

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, visitShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Visit__c> visits_1 = selectVisits();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, visits_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Visit__c> visits_2 = selectVisits();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, visits_2.size());
        }
    }

    @IsTest
    private static void manyAccounts_createManyPromoAccountMappingsTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromos;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
        insert objPromoMappings;
        Test.stopTest();

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromoShares.size());

        System.runAs(user1) {
            List<EUR_CRM_ObjPromo__c> objPromos_1 = selectObjPromos();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromos_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_ObjPromo__c> objPromos_2 = selectObjPromos();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromos_2.size());
        }
    }

    @IsTest
    private static void manyAccounts_createManyObjectivesTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
        insert objectives;
        Test.stopTest();

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectiveShares.size());

        System.runAs(user1) {
            List<EUR_CRM_GB_Objective__c> objectives_1 = selectObjectives();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectives_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_GB_Objective__c> objectives_2 = selectObjectives();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectives_2.size());
        }
    }

    @IsTest
    private static void manyAccounts_createManyContractTrackersTest() {
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        Test.startTest();
        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
        insert contractTrackers;
        Test.stopTest();

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackerShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Contract_Tracker__c> contractTrackers_1 = selectContractTrackers();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackers_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Contract_Tracker__c> contractTrackers_2 = selectContractTrackers();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackers_2.size());
        }
    }

    @IsTest
    private static void manyAccounts_createManyOfEachRelatedListTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        accountGroups.addAll(makeAccountGroups(euAccounts));
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user1.Id, 'Read'));
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, user2.Id, 'Read'));
        insert accountGroupUsers;

        List<SObject> sObjects = new List<SObject>();

        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
        sObjects.addAll((List<SObject>)competitorPromoTrackings);

        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
        sObjects.addAll((List<SObject>)brandSecurityInfringements);

        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
        sObjects.addAll((List<SObject>)visits);

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromos;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
        sObjects.addAll((List<SObject>)objPromoMappings);

        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
        sObjects.addAll((List<SObject>)objectives);

        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
        sObjects.addAll((List<SObject>)contractTrackers);

        insert sObjects;
        Test.stopTest();

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackingShares.size());

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringementShares.size());

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, visitShares.size());

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromoShares.size());

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectiveShares.size());

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
        System.assertEquals(2 * COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackerShares.size());

        System.runAs(user1) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings_1 = selectCompetitorPromoTracking();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackings_1.size());

            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements_1 = selectBrandSecurityInfringements();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringements_1.size());

            List<EUR_CRM_Visit__c> visits_1 = selectVisits();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, visits_1.size());

            List<EUR_CRM_ObjPromo__c> objPromos_1 = selectObjPromos();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromos_1.size());

            List<EUR_CRM_GB_Objective__c> objectives_1 = selectObjectives();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectives_1.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers_1 = selectContractTrackers();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackers_1.size());
        }

        System.runAs(user2) {
            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings_2 = selectCompetitorPromoTracking();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackings_2.size());

            List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements_2 = selectBrandSecurityInfringements();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringements_2.size());

            List<EUR_CRM_Visit__c> visits_2 = selectVisits();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, visits_2.size());

            List<EUR_CRM_ObjPromo__c> objPromos_2 = selectObjPromos();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromos_2.size());

            List<EUR_CRM_GB_Objective__c> objectives_2 = selectObjectives();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectives_2.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers_2 = selectContractTrackers();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackers_2.size());
        }
    }


    /* ========================================================= */
    /*     High Level Makers (sObjects)
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> makeAccounts() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            accounts.add(makeAccount('Account #' + (i + 1)));
        }
        return accounts;
    }

    private static List<EUR_CRM_AccountGroup__c> makeAccountGroups(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        for (EUR_CRM_Account__c account : accounts) {
            accountGroups.add(makeAccountGroup(account.Id));
        }
        return accountGroups;
    }

    private static List<EUR_CRM_AccountGroupUser__c> makeAccountGroupUsers(List<EUR_CRM_AccountGroup__c> accountGroups, Id usId, String accessLevel) {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        for (EUR_CRM_AccountGroup__c accGroup : accountGroups) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                accountGroupUsers.add(makeAccountGroupUser(accGroup.Id, usId, accessLevel));
            }
        }
        return accountGroupUsers;
    }

    public static User makeUser(String profileName, String roleName, String userEmail, String userName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1][0];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = :roleName LIMIT 1][0];
        User u = new User(
            Alias = 'standt'
        ,   Email = userEmail
        ,   UserRoleId = r.Id
        ,   EmailEncodingKey = 'UTF-8'
        ,   LastName = lastName
        ,   LanguageLocaleKey = 'en_US'
        ,   LocaleSidKey = 'en_US'
        ,   ProfileId = p.Id
        ,   TimeZoneSidKey = 'America/Los_Angeles'
        ,   Username = userName
        );
        return u;
    }

    private static List<EUR_CRM_Competitor_Promo_Tracking__c> makeCompetitorPromoTrackings(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = new List<EUR_CRM_Competitor_Promo_Tracking__c>();
        for (EUR_CRM_Account__c account : accounts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                competitorPromoTrackings.add(makeCompetitorPromoTracking(account.Id));
            }
        }
        return competitorPromoTrackings;
    }

    private static List<EUR_CRM_Brand_Security_Infringement__c> makeBrandSecurityInfringements(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = new List<EUR_CRM_Brand_Security_Infringement__c>();
        for (EUR_CRM_Account__c account : accounts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                brandSecurityInfringements.add(makeBrandSecurityInfringement(account.Id));
            }
        }
        return brandSecurityInfringements;
    }

    private static List<EUR_CRM_Visit__c> makeVisits(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Visit__c> visits = new List<EUR_CRM_Visit__c>();
        for (EUR_CRM_Account__c account : accounts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                visits.add(makeVisit(account.Id));
            }
        }
        return visits;
    }

    private static List<EUR_CRM_ObjPromo__c> makeObjPromos(String rtDevName) {
        Id rtId = selectRecordTypeIdWhereDeveloperName(rtDevName);
        List<EUR_CRM_ObjPromo__c> objPromos = new List<EUR_CRM_ObjPromo__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS * COUNT_OF_RECORDS; i++) {
            objPromos.add(makeObjPromo(rtId));
        }
        return objPromos;
    }

    private static List<EUR_CRM_ObjPromo_Account_Mapping__c> makeObjPromoAccountMappings(List<EUR_CRM_Account__c> accounts, List<EUR_CRM_ObjPromo__c> objPromos) {
        List<EUR_CRM_ObjPromo_Account_Mapping__c> promoAccountMappings = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        for (EUR_CRM_Account__c account : accounts) {
            for (EUR_CRM_ObjPromo__c objPromo : objPromos) {
                promoAccountMappings.add(makeObjPromoAccountMapping(account.Id, objPromo.Id));
            }
        }
        return promoAccountMappings;
    }

    private static List<EUR_CRM_GB_Objective__c> makeObjectives(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_GB_Objective__c> objectives = new List<EUR_CRM_GB_Objective__c>();
        for (EUR_CRM_Account__c account : accounts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                objectives.add(makeObjective(account.Id));
            }
        }
        return objectives;
    }

    private static List<EUR_CRM_Contract_Tracker__c> makeContractTrackers(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Contract_Tracker__c> contractTrackers = new List<EUR_CRM_Contract_Tracker__c>();
        for (EUR_CRM_Account__c account : accounts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                contractTrackers.add(makeContractTracker(account.Id));
            }
        }
        return contractTrackers;
    }


    /* ========================================================= */
    /*     Low Level Makers (sObjects)
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String name) {
        return new EUR_CRM_Account__c(
            Name = name
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static Contact makeContact(Id accId, String ln) {
        return new Contact(
            AccountId = accId
        ,   LastName = ln
        );
    }

    private static EUR_CRM_AccountGroup__c makeAccountGroup(Id accId) {
        return new EUR_CRM_AccountGroup__c(
                EUR_CRM_Account__c = accId,
                EUR_CRM_Status__c = 'Normal'
        );
    }

    private static EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId, Id usId, String accessLevel) {
        return new EUR_CRM_AccountGroupUser__c(
                EUR_CRM_AccountGroup__c = agId
                , EUR_CRM_User__c = usId
                , EUR_CRM_AccessLevel__c = accessLevel
                , EUR_CRM_Status__c = EUR_CRM_AccRelObjSharingService.SHARED_STATUS
        );
    }

    private static EUR_CRM_Competitor_Promo_Tracking__c makeCompetitorPromoTracking(Id accId) {
        return new EUR_CRM_Competitor_Promo_Tracking__c(
            EUR_CRM_Account_Name__c = accId
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Competitor_Promo_Tracking__c', 'EUR_BE_Off_Trade_CPT')
        );
    }

    private static EUR_CRM_Brand_Security_Infringement__c makeBrandSecurityInfringement(Id accId) {
        return new EUR_CRM_Brand_Security_Infringement__c(
            EUR_CRM_Outlet_Name__c = accId
        );
    }

    private static EUR_CRM_Visit__c makeVisit(Id accId) {
        return new EUR_CRM_Visit__c(
            EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplate(String recordTypeDevName, String externalId) {
        EUR_CRM_OP_Action_List_Template__c actionListTemplate = makeActionListTemplateSkeleton(externalId);
        actionListTemplate.RecordTypeId = selectRecordTypeIdWhereDeveloperName(recordTypeDevName);
        return actionListTemplate;
    }

    private static EUR_CRM_OP_Action_List_Template__c makeActionListTemplateSkeleton(String externalId) {
        return new EUR_CRM_OP_Action_List_Template__c(
            Name = 'Template Name'
        ,   EUR_CRM_External_ID__c = externalId
        );
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(String recordTypeDevName) {
        EUR_CRM_ObjPromo__c objPromo = makeObjPromoSkeleton();
        objPromo.RecordTypeId = selectRecordTypeIdWhereDeveloperName(recordTypeDevName);
        return objPromo;
    }

    private static EUR_CRM_ObjPromo__c makeObjPromo(Id rtId) {
        EUR_CRM_ObjPromo__c objPromo = makeObjPromoSkeleton();
        objPromo.RecordTypeId = rtId;
        return objPromo;
    }

    private static EUR_CRM_ObjPromo__c makeObjPromoSkeleton() {
        return new EUR_CRM_ObjPromo__c(
            Name = 'Promo Name'
        ,   EUR_CRM_MAF_ID__c = '12345'
        ,   EUR_CRM_Active_Start_Date__c = Date.today().addDays(1)
        ,   EUR_CRM_Active_End_Date__c = Date.today().addDays(7)
        ,   EUR_CRM_Status__c = 'Active'
        );
    }

    private static EUR_CRM_ObjPromo_Account_Mapping__c makeObjPromoAccountMapping(Id accId, Id objPromoId) {
        return new EUR_CRM_ObjPromo_Account_Mapping__c(
            EUR_CRM_Account__c = accId
        ,   EUR_CRM_ObjPromo__c = objPromoId
        );
    }

    private static EUR_CRM_GB_Objective__c makeObjective(Id accId) {
        return new EUR_CRM_GB_Objective__c(
            EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_Contract_Tracker__c makeContractTracker(Id accId) {
        return new EUR_CRM_Contract_Tracker__c(
            EUR_CRM_Account__c = accId
        );
    }


    /* ========================================================= */
    /*     Low Level Makers (sharing)
    /* ========================================================= */
    private static EUR_CRM_Account__Share makeEUAccountShare(Id accId, Id userId) {
        return new EUR_CRM_Account__Share(
            ParentId = accId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }

    private static AccountShare makeAccountShare(Id accId, Id userId) {
        return new AccountShare(
            AccountId = accId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccountAccessLevel = 'Read'
        ,   OpportunityAccessLevel = 'Read'
        );
    }

    private static EUR_CRM_Competitor_Promo_Tracking__Share makeCompetitorPromoTrackingShare(Id parentId, Id userId) {
        return new EUR_CRM_Competitor_Promo_Tracking__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }

    private static EUR_CRM_Brand_Security_Infringement__Share makeBrandSecurityInfringementShare(Id parentId, Id userId) {
        return new EUR_CRM_Brand_Security_Infringement__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }

    private static EUR_CRM_Visit__Share makeVisitShare(Id parentId, Id userId) {
        return new EUR_CRM_Visit__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }

    private static EUR_CRM_ObjPromo__Share makeObjPromoShare(Id parentId, Id userId) {
        return new EUR_CRM_ObjPromo__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }

    private static EUR_CRM_GB_Objective__Share makeObjectiveShare(Id parentId, Id userId) {
        return new EUR_CRM_GB_Objective__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }

    private static EUR_CRM_Contract_Tracker__Share makeContractTrackerShare(Id parentId, Id userId) {
        return new EUR_CRM_Contract_Tracker__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors (sObjects)
    /* ========================================================= */
    private static User selectUsersWhereUserName(String username) {
        return [
            SELECT Id
            FROM User
            WHERE Username = :username
            LIMIT 1
        ][0];
    }

    private static List<EUR_CRM_Competitor_Promo_Tracking__c> selectCompetitorPromoTracking() {
        return [
            SELECT Id
            FROM EUR_CRM_Competitor_Promo_Tracking__c
        ];
    }

    private static List<EUR_CRM_Brand_Security_Infringement__c> selectBrandSecurityInfringements() {
        return [
            SELECT Id
            FROM EUR_CRM_Brand_Security_Infringement__c
        ];
    }

    private static List<EUR_CRM_Visit__c> selectVisits() {
        return [
            SELECT Id
            FROM EUR_CRM_Visit__c
        ];
    }

    private static List<EUR_CRM_ObjPromo__c> selectObjPromos() {
        return [
            SELECT Id
            FROM EUR_CRM_ObjPromo__c
        ];
    }

    private static List<EUR_CRM_GB_Objective__c> selectObjectives() {
        return [
            SELECT Id
            FROM EUR_CRM_GB_Objective__c
        ];
    }

    private static List<EUR_CRM_Contract_Tracker__c> selectContractTrackers() {
        return [
            SELECT Id
            FROM EUR_CRM_Contract_Tracker__c
        ];
    }

    private static Id selectRecordTypeIdWhereDeveloperName(String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :devName
            LIMIT 1
        ][0].Id;
    }


    /* ========================================================= */
    /*     SOQL Selectors (sharing)
    /* ========================================================= */
    private static List<EUR_CRM_Competitor_Promo_Tracking__Share> selectCompetitorPromoTrackingShares(Set<Id> accountIds, Set<Id> userIds) {
        return [
            SELECT Id
            FROM EUR_CRM_Competitor_Promo_Tracking__Share
            WHERE Parent.EUR_CRM_Account_Name__c = :accountIds
                AND UserOrGroupId = :userIds
        ];
    }

    private static List<EUR_CRM_Brand_Security_Infringement__Share> selectBrandSecurityInfringementShares(Set<Id> accountIds, Set<Id> userIds) {
        return [
            SELECT Id
            FROM EUR_CRM_Brand_Security_Infringement__Share
            WHERE Parent.EUR_CRM_Outlet_Name__c = :accountIds
                AND UserOrGroupId = :userIds
        ];
    }

    private static List<EUR_CRM_Visit__Share> selectVisitShares(Set<Id> accountIds, Set<Id> userIds) {
        return [
            SELECT Id
            FROM EUR_CRM_Visit__Share
            WHERE Parent.EUR_CRM_Account__c = :accountIds
                AND UserOrGroupId = :userIds
        ];
    }

    private static List<EUR_CRM_ObjPromo__Share> selectObjPromoShares(Set<Id> userIds) {
        return [
            SELECT Id
            FROM EUR_CRM_ObjPromo__Share
            WHERE UserOrGroupId = :userIds
        ];
    }

    private static List<EUR_CRM_GB_Objective__Share> selectObjectiveShares(Set<Id> accountIds, Set<Id> userIds) {
        return [
            SELECT Id
            FROM EUR_CRM_GB_Objective__Share
            WHERE Parent.EUR_CRM_Account__c = :accountIds
                AND UserOrGroupId = :userIds
        ];
    }

    private static List<EUR_CRM_Contract_Tracker__Share> selectContractTrackerShares(Set<Id> accountIds, Set<Id> userIds) {
        return [
            SELECT Id
            FROM EUR_CRM_Contract_Tracker__Share
            WHERE Parent.EUR_CRM_Account__c = :accountIds
                AND UserOrGroupId = :userIds
        ];
    }

}