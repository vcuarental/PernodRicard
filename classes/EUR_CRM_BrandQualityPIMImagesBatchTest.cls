@IsTest (isParallel = true)
private class EUR_CRM_BrandQualityPIMImagesBatchTest {

    private static final Integer COUNT_OF_RECORDS = 5;

    @testSetup
    private static void setupMethod() {
        insert makeQualities();
    }

    @IsTest
    private static void setupTest() {
        Test.startTest();
        List<EUR_CRM_Quality__c> qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());
        Test.stopTest();
    }


    @IsTest
    private static void allCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch(), 10);
        Test.stopTest();

        List<EUR_CRM_Quality__c> qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());

        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }
    }

    @IsTest
    private static void specificCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch('RU'), 10);
        Test.stopTest();

        List<EUR_CRM_Quality__c> qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());

        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }
    }

    @IsTest
    private static void overrideAttachmentsTest() {
        List<EUR_CRM_Quality__c> qualities = selectQualities();
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Quality__c quality : qualities) {
            attachments.add(makeAttachment(quality));
        }
        insert attachments;

        qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());
        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch(), 10);
        Test.stopTest();

        qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());

        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Quality__c> makeQualities() {
        List<EUR_CRM_Quality__c> qualities = new List<EUR_CRM_Quality__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            qualities.add(makeQuality());
        }
        return qualities;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Quality__c makeQuality() {
        return new EUR_CRM_Quality__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByName().get('EUR RU Quality').getRecordTypeId()
        ,   EUR_CRM_Quality_Image_URL__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
        );
    }

    private static Attachment makeAttachment(EUR_CRM_Quality__c quality) {
        String name = quality.EUR_CRM_Quality_Image_URL__c.substringAfterLast('/').substringBeforeLast('.') + '.png';
        return new Attachment(
            ParentId = quality.Id
        ,   Name = name
        ,   Body = Blob.valueOf('String')
        ,   ContentType = 'image/png'
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Quality__c> selectQualities() {
        return [
            SELECT Id
            ,   EUR_CRM_Quality_Image_URL__c
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
            )
            FROM EUR_CRM_Quality__c
        ];
    }

}