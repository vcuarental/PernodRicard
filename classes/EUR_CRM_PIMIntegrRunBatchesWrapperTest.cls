@IsTest (isParallel = true)
private class EUR_CRM_PIMIntegrRunBatchesWrapperTest {
    @testSetup
    private static void setupMethod() {
        insert new EUR_CRM_PIMIntegrationRunningBatches__c();
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        System.assertEquals(1, selectPIMIntegrationRunningBatches().size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Test getters
    /* ========================================================= */
    @IsTest
    private static void getCountryCodesForImagesForBrands_Empty_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        Test.startTest();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void getCountryCodesForImagesForBrands_OneCountryCode_Test() {
        EUR_CRM_PIMIntegrationRunningBatches__c info = selectPIMIntegrationRunningBatches()[0];
        info.EUR_CRM_ImagesForB__c = 'RU';
        update info;

        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        Test.startTest();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void getCountryCodesForImagesForBrands_ManyCountryCodes_Test() {
        EUR_CRM_PIMIntegrationRunningBatches__c info = selectPIMIntegrationRunningBatches()[0];
        info.EUR_CRM_ImagesForB__c = 'RU,DE,BG,GB,';
        update info;

        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        Test.startTest();
        System.assertEquals(4, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void getCountryCodesForImagesForBrandQualities_Empty_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        Test.startTest();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrandQualities().size());
        Test.stopTest();
    }

    @IsTest
    private static void getCountryCodesForImagesForBrandQualitySizes_Empty_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        Test.startTest();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrandQualitySizes().size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Test adders
    /* ========================================================= */
    @IsTest
    private static void addCountryCodeForImagesForBrands_FirstCountryCode_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrands('RU');

        Test.startTest();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void addCountryCodeForImagesForBrands_ManyCountryCodes_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrands('RU');
        wrapper.addCountryCodeForImagesForBrands('DE');
        wrapper.addCountryCodeForImagesForBrands('BG');
        wrapper.addCountryCodeForImagesForBrands('GB');

        Test.startTest();
        System.assertEquals(4, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void addCountryCodeForImagesForBrands_AllFirstlyPlusMany_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrands('All');

        Test.startTest();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());
        System.assert(wrapper.getCountryCodesForImagesForBrands().contains('All'));

        wrapper.addCountryCodeForImagesForBrands('RU');
        wrapper.addCountryCodeForImagesForBrands('DE');
        wrapper.addCountryCodeForImagesForBrands('BG');
        wrapper.addCountryCodeForImagesForBrands('GB');

        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());
        System.assert(wrapper.getCountryCodesForImagesForBrands().contains('All'));
        Test.stopTest();
    }

    @IsTest
    private static void addCountryCodeForImagesForBrands_ManyCountryCodesPlusAll_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrands('RU');
        wrapper.addCountryCodeForImagesForBrands('DE');
        wrapper.addCountryCodeForImagesForBrands('BG');
        wrapper.addCountryCodeForImagesForBrands('GB');

        Test.startTest();
        System.assertEquals(4, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrands('All');
        System.assertEquals(5, wrapper.getCountryCodesForImagesForBrands().size());
        System.assert(wrapper.getCountryCodesForImagesForBrands().contains('All'));

        wrapper.addCountryCodeForImagesForBrands('FI');
        System.assertEquals(5, wrapper.getCountryCodesForImagesForBrands().size());
        System.assert(wrapper.getCountryCodesForImagesForBrands().contains('All'));
        Test.stopTest();
    }

    @IsTest
    private static void addCountryCodeForImagesForBrandQualities_FirstCountryCode_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrandQualities('RU');

        Test.startTest();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrandQualities().size());
        Test.stopTest();
    }

    @IsTest
    private static void addCountryCodeForImagesForBrandQualitySizes_FirstCountryCode_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.addCountryCodeForImagesForBrandQualitySizes('RU');

        Test.startTest();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrandQualitySizes().size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Test removers
    /* ========================================================= */
    @IsTest
    private static void removeCountryCodeForImagesForBrands_emptyData_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('RU');

        Test.startTest();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void removeCountryCodeForImagesForBrands_removeOne_Test() {
        EUR_CRM_PIMIntegrationRunningBatches__c info = selectPIMIntegrationRunningBatches()[0];
        info.EUR_CRM_ImagesForB__c = 'RU';
        update info;

        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());

        Test.startTest();
        wrapper.removeCountryCodeForImagesForBrands('RU');
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('DE');
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('BG');
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('GB');
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void removeCountryCodeForImagesForBrands_removeMany_Test() {
        EUR_CRM_PIMIntegrationRunningBatches__c info = selectPIMIntegrationRunningBatches()[0];
        info.EUR_CRM_ImagesForB__c = 'RU,BG,GB,DE,';
        update info;

        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(4, wrapper.getCountryCodesForImagesForBrands().size());

        Test.startTest();
        wrapper.removeCountryCodeForImagesForBrands('RU');
        System.assertEquals(3, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('DE');
        System.assertEquals(2, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('BG');
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('GB');
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void removeCountryCodeForImagesForBrands_ManyCountryCodesPlusAll_Test() {
        EUR_CRM_PIMIntegrationRunningBatches__c info = selectPIMIntegrationRunningBatches()[0];
        info.EUR_CRM_ImagesForB__c = 'RU,BG,GB,DE,All';
        update info;

        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(5, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('RU');
        wrapper.removeCountryCodeForImagesForBrands('DE');
        wrapper.removeCountryCodeForImagesForBrands('BG');
        wrapper.removeCountryCodeForImagesForBrands('GB');

        Test.startTest();
        System.assertEquals(1, wrapper.getCountryCodesForImagesForBrands().size());

        wrapper.removeCountryCodeForImagesForBrands('All');
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrands().size());
        Test.stopTest();
    }

    @IsTest
    private static void removeCountryCodeForImagesForBrandQualities_emptyData_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrandQualities().size());

        wrapper.removeCountryCodeForImagesForBrandQualities('RU');

        Test.startTest();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrandQualities().size());
        Test.stopTest();
    }

    @IsTest
    private static void removeCountryCodeForImagesForBrandQualitySizes_emptyData_Test() {
        EUR_CRM_PIMIntegrRunBatchesWrapper wrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrandQualitySizes().size());

        wrapper.removeCountryCodeForImagesForBrandQualitySizes('RU');

        Test.startTest();
        System.assertEquals(0, wrapper.getCountryCodesForImagesForBrandQualitySizes().size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_PIMIntegrationRunningBatches__c> selectPIMIntegrationRunningBatches() {
        return [
            SELECT Id
            ,   EUR_CRM_ImagesForB__c
            ,   EUR_CRM_ImagesForBQ__c
            ,   EUR_CRM_ImagesForBQS__c
            FROM EUR_CRM_PIMIntegrationRunningBatches__c
        ];
    }

}