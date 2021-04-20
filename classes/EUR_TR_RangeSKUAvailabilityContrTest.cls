/**
 * Created by osman on 13.01.2021.
 */

@IsTest
private with sharing class EUR_TR_RangeSKUAvailabilityContrTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'Test Account';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_Status__c = 'Aktif';
        insert account;

        EUR_TR_RangeSKUAvailability__c rangeSKUAvailability = new EUR_TR_RangeSKUAvailability__c();
        rangeSKUAvailability.EUR_TR_RelatedAccount__c = account.Id;
        rangeSKUAvailability.RecordTypeId = Schema.SObjectType.EUR_TR_RangeSKUAvailability__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_RangeSKUAvailability').getRecordTypeId();
        rangeSKUAvailability.EUR_TR_Last3mAvailability__c = true;
        rangeSKUAvailability.EUR_TR_Last6mAvailability__c = true;
        rangeSKUAvailability.EUR_TR_Last9mAvailability__c = true;
        rangeSKUAvailability.EUR_TR_Last12mAvailability__c = true;
        rangeSKUAvailability.EUR_TR_RN__c = true;
        rangeSKUAvailability.EUR_TR_MTDAvailability__c = true;
        rangeSKUAvailability.EUR_TR_QTDAvailability__c = true;
        rangeSKUAvailability.EUR_TR_YTDAvailability__c = true;
        rangeSKUAvailability.EUR_TR_Range__c = 'STANDART';
        rangeSKUAvailability.EUR_TR_BrandQualitySize__c = 'JACK DANIELS /0.05 L';
        insert rangeSKUAvailability;

        EUR_TR_RangeSKUAvailability__c rangeSKUAvailability2 = new EUR_TR_RangeSKUAvailability__c();
        rangeSKUAvailability2.EUR_TR_RelatedAccount__c = account.Id;
        rangeSKUAvailability2.RecordTypeId = Schema.SObjectType.EUR_TR_RangeSKUAvailability__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_RangeSKUAvailability').getRecordTypeId();
        rangeSKUAvailability2.EUR_TR_Last3mAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_Last6mAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_Last9mAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_Last12mAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_RN__c = true;
        rangeSKUAvailability2.EUR_TR_MTDAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_QTDAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_YTDAvailability__c = true;
        rangeSKUAvailability2.EUR_TR_Range__c = 'STANDART';
        rangeSKUAvailability2.EUR_TR_BrandQualitySize__c = 'JACK DANIELS /0.375 L';
        insert rangeSKUAvailability2;

        EUR_TR_SKU__c sku = new EUR_TR_SKU__c();
        sku.EUR_TR_ImageUrl__c = 'https://dummy1.com.tr';
        sku.Name = 'JACK DANIELS /0.05 L';
        sku.EUR_TR_BrandQualitySize__c = 'JACK DANIELS /0.05 L';
        insert sku;

        EUR_TR_SKU__c sku2 = new EUR_TR_SKU__c();
        sku2.EUR_TR_ImageUrl__c = 'https://dummy1.com.tr';
        sku2.Name = 'JACK DANIELS /0.375 L';
        sku2.EUR_TR_BrandQualitySize__c = 'JACK DANIELS /0.375 L';
        insert sku2;


    }


    @IsTest
    static void testGetRangeSKUAvailabilityPercentagesFromMiddleware() {

        EUR_TR_Account__c account = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
        Test.startTest();
        {
            EUR_TR_RangeSKUAvailabilityController.getRangeSKUAvailabilityPercentagesFromMiddleware(JSON.serialize(account));
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetSKUAvailabilityFiltersFromMiddleware() {

        Test.startTest();
        {
            EUR_TR_RangeSKUAvailabilityController.getSKUAvailabilityFiltersFromMiddleware('');
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetListOfSKUByAvailabilityFilterFromMiddleware() {

        EUR_TR_Account__c account = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];

        Test.startTest();
        {
            EUR_TR_RangeSKUAvailabilityController.getListOfSKUByAvailabilityFilterFromMiddleware(JSON.serialize(account));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetListOfSKUByAvailabilityFilterFromMiddleware_error_account_Id_is_null() {

        EUR_TR_Account__c account = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];

        Test.startTest();
        {
            account.Id = null;
            EUR_TR_RangeSKUAvailabilityController.getListOfSKUByAvailabilityFilterFromMiddleware(JSON.serialize(account));
        }
        Test.stopTest();

    }

}