@IsTest (isParallel = true)
private class EUR_CRM_BrandQualitySizePIMImagesBatchTe {

    private static final Integer COUNT_OF_RECORDS = 5;

    @testSetup
    private static void setupMethod() {
        insert makeSizes();
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Size__c> sizes = selectSizes();
        System.assertEquals(COUNT_OF_RECORDS, sizes.size());
        Test.stopTest();
    }


    @IsTest
    private static void allCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch(), 10);
        Test.stopTest();

        List<EUR_CRM_Size__c> sizes = selectSizes();
        System.assertEquals(COUNT_OF_RECORDS, sizes.size());

        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
        }
    }

    @IsTest
    private static void specificCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch('RU'), 10);
        Test.stopTest();

        List<EUR_CRM_Size__c> sizes = selectSizes();
        System.assertEquals(COUNT_OF_RECORDS, sizes.size());

        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
        }
    }

    @IsTest
    private static void overrideAttachmentsTest() {
        List<EUR_CRM_Size__c> sizes = selectSizes();
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Size__c size : sizes) {
            attachments.add(makeAttachment(size));
        }
        insert attachments;

        sizes = selectSizes();
        System.assertEquals(COUNT_OF_RECORDS, sizes.size());
        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch(), 10);
        Test.stopTest();

        sizes = selectSizes();
        System.assertEquals(COUNT_OF_RECORDS, sizes.size());

        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Size__c> makeSizes() {
        List<EUR_CRM_Size__c> sizes = new List<EUR_CRM_Size__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            sizes.add(makeSize());
        }
        return sizes;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Size__c makeSize() {
        return new EUR_CRM_Size__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByName().get('EUR RU Size').getRecordTypeId()
        ,   EUR_CRM_Size_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
        );
    }

    private static Attachment makeAttachment(EUR_CRM_Size__c size) {
        String name = size.EUR_CRM_Size_Image_url__c.substringAfterLast('/').substringBeforeLast('.') + '.png';
        return new Attachment(
            ParentId = size.Id
        ,   Name = name
        ,   Body = Blob.valueOf('String')
        ,   ContentType = 'image/png'
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Size__c> selectSizes() {
        return [
            SELECT Id
            ,   EUR_CRM_Size_Image_url__c
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
            )
            FROM EUR_CRM_Size__c
        ];
    }

}