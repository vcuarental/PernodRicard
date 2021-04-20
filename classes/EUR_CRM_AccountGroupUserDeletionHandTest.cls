@IsTest (IsParallel = true)
private class EUR_CRM_AccountGroupUserDeletionHandTest {

    private static final Integer COUNT_OF_RECORDS = 3;

    @TestSetup
    private static void testSetup() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('Test Account');
        insert accounts;

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        for (EUR_CRM_Account__c account : accounts) {
            accountGroups.addAll(makeAccountGroups(account.Id));
        }
        insert accountGroups;

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            accountGroupUsers.addAll(makeAccountGroupUsers(accountGroup.Id));
        }
        insert accountGroupUsers;
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(COUNT_OF_RECORDS, accounts.size());

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroupUsers.size());
        Test.stopTest();
    }

    @IsTest
    private static void cannotDeleteRegularRecordsTest() {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();

        Test.startTest();
        Boolean receiveExpectedErrorMessage = false;
        try {
            delete accountGroupUsers;
        } catch (Exception e) {
            receiveExpectedErrorMessage = e.getMessage().containsIgnoreCase(EUR_CRM_AccountGroupUserDeletionHandler.CANNOT_BE_DELETED);
        }

        System.assertEquals(true, receiveExpectedErrorMessage);
        Test.stopTest();

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroupUsers.size());
    }

    @IsTest
    private static void cannotDeleteRecordsMarkedToDeleteButWithoutCheckedAllowDeletionTest() {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccountGroupUserDeletionHandler.TO_DELETE_STATUS;
        }
        update accountGroupUsers;

        Test.startTest();
        Boolean receiveExpectedErrorMessage = false;
        try {
            delete accountGroupUsers;
        } catch (Exception e) {
            receiveExpectedErrorMessage = e.getMessage().containsIgnoreCase(EUR_CRM_AccountGroupUserDeletionHandler.CANNOT_BE_DELETED);
        }

        System.assertEquals(true, receiveExpectedErrorMessage);
        Test.stopTest();

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroupUsers.size());
    }

    @IsTest
    private static void cannotDeleteRecordsMarkedToDeleteAndWithCheckedAllowDeletionTest() {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccountGroupUserDeletionHandler.TO_DELETE_STATUS;
            accountGroupUser.EUR_CRM_AllowDeletion__c = true;
        }
        update accountGroupUsers;

        Test.startTest();
        delete accountGroupUsers;
        Test.stopTest();

        accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(0, accountGroupUsers.size());
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> makeAccounts(String name) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            accounts.add(makeAccount(name));
        }
        return accounts;
    }

    private static List<EUR_CRM_AccountGroup__c> makeAccountGroups(Id accId) {
        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            accountGroups.add(makeAccountGroup(accId));
        }
        return accountGroups;
    }

    private static List<EUR_CRM_AccountGroupUser__c> makeAccountGroupUsers(Id agId) {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = new List<EUR_CRM_AccountGroupUser__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            accountGroupUsers.add(makeAccountGroupUser(agId));
        }
        return accountGroupUsers;
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

    private static EUR_CRM_AccountGroup__c makeAccountGroup(Id accId) {
        return new EUR_CRM_AccountGroup__c(
            EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_AccountGroupUser__c makeAccountGroupUser(Id agId) {
        return new EUR_CRM_AccountGroupUser__c(
            EUR_CRM_AccountGroup__c = agId
        ,   EUR_CRM_User__c = UserInfo.getUserId()
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
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