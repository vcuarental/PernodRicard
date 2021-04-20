@IsTest
private class EUR_CRM_AccGroupUserSharingBatchTest {
    private static final Integer COUNT_OF_RECORDS = 4;

    @TestSetup
    private static void setupTest() {
        insert makeUser('EUR DK ON Trade SR', 'EUR_DK_OnTrade_SalesRep', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
        insert makeUser('EUR DK OFF Trade SR', 'EUR_DK_OffTrade_SalesRep', 'test.userB@mail.com', 'test.userB@mail.com', 'LastNameB');
    }

    @IsTest
    private static void batchTest() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
        Test.stopTest();
    }

    @IsTest
    private static void schedulerTest() {
        Test.startTest();
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_AccGroupUserSharingBatch scheduledJob = new EUR_CRM_AccGroupUserSharingBatch();
        System.schedule('Account Group User Sharing Scheduled Job', cronExpression, scheduledJob);
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Create Sharing
    /* ========================================================= */
    @IsTest
    private static void insertAccountGroupUserWithReadAccessSingleTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;

        EUR_CRM_Competitor_Promo_Tracking__c competitorPromoTracking = makeCompetitorPromoTracking(euAccount.Id);
        insert competitorPromoTracking;

        EUR_CRM_Brand_Security_Infringement__c brandSecurityInfringement = makeBrandSecurityInfringement(euAccount.Id);
        insert brandSecurityInfringement;

        EUR_CRM_Visit__c visit = makeVisit(euAccount.Id);
        insert visit;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromo;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(new List<EUR_CRM_Account__c> { euAccount }, new List<EUR_CRM_ObjPromo__c> { objPromo });
        insert objPromoAccountMappings;

        EUR_CRM_GB_Objective__c objective = makeObjective(euAccount.Id);
        insert objective;

        EUR_CRM_Contract_Tracker__c contractTracker = makeContractTracker(euAccount.Id);
        insert contractTracker;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
        insert accountGroupUser;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(accountGroupUser.Id), 200);
        Test.stopTest();

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());
        System.assertEquals('Read', euAccountShares[0].AccessLevel);

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());
        System.assertEquals('Read', accountShares[0].AccountAccessLevel);

//        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, competitorPromoTrackingShares.size());
//
//        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, brandSecurityInfringementShares.size());
//
//        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, visitShares.size());
//
//        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { us.Id });
//        System.assertEquals(1, objPromoShares.size());
//
//        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, objectiveShares.size());
//
//        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, contractTrackerShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(1, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(1, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(1, contactsForSpecificUser.size());

//            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
//            System.assertEquals(1, competitorPromoTrackings.size());
//
//            List<EUR_CRM_Brand_Security_Infringement__c> btaBrandSecurityInfringements = selectBrandSecurityInfringements();
//            System.assertEquals(1, btaBrandSecurityInfringements.size());
//
//            List<EUR_CRM_Visit__c> visits = selectVisits();
//            System.assertEquals(1, visits.size());
//
//            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
//            System.assertEquals(1, objPromos.size());
//
//            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
//            System.assertEquals(1, objectives.size());
//
//            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
//            System.assertEquals(1, contractTrackers.size());
        }
    }

    @IsTest
    private static void updateSharingsForAccountGroupUserWithReadAccessSingleTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;


        User us = selectUsersWhereUserName('test.userA@mail.com');

        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
        insert accountGroupUser;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(new Set<Id>{euAccount.Id}, true), 200);
    }

    @IsTest
    private static void insertAccountGroupUserWithEditAccessSingleTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Edit');
        insert accountGroupUser;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(new Set<Id> { accountGroupUser.Id }), 200);
        Test.stopTest();

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());
        System.assertEquals('Edit', euAccountShares[0].AccessLevel);

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());
        System.assertEquals('Edit', accountShares[0].AccountAccessLevel);

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(1, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(1, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(1, contactsForSpecificUser.size());
        }
    }

    @IsTest
    private static void insertAccountGroupUsersMultiplePerOneUserTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
        insert competitorPromoTrackings;

        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
        insert brandSecurityInfringements;

        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
        insert visits;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromos;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
        insert objPromoAccountMappings;

        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
        insert objectives;

        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
        insert contractTrackers;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        userShouldSeeNothing(euAccounts, accounts, us);

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, us.Id, 'Read');
        insert accountGroupUsers;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
        Test.stopTest();

        userShouldSeeAllData(euAccounts, accounts, us);
    }

//    @IsTest
//    private static void insertAccountGroupUsersMultiplePerTwoUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
//
//        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
//        insert competitorPromoTrackings;
//
//        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
//        insert brandSecurityInfringements;
//
//        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
//        insert visits;
//
//        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
//        insert listTemplate;
//
//        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
//        insert objPromos;
//
//        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
//        insert objPromoAccountMappings;
//
//        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
//        insert objectives;
//
//        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
//        insert contractTrackers;
//
//        User user1 = selectUsersWhereUserName('test.userA@mail.com');
//        User user2 = selectUsersWhereUserName('test.userB@mail.com');
//
//        userShouldSeeNothing(euAccounts, accounts, user1);
//        userShouldSeeNothing(euAccounts, accounts, user2);
//
//        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
//        insert accountGroups;
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsersForUser1 = makeAccountGroupUsers(accountGroups, user1.Id, 'Read');
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsersForUser2 = makeAccountGroupUsers(accountGroups, user2.Id, 'Read');
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
//        accountGroupUsers.addAll(accountGroupUsersForUser1);
//        accountGroupUsers.addAll(accountGroupUsersForUser2);
//        insert accountGroupUsers;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
//        Test.stopTest();
//
//        userShouldSeeAllData(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//    }


    /* ========================================================= */
    /*     Delete Sharing
    /* ========================================================= */
    @IsTest
    private static void deleteAccountGroupUserSingleTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;

        EUR_CRM_Competitor_Promo_Tracking__c competitorPromoTracking = makeCompetitorPromoTracking(euAccount.Id);
        insert competitorPromoTracking;

        EUR_CRM_Brand_Security_Infringement__c brandSecurityInfringement = makeBrandSecurityInfringement(euAccount.Id);
        insert brandSecurityInfringement;

        EUR_CRM_Visit__c visit = makeVisit(euAccount.Id);
        insert visit;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromo;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(new List<EUR_CRM_Account__c> { euAccount }, new List<EUR_CRM_ObjPromo__c> { objPromo });
        insert objPromoAccountMappings;

        EUR_CRM_GB_Objective__c objective = makeObjective(euAccount.Id);
        insert objective;

        EUR_CRM_Contract_Tracker__c contractTracker = makeContractTracker(euAccount.Id);
        insert contractTracker;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
        insert accountGroupUser;

        EUR_CRM_Account__Share euAccountShare = makeEUAccountShare(euAccount.Id, us.Id);
        insert euAccountShare;

        AccountShare accountShare = makeAccountShare(acc.Id, us.Id);
        insert accountShare;

        EUR_CRM_Competitor_Promo_Tracking__Share competitorPromoTrackingShare = makeCompetitorPromoTrackingShare(competitorPromoTracking.Id, us.Id);
        insert competitorPromoTrackingShare;

        EUR_CRM_Brand_Security_Infringement__Share brandSecurityInfringementShare = makeBrandSecurityInfringementShare(brandSecurityInfringement.Id, us.Id);
        insert brandSecurityInfringementShare;

        EUR_CRM_ObjPromo__Share objPromoShare = makeObjPromoShare(objPromo.Id, us.Id);
        insert objPromoShare;

        EUR_CRM_Visit__Share visitShare = makeVisitShare(visit.Id, us.Id);
        insert visitShare;

        EUR_CRM_GB_Objective__Share objectiveShare = makeObjectiveShare(objective.Id, us.Id);
        insert objectiveShare;

        EUR_CRM_Contract_Tracker__Share contractTrackerShare = makeContractTrackerShare(contractTracker.Id, us.Id);
        insert contractTrackerShare;

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, competitorPromoTrackingShares.size());

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, brandSecurityInfringementShares.size());

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, visitShares.size());

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { us.Id });
        System.assertEquals(1, objPromoShares.size());

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, objectiveShares.size());

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, contractTrackerShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(1, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(1, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(1, contactsForSpecificUser.size());

            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(1, competitorPromoTrackings.size());

            List<EUR_CRM_Brand_Security_Infringement__c> btaBrandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(1, btaBrandSecurityInfringements.size());

            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(1, visits.size());

            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(1, objPromos.size());

            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(1, objectives.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(1, contractTrackers.size());
        }

        accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        update accountGroupUser;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
        Test.stopTest();

        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(0, accountGroupUsers.size());
    }

    @IsTest
    private static void deleteAccountGroupUserWithParentSingleTest() {
        Test.startTest();
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;

        EUR_CRM_Competitor_Promo_Tracking__c competitorPromoTracking = makeCompetitorPromoTracking(euAccount.Id);
        insert competitorPromoTracking;

        EUR_CRM_Brand_Security_Infringement__c brandSecurityInfringement = makeBrandSecurityInfringement(euAccount.Id);
        insert brandSecurityInfringement;

        EUR_CRM_Visit__c visit = makeVisit(euAccount.Id);
        insert visit;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        EUR_CRM_ObjPromo__c objPromo = makeObjPromo('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromo;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(new List<EUR_CRM_Account__c> { euAccount }, new List<EUR_CRM_ObjPromo__c> { objPromo });
        insert objPromoAccountMappings;

        EUR_CRM_GB_Objective__c objective = makeObjective(euAccount.Id);
        insert objective;

        EUR_CRM_Contract_Tracker__c contractTracker = makeContractTracker(euAccount.Id);
        insert contractTracker;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
        insert accountGroupUser;

        EUR_CRM_Account__Share euAccountShare = makeEUAccountShare(euAccount.Id, us.Id);
        insert euAccountShare;

        AccountShare accountShare = makeAccountShare(acc.Id, us.Id);
        insert accountShare;

        EUR_CRM_Competitor_Promo_Tracking__Share competitorPromoTrackingShare = makeCompetitorPromoTrackingShare(competitorPromoTracking.Id, us.Id);
        insert competitorPromoTrackingShare;

        EUR_CRM_Brand_Security_Infringement__Share brandSecurityInfringementShare = makeBrandSecurityInfringementShare(brandSecurityInfringement.Id, us.Id);
        insert brandSecurityInfringementShare;

        EUR_CRM_ObjPromo__Share objPromoShare = makeObjPromoShare(objPromo.Id, us.Id);
        insert objPromoShare;

        EUR_CRM_Visit__Share visitShare = makeVisitShare(visit.Id, us.Id);
        insert visitShare;

        EUR_CRM_GB_Objective__Share objectiveShare = makeObjectiveShare(objective.Id, us.Id);
        insert objectiveShare;

        EUR_CRM_Contract_Tracker__Share contractTrackerShare = makeContractTrackerShare(contractTracker.Id, us.Id);
        insert contractTrackerShare;

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, competitorPromoTrackingShares.size());

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, brandSecurityInfringementShares.size());

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, visitShares.size());

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { us.Id });
        System.assertEquals(1, objPromoShares.size());

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, objectiveShares.size());

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, contractTrackerShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(1, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(1, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(1, contactsForSpecificUser.size());

            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(1, competitorPromoTrackings.size());

            List<EUR_CRM_Brand_Security_Infringement__c> btaBrandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(1, btaBrandSecurityInfringements.size());

            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(1, visits.size());

            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(1, objPromos.size());

            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(1, objectives.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(1, contractTrackers.size());
        }

        accountGroup.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        update accountGroup;

        accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        update accountGroupUser;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
        Test.stopTest();

        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(0, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(0, accountGroupUsers.size());
    }

    @IsTest
    private static void deleteAccountGroupUsersMultiplePerOneUserTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
        insert competitorPromoTrackings;

        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
        insert brandSecurityInfringements;

        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
        insert visits;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromos;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
        insert objPromoAccountMappings;

        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
        insert objectives;

        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
        insert contractTrackers;

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, us.Id, 'Read');
        insert accountGroupUsers;

        List<EUR_CRM_Account__Share> ueAccountShares = makeEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        insert ueAccountShares;

        List<AccountShare> accountShares = makeAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
        insert accountShares;

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = makeCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Competitor_Promo_Tracking__c>(competitorPromoTrackings).keySet(), new Set<Id> { us.Id });
        insert competitorPromoTrackingShares;

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = makeBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Brand_Security_Infringement__c>(brandSecurityInfringements).keySet(), new Set<Id> { us.Id });
        insert brandSecurityInfringementShares;

        List<EUR_CRM_ObjPromo__Share> objPromoShares = makeObjPromoShares(new Map<Id, EUR_CRM_ObjPromo__c>(objPromos).keySet(), new Set<Id> { us.Id });
        insert objPromoShares;

        List<EUR_CRM_Visit__Share> visitShares = makeVisitShares(new Map<Id, EUR_CRM_Visit__c>(visits).keySet(), new Set<Id> { us.Id });
        insert visitShares;

        List<EUR_CRM_GB_Objective__Share> objectiveShares = makeObjectiveShares(new Map<Id, EUR_CRM_GB_Objective__c>(objectives).keySet(), new Set<Id> { us.Id });
        insert objectiveShares;

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = makeContractTrackerShares(new Map<Id, EUR_CRM_Contract_Tracker__c>(contractTrackers).keySet(), new Set<Id> { us.Id });
        insert contractTrackerShares;

        userShouldSeeAllData(euAccounts, accounts, us);

        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        }
        update accountGroupUsers;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
        Test.stopTest();

        userShouldSeeNothing(euAccounts, accounts, us);

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(0, accountGroupUsers.size());
    }

    @IsTest
    private static void deleteAccountGroupUsersWithParentMultiplePerOneUserTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
        insert competitorPromoTrackings;

        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
        insert brandSecurityInfringements;

        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
        insert visits;

        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
        insert listTemplate;

        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
        insert objPromos;

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
        insert objPromoAccountMappings;

        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
        insert objectives;

        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
        insert contractTrackers;

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        User us = selectUsersWhereUserName('test.userA@mail.com');

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, us.Id, 'Read');
        insert accountGroupUsers;

        List<EUR_CRM_Account__Share> ueAccountShares = makeEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        insert ueAccountShares;

        List<AccountShare> accountShares = makeAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
        insert accountShares;

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = makeCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Competitor_Promo_Tracking__c>(competitorPromoTrackings).keySet(), new Set<Id> { us.Id });
        insert competitorPromoTrackingShares;

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = makeBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Brand_Security_Infringement__c>(brandSecurityInfringements).keySet(), new Set<Id> { us.Id });
        insert brandSecurityInfringementShares;

        List<EUR_CRM_ObjPromo__Share> objPromoShares = makeObjPromoShares(new Map<Id, EUR_CRM_ObjPromo__c>(objPromos).keySet(), new Set<Id> { us.Id });
        insert objPromoShares;

        List<EUR_CRM_Visit__Share> visitShares = makeVisitShares(new Map<Id, EUR_CRM_Visit__c>(visits).keySet(), new Set<Id> { us.Id });
        insert visitShares;

        List<EUR_CRM_GB_Objective__Share> objectiveShares = makeObjectiveShares(new Map<Id, EUR_CRM_GB_Objective__c>(objectives).keySet(), new Set<Id> { us.Id });
        insert objectiveShares;

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = makeContractTrackerShares(new Map<Id, EUR_CRM_Contract_Tracker__c>(contractTrackers).keySet(), new Set<Id> { us.Id });
        insert contractTrackerShares;

        userShouldSeeAllData(euAccounts, accounts, us);

        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            accountGroup.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        }
        update accountGroups;

        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        }
        update accountGroupUsers;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
        Test.stopTest();

        userShouldSeeNothing(euAccounts, accounts, us);

        accountGroups = selectAccountGroups();
        System.assertEquals(0, accountGroups.size());

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(0, accountGroupUsers.size());
    }

//    @IsTest
//    private static void deleteAccountGroupUsersMultiplePerTwoUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
//
//        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = makeCompetitorPromoTrackings(euAccounts);
//        insert competitorPromoTrackings;
//
//        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = makeBrandSecurityInfringements(euAccounts);
//        insert brandSecurityInfringements;
//
//        List<EUR_CRM_Visit__c> visits = makeVisits(euAccounts);
//        insert visits;
//
//        EUR_CRM_OP_Action_List_Template__c listTemplate = makeActionListTemplate('EUR_DK_OP_Action_List_Template', 'DK_OFF_EffectsManager_Price_Promotion');
//        insert listTemplate;
//
//        List<EUR_CRM_ObjPromo__c> objPromos = makeObjPromos('EUR_DK_Off_Trade_EM_Price_Promotion');
//        insert objPromos;
//
//        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = makeObjPromoAccountMappings(euAccounts, objPromos);
//        insert objPromoAccountMappings;
//
//        List<EUR_CRM_GB_Objective__c> objectives = makeObjectives(euAccounts);
//        insert objectives;
//
//        List<EUR_CRM_Contract_Tracker__c> contractTrackers = makeContractTrackers(euAccounts);
//        insert contractTrackers;
//
//        User user1 = selectUsersWhereUserName('test.userA@mail.com');
//        User user2 = selectUsersWhereUserName('test.userB@mail.com');
//
//        userShouldSeeNothing(euAccounts, accounts, user1);
//        userShouldSeeNothing(euAccounts, accounts, user2);
//
//        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
//        insert accountGroups;
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsersForUser1 = makeAccountGroupUsers(accountGroups, user1.Id, 'Read');
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsersForUser2 = makeAccountGroupUsers(accountGroups, user2.Id, 'Read');
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
//        accountGroupUsers.addAll(accountGroupUsersForUser1);
//        accountGroupUsers.addAll(accountGroupUsersForUser2);
//        insert accountGroupUsers;
//
//        List<EUR_CRM_Account__Share> ueAccountShares = makeEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert ueAccountShares;
//
//        List<AccountShare> accountShares = makeAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert accountShares;
//
//        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = makeCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Competitor_Promo_Tracking__c>(competitorPromoTrackings).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert competitorPromoTrackingShares;
//
//        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = makeBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Brand_Security_Infringement__c>(brandSecurityInfringements).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert brandSecurityInfringementShares;
//
//        List<EUR_CRM_ObjPromo__Share> objPromoShares = makeObjPromoShares(new Map<Id, EUR_CRM_ObjPromo__c>(objPromos).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert objPromoShares;
//
//        List<EUR_CRM_Visit__Share> visitShares = makeVisitShares(new Map<Id, EUR_CRM_Visit__c>(visits).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert visitShares;
//
//        List<EUR_CRM_GB_Objective__Share> objectiveShares = makeObjectiveShares(new Map<Id, EUR_CRM_GB_Objective__c>(objectives).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert objectiveShares;
//
//        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = makeContractTrackerShares(new Map<Id, EUR_CRM_Contract_Tracker__c>(contractTrackers).keySet(), new Set<Id> { user1.Id, user2.Id });
//        insert contractTrackerShares;
//
//        userShouldSeeAllData(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//
//        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
//            accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
//        }
//        update accountGroupUsers;
//
//        Test.startTest();
//        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
//        Test.stopTest();
//
//        userShouldSeeNothing(euAccounts, accounts, user1);
//        userShouldSeeNothing(euAccounts, accounts, user2);
//
//        accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(0, accountGroupUsers.size());
//    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private static void userShouldSeeNothing(List<EUR_CRM_Account__c> euAccounts, List<Account> accounts, User us) {
        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, euAccountShares.size());

        List<AccountShare> accountShares = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, accountShares.size());

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, competitorPromoTrackingShares.size());

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, brandSecurityInfringementShares.size());

        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, visitShares.size());

        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { us.Id });
        System.assertEquals(0, objPromoShares.size());

        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, objectiveShares.size());

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, contractTrackerShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(0, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(0, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(0, contactsForSpecificUser.size());

            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
            System.assertEquals(0, competitorPromoTrackings.size());

            List<EUR_CRM_Brand_Security_Infringement__c> btaBrandSecurityInfringements = selectBrandSecurityInfringements();
            System.assertEquals(0, btaBrandSecurityInfringements.size());

            List<EUR_CRM_Visit__c> visits = selectVisits();
            System.assertEquals(0, visits.size());

            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
            System.assertEquals(0, objPromos.size());

            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
            System.assertEquals(0, objectives.size());

            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
            System.assertEquals(0, contractTrackers.size());
        }
    }

    private static void userShouldSeeAllData(List<EUR_CRM_Account__c> euAccounts, List<Account> accounts, User us) {
        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(COUNT_OF_RECORDS, euAccountShares.size());

        List<AccountShare> accountShares = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(COUNT_OF_RECORDS, accountShares.size());

//        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = selectCompetitorPromoTrackingShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackingShares.size());
//
//        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = selectBrandSecurityInfringementShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, brandSecurityInfringementShares.size());
//
//        List<EUR_CRM_Visit__Share> visitShares = selectVisitShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, visitShares.size());
//
//        List<EUR_CRM_ObjPromo__Share> objPromoShares = selectObjPromoShares(new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromoShares.size());
//
//        List<EUR_CRM_GB_Objective__Share> objectiveShares = selectObjectiveShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectiveShares.size());
//
//        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = selectContractTrackerShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackerShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(COUNT_OF_RECORDS, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(COUNT_OF_RECORDS, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contactsForSpecificUser.size());

//            List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings = selectCompetitorPromoTracking();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, competitorPromoTrackings.size());
//
//            List<EUR_CRM_Brand_Security_Infringement__c> btaBrandSecurityInfringements = selectBrandSecurityInfringements();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, btaBrandSecurityInfringements.size());
//
//            List<EUR_CRM_Visit__c> visits = selectVisits();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, visits.size());
//
//            List<EUR_CRM_ObjPromo__c> objPromos = selectObjPromos();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objPromos.size());
//
//            List<EUR_CRM_GB_Objective__c> objectives = selectObjectives();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, objectives.size());
//
//            List<EUR_CRM_Contract_Tracker__c> contractTrackers = selectContractTrackers();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contractTrackers.size());
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

    private static List<Contact> makeContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                contacts.add(makeContact(acc.Id, acc.Name + ' : Contact #' + (i + 1)));
            }
        }
        return contacts;
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
    /*     High Level Makers (sharing)
    /* ========================================================= */
    private static List<EUR_CRM_Account__Share> makeEUAccountShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_Account__Share> shares = new List<EUR_CRM_Account__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeEUAccountShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<AccountShare> makeAccountShares(Set<Id> parentIds, Set<Id> userIds) {
        List<AccountShare> shares = new List<AccountShare>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeAccountShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<EUR_CRM_Competitor_Promo_Tracking__Share> makeCompetitorPromoTrackingShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_Competitor_Promo_Tracking__Share> shares = new List<EUR_CRM_Competitor_Promo_Tracking__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeCompetitorPromoTrackingShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<EUR_CRM_Brand_Security_Infringement__Share> makeBrandSecurityInfringementShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_Brand_Security_Infringement__Share> shares = new List<EUR_CRM_Brand_Security_Infringement__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeBrandSecurityInfringementShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<EUR_CRM_Visit__Share> makeVisitShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_Visit__Share> shares = new List<EUR_CRM_Visit__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeVisitShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<EUR_CRM_ObjPromo__Share> makeObjPromoShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_ObjPromo__Share> shares = new List<EUR_CRM_ObjPromo__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeObjPromoShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<EUR_CRM_GB_Objective__Share> makeObjectiveShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_GB_Objective__Share> shares = new List<EUR_CRM_GB_Objective__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeObjectiveShare(parentId, userId));
            }
        }
        return shares;
    }

    private static List<EUR_CRM_Contract_Tracker__Share> makeContractTrackerShares(Set<Id> parentIds, Set<Id> userIds) {
        List<EUR_CRM_Contract_Tracker__Share> shares = new List<EUR_CRM_Contract_Tracker__Share>();
        for (Id parentId : parentIds) {
            for (Id userId : userIds) {
                shares.add(makeContractTrackerShare(parentId, userId));
            }
        }
        return shares;
    }


    /* ========================================================= */
    /*     Low Level Makers (sObjects)
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String name) {
        return new EUR_CRM_Account__c(
            Name = name
        ,   EUR_CRM_Postal_Code__c = '11223'
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
        ,   EUR_CRM_User__c = usId
        ,   EUR_CRM_AccessLevel__c = accessLevel
        , EUR_CRM_Status__c = 'New'
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
    private static List<EUR_CRM_Account__c> selectEUAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<Account> selectAccounts() {
        return [
            SELECT Id
            ,   Name
            FROM Account
        ];
    }

    private static List<Contact> selectContacts() {
        return [
            SELECT Id
            FROM Contact
        ];
    }

    private static List<EUR_CRM_AccountGroup__c> selectAccountGroups() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_AllowDeletion__c
            FROM EUR_CRM_AccountGroup__c
        ];
    }

    private static List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsers() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_AllowDeletion__c
            FROM EUR_CRM_AccountGroupUser__c
        ];
    }

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
    private static List<EUR_CRM_Account__Share> selectEUAccountShares(Set<Id> parentIds, Set<Id> userIds) {
        return [
            SELECT Id
            ,   ParentId
            ,   UserOrGroupId
            ,   AccessLevel
            FROM EUR_CRM_Account__Share
            WHERE ParentId IN :parentIds
                AND UserOrGroupId IN :userIds
        ];
    }

    private static List<AccountShare> selectAccountShares(Set<Id> parentIds, Set<Id> userIds) {
        return [
            SELECT Id
            ,   AccountId
            ,   UserOrGroupId
            ,   AccountAccessLevel
            FROM AccountShare
            WHERE AccountId IN :parentIds
                AND UserOrGroupId IN :userIds
        ];
    }

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