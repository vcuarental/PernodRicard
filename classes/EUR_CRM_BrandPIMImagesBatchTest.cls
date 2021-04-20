@IsTest (isParallel = true)
private class EUR_CRM_BrandPIMImagesBatchTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @testSetup
    private static void setupMethod() {
        insert makeBrands();
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Brand__c> brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());
        Test.stopTest();
    }


    @IsTest
    private static void allCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch(), 10);
        Test.stopTest();

        List<EUR_CRM_Brand__c> brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());

        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }
    }

    @IsTest
    private static void specificCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch('RU'), 10);
        Test.stopTest();

        List<EUR_CRM_Brand__c> brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());

        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }
    }

    @IsTest
    private static void overrideAttachmentsTest() {
        List<EUR_CRM_Brand__c> brands = selectBrands();
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Brand__c brand : brands) {
            attachments.add(makeAttachment(brand));
        }
        insert attachments;

        brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());
        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch(), 10);
        Test.stopTest();

        brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());

        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Brand__c> makeBrands() {
        List<EUR_CRM_Brand__c> brands = new List<EUR_CRM_Brand__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            brands.add(makeBrand());
        }
        return brands;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Brand__c makeBrand() {
        return new EUR_CRM_Brand__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByName().get('EUR RU Brand').getRecordTypeId()
        ,   EUR_CRM_Brand_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
        );
    }

    private static Attachment makeAttachment(EUR_CRM_Brand__c brand) {
        String name = brand.EUR_CRM_Brand_Image_url__c.substringAfterLast('/').substringBeforeLast('.') + '.png';
        return new Attachment(
            ParentId = brand.Id
        ,   Name = name
        ,   Body = Blob.valueOf('String')
        ,   ContentType = 'image/png'
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Brand__c> selectBrands() {
        return [
            SELECT Id
            ,   EUR_CRM_Brand_Image_url__c
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
            )
            FROM EUR_CRM_Brand__c
        ];
    }

}