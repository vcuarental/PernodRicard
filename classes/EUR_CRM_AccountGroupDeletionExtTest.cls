@IsTest (IsParallel = true)
private class EUR_CRM_AccountGroupDeletionExtTest {

    @TestSetup
    private static void testSetup() {
        EUR_CRM_Account__c account = makeAccount('Test Account');
        insert account;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(account.Id);
        insert accountGroup;
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(1, accountGroups.size());
        Test.stopTest();
    }

    @IsTest
    private static void cannotDeleteRecordTest() {
        EUR_CRM_AccountGroup__c accountGroup = selectAccountGroups()[0];

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupDeletion);
        ApexPages.StandardController standardController = new ApexPages.StandardController(accountGroup);
        EUR_CRM_AccountGroupDeletionExt extension = new EUR_CRM_AccountGroupDeletionExt(standardController);

        System.assertEquals(EUR_CRM_AccountGroupDeletionExt.CANNOT_DELETE_RECORD_MANUALLY, extension.message);
        Test.stopTest();
    }

    @IsTest
    private static void alreadyMarkedToDeleteTest() {
        EUR_CRM_AccountGroup__c accountGroup = selectAccountGroups()[0];
        accountGroup.EUR_CRM_Status__c = EUR_CRM_AccountGroupDeletionExt.TO_DELETE_STATUS;
        update accountGroup;

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupDeletion);
        ApexPages.StandardController standardController = new ApexPages.StandardController(accountGroup);
        EUR_CRM_AccountGroupDeletionExt extension = new EUR_CRM_AccountGroupDeletionExt(standardController);

        System.assertEquals(EUR_CRM_AccountGroupDeletionExt.RECORD_ALREADY_MARKED, extension.message);
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Makers
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
            FROM EUR_CRM_AccountGroup__c
        ];
    }

}