@IsTest
private class EUR_NIM_FilteredListController_Test {

    @isTest static void test_getParent() {

        Account a = new Account(
                Name='account test1',
                ShippingCountry = 'Switzerland');
        insert a;


        Test.startTest();

        EUR_NIM_FilteredListController.getParent(a.Id);
        Test.stopTest();
    }
    @isTest static void test_querySObject() {

        Account a = new Account(
                Name='account test1',
                ShippingCountry = 'Switzerland');
        insert a;


        Test.startTest();
        String sObjectName = 'Account';
        List<String> fields = new List<String>{'{"fieldName":"Name"}', '{"soqlStmt":"Name"}', '{"soqlStmt":"Name"}'};
        String whereClause = ' Name != null';
        EUR_NIM_FilteredListController.querySObject(sObjectName, fields, whereClause);
        Test.stopTest();
    }
    @isTest static void test_getSObjectFieldList() {



        Test.startTest();

        EUR_NIM_FilteredListController.getSObjectFieldList('Account');
        Test.stopTest();
    }
    @isTest static void test_getTranslations() {



        Test.startTest();

        EUR_NIM_FilteredListController.getTranslations();
        Test.stopTest();
    }
}