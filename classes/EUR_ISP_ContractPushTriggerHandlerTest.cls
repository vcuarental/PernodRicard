@IsTest
private class EUR_ISP_ContractPushTriggerHandlerTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_Account__c account = makeAccount();
        insert account;

        //fixed bug: no manager for approvalProcess
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User usr = new User(LastName = 'testManaget',
            FirstName='test',
            Alias = 'jliv',
            Email = 'jason.liveston@asdf.com',
            Username = 'ContractTest@service.pernod-ricard.com.eursb6pc',
            ProfileId = prfl.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usr;
        User currentUser = selectCurrentUser();
        currentUser.ManagerId = usr.Id;
        update currentUser;
    }

    @IsTest
    private static void setupTest() {
        EUR_CRM_Account__c account = selectAccount();
        System.assertNotEquals(null, account);
        System.assertNotEquals(null, selectCurrentUser().ManagerId);
    }

    @IsTest
    private static void insertZeroChildPositiveTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Activated');
        contract.EUR_CRM_N_of_child_records__c = 0;
        insert contract;
        Test.stopTest();

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
        System.assertEquals(contract.Id, iSpends[0].EUR_ISP_Contract__c);
    }

    @IsTest
    private static void insertNullChildNegativeTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Activated');
        insert contract;
        Test.stopTest();

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
    }

    @IsTest
    private static void insertDraftNegativeTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_N_of_child_records__c = 0;
        insert contract;
        Test.stopTest();

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(0, iSpends.size());
    }

    @IsTest
    private static void updateToZeroChildAndToActivatedStatusPositiveTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(0, iSpends.size());

        contract.EUR_CRM_N_of_child_records__c = 0;
        contract.EUR_CRM_Status__c = 'Activated';
        update contract;
        Test.stopTest();

        iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
        System.assertEquals(contract.Id, iSpends[0].EUR_ISP_Contract__c);
    }

    @IsTest
    private static void updateToZeroChildPositiveTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Activated');
        insert contract;

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());

        contract.EUR_CRM_N_of_child_records__c = 0;
        update contract;
        Test.stopTest();

        iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
        System.assertEquals(contract.Id, iSpends[0].EUR_ISP_Contract__c);
    }

    @IsTest
    private static void updateToActivatedStatusPositiveTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_N_of_child_records__c = 0;
        insert contract;

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(0, iSpends.size());

        contract.EUR_CRM_Status__c = 'Activated';
        update contract;
        Test.stopTest();

        iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
        System.assertEquals(contract.Id, iSpends[0].EUR_ISP_Contract__c);
    }

    @IsTest
    private static void updateToZeroChildAndUpdateToActivatedStatusPositiveTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        contract.EUR_CRM_N_of_child_records__c = 0;
        update contract;

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(0, iSpends.size());

        contract.EUR_CRM_Status__c = 'Activated';
        update contract;
        Test.stopTest();

        iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
        System.assertEquals(contract.Id, iSpends[0].EUR_ISP_Contract__c);
    }

    @IsTest
    private static void updateToActivatedStatusAndUpdateToZeroChildPositiveTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        contract.EUR_CRM_Status__c = 'Activated';
        update contract;

        List<EUR_ISP_Spend__c> iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());

        contract.EUR_CRM_N_of_child_records__c = 0;
        update contract;
        Test.stopTest();

        iSpends = selectISpends();
        System.assertEquals(1, iSpends.size());
        System.assertEquals(contract.Id, iSpends[0].EUR_ISP_Contract__c);
    }



    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Contract__c> makeContracts(Id accId, Id rtId, String status) {
        List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            contracts.add(makeContract(accId, rtId, status));
        }
        return contracts;
    }

    private static List<EUR_CRM_Contract_Activity_Item__c> makeContractActivityItems(List<EUR_CRM_Contract__c> contracts) {
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                contractActivityItems.add(makeContractActivityItem(contract.Id));
            }
        }
        return contractActivityItems;
    }

    private static List<EUR_CRM_Contract_Product_Item__c> makeContractProductItems(List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems) {
        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem : contractActivityItems) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                contractProductItems.add(makeContractProductItem(contractActivityItem.Id));
            }
        }
        return contractProductItems;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_Budget__c makeBudget() {
        return new EUR_CRM_Budget__c();
    }

    private static EUR_CRM_Contract__c makeContract(Id accId, Id rtId, String status) {
        return new EUR_CRM_Contract__c(
            EUR_CRM_Account__c = accId
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Status__c = status
        );
    }

    private static EUR_CRM_Contract_Activity_Item__c makeContractActivityItem(Id contractId) {
        return new EUR_CRM_Contract_Activity_Item__c(
            EUR_CRM_Contract__c = contractId
        );
    }

    private static EUR_CRM_Contract_Product_Item__c makeContractProductItem(Id caiId) {
        return new EUR_CRM_Contract_Product_Item__c(
            EUR_CRM_Contract_Activity_Item__c = caiId
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static EUR_CRM_Account__c selectAccount() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
            LIMIT 1
        ][0];
    }

    private static User selectCurrentUser() {
        return [
            SELECT Id
            ,   ManagerId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ][0];
    }

    private static List<EUR_CRM_Contract__c> selectContracts() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_Contract__c
        ];
    }

    private static List<ProcessInstance> selectProcessInstances() {
        return [
            SELECT Id
            ,   TargetObjectId
            ,   CreatedDate
            FROM ProcessInstance
        ];
    }

    private static List<EUR_ISP_Spend__c> selectISpends() {
        return [
            SELECT Id
            ,   EUR_ISP_Contract__c
            FROM EUR_ISP_Spend__c
        ];
    }

}