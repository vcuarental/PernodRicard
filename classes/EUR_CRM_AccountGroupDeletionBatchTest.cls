@IsTest
private class EUR_CRM_AccountGroupDeletionBatchTest {

    private static final Integer COUNT_OF_RECORDS = 4;

    @IsTest
    private static void batchTest() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(), 200);
        Test.stopTest();
    }

    @IsTest
    private static void schedulerTest() {
        Test.startTest();
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_AccountGroupDeletionBatch scheduledJob = new EUR_CRM_AccountGroupDeletionBatch();
        System.schedule('Account Group Deletion Scheduled Job', cronExpression, scheduledJob);
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Delete Single
    /* ========================================================= */
    @IsTest
    private static void deleteWhenChildExistSingleTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id, UserInfo.getUserId(), 'Read');
        insert accountGroupUser;

        accountGroup.EUR_CRM_Status__c = EUR_CRM_AccountGroupDeletionBatch.TO_DELETE_STATUS;
        update accountGroup;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(accountGroup.Id), 200);
        Test.stopTest();

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(1, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(1, accountGroupUsers.size());
    }

    @IsTest
    private static void deleteWithoutChildSingleTest() {
        EUR_CRM_Account__c euAccount = makeAccount('Test Account');
        insert euAccount;

        Account acc = selectAccounts()[0];

        Contact contact = makeContact(acc.Id, 'Contact LastName');
        insert contact;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(euAccount.Id);
        insert accountGroup;

        accountGroup.EUR_CRM_Status__c = EUR_CRM_AccountGroupDeletionBatch.TO_DELETE_STATUS;
        update accountGroup;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(accountGroup.Id), 200);
        Test.stopTest();

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(0, accountGroups.size());
    }


    /* ========================================================= */
    /*     Delete Multiple
    /* ========================================================= */
    @IsTest
    private static void deleteWhenChildExistMultipleTest() {
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = makeAccountGroupUsers(accountGroups, UserInfo.getUserId(), 'Read');
        insert accountGroupUsers;

        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            accountGroup.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        }
        update accountGroups;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(new Map<Id, EUR_CRM_AccountGroup__c>(accountGroups).keySet()), 200);
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS, accountGroups.size());

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroupUsers.size());
    }

    @IsTest
    private static void deleteWithoutChildMultipleTest() {
        List<EUR_CRM_Account__c> euAccounts = makeAccounts();
        insert euAccounts;

        List<Account> accounts = selectAccounts();

        List<Contact> contacts = makeContacts(accounts);
        insert contacts;

        List<EUR_CRM_AccountGroup__c> accountGroups = makeAccountGroups(euAccounts);
        insert accountGroups;

        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            accountGroup.EUR_CRM_Status__c = EUR_CRM_AccGroupUserSharingBatch.TO_DELETE_STATUS;
        }
        update accountGroups;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(new Map<Id, EUR_CRM_AccountGroup__c>(accountGroups).keySet()), 200);
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(0, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(0, accountGroupUsers.size());
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


    /* ========================================================= */
    /*     Low Level Makers (sObjects)
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

    private static EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId, Id usId, String accessLevel) {
        return new EUR_CRM_AccountGroupUser__c(
            EUR_CRM_AccountGroup__c = agId
        ,   EUR_CRM_User__c = usId
        ,   EUR_CRM_AccessLevel__c = accessLevel
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors (sObjects)
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

}