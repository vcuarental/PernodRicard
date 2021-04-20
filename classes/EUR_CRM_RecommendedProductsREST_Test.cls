/**
 * Created by larsz on 01.12.2020.
 */

@IsTest
private class EUR_CRM_RecommendedProductsREST_Test {
    static String requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/convivio/v1/recommended-products/';

    @TestSetup
    static void setup() {
        List<EUR_CRM_Account__c> accounts = EUR_CRM_TestClassUtilityHelper.createAccountsEU(5, 'EUR DE On Trade B2B');
        insert accounts;
        EUR_CRM_Brand__c brand = createBrand();
        insert brand;
    }

    @IsTest
    static void testPositiveBody() {
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_Brand__c brand = [SELECT Id FROM EUR_CRM_Brand__c LIMIT 1];
        RestContext.request = setPostRestRequest(setupBody(account.Id, brand.Id,false));
        RestContext.response = new RestResponse();

        Test.startTest();
        EUR_CRM_RecommendedProductsREST.doPost();
        Test.stopTest();

        System.debug('<== Response Body ==> \n' + RestContext.response.responseBody.toString());
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testInvalidBody() {
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_Brand__c brand = [SELECT Id FROM EUR_CRM_Brand__c LIMIT 1];
        RestContext.request = setPostRestRequest(setupBody(account.Id, brand.Id,true));
        RestContext.response = new RestResponse();

        Test.startTest();
        EUR_CRM_RecommendedProductsREST.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void testInvalidAccAndProdIds() {
        RestContext.request = setPostRestRequest(setupBody('aCa0Q00000998NRSAY', 'aCa0Q000000093DSAQ',
                false));
        RestContext.response = new RestResponse();

        Test.startTest();
        EUR_CRM_RecommendedProductsREST.doPost();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
    }

    private static RestRequest setPostRestRequest(String body) {
        RestRequest request = new RestRequest();
        request.requestURI = requestUri;
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(body);
        return request;
    }

    private static String setupBody(Id accId, Id brandId, Boolean makeInvalid) {
        String body = '{\n' +
                '  "accounts": [\n' +
                '    {\n' +
                '      "Id": "'+ accId +'",\n' +
                '      "Affiliate": "DE",\n' +
                '      "FinancialCategory": "Low sell out",\n' +
                '      "EnvironmentType": "Focus area",\n' +
                '      "PhysicalInfo": "Edeka",\n' +
                '      "StoreSize": 600,\n' +
                '      "SellOutPotentialFood": 12.2,\n' +
                '      "FoodRatio": 0.86,\n' +
                '      "AnnualTarget": 5,\n' +
                '      "VisitTargetToday": 4.2,\n' +
                '      "CurrentVisitNumber": 3,\n' +
                '      "LastFacingsNumber": 23,\n' +
                '      "Products": [\n' +
                '        {\n' +
                '          "Id": "'+ brandId +'",\n' +
                '          "Name": "Lillet Blanc",\n' +
                '          "Rank": 1,\n' +
                '          "Category": "Aperitif",\n' +
                '          "CategoryRankPR": 5,\n' +
                '          "CategoryRankAll": 7,\n' +
                '          "RankSimilarStores": 12,\n' +
                '          "RankRegion": 14,\n' +
                '          "Presence": 0.56,\n' +
                '          "AverageFacings": 2,\n' +
                '          "IsHouseOfBrands": true\n' +
                '        }\n' +
                '      ]\n' +
                '    }\n' +
                '  ]\n' +
                '}';
        if (makeInvalid) {
            body = body.reverse();
        }
        return body;
    }

    private static EUR_CRM_Brand__c createBrand() {
        Id rtId =  Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByName().get('EUR DE Brand')
                .getRecordTypeId();
        return new EUR_CRM_Brand__c(RecordTypeId = rtId, Name = 'Test Name', EUR_CRM_Active__c = TRUE);
    }
}