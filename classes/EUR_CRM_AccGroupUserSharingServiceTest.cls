@IsTest
private class EUR_CRM_AccGroupUserSharingServiceTest {

//    private static final Integer COUNT_OF_RECORDS = 4;
//
//    @TestSetup
//    private static void setupTest() {
//        insert makeUser('EUR DK ON Trade SR', 'EUR_DK_OnTrade_SalesRep', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
//        insert makeUser('EUR DK OFF Trade SR', 'EUR_DK_OffTrade_SalesRep', 'test.userB@mail.com', 'test.userB@mail.com', 'LastNameB');
//    }
//
//
//    /* ========================================================= */
//    /*     Create Sharing
//    /* ========================================================= */
//    @IsTest
//    private static void insertAccountGroupUserWithReadAccessSingleTest() {
//        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
//        insert euAccount;
//
//        Account acc = selectAccounts()[0];
//
//        Contact contact = makeContact(acc.Id, 'Contact LastName');
//        insert contact;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);
//
//        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
//        insert accountGroup;
//
//        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
//
//        Test.startTest();
//        insert accountGroupUser;
//        Test.stopTest();
//
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, euAccountShares.size());
//        System.assertEquals('Read', euAccountShares[0].AccessLevel);
//
//        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, accountShares.size());
//        System.assertEquals('Read', accountShares[0].AccountAccessLevel);
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(1, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(1, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(1, contactsForSpecificUser.size());
//        }
//    }
//
//    @IsTest
//    private static void insertAccountGroupUserWithEditAccessSingleTest() {
//        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
//        insert euAccount;
//
//        Account acc = selectAccounts()[0];
//
//        Contact contact = makeContact(acc.Id, 'Contact LastName');
//        insert contact;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);
//
//        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
//        insert accountGroup;
//
//        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Edit');
//
//        Test.startTest();
//        insert accountGroupUser;
//        Test.stopTest();
//
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, euAccountShares.size());
//        System.assertEquals('Edit', euAccountShares[0].AccessLevel);
//
//        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, accountShares.size());
//        System.assertEquals('Edit', accountShares[0].AccountAccessLevel);
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(1, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(1, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(1, contactsForSpecificUser.size());
//        }
//    }
//
//    @IsTest
//    private static void insertAccountGroupUsersMultiplePerOneUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        userShouldSeeNothing(euAccounts, accounts, us);
//
//        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
//        insert accountGroups;
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, us.Id, 'Read');
//
//        Test.startTest();
//        insert accountGroupUsers;
//        Test.stopTest();
//
//        userShouldSeeAllData(euAccounts, accounts, us);
//    }
//
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
//
//        Test.startTest();
//        insert accountGroupUsers;
//        Test.stopTest();
//
//        userShouldSeeAllData(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//    }
//
//
//    /* ========================================================= */
//    /*     Delete Sharing
//    /* ========================================================= */
//    @IsTest
//    private static void deleteAccountGroupUserSingleTest() {
//        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
//        insert euAccount;
//
//        Account acc = selectAccounts()[0];
//
//        Contact contact = makeContact(acc.Id, 'Contact LastName');
//        insert contact;
//
//        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
//        insert accountGroup;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
//        insert accountGroupUser;
//
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, euAccountShares.size());
//        for (EUR_CRM_Account__Share share : euAccountShares) {
//            System.assertEquals(us.Id, share.UserOrGroupId);
//        }
//
//        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, accountShares.size());
//        for (AccountShare share : accountShares) {
//            System.assertEquals(us.Id, share.UserOrGroupId);
//        }
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(1, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(1, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(1, contactsForSpecificUser.size());
//        }
//
//        Test.startTest();
//        delete accountGroupUser;
//        Test.stopTest();
//
//        userShouldSeeNothing(new List<EUR_CRM_Account__c> { euAccount }, new List<Account> { acc }, us);
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(0, accountGroupUsers.size());
//    }
//
//    @IsTest
//    private static void deleteAccountGroupUsersMultiplePerOneUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
//
//        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
//        insert accountGroups;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, us.Id, 'Read');
//        insert accountGroupUsers;
//
//        userShouldSeeAllData(euAccounts, accounts, us);
//
//        Test.startTest();
//        delete accountGroupUsers;
//        Test.stopTest();
//
//        userShouldSeeNothing(euAccounts, accounts, us);
//
//        accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(0, accountGroupUsers.size());
//    }
//
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
//        userShouldSeeAllData(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//
//
//        Test.startTest();
//        delete accountGroupUsers;
//        Test.stopTest();
//
//        userShouldSeeNothing(euAccounts, accounts, user1);
//        userShouldSeeNothing(euAccounts, accounts, user2);
//
//        accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(0, accountGroupUsers.size());
//    }
//
//    @IsTest
//    private static void deletePartiallyAccountGroupUsersMultiplePerTwoUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
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
//        userShouldSeeAllData(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//
//        Test.startTest();
//        delete accountGroupUsersForUser1;
//
//        userShouldSeeNothing(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//
//        accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroupUsers.size());
//
//        delete accountGroupUsersForUser2;
//        Test.stopTest();
//
//        userShouldSeeNothing(euAccounts, accounts, user2);
//    }
//
//    @IsTest
//    private static void deleteAccountGroupSingleTest() {
//        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
//        insert euAccount;
//
//        Account acc = selectAccounts()[0];
//
//        Contact contact = makeContact(acc.Id, 'Contact LastName');
//        insert contact;
//
//        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
//        insert accountGroup;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id, 'Read');
//        insert accountGroupUser;
//
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, euAccountShares.size());
//        for (EUR_CRM_Account__Share share : euAccountShares) {
//            System.assertEquals(us.Id, share.UserOrGroupId);
//        }
//
//        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, accountShares.size());
//        for (AccountShare share : accountShares) {
//            System.assertEquals(us.Id, share.UserOrGroupId);
//        }
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(1, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(1, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(1, contactsForSpecificUser.size());
//        }
//
//        Test.startTest();
//        delete accountGroup;
//        Test.stopTest();
//
//        List<EUR_CRM_Account__Share> euAccountSharesAfter = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(0, euAccountSharesAfter.size());
//
//        List<AccountShare> accountSharesAfter = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
//        System.assertEquals(0, accountSharesAfter.size());
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(0, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(0, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(0, contactsForSpecificUser.size());
//        }
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(0, accountGroupUsers.size());
//    }
//
//    @IsTest
//    private static void deleteAccountGroupsMultiplePerOneUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
//
//        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
//        insert accountGroups;
//
//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, us.Id, 'Read');
//        insert accountGroupUsers;
//
//        userShouldSeeAllData(euAccounts, accounts, us);
//
//        Test.startTest();
//        delete accountGroups;
//        Test.stopTest();
//
//        userShouldSeeNothing(euAccounts, accounts, us);
//
//        accountGroupUsers = selectAccountGroupUsers();
//        System.assertEquals(0, accountGroupUsers.size());
//    }
//
//    @IsTest
//    private static void deleteAccountGroupMultiplePerTwoUserTest() {
//        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
//        insert euAccounts;
//
//        List<Account> accounts = selectAccounts();
//
//        List<Contact> contacts = makeContacts(accounts);
//        insert contacts;
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
//
//        Test.startTest();
//        insert accountGroupUsers;
//        Test.stopTest();
//
//        userShouldSeeAllData(euAccounts, accounts, user1);
//        userShouldSeeAllData(euAccounts, accounts, user2);
//    }
//
//
//    /* ========================================================= */
//    /*     Delegate Methods
//    /* ========================================================= */
//    private static void userShouldSeeNothing(List<EUR_CRM_Account__c> euAccounts, List<Account> accounts, User us) {
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(0, euAccountShares.size());
//
//        List<AccountShare> accountShares = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(0, accountShares.size());
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(0, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(0, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(0, contactsForSpecificUser.size());
//        }
//    }
//
//    private static void userShouldSeeAllData(List<EUR_CRM_Account__c> euAccounts, List<Account> accounts, User us) {
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS, euAccountShares.size());
//
//        List<AccountShare> accountShares = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { us.Id });
//        System.assertEquals(COUNT_OF_RECORDS, accountShares.size());
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(COUNT_OF_RECORDS, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(COUNT_OF_RECORDS, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, contactsForSpecificUser.size());
//        }
//    }
//
//
//    /* ========================================================= */
//    /*     High Level Makers
//    /* ========================================================= */
//    private static List<EUR_CRM_Account__c> makeAccounts() {
//        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
//        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//            accounts.add(makeAccount('Account #' + (i + 1)));
//        }
//        return accounts;
//    }
//
//    private static List<Contact> makeContacts(List<Account> accounts) {
//        List<Contact> contacts = new List<Contact>();
//        for (Account acc : accounts) {
//            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//                contacts.add(makeContact(acc.Id, acc.Name + ' : Contact #' + (i + 1)));
//            }
//        }
//        return contacts;
//    }
//
//    private static List<EUR_CRM_AccountGroup__c> makeAccountGroups(List<EUR_CRM_Account__c> accounts) {
//        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
//        for (EUR_CRM_Account__c account : accounts) {
//            accountGroups.add(makeAccountGroup(account.Id));
//        }
//        return accountGroups;
//    }
//
//    private static List<EUR_CRM_AccountGroupUser__c> makeAccountGroupUsers(List<EUR_CRM_AccountGroup__c> accountGroups, Id usId, String accessLevel) {
//        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
//        for (EUR_CRM_AccountGroup__c accGroup : accountGroups) {
//            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//                accountGroupUsers.add(makeAccountGroupUser(accGroup.Id, usId, accessLevel));
//            }
//        }
//        return accountGroupUsers;
//    }
//
//    public static User makeUser(String profileName, String roleName, String userEmail, String userName, String lastName) {
//        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1][0];
//        UserRole r = [SELECT Id from UserRole WHERE DeveloperName = :roleName LIMIT 1][0];
//        User u = new User(
//            Alias = 'standt'
//        ,   Email = userEmail
//        ,   UserRoleId = r.id
//        ,   EmailEncodingKey = 'UTF-8'
//        ,   LastName = lastName
//        ,   LanguageLocaleKey = 'en_US'
//        ,   LocaleSidKey = 'en_US'
//        ,   ProfileId = p.Id
//        ,   TimeZoneSidKey = 'America/Los_Angeles'
//        ,   UserName = userName
//        );
//        return u;
//    }
//
//
//    /* ========================================================= */
//    /*     Low Level Makers
//    /* ========================================================= */
//    private static EUR_CRM_Account__c makeAccount(String name) {
//        return new EUR_CRM_Account__c(
//            Name = name
//        );
//    }
//
//    private static Contact makeContact(Id accId, String ln) {
//        return new Contact(
//            AccountId = accId
//        ,   LastName = ln
//        );
//    }
//
//    private static EUR_CRM_AccountGroup__c makeAccountGroup(Id accId) {
//        return new EUR_CRM_AccountGroup__c(
//            EUR_CRM_Account__c = accId
//        );
//    }
//
//    private static EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId, Id usId, String accessLevel) {
//        return new EUR_CRM_AccountGroupUser__c(
//            EUR_CRM_AccountGroup__c = agId
//        ,   EUR_CRM_User__c = usId
//        ,   EUR_CRM_AccessLevel__c = accessLevel
//        );
//    }
//
//    private static EUR_CRM_Account__Share makeEUAccountShare(Id accId, Id userId) {
//        return new EUR_CRM_Account__Share(
//            ParentId = accId
//        ,   UserOrGroupId = userId
//        ,   RowCause = 'Manual'
//        ,   AccessLevel = 'Read'
//        );
//    }
//
//    private static AccountShare makeAccountShare(Id accId, Id userId) {
//        return new AccountShare(
//            AccountId = accId
//        ,   UserOrGroupId = userId
//        ,   RowCause = 'Manual'
//        ,   AccountAccessLevel = 'Read'
//        ,   OpportunityAccessLevel = 'Read'
//        );
//    }
//
//
//    /* ========================================================= */
//    /*     SOQL Selectors
//    /* ========================================================= */
//    private static List<EUR_CRM_Account__c> selectEUAccounts() {
//        return [
//            SELECT Id
//            FROM EUR_CRM_Account__c
//        ];
//    }
//
//    private static List<Account> selectAccounts() {
//        return [
//            SELECT Id
//            ,   Name
//            FROM Account
//        ];
//    }
//
//    private static List<Contact> selectContacts() {
//        return [
//            SELECT Id
//            FROM Contact
//        ];
//    }
//
//    private static List<EUR_CRM_AccountGroup__c> selectAccountGroups() {
//        return [
//            SELECT Id
//            ,   EUR_CRM_Status__c
//            ,   EUR_CRM_AllowDeletion__c
//            FROM EUR_CRM_AccountGroup__c
//        ];
//    }
//
//    private static List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsers() {
//        return [
//            SELECT Id
//            ,   EUR_CRM_Status__c
//            ,   EUR_CRM_AllowDeletion__c
//            FROM EUR_CRM_AccountGroupUser__c
//        ];
//    }
//
//    private static List<EUR_CRM_Account__Share> selectEUAccountShares(Set<Id> parentIds, Set<Id> userIds) {
//        return [
//            SELECT Id
//            ,   ParentId
//            ,   UserOrGroupId
//            ,   AccessLevel
//            FROM EUR_CRM_Account__Share
//            WHERE ParentId IN :parentIds
//                AND UserOrGroupId IN :userIds
//        ];
//    }
//
//    private static List<AccountShare> selectAccountShares(Set<Id> parentIds, Set<Id> userIds) {
//        return [
//            SELECT Id
//            ,   AccountId
//            ,   UserOrGroupId
//            ,   AccountAccessLevel
//            FROM AccountShare
//            WHERE AccountId IN :parentIds
//                AND UserOrGroupId IN :userIds
//        ];
//    }
//
//    private static User selectUsersWhereUserName(String username) {
//        return [
//            SELECT Id
//            FROM User
//            WHERE Username = :username
//            LIMIT 1
//        ][0];
//    }

}