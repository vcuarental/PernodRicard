@IsTest(IsParallel = true)
private class EUR_CRM_SalesOrderAutoNumberTest {

    private static final Integer COUNT_OF_RECORDS = 5;
    private static final String IDL_ON_TRADE_ACC_RT = 'EUR_IDL_On_Trade_Account';
    private static final String DB_ON_TRADE_ACC_RT = 'EUR_DB_On_Trade_Account';
    private static final String NL_ON_TRADE_ACC_RT = 'EUR_NL_On_Trade';
    private static final String EUR_DIRECT = 'EUR_Direct';
    private static final String EUR_INDIRECT = 'EUR_Indirect';

    @TestSetup
    private static void setupMethod() {
        insert new List<EUR_CRM_Account__c> {
            makeAccount(IDL_ON_TRADE_ACC_RT)
        ,   makeAccount(DB_ON_TRADE_ACC_RT)
        ,   makeAccount(NL_ON_TRADE_ACC_RT)
        };
        List<EUR_CRM_SalesOrderAutoNumber__c> autoNumbers = new List<EUR_CRM_SalesOrderAutoNumber__c>();
        autoNumbers.add(makeConfigurations('IDL', EUR_DIRECT, '009000000'));
        autoNumbers.add(makeConfigurations('NL', EUR_DIRECT, '008000000'));
        autoNumbers.add(makeConfigurations('NL', EUR_INDIRECT, '007000000'));
        insert autoNumbers;
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(3, accounts.size());
        Test.stopTest();
    }


    @IsTest
    private static void IDL_DB_OneNumberSequence_WithCustomSettingsPositiveTest() {
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        EUR_CRM_Account__c accountIDL = accounts[0];
        EUR_CRM_Account__c accountDB = accounts[1];
        System.assertEquals(IDL_ON_TRADE_ACC_RT, accountIDL.RecordType.DeveloperName);
        System.assertEquals(DB_ON_TRADE_ACC_RT, accountDB.RecordType.DeveloperName);

        EUR_CRM_Sales_Order__c orderIDL = makeSalesOrder(accountIDL.Id, EUR_DIRECT);
        EUR_CRM_Sales_Order__c orderDB = makeSalesOrder(accountDB.Id, EUR_DIRECT);

        Test.startTest();
        insert new List<EUR_CRM_Sales_Order__c>{ orderIDL, orderDB };
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> insertedSO = selectSalesOrders();
        System.assertEquals('009000002', insertedSO[0].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009000001', insertedSO[1].EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals('009000002', salesOrderAutoNumbers[0].EUR_CRM_LastNumber__c);
    }

    @IsTest
    private static void singleWithoutCustomSettingPositiveTest() {
        deleteConfiguration();

        EUR_CRM_Account__c account = selectAccounts()[0];

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(EUR_DIRECT).getRecordTypeId();
        EUR_CRM_Sales_Order__c order = makeSalesOrder(account.Id, rtId);

        Test.startTest();
        insert order;
        Test.stopTest();

        order = selectSalesOrders()[0];
        System.assertEquals('009295090', order.EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals('009295090', salesOrderAutoNumbers[0].EUR_CRM_LastNumber__c);
    }

    @IsTest
    private static void massivePositiveTest() {
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        EUR_CRM_Account__c accountIDL = accounts[0];
        EUR_CRM_Account__c accountDB = accounts[1];
        EUR_CRM_Account__c accountNL = accounts[2];
        System.assertEquals(IDL_ON_TRADE_ACC_RT, accountIDL.RecordType.DeveloperName);
        System.assertEquals(DB_ON_TRADE_ACC_RT, accountDB.RecordType.DeveloperName);
        System.assertEquals(NL_ON_TRADE_ACC_RT, accountNL.RecordType.DeveloperName);

        EUR_CRM_Sales_Order__c orderIDL_1 = makeSalesOrder(accountIDL.Id, EUR_DIRECT);
        EUR_CRM_Sales_Order__c orderIDL_2 = makeSalesOrder(accountIDL.Id, EUR_DIRECT);
        EUR_CRM_Sales_Order__c orderDB_1 = makeSalesOrder(accountDB.Id, EUR_DIRECT);
        EUR_CRM_Sales_Order__c orderDB_2 = makeSalesOrder(accountDB.Id, EUR_INDIRECT);
        EUR_CRM_Sales_Order__c orderNL_1 = makeSalesOrder(accountNL.Id, EUR_INDIRECT);


        Test.startTest();
        insert new List<EUR_CRM_Sales_Order__c>{ orderIDL_1, orderIDL_2, orderDB_1, orderNL_1, orderDB_2
        };
        Test.stopTest();

        List<EUR_CRM_Sales_Order__c> orders = selectSalesOrders();
        System.debug('\n orders.size() => ' + orders.size() + '\n');
        System.debug('\n orders => ' + JSON.serializePretty(orders) + '\n');

        System.assertEquals('DB', orders[0].EUR_CRM_Country_Code__c);
        System.assertEquals('IDL', orders[1].EUR_CRM_Country_Code__c);
        System.assertEquals('IDL', orders[2].EUR_CRM_Country_Code__c);
        System.assertEquals('NL', orders[3].EUR_CRM_Country_Code__c);
        System.assertEquals('DB', orders[4].EUR_CRM_Country_Code__c);
        System.assertEquals('009000003', orders[0].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009000002', orders[1].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009000001', orders[2].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('007000001', orders[3].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('002030401', orders[4].EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.debug('\n 111salesOrderAutoNumbers.size() => ' + salesOrderAutoNumbers.size() + '\n');
        System.debug('\n 111salesOrderAutoNumbers => ' + JSON.serializePretty(salesOrderAutoNumbers) + '\n');
        System.assertEquals('009000003', salesOrderAutoNumbers[0].EUR_CRM_LastNumber__c);
        System.assertEquals('008000000', salesOrderAutoNumbers[1].EUR_CRM_LastNumber__c);
        System.assertEquals('007000001', salesOrderAutoNumbers[2].EUR_CRM_LastNumber__c);
        System.assertEquals('002030401', salesOrderAutoNumbers[3].EUR_CRM_LastNumber__c);
    }

    @IsTest
    private static void massiveWithoutCustomSettingPositiveTest() {
        deleteConfiguration();

        EUR_CRM_Account__c account = selectAccounts()[0];

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(EUR_DIRECT).getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> orders = makeSalesOrders(account.Id, rtId);

        Test.startTest();
        insert orders;
        Test.stopTest();

        orders = selectSalesOrders();
        System.assertEquals('009295094', orders[0].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009295093', orders[1].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009295092', orders[2].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009295091', orders[3].EUR_CRM_SF_Order_Number__c);
        System.assertEquals('009295090', orders[4].EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals(1, salesOrderAutoNumbers.size());
        System.assertEquals('009295094', salesOrderAutoNumbers[0].EUR_CRM_LastNumber__c);
    }

    @IsTest
    private static void singleIsNotMobileNegativeTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(EUR_DIRECT).getRecordTypeId();
        EUR_CRM_Sales_Order__c order = makeSalesOrder(account.Id, rtId);
        order.EUR_CRM_IsMobile__c = false;

        Test.startTest();
        insert order;
        Test.stopTest();

        order = selectSalesOrders()[0]; 
        System.assertEquals(null, order.EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals('009000000', salesOrderAutoNumbers[0].EUR_CRM_LastNumber__c);
    } 

    @IsTest
    private static void singleWithoutCustomSettingIsNotMobileNegativeTest() {
        deleteConfiguration();

        EUR_CRM_Account__c account = selectAccounts()[0];

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(EUR_DIRECT).getRecordTypeId();
        EUR_CRM_Sales_Order__c order = makeSalesOrder(account.Id, rtId);
        order.EUR_CRM_IsMobile__c = false;

        Test.startTest();
        insert order;
        Test.stopTest();

        order = selectSalesOrders()[0];
        System.assertEquals(null, order.EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals(0, salesOrderAutoNumbers.size());
    }

    @IsTest
    private static void massiveIsNotMobileNegativeTest() {
        EUR_CRM_Account__c account = selectAccounts()[0];

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(EUR_DIRECT).getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> orders = makeSalesOrders(account.Id, rtId);
        for (EUR_CRM_Sales_Order__c order : orders) {
            order.EUR_CRM_IsMobile__c = false;
        }

        Test.startTest();
        insert orders;
        Test.stopTest();

        orders = selectSalesOrders();
        System.assertEquals(null, orders[0].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[1].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[2].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[3].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[4].EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals('009000000', salesOrderAutoNumbers[0].EUR_CRM_LastNumber__c);
    }

    @IsTest
    private static void massiveWithoutCustomSettingIsNotMobileNegativeTest() {
        deleteConfiguration();

        EUR_CRM_Account__c account = selectAccounts()[0];

        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(EUR_DIRECT).getRecordTypeId();
        List<EUR_CRM_Sales_Order__c> orders = makeSalesOrders(account.Id, rtId);
        for (EUR_CRM_Sales_Order__c order : orders) {
            order.EUR_CRM_IsMobile__c = false;
        }

        Test.startTest();
        insert orders;
        Test.stopTest();

        orders = selectSalesOrders();
        System.assertEquals(null, orders[0].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[1].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[2].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[3].EUR_CRM_SF_Order_Number__c);
        System.assertEquals(null, orders[4].EUR_CRM_SF_Order_Number__c);

        List<EUR_CRM_SalesOrderAutoNumber__c> salesOrderAutoNumbers = selectSalesOrderAutoNumbers();
        System.assertEquals(0, salesOrderAutoNumbers.size());
    }

    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static void deleteConfiguration() {
        delete selectSalesOrderAutoNumbers();
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Sales_Order__c> makeSalesOrders(Id accId, Id rtId) {
        List<EUR_CRM_Sales_Order__c> salesOrders = new List<EUR_CRM_Sales_Order__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            salesOrders.add(makeSalesOrder(accId, rtId));
        }
        return salesOrders;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
            Name = 'Account'
        ,   EUR_CRM_Postal_Code__c = '12345'
        ,   RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accId, Id rtId) {
        return new EUR_CRM_Sales_Order__c(
            EUR_CRM_Account__c = accId
        ,   RecordTypeId = rtId
        ,   EUR_CRM_IsMobile__c = true
        );
    }

    private static EUR_CRM_Sales_Order__c makeSalesOrder(Id accId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Sales_Order__c(
            EUR_CRM_Account__c = accId
            ,   RecordTypeId = rtId
            ,   EUR_CRM_IsMobile__c = true
        );
    }

    public static EUR_CRM_SalesOrderAutoNumber__c makeConfigurations(String countryCode, String rt, String num) {
        return new EUR_CRM_SalesOrderAutoNumber__c(
            Name = rt + countryCode
        ,   EUR_CRM_Country_Code__c = countryCode
        ,   EUR_CRM_SalesOrderRecordType__c = rt
        ,   EUR_CRM_LastNumber__c = num
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Account__c
        ];
    }

    private static List<EUR_CRM_Sales_Order__c> selectSalesOrders() {
        return [
            SELECT Id
            ,   EUR_CRM_Country_Code__c
            ,   EUR_CRM_SF_Order_Number__c
            FROM EUR_CRM_Sales_Order__c
            ORDER BY EUR_CRM_SF_Order_Number__c DESC

        ];
    }

    private static List<EUR_CRM_SalesOrderAutoNumber__c> selectSalesOrderAutoNumbers() {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_SalesOrderRecordType__c
            ,   EUR_CRM_LastNumber__c
            FROM EUR_CRM_SalesOrderAutoNumber__c
            ORDER BY EUR_CRM_LastNumber__c DESC
        ];
    }

}