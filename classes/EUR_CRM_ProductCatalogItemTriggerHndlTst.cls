/**
 * Created by Andrii Leshchuk on 01.03.2019.
 */

@IsTest
private class EUR_CRM_ProductCatalogItemTriggerHndlTst {

    @TestSetup
    static void setup() {
        Test.startTest();
        EUR_CRM_ProductCatalogServiceForTests.initProducts();
        Test.stopTest();
    }

    @IsTest
    static void bulkCreationProductCatalogItems() {

        System.Test.startTest();
        System.runAs(EUR_CRM_ProductCatalogServiceForTests.initUser()) {
            createTestData();
        }
        System.Test.stopTest();

        List<EUR_CRM_ProductCatalogItem__c> catalogItems = getCatalogItems();
        for (EUR_CRM_ProductCatalogItem__c catalogItem : catalogItems) {
            String recordTypeName = catalogItem.EUR_CRM_PriceBookID__r.RecordType.Name;
            Boolean isStandard = catalogItem.EUR_CRM_PriceBookID__r.EUR_CRM_IsStandard__c;
            
//            if (recordTypeName == EUR_CRM_ProductCatalogServiceForTests.DIRECT_CATALOG_RECORD_TYPE_NAME && isStandard) {
//                System.assertEquals(null, catalogItem.EUR_CRM_External_ID__c);
//            } else {
//                System.assertEquals(catalogItem.EUR_CRM_PriceBookID__r.EUR_CRM_External_ID__c + '-' + catalogItem.EUR_CRM_ProductMN__c, catalogItem.EUR_CRM_External_ID__c);
//            }
        }
    }

    private static void createTestData() {
        EUR_CRM_ProductCatalogServiceForTests catalogService = new EUR_CRM_ProductCatalogServiceForTests();
        createProductCatalogItems(createProductCatalogs(catalogService), catalogService);
    }

    private static List<EUR_CRM_ProductCatalog__c> createProductCatalogs(EUR_CRM_ProductCatalogServiceForTests catalogService) {
        List<EUR_CRM_ProductCatalog__c> catalogs = new List<EUR_CRM_ProductCatalog__c>();

        EUR_CRM_ProductCatalog__c sCat = catalogService.createStandardCatalog(false);
        sCat.EUR_CRM_External_ID__c = EUR_CRM_ProductCatalogServiceForTests.STANDARD_CATALOG_EXTERNAL_ID;
        insert sCat;

        catalogs.add(catalogService.generateCatalog(sCat, 'DirectCat', EUR_CRM_ProductCatalogServiceForTests.DIRECT_CATALOG_RECORD_TYPE_NAME));
        catalogs.add(catalogService.generateCatalog(sCat, 'IndirectCat', EUR_CRM_ProductCatalogServiceForTests.INDIRECT_CATALOG_RECORD_TYPE_NAME));
        catalogs.add(catalogService.generateCatalog(sCat, 'PosmCat', EUR_CRM_ProductCatalogServiceForTests.POSM_CATALOG_RECORD_TYPE_NAME));

        insert catalogs;

        catalogs.add(sCat);

        return catalogs;
    }

    private static void createProductCatalogItems(List<EUR_CRM_ProductCatalog__c> catalogs, EUR_CRM_ProductCatalogServiceForTests catalogService) {
        List<EUR_CRM_SKU__c> products = [SELECT Id FROM EUR_CRM_SKU__c LIMIT 5];

        List<EUR_CRM_ProductCatalogItem__c> catalogItems = new List<EUR_CRM_ProductCatalogItem__c>();

        for (EUR_CRM_ProductCatalog__c catalog : catalogs) {
            for (EUR_CRM_SKU__c product : products) {
                catalogItems.add(catalogService.generateProductCatalogItem(catalog, product));
            }
        }

        insert catalogItems;
    }

    private static List<EUR_CRM_ProductCatalogItem__c> getCatalogItems() {
        return [
                SELECT Id
                        , EUR_CRM_External_ID__c
                        , EUR_CRM_ProductMN__c
                        , EUR_CRM_PriceBookID__r.RecordType.Name
                        , EUR_CRM_PriceBookID__r.EUR_CRM_IsStandard__c
                        , EUR_CRM_PriceBookID__r.EUR_CRM_External_ID__c
                FROM EUR_CRM_ProductCatalogItem__c
                LIMIT 20
        ];
    }
}