@IsTest (isParallel = true)
private class EUR_CRM_ProsSegmentationCleanUpHandTest {

    @IsTest
    private static void firstTest() {
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(Name = 'Account');
        insert account;

        System.assertEquals(1, [SELECT Id FROM EUR_CRM_Pros_Segmentation__c].size());

        Test.startTest();
        delete account;
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM EUR_CRM_Pros_Segmentation__c].size());
    }

}