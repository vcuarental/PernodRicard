/**
 * Created by ali.kucuk@teknait.com on 12/27/2020.
 */

@IsTest
private class EUR_TR_BulkProfitabilityLoaderCtrlTest {

    @IsTest
    static void test_upsertProfitabilityItems() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'Test';
        account.EUR_TR_AccountCode__c = '12345';
        insert account;

        List<EUR_TR_BulkProfitabilityLoaderController.ProfitabilityItem> items =
                new List<EUR_TR_BulkProfitabilityLoaderController.ProfitabilityItem>();


        EUR_TR_BulkProfitabilityLoaderController.ProfitabilityItem successItem = new EUR_TR_BulkProfitabilityLoaderController.ProfitabilityItem();
        successItem.AccountCode = account.EUR_TR_AccountCode__c;
        successItem.Year = '19';
        successItem.Quarter = 'Q1';
        successItem.ProfitAmount = 100;
        successItem.TotalAmount = 120;
        items.add(successItem);

        EUR_TR_BulkProfitabilityLoaderController.ProfitabilityItem failedItem = new EUR_TR_BulkProfitabilityLoaderController.ProfitabilityItem();
        failedItem.AccountCode = 'UNKNOWN_ACCOUNT_CODE';
        failedItem.Year = '19';
        failedItem.Quarter = 'Q1';
        failedItem.ProfitAmount = 100;
        failedItem.TotalAmount = 120;
        items.add(failedItem);

        Test.startTest();
        EUR_TR_BulkProfitabilityLoaderController.UpsertProfitabilityResult result =
                EUR_TR_BulkProfitabilityLoaderController.upsertProfitabilityItems(items);

        System.assertEquals(1, result.errorSize);
        System.assertEquals(1, result.successSize);
        Test.stopTest();
    }
}