@IsTest
private class EUR_CRM_AccountGroupDeepCloneControlTest {

    private static final Integer COUNT_OF_RECORDS = 4;

    @TestSetup
    private static void setupMethod() {
        insert makeUser('EUR DK ON Trade SR', 'EUR_DK_OnTrade_SalesRep', 'test.userA@mail.com', 'test.userA@mail.com', 'LastNameA');
    }

    private static void createAllData() {
        User us = selectUsersWhereUserName('test.userA@mail.com');

        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, us.Id);
        insert accountGroupUser;

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(accountGroupUser.Id), 200);
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        createAllData();
        Test.stopTest();

        EUR_CRM_Account__c euAccount = selectEUAccounts()[0];
        Account acc = selectAccounts()[0];

        User us = selectUsersWhereUserName('test.userA@mail.com');

        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, euAccountShares.size());

        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
        System.assertEquals(1, accountShares.size());

        System.runAs(us) {
            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
            System.assertEquals(1, euAccountsForSpecificUser.size());

            List<Account> accountsForSpecificUser = selectAccounts();
            System.assertEquals(1, accountsForSpecificUser.size());

            List<Contact> contactsForSpecificUser = selectContacts();
            System.assertEquals(COUNT_OF_RECORDS, contactsForSpecificUser.size());
        }
    }

    @IsTest
    private static void theSameAccountTest() {
        createAllData();

        EUR_CRM_AccountGroup__c accountGroup = selectAccountGroups()[0];

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupDeepClone);
        System.currentPageReference().getParameters().put('Id', accountGroup.Id);

        EUR_CRM_AccountGroupDeepCloneController controller = new EUR_CRM_AccountGroupDeepCloneController();

        System.assertEquals(accountGroup.EUR_CRM_Account__c, controller.accountGroup.EUR_CRM_Account__c);

        controller.doCloning();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(EUR_CRM_AccountGroupDeepCloneController.CANNOT_CHOOSE_SAME_ACCOUNT));
        Test.stopTest();
    }

    @IsTest
    private static void emptyAccountTest() {
        createAllData();

        EUR_CRM_AccountGroup__c accountGroup = selectAccountGroups()[0];

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupDeepClone);
        System.currentPageReference().getParameters().put('Id', accountGroup.Id);

        EUR_CRM_AccountGroupDeepCloneController controller = new EUR_CRM_AccountGroupDeepCloneController();
        controller.accountGroup.EUR_CRM_Account__c = null;

        controller.doCloning();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains('Required fields are missing: [EUR_CRM_Account__c]'));
        Test.stopTest();
    }

    @IsTest
    private static void normalTest() {
        EUR_CRM_EUAccountLinkHandler.doRunOnce = true;
        Test.startTest();
        createAllData();
        Test.stopTest();

        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account accToInsert = new Account(
            Name = euAccount.Name
        ,   RecordTypeId = EUR_CRM_AccountUtils.EUR_CRM_GENERAL_RECORDTYPE.RecordTypeId
        );
        insert accToInsert;

        EUR_CRM_Account_Link__c accountLink = new EUR_CRM_Account_Link__c(
            EUR_CRM_EU_Account__c = euAccount.Id
        ,   EUR_CRM_Standard_Account__c = accToInsert.Id
        );
        insert accountLink;

        Account acc = selectAccounts()[1];

        List<Contact> contacts = makeContacts(new List<Account> { acc });
        insert contacts;

        EUR_CRM_AccountGroup__c accountGroup = selectAccountGroups()[0];

        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupDeepClone);
        System.currentPageReference().getParameters().put('Id', accountGroup.Id);

        EUR_CRM_AccountGroupDeepCloneController controller = new EUR_CRM_AccountGroupDeepCloneController();
        controller.accountGroup.EUR_CRM_Account__c = euAccount.Id;

        PageReference pRef = controller.doCloning();

        List<EUR_CRM_AccountGroup__c> ags = selectAccountGroups();
        System.assertEquals(true, pRef.getUrl().containsIgnoreCase(String.valueOf(ags[ags.size() - 1].Id)));

//        User us = selectUsersWhereUserName('test.userA@mail.com');
//
//        List<EUR_CRM_Account__Share> euAccountShares = selectEUAccountShares(new Set<Id> { euAccount.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, euAccountShares.size());
//
//        List<AccountShare> accountShares = selectAccountShares(new Set<Id> { acc.Id }, new Set<Id> { us.Id });
//        System.assertEquals(1, accountShares.size());
//
//        System.runAs(us) {
//            List<EUR_CRM_Account__c> euAccountsForSpecificUser = selectEUAccounts();
//            System.assertEquals(2, euAccountsForSpecificUser.size());
//
//            List<Account> accountsForSpecificUser = selectAccounts();
//            System.assertEquals(2, accountsForSpecificUser.size());
//
//            List<Contact> contactsForSpecificUser = selectContacts();
//            System.assertEquals(2 * COUNT_OF_RECORDS, contactsForSpecificUser.size());
//        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
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

    private static List<EUR_CRM_AccountGroupUser__c> makeAccountGroupUsers(List<EUR_CRM_AccountGroup__c> accountGroups, Id usId) {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        for (EUR_CRM_AccountGroup__c accGroup : accountGroups) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                accountGroupUsers.add(makeAccountGroupUser(accGroup.Id, usId));
            }
        }
        return accountGroupUsers;
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


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String name) {
        return new EUR_CRM_Account__c(
            Name = name
        ,   EUR_CRM_Postal_Code__c = '1122'
        , RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
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

    private static EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId, Id usId) {
        return new EUR_CRM_AccountGroupUser__c(
            EUR_CRM_AccountGroup__c = agId
        ,   EUR_CRM_User__c = usId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
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
            ,   EUR_CRM_Account__c
            FROM EUR_CRM_AccountGroup__c
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