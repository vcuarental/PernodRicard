@IsTest
private class EUR_CRM_ContractApprovalProcessRunnerTes {

    private static final String CLASS_NAME = 'EUR_CRM_ContractApprovalProcessRunner';

    private static final Set<String> VALID_RT = new Set<String> {
        'EUR_NL_Chain_Contract'
        ,   'EUR_NL_Independant_Contract'
        ,   'EUR_DE_Contract'
        ,   'EUR_FI_Chain_Contract'
        ,   'EUR_FI_Independent_Contract'
    };

    private static final Map<Object, Map<Object, Object>> VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME = new Map<Object, Map<Object, Object>> {
        'EUR_DE_Contract' => new Map<Object, Object> { 'EUR_CRM_Has_Budget__c' => true }
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest
            .add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'VALID_RT', VALID_RT));

        EUR_CRM_RecordTypeHelper_v2.rtMultilevelMapsForTest
            .addAll(EUR_CRM_RecordTypeHelper_v2.makeMultilevelMapsForTest(CLASS_NAME, 'VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME', VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME));
    }

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


    /* ========================================================= */
    /*     Before Update Context for EUR_NL_Chain_Contract RT
    /* ========================================================= */
    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_EmptySpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 0;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());

//        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_EmptySpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = 1;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());

//        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
//        }
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_EmptyNotSpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_EmptyNotSpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_NonEmptySpecifiedChildren_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 1;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_NonEmptySpecifiedChildren_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = COUNT_OF_RECORDS * COUNT_OF_RECORDS;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_NonEmptyNotSpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_NonEmptyNotSpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 10;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = 10;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     After Update Context for EUR_NL_Chain_Contract RT
    /* ========================================================= */
    @IsTest
    private static void EUR_NL_Chain_Contract_Submitted_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_N_of_child_records__c = 1;
        insert contract;

        EUR_CRM_Contract_Activity_Item__c caItem = makeContractActivityItem(contract.Id);
        insert caItem;

        EUR_CRM_Contract_Product_Item__c cpItem = makeContractProductItem(caItem.Id);
        insert cpItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_Submitted_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> caItems = makeContractActivityItems(contractsToInsert);
        insert caItems;

        List<EUR_CRM_Contract_Product_Item__c> cpItems = makeContractProductItems(caItems);
        insert cpItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED;
            contract.EUR_CRM_N_of_child_records__c = COUNT_OF_RECORDS * COUNT_OF_RECORDS;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_ProposalApproved_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = 'Proposal Approved';
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Chain_Contract_ProposalApproved_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Chain_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = 'Proposal Approved';
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     Before Update Context for EUR_NL_Independant_Contract RT
    /* ========================================================= */
    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_EmptySpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 0;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());

//        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_EmptySpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = 0;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());

//        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
//        }
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_EmptyNotSpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_EmptyNotSpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_NonEmptySpecifiedChildren_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 1;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_NonEmptySpecifiedChildren_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = COUNT_OF_RECORDS * COUNT_OF_RECORDS;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_NonEmptyNotSpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_NonEmptyNotSpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 10;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = 10;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     After Update Context for EUR_NL_Independant_Contract RT
    /* ========================================================= */
    @IsTest
    private static void EUR_NL_Independant_Contract_Submitted_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_N_of_child_records__c = 1;
        insert contract;

        EUR_CRM_Contract_Activity_Item__c caItem = makeContractActivityItem(contract.Id);
        insert caItem;

        EUR_CRM_Contract_Product_Item__c cpItem = makeContractProductItem(caItem.Id);
        insert cpItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_Submitted_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> caItems = makeContractActivityItems(contractsToInsert);
        insert caItems;

        List<EUR_CRM_Contract_Product_Item__c> cpItems = makeContractProductItems(caItems);
        insert cpItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED;
            contract.EUR_CRM_N_of_child_records__c = COUNT_OF_RECORDS * COUNT_OF_RECORDS;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_ProposalApproved_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = 'Proposal Approved';
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_NL_Independant_Contract_ProposalApproved_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_Independant_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = 'Proposal Approved';
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     Before Update Context for EUR_DE_Contract RT
    /* ========================================================= */
    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_EmptySpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        EUR_CRM_Budget__c budget = makeBudget();
        insert budget;

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_Budget__c = budget.Id;
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        contractActivityItem.EUR_CRM_Amount__c = 1000;
        insert contractActivityItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 0;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());

//        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_EmptySpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        EUR_CRM_Budget__c budget = makeBudget();
        insert budget;

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Budget__c = budget.Id;
        }
        insert contractsToInsert;

        List<EUR_CRM_Contract__c> contractsBefore = [SELECT Id, EUR_CRM_Status__c, EUR_CRM_N_of_child_records__c FROM EUR_CRM_Contract__c];

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = 0;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());

//        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
//        }
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_EmptyNotSpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update contractsToInsert;
        Test.stopTest();

        System.debug('\n contractsToInsert.size() => ' + contractsToInsert.size() + '\n');
        System.debug('\n contractsToInsert => ' + JSON.serializePretty(contractsToInsert) + '\n');
        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.debug('\n contracts.size() => ' + contracts.size() + '\n');
        System.debug('\n contracts => ' + JSON.serializePretty(contracts) + '\n');
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_NonEmptySpecifiedChildren_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        EUR_CRM_Budget__c budget = makeBudget();
        insert budget;

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_Budget__c = budget.Id;
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 1;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_NonEmptySpecifiedChildren_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        EUR_CRM_Budget__c budget = makeBudget();
        insert budget;

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Budget__c = budget.Id;
        }
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = COUNT_OF_RECORDS * COUNT_OF_RECORDS;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_NonEmptyNotSpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_NonEmptyNotSpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        EUR_CRM_Contract_Activity_Item__c contractActivityItem = makeContractActivityItem(contract.Id);
        insert contractActivityItem;

        EUR_CRM_Contract_Product_Item__c contractProductItem = makeContractProductItem(contractActivityItem.Id);
        insert contractProductItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        contract.EUR_CRM_N_of_child_records__c = 10;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());
        System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contracts[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_DE_Contract_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = makeContractActivityItems(contractsToInsert);
        insert contractActivityItems;

        List<EUR_CRM_Contract_Product_Item__c> contractProductItems = makeContractProductItems(contractActivityItems);
        insert contractProductItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            contract.EUR_CRM_N_of_child_records__c = 10;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());
        for (EUR_CRM_Contract__c contract : contracts) {
            System.assertEquals(EUR_CRM_ContractApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, contract.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     After Update Context for EUR_DE_Contract RT
    /* ========================================================= */
    @IsTest
    private static void EUR_DE_Contract_Submitted_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        EUR_CRM_Budget__c budget = makeBudget();
        insert budget;

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        contract.EUR_CRM_Budget__c = budget.Id;
        contract.EUR_CRM_N_of_child_records__c = 1;
        insert contract;

        EUR_CRM_Contract_Activity_Item__c caItem = makeContractActivityItem(contract.Id);
        insert caItem;

        EUR_CRM_Contract_Product_Item__c cpItem = makeContractProductItem(caItem.Id);
        insert cpItem;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED;
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(contracts[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_DE_Contract_Submitted_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        EUR_CRM_Budget__c budget = makeBudget();
        insert budget;

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Budget__c = budget.Id;
            contract.EUR_CRM_N_of_child_records__c = COUNT_OF_RECORDS * COUNT_OF_RECORDS;
        }
        insert contractsToInsert;

        List<EUR_CRM_Contract_Activity_Item__c> caItems = makeContractActivityItems(contractsToInsert);
        insert caItems;

        List<EUR_CRM_Contract_Product_Item__c> cpItems = makeContractProductItems(caItems);
        insert cpItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = EUR_CRM_ContractApprovalProcessRunner.STATUS_SUBMITTED;
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(contracts[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_DE_Contract_ProposalApproved_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        EUR_CRM_Contract__c contract = makeContract(account.Id, rtId, 'Draft');
        insert contract;

        System.assertEquals(0, selectProcessInstances().size());

        contract.EUR_CRM_Status__c = 'Proposal Approved';
        update contract;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(1, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_DE_Contract_ProposalApproved_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract').getRecordTypeId();
        List<EUR_CRM_Contract__c> contractsToInsert = makeContracts(account.Id, rtId, 'Draft');
        insert contractsToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Contract__c contract : contractsToInsert) {
            contract.EUR_CRM_Status__c = 'Proposal Approved';
        }
        update contractsToInsert;
        Test.stopTest();

        List<EUR_CRM_Contract__c> contracts = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, contracts.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
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
            From User
            WHERE Id = :UserInfo.getUserId()
            Limit 1
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

}