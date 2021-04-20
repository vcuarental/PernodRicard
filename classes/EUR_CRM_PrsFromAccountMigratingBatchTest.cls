@IsTest
private class EUR_CRM_PrsFromAccountMigratingBatchTest {
    @IsTest
    private static void prosToPrsMigratingBatchTest() {
        EUR_CRM_PRS_Group_Outlet_Type__c prsgot = new EUR_CRM_PRS_Group_Outlet_Type__c(EUR_CRM_External_ID__c = 'DE_GOT_RST');
        insert prsgot;

        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(
                EUR_CRM_PRS_Group_Outlet_Type__c = prsgot.Id,
                Name = 'Test Name',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Postal_Code__c = '02568',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_On_Trade_B2B').getRecordTypeId()
        );
        insert acc;

        Map<String, String> accountToPrsSegmentationMapping = new Map<String, String> {
            'EUR_CRM_PRS_Group_Outlet_Type__c' => 'EUR_CRM_PRS_Group_Outlet_Type__c',
            'EUR_CRM_PRS_Outlet_Type__c' => 'EUR_CRM_PRS_Outlet_Type__c',
            'EUR_CRM_PRS_Image_Level__c' => 'EUR_CRM_Image_Level__c',
            'EUR_CRM_PRS_Volume_Potential__c' => 'EUR_CRM_Volume_Potential__c'
        };

        Map<String, String> channelToRecordTypeMapping = new Map<String, String>{
                'OFF TRADE'  => 'EUR_PRS_Segmentation_Off_Trade',
                'ON TRADE'  => 'EUR_PRS_Segmentation_On_Trade'
        };

        Test.startTest();
        Database.executeBatch(new EUR_CRM_PrsFromAccountMigratingBatch(accountToPrsSegmentationMapping, channelToRecordTypeMapping));
        Test.stopTest();

        List<EUR_CRM_PRS_Segmentation__c> prsSegmentations = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :acc.Id AND EUR_CRM_PRS_Group_Outlet_Type__c = :prsgot.Id];
        System.assertEquals(1, prsSegmentations.size());
    }
}