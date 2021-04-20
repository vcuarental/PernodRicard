@IsTest (IsParallel = true)
private class EUR_CRM_ContractAccountMapHandlerTest {

    private static final String CLASS_NAME = 'EUR_CRM_ContractAccountMapHandler';

    private static final Set<String> ALL_VALID_ACCOUNT_RECORD_TYPES = new Set<String> {
        'EUR_FI_Indirect_On_Trade'
        ,   'EUR_FI_Direct_On_Trade'
        ,   'EUR_NL_On_Trade'
    };

    private static final Set<String> VALID_CONTRACT_RECORD_TYPES = new Set<String> {
        'EUR_FI_Chain_Contract'
        ,   'EUR_NL_Chain_Contract'
    };

    private static final Map<String, String> CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES = new Map<String, String> {
        'EUR_FI_Indirect_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
        ,   'EUR_FI_Direct_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
        ,   'EUR_NL_On_Trade' => 'EUR_NL_Contract_Account_Mapping'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest
            .add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'ALL_VALID_ACCOUNT_RECORD_TYPES', ALL_VALID_ACCOUNT_RECORD_TYPES));

        EUR_CRM_RecordTypeHelper_v2.rtListsForTest
            .add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'VALID_CONTRACT_RECORD_TYPES', VALID_CONTRACT_RECORD_TYPES));

        EUR_CRM_RecordTypeHelper_v2.rtMapsForTest
            .addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(CLASS_NAME, 'CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES', CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES));
    }

    @TestSetup
    private static void setupMethod() {
        Test.startTest();
        EUR_CRM_Account__c headAccount = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.HEAD_OFFICE);
        headAccount.Name = 'Head Office';
        insert headAccount;
        Test.stopTest();

        EUR_CRM_Account__c account = makeAccount('EUR_FI_Indirect_On_Trade', EUR_CRM_AccountContractMapHandler.OUTLET);
        account.EUR_CRM_Parent_Account__c = headAccount.Id;
        insert account;
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        EUR_CRM_Account__c account = selectHeadAccount();
        System.assertNotEquals(null, account);

        System.assertEquals(1, account.Accounts__r.size());

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
        Test.stopTest();
    }


    @IsTest
    private static void update_EUR_FI_Chain_Contract_PositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();
        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', headAccount.Id);
        insert contract;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        contract.EUR_CRM_Status__c = 'Activated';
        update contract;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(headAccount.Accounts__r[0].Id, contractAccountMappings[0].EUR_CRM_Account__c);
        Test.stopTest();
    }

    @IsTest
    private static void update_EUR_NL_Chain_Contract_PositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();
        EUR_CRM_Contract__c contract = makeContract('EUR_NL_Chain_Contract', headAccount.Id);
        insert contract;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        contract.EUR_CRM_Status__c = 'Activated';
        update contract;
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.debug('\n accounts.size() => ' + accounts.size() + '\n');
        System.debug('\n accounts => ' + JSON.serializePretty(accounts) + '\n');
        System.assertEquals(2, accounts.size());
        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.debug('\n contractAccountMappings.size() => ' + contractAccountMappings.size() + '\n');
        System.debug('\n contractAccountMappings => ' + JSON.serializePretty(contractAccountMappings) + '\n');
        System.assertEquals(1, contractAccountMappings.size());
        System.assertEquals(headAccount.Accounts__r[0].Id, contractAccountMappings[0].EUR_CRM_Account__c);
        Test.stopTest();
    }

    @IsTest
    private static void update_EUR_FI_Chain_Contract_WrongStatusNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c headAccount = selectHeadAccount();
        EUR_CRM_Contract__c contract = makeContract('EUR_FI_Chain_Contract', headAccount.Id);
        insert contract;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsBefore = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappingsBefore.size());

        contract.EUR_CRM_Status__c = 'Deactivated';
        update contract;

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappings = selectContractAccountMappings();
        System.assertEquals(0, contractAccountMappings.size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rtDevName, String businessType) {
        return new EUR_CRM_Account__c(
            RecordTypeId = selectRTId('EUR_CRM_Account__c', rtDevName)
        ,   Name = 'Test Account'
        ,   EUR_CRM_Business_Type__c = businessType
        ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static EUR_CRM_Contract__c makeContract(String rtDevName, Id accId) {
        return new EUR_CRM_Contract__c(
            RecordTypeId = selectRTId('EUR_CRM_Contract__c', rtDevName)
        ,   EUR_CRM_Account__c = accId
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
            ,   (
                SELECT Id
                FROM Accounts__r
            )
            FROM EUR_CRM_Account__c
            WHERE EUR_CRM_Business_Type__c = :EUR_CRM_AccountContractMapHandler.HEAD_OFFICE
            LIMIT 1
        ][0];
    }

    private static Id selectRTId(String sObjectName, String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = :sObjectName
                AND DeveloperName = :devName
            LIMIT 1
        ][0].Id;
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

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
        ];
    }

}