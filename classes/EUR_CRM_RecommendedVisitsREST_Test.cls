/**
 * Created by Ilarion Tokarskyi on 06.11.2020.
 */

@IsTest(IsParallel=true)
private class EUR_CRM_RecommendedVisitsREST_Test {

    static String requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/convivio/v1/recommended-accounts/';

    @TestSetup
    static void setup() {
        List<EUR_CRM_Account__c> accounts = EUR_CRM_TestClassUtilityHelper.createAccountsEU(5, 'EUR DE On Trade B2B');
        insert accounts;
        EUR_CRM_Brand__c brand = createBrand();
        insert brand;
    }

    @IsTest
    static void testPostPositive() {
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_Brand__c brand = [SELECT Id FROM EUR_CRM_Brand__c LIMIT 1];
        RestContext.request = setPostRestRequest(setupBody(account.Id, brand.Id,'2020-11-02',false));
        RestContext.response = new RestResponse();

        Test.startTest();
        EUR_CRM_RecommendedVisitsREST.doPost();
        Test.stopTest();

        System.debug('<== Response Body ==> \n' + RestContext.response.responseBody.toString());
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostInvalidBody() {
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_Brand__c brand = [SELECT Id FROM EUR_CRM_Brand__c LIMIT 1];
        RestContext.request = setPostRestRequest(setupBody(account.Id, brand.Id,'2020-11-02',true));
        RestContext.response = new RestResponse();

        Test.startTest();
        EUR_CRM_RecommendedVisitsREST.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostInvalidWeekAndAccounts() {
        RestContext.request = setPostRestRequest(setupBody('aCa0Q00000998NRSAY', 'aCa0Q000000093DSAQ','2020-11-04',
                false));
        RestContext.response = new RestResponse();

        Test.startTest();
        EUR_CRM_RecommendedVisitsREST.doPost();
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

    private static EUR_CRM_Brand__c createBrand() {
        Id rtId =  Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByName().get('EUR DE Brand')
                .getRecordTypeId();
        return new EUR_CRM_Brand__c(RecordTypeId = rtId, Name = 'Test Name', EUR_CRM_Active__c = TRUE);
    }

    private static String setupBody(Id accId, Id brandId, String weekStartDate, Boolean makeInvalid) {
        String body = '{\n' +
                '  "Weeks": [\n' +
                '    {\n' +
                '      "WeekStartDate": "'+ weekStartDate +'",\n' +
                '      "Affiliate": "DE",\n' +
                '      "BusinessDevNumber": 2,\n' +
                '      "accounts": [\n' +
                '        {\n' +
                '          "Id": "'+ accId +'",\n' +
                '          "VisitType": "Promotion",\n' +
                '          "visitRank": "2",\n' +
                '          "PromotionScore": 0.5,\n' +
                '          "BusinessDevScore": 0.2,\n' +
                '          "Promotions": [\n' +
                '            {\n' +
                '              "Promotion": "KW 50 Handzettel GAM Logo Heurich",\n' +
                '              "Products": [\n' +
                '                "'+ brandId +'"\n' +
                '              ]\n' +
                '            }\n' +
                '          ]\n' +
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
}