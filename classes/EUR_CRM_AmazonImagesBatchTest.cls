/**
 * Created by illia on 15.08.18.
 */

@IsTest (isParallel = true)
private class EUR_CRM_AmazonImagesBatchTest {
    private static final Integer COUNT_OF_RECORDS = 5;
    private static final String BRAND_OBJECT_TYPE = 'EUR_CRM_Brand__c';
    private static final String QUALITY_OBJECT_TYPE = 'EUR_CRM_Quality__c';

    @testSetup
    private static void setupMethod() {
        insert makeBrands();
        insert makeQualities();

    }

    @IsTest
    private static void allBrandCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AmazonImagesMockGenerator());
        Database.executeBatch(new EUR_CRM_AmazonImagesBatch(BRAND_OBJECT_TYPE, null), 10);
        Test.stopTest();

        List<EUR_CRM_Brand__c> brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());

        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }
    }

    @IsTest
    private static void allQualityCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AmazonImagesMockGenerator());
        Database.executeBatch(new EUR_CRM_AmazonImagesBatch(QUALITY_OBJECT_TYPE, null), 10);
        Test.stopTest();

        List<EUR_CRM_Quality__c> qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());

        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }
    }

    @IsTest
    private static void specificBrandCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AmazonImagesMockGenerator());
        Database.executeBatch(new EUR_CRM_AmazonImagesBatch(BRAND_OBJECT_TYPE,'RU'), 10);
        Test.stopTest();

        List<EUR_CRM_Brand__c> brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());

        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }
    }

    @IsTest
    private static void specificQualityCountryTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AmazonImagesMockGenerator());
        Database.executeBatch(new EUR_CRM_AmazonImagesBatch(QUALITY_OBJECT_TYPE, 'RU'), 10);
        Test.stopTest();

        List<EUR_CRM_Quality__c> qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());

        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }
    }

    @IsTest
    private static void overrideBrandAttachmentsTest() {

        List<EUR_CRM_Brand__c> brands = selectBrands();
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Brand__c brand : brands) {
            attachments.add(makeBrandAttachment(brand));
        }
        insert attachments;

        brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());
        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AmazonImagesMockGenerator());
        Database.executeBatch(new EUR_CRM_AmazonImagesBatch(BRAND_OBJECT_TYPE, null), 10);
        Test.stopTest();

        brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());

        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }
    }

    @IsTest
    private static void overrideQualityAttachmentsTest() {
        List<EUR_CRM_Quality__c> qualities = selectQualities();
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Quality__c quality : qualities) {
            attachments.add(makeQualityAttachment(quality));
        }
        insert attachments;

        qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());
        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AmazonImagesMockGenerator());
        Database.executeBatch(new EUR_CRM_AmazonImagesBatch(QUALITY_OBJECT_TYPE, null), 10);
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
    private static List<EUR_CRM_Brand__c> makeBrands() {
        List<EUR_CRM_Brand__c> brands = new List<EUR_CRM_Brand__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            brands.add(makeBrand());
        }
        return brands;
    }

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
    private static EUR_CRM_Brand__c makeBrand() {
        return new EUR_CRM_Brand__c(
                RecordTypeId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByName().get('EUR RU Brand').getRecordTypeId()
        ,   EUR_CRM_Brand_Image_url__c = 'https://s3-eu-west-1.amazonaws.com/pr-files3.ipernodricard.com/2015/04/29/preview-55408c1c0db6c-Bacardi%20Superior.png.png'
        );
    }

    private static EUR_CRM_Quality__c makeQuality() {
        return new EUR_CRM_Quality__c(
                RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByName().get('EUR RU Quality').getRecordTypeId()
        ,   EUR_CRM_Quality_Image_URL__c = 'https://s3-eu-west-1.amazonaws.com/files.ipernodricard.com/143d2ad1f993bd5660cb26e44a5ed69b_1084576.jpg'
        );
    }

    private static Attachment makeBrandAttachment(EUR_CRM_Brand__c brand) {
        String name = brand.EUR_CRM_Brand_Image_url__c.substringAfterLast('/').substringBeforeLast('.') + '.png';
        return new Attachment(
                ParentId = brand.Id
        ,   Name = name
        ,   Body = Blob.valueOf('String')
        ,   ContentType = 'image/png'
        );
    }

    private static Attachment makeQualityAttachment(EUR_CRM_Quality__c quality) {
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