@IsTest (IsParallel = true)
private class EUR_CRM_BBQBQS_ImageDownloaderServiceTes {

    private static final Integer COUNT_OF_RECORDS = 5;
    private static final String DOCUMENT_NAME_PREFIX = EUR_CRM_BBQBQS_ImageDownloaderService.DOCUMENT_NAME_PREFIX;
    private static final String DOCUMENT_NAME_POSTFIX = EUR_CRM_BBQBQS_ImageDownloaderService.DOCUMENT_NAME_POSTFIX;


    /* ========================================================= */
    /*     Brands
    /* ========================================================= */
    @IsTest
    private static void brand_setURLtest() {
        List<EUR_CRM_Brand__c> brands = makeBrands();
        insert brands;

        brands = updateURLs(brands);

        System.assertEquals(0, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_B' + DOCUMENT_NAME_POSTFIX + '.zip').size());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        update brands;
        Test.stopTest();

        brands = selectBrands();
        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }

        System.assertEquals(1, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_B' + DOCUMENT_NAME_POSTFIX + '.zip').size());
    }

    @IsTest
    private static void brand_updateURLtest() {
        List<EUR_CRM_Brand__c> brands = makeBrands();
        insert brands;

        List<Attachment> initialAttachments = makeAttachments(brands);
        insert initialAttachments;

        brands = selectBrands();
        System.assertEquals(COUNT_OF_RECORDS, brands.size());
        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
        }

        brands = updateURLs(brands);

        System.assertEquals(0, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_B' + DOCUMENT_NAME_POSTFIX + '.zip').size());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        update brands;
        Test.stopTest();

        brands = selectBrands();
        for (EUR_CRM_Brand__c brand : brands) {
            System.assertEquals(1, brand.Attachments.size());
            System.assert( ! new Map<Id, Attachment>(initialAttachments).containsKey(brand.Attachments[0].Id));
        }

        System.assertEquals(1, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_B' + DOCUMENT_NAME_POSTFIX + '.zip').size());
    }


    /* ========================================================= */
    /*     Brands Quality
    /* ========================================================= */
    @IsTest
    private static void quality_setURLtest() {
        List<EUR_CRM_Quality__c> qualities = makeQualities();
        insert qualities;

        qualities = updateURLs(qualities);

        System.assertEquals(0, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQ' + DOCUMENT_NAME_POSTFIX + '.zip').size());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        update qualities;
        Test.stopTest();

        qualities = selectQualities();
        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }

        System.assertEquals(1, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQ' + DOCUMENT_NAME_POSTFIX + '.zip').size());
    }

    @IsTest
    private static void quality_updateURLtest() {
        List<EUR_CRM_Quality__c> qualities = makeQualities();
        insert qualities;

        List<Attachment> initialAttachments = makeAttachments(qualities);
        insert initialAttachments;

        qualities = selectQualities();
        System.assertEquals(COUNT_OF_RECORDS, qualities.size());
        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
        }

        qualities = updateURLs(qualities);

        System.assertEquals(0, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQ' + DOCUMENT_NAME_POSTFIX + '.zip').size());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        update qualities;
        Test.stopTest();

        qualities = selectQualities();
        for (EUR_CRM_Quality__c quality : qualities) {
            System.assertEquals(1, quality.Attachments.size());
            System.assert( ! new Map<Id, Attachment>(initialAttachments).containsKey(quality.Attachments[0].Id));
        }

        System.assertEquals(1, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQ' + DOCUMENT_NAME_POSTFIX + '.zip').size());
    }


    /* ========================================================= */
    /*     Brands Quality Size
    /* ========================================================= */
    @IsTest
    private static void size_setURLtest() {
        List<EUR_CRM_Size__c> sizes = makeSizes();
        insert sizes;

        sizes = updateURLs(sizes);

        System.assertEquals(0, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQS' + DOCUMENT_NAME_POSTFIX + '.zip').size());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        update sizes;
        Test.stopTest();

        sizes = selectSizes();
        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
        }

        System.assertEquals(1, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQS' + DOCUMENT_NAME_POSTFIX + '.zip').size());
    }

    @IsTest
    private static void size_updateURLtest() {
        List<EUR_CRM_Size__c> sizes = makeSizes();
        insert sizes;

        List<Attachment> initialAttachments = makeAttachments(sizes);
        insert initialAttachments;

        sizes = selectSizes();
        System.assertEquals(COUNT_OF_RECORDS, sizes.size());
        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
        }

        sizes = updateURLs(sizes);

        System.assertEquals(0, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQS' + DOCUMENT_NAME_POSTFIX + '.zip').size());

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_PIMIntegrationMockGenerator());
        update sizes;
        Test.stopTest();

        sizes = selectSizes();
        for (EUR_CRM_Size__c size : sizes) {
            System.assertEquals(1, size.Attachments.size());
            System.assert( ! new Map<Id, Attachment>(initialAttachments).containsKey(size.Attachments[0].Id));
        }

        System.assertEquals(1, selectDocuments(DOCUMENT_NAME_PREFIX + 'RU' + '_BQS' + DOCUMENT_NAME_POSTFIX + '.zip').size());
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static List<EUR_CRM_Brand__c> updateURLs(List<EUR_CRM_Brand__c> brands) {
        for (EUR_CRM_Brand__c brand : brands) {
            brand.EUR_CRM_Brand_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg';
        }
        return brands;
    }

    private static List<EUR_CRM_Quality__c> updateURLs(List<EUR_CRM_Quality__c> qualities) {
        for (EUR_CRM_Quality__c quality : qualities) {
            quality.EUR_CRM_Quality_Image_URL__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg';
        }
        return qualities;
    }

    private static List<EUR_CRM_Size__c> updateURLs(List<EUR_CRM_Size__c> sizes) {
        for (EUR_CRM_Size__c size : sizes) {
            size.EUR_CRM_Size_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg';
        }
        return sizes;
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Brand__c> makeBrands() {
        List<EUR_CRM_Brand__c> brands = new List<EUR_CRM_Brand__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            brands.add(makeBrand(i));
        }
        return brands;
    }

    private static List<EUR_CRM_Quality__c> makeQualities() {
        List<EUR_CRM_Quality__c> qualities = new List<EUR_CRM_Quality__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            qualities.add(makeQuality(i));
        }
        return qualities;
    }

    private static List<EUR_CRM_Size__c> makeSizes() {
        List<EUR_CRM_Size__c> sizes = new List<EUR_CRM_Size__c>();
        for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
            sizes.add(makeSize(i));
        }
        return sizes;
    }

    private static List<Attachment> makeAttachments(List<EUR_CRM_Brand__c> brands) {
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Brand__c brand : brands) {
            attachments.add(makeAttachment(brand.Id, brand.EUR_CRM_Brand_Image_url__c.substringAfterLast('/').substringBeforeLast('.') + '.png'));
        }
        return attachments;
    }

    private static List<Attachment> makeAttachments(List<EUR_CRM_Quality__c> qualities) {
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Quality__c quality : qualities) {
            attachments.add(makeAttachment(quality.Id, quality.EUR_CRM_Quality_Image_URL__c.substringAfterLast('/').substringBeforeLast('.') + '.png'));
        }
        return attachments;
    }

    private static List<Attachment> makeAttachments(List<EUR_CRM_Size__c> sizes) {
        List<Attachment> attachments = new List<Attachment>();
        for (EUR_CRM_Size__c size : sizes) {
            attachments.add(makeAttachment(size.Id, size.EUR_CRM_Size_Image_url__c.substringAfterLast('/').substringBeforeLast('.') + '.png'));
        }
        return attachments;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Brand__c makeBrand(Integer counter) {
        return new EUR_CRM_Brand__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Brand').getRecordTypeId()
        ,   EUR_CRM_Brand_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
        ,   EUR_CRM_External_ID__c = 'Brand_' + (counter + 1)
        );
    }

    private static EUR_CRM_Quality__c makeQuality(Integer counter) {
        return new EUR_CRM_Quality__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Quality').getRecordTypeId()
        ,   EUR_CRM_Quality_Image_URL__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
        ,   EUR_CRM_External_ID__c = 'Quality_' + (counter + 1)
        );
    }

    private static EUR_CRM_Size__c makeSize(Integer counter) {
        return new EUR_CRM_Size__c(
            RecordTypeId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get('EUR_RU_Size').getRecordTypeId()
        ,   EUR_CRM_Size_Image_url__c = 'https://assets.pernod-ricard.io/pim/production/v2/Absolut_Vodka_Sweden_Pears_70Cl_Bottle_1_forsightPreview.jpg?version=1518055414426'
        ,   EUR_CRM_External_ID__c = 'Size_' + (counter + 1)
        );
    }

    private static Attachment makeAttachment(Id parentId, String name) {
        return new Attachment(
            ParentId = parentId
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

    private static List<Document> selectDocuments(String name) {
        return [
            SELECT Id
            FROM Document
            WHERE Name = :name
                AND ContentType = 'application/zip'
        ];
    }

}