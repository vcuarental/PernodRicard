@IsTest
private class EUR_CRM_SalesOrderApprovalProcessRunnerT {

    private static final Integer COUNT_OF_RECORDS = 5;

    private static final String CLASS_NAME = 'EUR_CRM_SalesOrderApprovalProcessRunner';

    private static final Set<String> VALID_SO_RT = new Set<String> {
        'EUR_Free_Goods_to_Customer'
    ,   'EUR_Free_Goods_to_Stock'
    };

    private static final Set<String> VALID_SO_COUNTRY_CODES = new Set<String> {
        'DE'
    ,   'AT'
    };

    private static void initCMT() {
        EUR_CRM_RecordTypeHelper_v2.rtListsForTest
            .add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'VALID_SO_RT', VALID_SO_RT));

        EUR_CRM_RecordTypeHelper_v2.rtListsForTest
            .add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest(CLASS_NAME, 'VALID_SO_COUNTRY_CODES', VALID_SO_COUNTRY_CODES));


    }

    @TestSetup
    private static void setupMethod() {
        EUR_CRM_Account__c account = makeAccount();
        insert account;

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
    /*     Before Update Context for EUR_Free_Goods_to_Customer RT
    /* ========================================================= */
    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_ZeroSpecifiedChildren_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        salesOrder.EUR_CRM_NumberOfLines__c = 0;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(salesOrders[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_ZeroSpecifiedChildren_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            salesOrder.EUR_CRM_NumberOfLines__c = 0;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(salesOrders[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_EmptySpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrders[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_EmptySpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrder.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

//    @IsTest
//    private static void EUR_Free_Goods_to_Customer_WaitingForSync_NonEmptySpecifiedChildren_SinglePositiveTest() {
//        Test.startTest();
//        EUR_CRM_Account__c account = selectAccount();
//
//        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
//        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
//        insert salesOrder;
//
//        EUR_CRM_Sales_Order_Items__c salesOrderActivityItem = makeSalesOrderActivityItem(salesOrder.Id);
//        insert salesOrderActivityItem;
//
//        System.assertEquals(0, selectProcessInstances().size());
//
//        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
//        salesOrder.EUR_CRM_NumberOfLines__c = 1;
//        update salesOrder;
//        Test.stopTest();
//
//        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
//        System.assertEquals(1, salesOrders.size());
//
//        List<ProcessInstance> processInstances = selectProcessInstances();
//        System.assertEquals(1, processInstances.size());
//
//        System.assertEquals(salesOrders[0].Id, processInstances[0].TargetObjectId);
//    }

//    @IsTest
//    private static void EUR_Free_Goods_to_Customer_WaitingForSync_NonEmptySpecifiedChildren_MultiplePositiveTest() {
//        Test.startTest();
//        EUR_CRM_Account__c account = selectAccount();
//
//        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
//        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
//        insert salesOrdersToInsert;
//
//        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = makeContractActivityItems(salesOrdersToInsert);
//        insert salesOrderActivityItems;
//
//        System.assertEquals(0, selectProcessInstances().size());
//
//        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
//            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
//            salesOrder.EUR_CRM_NumberOfLines__c = COUNT_OF_RECORDS;
//        }
//        update salesOrdersToInsert;
//        Test.stopTest();
//
//        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
//        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
//
//        List<ProcessInstance> processInstances = selectProcessInstances();
//        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());
//
//        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//            System.assertEquals(salesOrders[i].Id, processInstances[i].TargetObjectId);
//        }
//    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_EmptySpecifiedChildrenButChildrenExist_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        EUR_CRM_Sales_Order_Items__c salesOrderActivityItem = makeSalesOrderActivityItem(salesOrder.Id);
        insert salesOrderActivityItem;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrders[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_EmptySpecifiedChildrenButChildrenExist_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = makeContractActivityItems(salesOrdersToInsert);
        insert salesOrderActivityItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrder.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        EUR_CRM_Sales_Order_Items__c salesOrderActivityItem = makeSalesOrderActivityItem(salesOrder.Id);
        insert salesOrderActivityItem;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        salesOrder.EUR_CRM_NumberOfLines__c = 10;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrders[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = makeContractActivityItems(salesOrdersToInsert);
        insert salesOrderActivityItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            salesOrder.EUR_CRM_NumberOfLines__c = 10;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrder.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     After Update Context for EUR_Free_Goods_to_Customer RT
    /* ========================================================= */
    @IsTest
    private static void EUR_Free_Goods_to_Customer_InstantValidated_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_INSTANT_VALIDATION;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(salesOrders[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_InstantValidated_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_INSTANT_VALIDATION;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(salesOrders[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_PendingForApproval_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = 'Pending for approval';
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Customer_PendingForApproval_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Customer').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = 'Pending for approval';
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     Before Update Context for EUR_Free_Goods_to_Stock RT
    /* ========================================================= */
    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_ZeroSpecifiedChildren_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        salesOrder.EUR_CRM_NumberOfLines__c = 0;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(salesOrders[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_ZeroSpecifiedChildren_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            salesOrder.EUR_CRM_NumberOfLines__c = 0;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(salesOrders[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_EmptySpecifiedChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrders[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_EmptySpecifiedChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrder.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

//    @IsTest
//    private static void EUR_Free_Goods_to_Stock_WaitingForSync_NonEmptySpecifiedChildren_SinglePositiveTest() {
//        Test.startTest();
//        EUR_CRM_Account__c account = selectAccount();
//
//        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
//        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
//        insert salesOrder;
//
//        EUR_CRM_Sales_Order_Items__c salesOrderActivityItem = makeSalesOrderActivityItem(salesOrder.Id);
//        insert salesOrderActivityItem;
//
//        System.assertEquals(0, selectProcessInstances().size());
//
//        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
//        salesOrder.EUR_CRM_NumberOfLines__c = 1;
//        update salesOrder;
//        Test.stopTest();
//
//        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
//        System.assertEquals(1, salesOrders.size());
//
//        List<ProcessInstance> processInstances = selectProcessInstances();
//        System.assertEquals(1, processInstances.size());
//
//        System.assertEquals(salesOrders[0].Id, processInstances[0].TargetObjectId);
//    }

//    @IsTest
//    private static void EUR_Free_Goods_to_Stock_WaitingForSync_NonEmptySpecifiedChildren_MultiplePositiveTest() {
//        Test.startTest();
//        EUR_CRM_Account__c account = selectAccount();
//
//        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
//        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
//        insert salesOrdersToInsert;
//
//        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = makeContractActivityItems(salesOrdersToInsert);
//        insert salesOrderActivityItems;
//
//        System.assertEquals(0, selectProcessInstances().size());
//
//        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
//            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
//            salesOrder.EUR_CRM_NumberOfLines__c = COUNT_OF_RECORDS;
//        }
//        update salesOrdersToInsert;
//        Test.stopTest();
//
//        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
//        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
//
//        List<ProcessInstance> processInstances = selectProcessInstances();
//        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());
//
//        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
//            System.assertEquals(salesOrders[i].Id, processInstances[i].TargetObjectId);
//        }
//    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_EmptySpecifiedChildrenButChildrenExist_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        EUR_CRM_Sales_Order_Items__c salesOrderActivityItem = makeSalesOrderActivityItem(salesOrder.Id);
        insert salesOrderActivityItem;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrders[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_EmptySpecifiedChildrenButChildrenExist_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = makeContractActivityItems(salesOrdersToInsert);
        insert salesOrderActivityItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrder.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        EUR_CRM_Sales_Order_Items__c salesOrderActivityItem = makeSalesOrderActivityItem(salesOrder.Id);
        insert salesOrderActivityItem;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
        salesOrder.EUR_CRM_NumberOfLines__c = 10;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());
        System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrders[0].EUR_CRM_Status__c);

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_WaitingForSync_NonEmptySpecifiedWrongNumberOfChildren_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = makeContractActivityItems(salesOrdersToInsert);
        insert salesOrderActivityItems;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC;
            salesOrder.EUR_CRM_NumberOfLines__c = 10;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            System.assertEquals(EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_WAITING_FOR_SYNC, salesOrder.EUR_CRM_Status__c);
        }

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     After Update Context for EUR_Free_Goods_to_Stock RT
    /* ========================================================= */
    @IsTest
    private static void EUR_Free_Goods_to_Stock_InstantValidated_SinglePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_INSTANT_VALIDATION;
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(1, processInstances.size());

        System.assertEquals(salesOrders[0].Id, processInstances[0].TargetObjectId);
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_InstantValidated_MultiplePositiveTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = EUR_CRM_SalesOrderApprovalProcessRunner.STATUS_INSTANT_VALIDATION;
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(COUNT_OF_RECORDS, processInstances.size());

        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            System.assertEquals(salesOrders[i].Id, processInstances[i].TargetObjectId);
        }
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_PendingForApproval_SingleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        EUR_CRM_Sales_Order__c salesOrder = makeSalesOrder(account.Id, rtId, 'On hold');
        insert salesOrder;

        System.assertEquals(0, selectProcessInstances().size());

        salesOrder.EUR_CRM_Status__c = 'Pending for approval';
        update salesOrder;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(1, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }

    @IsTest
    private static void EUR_Free_Goods_to_Stock_PendingForApproval_MultipleNegativeTest() {
        initCMT();

        Test.startTest();
        EUR_CRM_Account__c account = selectAccount();

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get('EUR_Free_Goods_to_Stock').getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> salesOrdersToInsert = makeContracts(account.Id, rtId, 'On hold');
        insert salesOrdersToInsert;

        System.assertEquals(0, selectProcessInstances().size());

        for (EUR_CRM_Sales_Order__c salesOrder : salesOrdersToInsert) {
            salesOrder.EUR_CRM_Status__c = 'Pending for approval';
        }
        update salesOrdersToInsert;
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> salesOrders = selectContracts();
        System.assertEquals(COUNT_OF_RECORDS, salesOrders.size());

        List<ProcessInstance> processInstances = selectProcessInstances();
        System.assertEquals(0, processInstances.size());
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Sales_Order__c> makeContracts(Id accId, Id rtId, String status) {
        List<EUR_CRM_Sales_Order__c> salesOrders = new List<EUR_CRM_Sales_Order__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            salesOrders.add(makeSalesOrder(accId, rtId, status));
        }
        return salesOrders;
    }

    private static List<EUR_CRM_Sales_Order_Items__c> makeContractActivityItems(List<EUR_CRM_Sales_Order__c> salesOrders) {
        List<EUR_CRM_Sales_Order_Items__c> salesOrderActivityItems = new List<EUR_CRM_Sales_Order_Items__c>();
        for (EUR_CRM_Sales_Order__c salesOrder : salesOrders) {
            for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
                salesOrderActivityItems.add(makeSalesOrderActivityItem(salesOrder.Id));
            }
        }
        return salesOrderActivityItems;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Postal_Code__c = '112233'
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
    }

    private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accId, Id rtId, String status) {
        return new EUR_CRM_Sales_Order__c(
            EUR_CRM_Account__c = accId
        ,   RecordTypeId = rtId
        ,   EUR_CRM_Status__c = status
        );
    }

    private static EUR_CRM_Sales_Order_Items__c makeSalesOrderActivityItem(Id salesOrderId) {
        return new EUR_CRM_Sales_Order_Items__c(
            EUR_CRM_Sales_Order__c = salesOrderId
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

    private static List<EUR_CRM_Sales_Order__c> selectContracts() {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_Sales_Order__c
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