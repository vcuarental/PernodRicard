/**
 * Created by Andrii Leshchuk on 01.03.2019.
 */
@IsTest
public with sharing class EUR_CRM_ProductCatalogTriggerHandlerTest {

    @IsTest
    static void createStandardCatalog() {
        System.Test.startTest();
        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();
        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {
            EUR_CRM_ProductCatalog__c sCat =  createStandardCatalogObject(catalogService);
        }
        System.Test.stopTest();

        List<EUR_CRM_ProductCatalog__c> productCatalogs = [SELECT Id, EUR_CRM_External_ID__c FROM EUR_CRM_ProductCatalog__c LIMIT 1];

        System.assertEquals(EUR_CRM_ProductCatalogServiceForTests.STANDARD_CATALOG_EXTERNAL_ID, productCatalogs[0].EUR_CRM_External_ID__c);
    }

    @IsTest
    static void createDirectCatalog() {
        System.Test.startTest();
        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();

        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {

            EUR_CRM_ProductCatalog__c sCat =  createStandardCatalogObject(catalogService);

            EUR_CRM_ProductCatalog__c directCat = catalogService.generateCatalog(sCat, 'DirectCat', EUR_CRM_ProductCatalogServiceForTests.DIRECT_CATALOG_RECORD_TYPE_NAME);
            directCat.EUR_CRM_IsStandard__c = true;
            insert directCat;
        }

        System.Test.stopTest();

        List<EUR_CRM_ProductCatalog__c> productCatalogs = getProductCatalogsWithStandard();
        for (EUR_CRM_ProductCatalog__c catalog : productCatalogs) {
            System.assertNotEquals('DIR-' + catalog.EUR_CRM_Unique_Number__c, catalog.EUR_CRM_External_ID__c);
        }
    }

    @IsTest
    static void createDirectCatalog_IsStandardFalse() {
        System.Test.startTest();
        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();

        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {

            EUR_CRM_ProductCatalog__c sCat =  createStandardCatalogObject(catalogService);

            EUR_CRM_ProductCatalog__c directCat = catalogService.generateCatalog(sCat, 'DirectCat', EUR_CRM_ProductCatalogServiceForTests.DIRECT_CATALOG_RECORD_TYPE_NAME);
            directCat.EUR_CRM_IsStandard__c = false;
            insert directCat;
        }

        System.Test.stopTest();

        List<EUR_CRM_ProductCatalog__c> productCatalogs = getProductCatalogsWithoutStandard();

        System.assertEquals('DIR-' + productCatalogs[0].EUR_CRM_Unique_Number__c, productCatalogs[0].EUR_CRM_External_ID__c);
    }

    @IsTest
    static void createIndirectCatalog() {
        System.Test.startTest();
        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();
        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {

            EUR_CRM_ProductCatalog__c sCat =  createStandardCatalogObject(catalogService);

            EUR_CRM_ProductCatalog__c indirectCat = catalogService.generateCatalog(sCat, 'IndirectCat', EUR_CRM_ProductCatalogServiceForTests.INDIRECT_CATALOG_RECORD_TYPE_NAME);
            insert indirectCat;
        }

        System.Test.stopTest();

        List<EUR_CRM_ProductCatalog__c> productCatalogs = getProductCatalogsWithoutStandard();

        System.assertEquals('IND-' + productCatalogs[0].EUR_CRM_Unique_Number__c, productCatalogs[0].EUR_CRM_External_ID__c);
    }

    @IsTest
    static void createPOSMCatalog() {

        System.Test.startTest();
        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();

        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {

            EUR_CRM_ProductCatalog__c sCat = createStandardCatalogObject(catalogService);

            EUR_CRM_ProductCatalog__c indirectCat = catalogService.generateCatalog(sCat, 'IndirectCat', EUR_CRM_ProductCatalogServiceForTests.POSM_CATALOG_RECORD_TYPE_NAME);
            indirectCat.EUR_CRM_IsStandard__c = false;
            insert indirectCat;
        }

        System.Test.stopTest();

        List<EUR_CRM_ProductCatalog__c> productCatalogs = getProductCatalogsWithoutStandard();

        System.assertEquals('POSM-' + productCatalogs[0].EUR_CRM_Unique_Number__c, productCatalogs[0].EUR_CRM_External_ID__c);
    }

    @isTest
    static void bulkCreationCatalogs() {

        System.Test.startTest();

        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();

        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {

            List<EUR_CRM_ProductCatalog__c> catalogs = new List<EUR_CRM_ProductCatalog__c>();

            EUR_CRM_ProductCatalog__c sCat = createStandardCatalogObject(catalogService);

            catalogs.add(catalogService.generateCatalog(sCat, 'DirectCat', EUR_CRM_ProductCatalogServiceForTests.DIRECT_CATALOG_RECORD_TYPE_NAME));
            catalogs.add(catalogService.generateCatalog(sCat, 'IndirectCat', EUR_CRM_ProductCatalogServiceForTests.INDIRECT_CATALOG_RECORD_TYPE_NAME));
            catalogs.add(catalogService.generateCatalog(sCat, 'PosmCat', EUR_CRM_ProductCatalogServiceForTests.POSM_CATALOG_RECORD_TYPE_NAME));

            insert catalogs;
        }

        System.Test.stopTest();

        List<EUR_CRM_ProductCatalog__c> productCatalogs = getProductCatalogsWithoutStandard();

        for (EUR_CRM_ProductCatalog__c catalog : productCatalogs) {
            String recordTypeName = catalog.RecordType.Name;
            if (recordTypeName == EUR_CRM_ProductCatalogServiceForTests.DIRECT_CATALOG_RECORD_TYPE_NAME) {
                System.assertEquals('DIR-' + catalog.EUR_CRM_Unique_Number__c, catalog.EUR_CRM_External_ID__c);
            } else if (recordTypeName == EUR_CRM_ProductCatalogServiceForTests.INDIRECT_CATALOG_RECORD_TYPE_NAME) {
                System.assertEquals('IND-' + catalog.EUR_CRM_Unique_Number__c, catalog.EUR_CRM_External_ID__c);
            } else if (recordTypeName == EUR_CRM_ProductCatalogServiceForTests.POSM_CATALOG_RECORD_TYPE_NAME) {
                System.assertEquals('POSM-' + catalog.EUR_CRM_Unique_Number__c, catalog.EUR_CRM_External_ID__c);
            }
        }
    }

    private static EUR_CRM_ProductCatalog__c createStandardCatalogObject(EUR_CRM_ProductCatalogServiceForTests catalogService) {
        EUR_CRM_ProductCatalog__c sCat = catalogService.createStandardCatalog(false);
        sCat.EUR_CRM_External_ID__c = EUR_CRM_ProductCatalogServiceForTests.STANDARD_CATALOG_EXTERNAL_ID;
        insert sCat;
        return sCat;
    }

    private static List<EUR_CRM_ProductCatalog__c> getProductCatalogsWithoutStandard() {
        return [
                SELECT Id, EUR_CRM_External_ID__c, EUR_CRM_Unique_Number__c, RecordType.Name
                FROM EUR_CRM_ProductCatalog__c
                WHERE EUR_CRM_IsStandard__c = FALSE
                LIMIT 3
        ];
    }

    private static List<EUR_CRM_ProductCatalog__c> getProductCatalogsWithStandard() {
        return [
            SELECT Id, EUR_CRM_External_ID__c, EUR_CRM_Unique_Number__c, RecordType.Name, EUR_CRM_IsStandard__c
            FROM EUR_CRM_ProductCatalog__c
            WHERE EUR_CRM_IsStandard__c = TRUE
            LIMIT 3
        ];
    }
}