@IsTest
private class EUR_CRM_AccountEUSharingWebServiceTest {

    private static final Integer COUNT_OF_RECORDS = 1;

    @TestSetup
    private static void setupMethod() {
        insert makeUser('EUR DK ON Trade SR', 'EUR_DK_OnTrade_SalesRep', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
        insert makeUser('EUR DK OFF Trade SR', 'EUR_DK_OffTrade_SalesRep', 'test.userB@mail.com', 'test.userB@mail.com', 'LastNameB');
    }


    @IsTest
    private static void run_EUR_CRM_AccountEUShareBatch_Test() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        userShouldSeeNothing(euAccounts, accounts, user1);
        userShouldSeeNothing(euAccounts, accounts, user2);

        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        accountShares.addAll(makeEUAccountShares(euAccounts, user1.Id));
        accountShares.addAll(makeEUAccountShares(euAccounts, user2.Id));
        insert accountShares;

        String result = EUR_CRM_AccountEUSharingWebService.run_EUR_CRM_AccountEUShareBatch(euAccounts[0].Id);
        System.assertEquals(EUR_CRM_AccountEUSharingWebService.SUCCESSFULLY_RUN_MIGRATION, result);
        Test.stopTest();

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(2 * COUNT_OF_RECORDS, accountGroupUsers.size());
    }

    @IsTest
    private static void run_EUR_CRM_AccGroupUserSharingBatch_for_AG() {
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

        String result = EUR_CRM_AccountEUSharingWebService.run_EUR_CRM_AccGroupUserSharingBatch_for_AG(accountGroup.Id);
        System.assertEquals(EUR_CRM_AccountEUSharingWebService.SUCCESSFULLY_RUN_DATA_SHARING, result);
        Test.stopTest();

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());
        System.assertEquals('Read', euAccountShares[0].AccessLevel);

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());
        System.assertEquals('Read', accountShares[0].AccountAccessLevel);

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
    }

    @IsTest
    private static void run_EUR_CRM_AccGroupUserSharingBatch_for_AGU() {
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

        String result = EUR_CRM_AccountEUSharingWebService.run_EUR_CRM_AccGroupUserSharingBatch_for_AGU(accountGroupUser.Id);
        System.assertEquals(EUR_CRM_AccountEUSharingWebService.SUCCESSFULLY_RUN_DATA_SHARING, result);
        Test.stopTest();

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());
        System.assertEquals('Read', euAccountShares[0].AccessLevel);

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());
        System.assertEquals('Read', accountShares[0].AccountAccessLevel);

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
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private static void userShouldSeeNothing(List<EUR_CRM_Account__c> euAccounts, List<Account> accounts, User us) {
        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, euAccountShares.size());

        List<AccountShare> accountShares = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
        System.assertEquals(0, accountShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(0, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(0, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(0, contactsForSpecificUser.size());
        }
    }


    /* ========================================================= */
    /*     High Level Makers
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

    private static List<EUR_CRM_AccountGroupUser__c> makeAccountGroupUsers(List<EUR_CRM_AccountGroup__c> accountGroups, Set<Id> userIds, String accessLevel) {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        for (EUR_CRM_AccountGroup__c accGroup : accountGroups) {
            for (Id usId : userIds) {
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

    private static List<EUR_CRM_Account__Share> makeEUAccountShares(List<EUR_CRM_Account__c> accounts, Id userId) {
        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        for (EUR_CRM_Account__c account : accounts) {
            accountShares.add(makeEUAccountShare(account.Id, userId));
        }
        return accountShares;
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


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String name) {
        return new EUR_CRM_Account__c(
            Name = name
        ,   EUR_CRM_Postal_Code__c = '1122'
        , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_DE_Off_Trade_Retail')
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
            EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId, Id usId, String accessLevel) {
        return new EUR_CRM_AccountGroupUser__c(
            EUR_CRM_AccountGroup__c = agId
        ,   EUR_CRM_User__c = usId
        ,   EUR_CRM_AccessLevel__c = accessLevel
        );
    }

    private static EUR_CRM_Account__Share makeEUAccountShare(Id accId, Id userId) {
        return new EUR_CRM_Account__Share(
            ParentId = accId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = 'Read'
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