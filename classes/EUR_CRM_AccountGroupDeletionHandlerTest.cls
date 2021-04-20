@IsTest (IsParallel = true)
private class EUR_CRM_AccountGroupDeletionHandlerTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @TestSetup
    private static void testSetup() {
        List<EUR_CRM_Account__c> accounts = makeAccounts('Test Account');
        insert accounts;

        List<EUR_CRM_AccountGroup__c> accountGroups = new List<EUR_CRM_AccountGroup__c>();
        for (EUR_CRM_Account__c account : accounts) {
            accountGroups.addAll(makeAccountGroups(account.Id));
        }
        insert accountGroups;
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(COUNT_OF_RECORDS, accounts.size());

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroups.size());
        Test.stopTest();
    }

    @IsTest
    private static void cannotDeleteRegularRecordsTest() {
        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();

        Test.startTest();
        Boolean receiveExpectedErrorMessage = false;
        try {
            delete accountGroups;
        } catch (Exception e) {
            receiveExpectedErrorMessage = e.getMessage().containsIgnoreCase(EUR_CRM_AccountGroupDeletionHandler.CANNOT_BE_DELETED);
        }

        System.assertEquals(true, receiveExpectedErrorMessage);
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroups.size());
    }

    @IsTest
    private static void cannotDeleteRecordsMarkedToDeleteButWithoutCheckedAllowDeletionTest() {
        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            accountGroup.EUR_CRM_Status__c = EUR_CRM_AccountGroupDeletionHandler.TO_DELETE_STATUS;
        }
        update accountGroups;

        Test.startTest();
        Boolean receiveExpectedErrorMessage = false;
        try {
            delete accountGroups;
        } catch (Exception e) {
            receiveExpectedErrorMessage = e.getMessage().containsIgnoreCase(EUR_CRM_AccountGroupDeletionHandler.CANNOT_BE_DELETED);
        }

        System.assertEquals(true, receiveExpectedErrorMessage);
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(COUNT_OF_RECORDS * COUNT_OF_RECORDS, accountGroups.size());
    }

    @IsTest
    private static void cannotDeleteRecordsMarkedToDeleteAndWithCheckedAllowDeletionTest() {
        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            accountGroup.EUR_CRM_Status__c = EUR_CRM_AccountGroupDeletionHandler.TO_DELETE_STATUS;
            accountGroup.EUR_CRM_AllowDeletion__c = true;
        }
        update accountGroups;

        Test.startTest();
        delete accountGroups;
        Test.stopTest();

        accountGroups = selectAccountGroups();
        System.assertEquals(0, accountGroups.size());
    }

    @IsTest
    private static void deleteAccounts() {
        List<EUR_CRM_Account__c> accounts = selectAccounts();

        Test.startTest();
            delete accounts;
        Test.stopTest();

        accounts = selectAccounts();
        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(0, accounts.size());
        System.assertEquals(0, accountGroups.size());
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

}