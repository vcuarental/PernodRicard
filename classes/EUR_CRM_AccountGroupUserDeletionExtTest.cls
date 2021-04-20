@IsTest (IsParallel = true)
private class EUR_CRM_AccountGroupUserDeletionExtTest {

    @TestSetup
    private static void testSetup() {
        EUR_CRM_Account__c account =  makeAccount('Test Account');
        insert account;

        EUR_CRM_AccountGroup__c accountGroup = makeAccountGroup(account.Id);
        insert accountGroup;

        EUR_CRM_AccountGroupUser__c accountGroupUser = makeAccountGroupUser(accountGroup.Id);
        insert accountGroupUser;
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());

        List<EUR_CRM_AccountGroup__c> accountGroups = selectAccountGroups();
        System.assertEquals(1, accountGroups.size());

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = selectAccountGroupUsers();
        System.assertEquals(1, accountGroupUsers.size());
        Test.stopTest();
    }

    @IsTest
    private static void cannotDeleteRecordTest() {
        EUR_CRM_AccountGroupUser__c accountGroupUser = selectAccountGroupUsers()[0];

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupUserDeletion);
        ApexPages.StandardController standardController = new ApexPages.StandardController(accountGroupUser);
        EUR_CRM_AccountGroupUserDeletionExt extension = new EUR_CRM_AccountGroupUserDeletionExt(standardController);

        System.assertEquals(EUR_CRM_AccountGroupUserDeletionExt.CANNOT_DELETE_RECORD_MANUALLY, extension.message);
        Test.stopTest();
    }

    @IsTest
    private static void alreadyMarkedToDeleteTest() {
        EUR_CRM_AccountGroupUser__c accountGroupUser = selectAccountGroupUsers()[0];
        accountGroupUser.EUR_CRM_Status__c = EUR_CRM_AccountGroupUserDeletionExt.TO_DELETE_STATUS;
        update accountGroupUser;

        Test.startTest();
        Test.setCurrentPageReference(Page.EUR_CRM_AccountGroupUserDeletion);
        ApexPages.StandardController standardController = new ApexPages.StandardController(accountGroupUser);
        EUR_CRM_AccountGroupUserDeletionExt extension = new EUR_CRM_AccountGroupUserDeletionExt(standardController);

        System.assertEquals(EUR_CRM_AccountGroupUserDeletionExt.RECORD_ALREADY_MARKED, extension.message);
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
            FROM EUR_CRM_AccountGroup__c
        ];
    }

    private static List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsers() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_AccountGroupUser__c
        ];
    }

}