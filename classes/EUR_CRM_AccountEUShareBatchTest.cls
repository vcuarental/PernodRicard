@IsTest
private class EUR_CRM_AccountEUShareBatchTest {

    private static final Integer COUNT_OF_RECORDS = 2;

    @TestSetup
    private static void setupMethod() {
        insert makeUser('EUR DK ON Trade SR', 'EUR_DK_OnTrade_SalesRep', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
        insert makeUser('EUR DK OFF Trade SR', 'EUR_DK_OffTrade_SalesRep', 'test.userB@mail.com', 'test.userB@mail.com', 'LastNameB');
    }

    @IsTest
    private static void schedulerTest() {
        Test.startTest();
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_AccountEUShareBatch scheduledJob = new EUR_CRM_AccountEUShareBatch(true);
        System.schedule('Account User Sharing Migration Scheduled Job', cronExpression, scheduledJob);
        System.assertEquals(true, scheduledJob.isScheduledJob);
        Test.stopTest();
    }

    @IsTest
    private static void accountGroupsNotExistAndAccountGroupUsersNotExistReadAccessTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        accountShares.addAll(makeEUAccountShares(euAccounts, user1.Id, 'Read'));
        accountShares.addAll(makeEUAccountShares(euAccounts, user2.Id, 'Read'));
        insert accountShares;

        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(2 * COUNT_OF_RECORDS, accountGroupUsers.size());
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            System.assertEquals('Read', accountGroupUser.EUR_CRM_AccessLevel__c);
        }
    }

    @IsTest
    private static void accountGroupsNotExistAndAccountGroupUsersNotExistEditAccessTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        accountShares.addAll(makeEUAccountShares(euAccounts, user1.Id, 'Edit'));
        accountShares.addAll(makeEUAccountShares(euAccounts, user2.Id, 'Edit'));
        insert accountShares;

        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(2 * COUNT_OF_RECORDS, accountGroupUsers.size());
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            System.assertEquals('Edit', accountGroupUser.EUR_CRM_AccessLevel__c);
        }
    }

    @IsTest
    private static void accountGroupsExistButAccountGroupUsersNotExistTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_Account__Share> euAccountSharesBefore = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user1.Id });
        System.assertEquals(0, euAccountSharesBefore.size());

        euAccountSharesBefore = selectEUAccountShares(new Map<Id, EUR_CRM_Account__c>(euAccounts).keySet(), new Set<Id> { user2.Id });
        System.assertEquals(0, euAccountSharesBefore.size());

        List<AccountShare> accountSharesBefore = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { user1.Id });
        System.assertEquals(0, accountSharesBefore.size());

        accountSharesBefore = selectAccountShares(new Map<Id, Account>(accounts).keySet(), new Set<Id> { user2.Id });
        System.assertEquals(0, accountSharesBefore.size());

        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        accountShares.addAll(makeEUAccountShares(euAccounts, user1.Id, 'Read'));
        accountShares.addAll(makeEUAccountShares(euAccounts, user2.Id, 'Read'));
        insert accountShares;

        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(), 200);
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(2 * COUNT_OF_RECORDS, accountGroupUsers.size());
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            System.assertEquals('Read', accountGroupUser.EUR_CRM_AccessLevel__c);
        }
    }

    @IsTest
    private static void accountGroupsExistAndAccountGroupUsersExistTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        accountGroupUsers.addAll(makeAccountGroupUsers(accountGroups, new Set<Id> { user1.Id, user2.Id }, 'Read'));
        insert accountGroupUsers;


        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(), 200);
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(2 * COUNT_OF_RECORDS, accountGroupUsers.size());
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            System.assertEquals('Read', accountGroupUser.EUR_CRM_AccessLevel__c);
        }
    }

    @IsTest
    private static void accountGroupsNotExistAndAccountGroupUsersUpdateAccountGroupExternalIdTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        User user1 = selectUsersWhereUserName('test.userA@mail.com');
        User user2 = selectUsersWhereUserName('test.userB@mail.com');

        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        accountShares.addAll(makeEUAccountShares(euAccounts, user1.Id, 'Read'));
        accountShares.addAll(makeEUAccountShares(euAccounts, user2.Id, 'Read'));
        insert accountShares;

        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(), 200);
        Test.stopTest();

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());
        for (Integer i = 0; i < accountGroups.size(); i++) {
            System.assertEquals('ExternalID_' + (i + 1), accountGroups.get(i).EUR_CRM_External_ID__c);
        }

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(2 * COUNT_OF_RECORDS, accountGroupUsers.size());
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            System.assertEquals('Read', accountGroupUser.EUR_CRM_AccessLevel__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> makeAccounts() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            accounts.add(makeAccount('Account #' + (i + 1), 'ExternalID_' + (i + 1)));
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

    private static List<EUR_CRM_Account__Share> makeEUAccountShares(List<EUR_CRM_Account__c> accounts, Id userId, String accessLevel) {
        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        for (EUR_CRM_Account__c account : accounts) {
            accountShares.add(makeEUAccountShare(account.Id, userId, accessLevel));
        }
        return accountShares;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String name, String externalId) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Off_Trade_Retail').getRecordTypeId();
        return new EUR_CRM_Account__c(
            Name = name
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   EUR_CRM_External_ID__c = externalId
        ,   RecordTypeId = rtId
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

    private static EUR_CRM_Account__Share makeEUAccountShare(Id accId, Id userId, String accessLevel) {
        return new EUR_CRM_Account__Share(
            ParentId = accId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<Account> selectAccounts() {
        return [
            SELECT Id
            ,   Name
            FROM Account
        ];
    }

    private static List<EUR_CRM_AccountGroup__c> selectAccountGroups() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_AllowDeletion__c
            ,   EUR_CRM_External_ID__c
            FROM EUR_CRM_AccountGroup__c
            ORDER BY EUR_CRM_External_ID__c
        ];
    }

    private static List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsers() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_AllowDeletion__c
            ,   EUR_CRM_AccessLevel__c
            FROM EUR_CRM_AccountGroupUser__c
        ];
    }

    private static List<EUR_CRM_Account__Share> selectEUAccountShares(Set<Id> parentIds, Set<Id> userIds) {
        return [
            SELECT Id
            ,   ParentId
            ,   UserOrGroupId
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
            FROM AccountShare
            WHERE AccountId IN :parentIds
                AND UserOrGroupId IN :userIds
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

}