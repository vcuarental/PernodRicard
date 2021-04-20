@IsTest (IsParallel = true)
private class EUR_CRM_PRS_SegmentationTriggerTest {

    @IsTest
    private static void simpleTest() {
        Test.startTest();
        EUR_CRM_Account__c account = new EUR_CRM_Account__c(Name = 'Acc', EUR_CRM_Postal_Code__c = '112233');
        insert account;

        EUR_CRM_PRS_Segmentation__c segmentation = new EUR_CRM_PRS_Segmentation__c(EUR_CRM_Account__c = account.Id);
        insert segmentation;

        delete segmentation;

        undelete segmentation;
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */

}