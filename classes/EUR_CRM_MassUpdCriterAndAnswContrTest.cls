@IsTest
private class EUR_CRM_MassUpdCriterAndAnswContrTest {

    @IsTest
    private static void Test() {
        EUR_CRM_MassUpdCriterAndAnswContr contrl = new EUR_CRM_MassUpdCriterAndAnswContr();
        contrl.countryCodeStr = 'NL';
        contrl.fieldToUpdate = 'EUR_CRM_Image_Level__c';
        contrl.runBatchJob();
        contrl.runImageBatchJob();
        contrl.runVolumeBatchJob();
    }
}