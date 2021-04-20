@IsTest (IsParallel = true)
private class EUR_CRM_AccountContractMapHandlerTest {

    private static final String CLASS_NAME = 'EUR_CRM_AccountContractMapHandler';


    private static final Set<String> ALL_VALID_ACCOUNT_RECORD_TYPES = new Set<String> {
        'EUR_FI_Indirect_On_Trade'
        ,   'EUR_FI_Direct_On_Trade'
        ,   'EUR_NL_On_Trade'
    };

    private static final Set<String> ALL_VALID_CONTRACT_RECORD_TYPES = new Set<String> {
        'EUR_FI_Chain_Contract'
        ,   'EUR_NL_Chain_Contract'
    };

    private static final Map<String, String> CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES = new Map<String, String> {
        'EUR_FI_Indirect_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
        ,   'EUR_FI_Direct_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
        ,   'EUR_NL_On_Trade' => 'EUR_NL_Contract_Account_Mapping'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(
            EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'ALL_VALID_ACCOUNT_RECORD_TYPES', ALL_VALID_ACCOUNT_RECORD_TYPES));

        EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(
            EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'ALL_VALID_CONTRACT_RECORD_TYPES', ALL_VALID_CONTRACT_RECORD_TYPES));

        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(
            EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(CLASS_NAME, 'CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES', CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES));

    }


    @TestSetup
    private static void setupMethod() {


        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
        account.Name = 'Head Office';
        insert account;

        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', account.Id);
        insert contract;
    }

    @IsTest
    private static void setupTest() {
        EUR_CRM_Account__c account = selectHeadAccount();
        System.assertNotEquals(null, account);

        System.assertEquals(1, account.Contracts__r.size());

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }


    /* ========================================================= */
    /*     Start Insert Tests
    /* ========================================================= */
    @IsTest
    private static void insert_EUR_FI_Direct_On_Trade_OutletAccountPositiveTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
    }

    @IsTest
    private static void insert_EUR_FI_Indirect_On_Trade_OutletAccountPositiveTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
    }

    @IsTest
    private static void insert_EUR_FI_Direct_On_Trade_HeadOfficeAccountNegativeTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void insert_EUR_FI_Indirect_On_Trade_HeadOfficeAccountNegativeTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void insert_EUR_FI_Direct_Off_Trade_OutletAccountNegativeTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void insert_EUR_FI_Indirect_Off_Trade_OutletAccountNegativeTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void insert_EUR_NL_On_Trade_OutletAccountPositiveTest() {
        initCMT();

        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;

        Test.startTest();
        insert account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
    }
    /* ========================================================= */
    /*     End Insert Tests
    /* ========================================================= */


    /* ========================================================= */
    /*     Start Update Tests
    /* ========================================================= */
    @IsTest
    private static void update_EUR_FI_Direct_On_Trade_OutletAccountSetParentPositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
    }

    @IsTest
    private static void update_EUR_FI_Indirect_On_Trade_OutletAccountSetParentPositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
    }

    @IsTest
    private static void update_EUR_FI_Direct_On_Trade_HeadOfficeAccountSetParentNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_FI_Indirect_On_Trade_HeadOfficeAccountSetParentNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_FI_Direct_Off_Trade_OutletAccountSetParentNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_FI_Indirect_Off_Trade_OutletAccountSetParentNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_NL_On_Trade_OutletAccountSetParentPositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
    }



//    @IsTest
//    private static void update_EUR_FI_Direct_On_Trade_OutletAccountParentWithoutContractPositiveTest() {
//        Test.startTest();
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappingsBefore.size());
//        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Indirect_On_Trade_OutletAccountParentWithoutContractPositiveTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappingsBefore.size());
//        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Direct_On_Trade_HeadOfficeAccountParentWithoutContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Indirect_On_Trade_HeadOfficeAccountParentWithoutContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Direct_Off_Trade_OutletAccountParentWithoutContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Indirect_Off_Trade_OutletAccountParentWithoutContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_NL_On_Trade_OutletAccountParentWithoutContractPositiveTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappingsBefore.size());
//        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//
//
//    @IsTest
//    private static void update_EUR_FI_Direct_On_Trade_OutletAccountParentWithContractPositiveTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappingsBefore.size());
//        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappings.size());
//        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
//        System.assertEquals(contract.Id, contractAccountMappings[0].EUR_CRM_Contract__c);
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Indirect_On_Trade_OutletAccountParentWithContractPositiveTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappingsBefore.size());
//        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappings.size());
//        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
//        System.assertEquals(contract.Id, contractAccountMappings[0].EUR_CRM_Contract__c);
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Direct_On_Trade_HeadOfficeAccountParentWithContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Indirect_On_Trade_HeadOfficeAccountParentWithContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Direct_Off_Trade_OutletAccountParentWithContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Direct_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_FI_Indirect_Off_Trade_OutletAccountParentWithContractNegativeTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappingsBefore.size());
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(0, contractAccountMappings.size());
//    }
//
//    @IsTest
//    private static void update_EUR_NL_On_Trade_OutletAccountParentWithContractPositiveTest() {
//        EUR_CRM_Account__c headAccount = selectHeadAccount();
//
//        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
//        account.EUR_CRM_Parent_Account__c = headAccount.Id;
//        insert account;
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappingsBefore.size());
//        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);
//
//        Test.startTest();
//        EUR_CRM_Account__c newHeadAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
//        insert newHeadAccount;
//
//        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', newHeadAccount.Id);
//        insert contract;
//
//        account.EUR_CRM_Parent_Account__c = newHeadAccount.Id;
//        update account;
//        Test.stopTest();
//
//        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
//        System.assertEquals(1, contractAccountMappings.size());
//        System.assertEquals(account.Id, contractAccountMappings[0].EUR_CRM_Account__c);
//        System.assertEquals(contract.Id, contractAccountMappings[0].EUR_CRM_Contract__c);
//    }



    @IsTest
    private static void update_EUR_FI_Direct_On_Trade_OutletAccountToHeadOfficePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappingsBefore.size());
        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);

        account.EUR_CRM_Business_Type__c = EUR_CRM_AccountContractMapHandler.HEAD_OFFICE;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_FI_Indirect_On_Trade_OutletAccountToHeadOfficePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappingsBefore.size());
        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);

        account.EUR_CRM_Business_Type__c = EUR_CRM_AccountContractMapHandler.HEAD_OFFICE;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_FI_Direct_Off_Trade_OutletAccountToHeadOfficeNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Business_Type__c = EUR_CRM_AccountContractMapHandler.HEAD_OFFICE;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_FI_Indirect_Off_Trade_OutletAccountToHeadOfficeNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Business_Type__c = EUR_CRM_AccountContractMapHandler.HEAD_OFFICE;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void update_EUR_NL_On_Trade_OutletAccountToHeadOfficePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappingsBefore.size());
        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);

        account.EUR_CRM_Business_Type__c = EUR_CRM_AccountContractMapHandler.HEAD_OFFICE;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }


    @IsTest
    private static void EUR_FI_Direct_On_Trade_OutletAccountRemoveLinkToParentAccountPositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappingsBefore.size());
        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);

        account.EUR_CRM_Parent_Account__c = null;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void EUR_FI_Indirect_On_Trade_OutletAccountRemoveLinkToParentAccountPositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappingsBefore.size());
        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);

        account.EUR_CRM_Parent_Account__c = null;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void EUR_FI_Direct_Off_Trade_OutletAccountRemoveLinkToParentAccountNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = null;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void EUR_FI_Indirect_Off_Trade_OutletAccountRemoveLinkToParentAccountNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_Off_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        account.EUR_CRM_Parent_Account__c = null;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }

    @IsTest
    private static void EUR_NL_On_Trade_OutletAccountRemoveLinkToParentAccountPositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();

        EUR_CRM_Account__c account = makeAccount('EUR_NL_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappingsBefore.size());
        System.assertEquals(account.Id, contractAccountMappingsBefore[0].EUR_CRM_Account__c);

        account.EUR_CRM_Parent_Account__c = null;
        update account;
        Test.stopTest();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
    }
    /* ========================================================= */
    /*     End Update Tests
    /* ========================================================= */


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rtDevName, String businessType) {
        return new EUR_CRM_Account__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId()
        ,   Name = 'Test Account'
        ,   EUR_CRM_Business_Type__c = businessType
        ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static EUR_CRM_Contract__c makeContract(String rtDevName, Id accId) {
        return new EUR_CRM_Contract__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId()
        ,   EUR_CRM_Account__c = accId
        ,   EUR_CRM_Status__c = 'Activated'
        );
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static EUR_CRM_Account__c selectHeadAccount() {
        return [
            SELECT Id
            ,   (
                SELECT Id
                FROM Contracts__r
            )
            FROM EUR_CRM_Account__c
            WHERE EUR_CRM_Business_Type__c = :EUR_CRM_AccountContractMapHandler.HEAD_OFFICE
            LIMIT 1
        ][0];
    }

    private static List<EUR_CRM_Contract_Account_Mapping__c> selectContractAccountMappings() {
        return [
            SELECT Id
            ,   EUR_CRM_Account__c
            ,   EUR_CRM_Contract__c
            ,   EUR_CRM_Active__c
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Contract_Account_Mapping__c
        ];
    }

}