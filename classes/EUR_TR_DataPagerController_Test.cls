/**
 * Created by bsavcı on 8/27/2020.
 */

@IsTest
private class EUR_TR_DataPagerController_Test {
    @TestSetup
    public static void setup() {
        List<EUR_TR_Account__c> accounts = new List<EUR_TR_Account__c>();
        for (Integer i = 0; i < 50; i++) {
            EUR_TR_Account__c account = new EUR_TR_Account__c(Name = 'Ali');
            accounts.add(account);
        }
        insert accounts;
    }

    @IsTest
    static void testDataPagerController_query() {
        EUR_TR_DataPagerController.QueryRequest request = new EUR_TR_DataPagerController.QueryRequest();
        request.objectName = 'EUR_TR_Account__c';
        request.filter = ' ID != null ';
        request.fields = new List<String>();
        request.fields.add('Id');
        request.fields.add('Name');
        request.pageSize = 5;
        request.selectedPageFirstId = null;
        request.pagerCount = 3;
        request.pagerStartIndex = 1;
        request.pagerStartId = null;
        EUR_TR_DataPagerController.query(request);

        request.filter = null;
        EUR_TR_DataPagerController.query(request);

        request.pageSize = 5000;
        EUR_TR_DataPagerController.query(request);

        EUR_TR_Account__c account = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
        request.selectedPageFirstId = account.Id;
        EUR_TR_DataPagerController.query(request);

        request.filter = ' ID != null ';
        EUR_TR_DataPagerController.query(request);

        EUR_TR_DataPagerController.getAllFields('EUR_TR_Account__c');
        EUR_TR_DataPagerController.getFieldOptions('EUR_TR_Account__c', 'Name');
        EUR_TR_DataPagerController.getAllFieldsOfLookup(new List<String>{
                'EUR_TR_Account__c'
        }, false);
    }
}