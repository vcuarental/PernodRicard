/**
 * Created by illia on 06.08.18.
 */

@IsTest
private class EUR_CRM_AccountGeolocationBatchTest {
    @isTest
    private static void testCallout() {
        HttpResponse res = getInfoFromExternalService();

        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.assertEquals(200, res.getStatusCode());

    }

    @IsTest
    private static void simplePositiveTest() {
        insert makeAccounts();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AccountGeolocationBatchMockTest(200, false));

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGeolocationBatch());
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(2, accounts.size());
//        System.assertEquals(37.4224764, accounts[0].EUR_CRM_Outlet_Geolocation__Latitude__s);
//        System.assertEquals(-122.0842499, accounts[0].EUR_CRM_Outlet_Geolocation__Longitude__s);
    }

    @IsTest
    private static void simplePositiveTest2() {
        insert makeAccounts();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AccountGeolocationBatchMockTest(200, false));

        Test.startTest();
        EUR_CRM_AccountGeolocationBatch.executeForAll();
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(2, accounts.size());
//        System.assertEquals(37.4224764, accounts[0].EUR_CRM_Outlet_Geolocation__Latitude__s);
//        System.assertEquals(-122.0842499, accounts[0].EUR_CRM_Outlet_Geolocation__Longitude__s);
    }

    @IsTest
    private static void simpleNegativeWithBadStatusCodeTest() {
        insert makeAccounts();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AccountGeolocationBatchMockTest(500, false));

        Test.startTest();
        Database.executeBatch(new EUR_CRM_AccountGeolocationBatch());
        Test.stopTest();

        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.debug('accounts ' + JSON.serializePretty(accounts));
        System.assertEquals(2, accounts.size());
        System.assertEquals(null, accounts[0].EUR_CRM_Outlet_Geolocation__c);
    }

    @IsTest
    private static void simpleNegativeWithBadResponseTest() {
        List<EUR_CRM_Account__c> insertedAccounts = makeAccounts();
        List<Database.SaveResult> saveResult = Database.insert(insertedAccounts);
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AccountGeolocationBatchMockTest(200, true));

        Test.startTest();
        EUR_CRM_AccountGeolocationBatch accountGeolocationBatch = new EUR_CRM_AccountGeolocationBatch();
        Database.executeBatch(accountGeolocationBatch);
        Test.stopTest();

        accountGeolocationBatch.getErrorMessages(saveResult, insertedAccounts);
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.debug('accounts ' + JSON.serializePretty(accounts));
        System.assertEquals(2, accounts.size());
        System.assertEquals(null, accounts[0].EUR_CRM_Outlet_Geolocation__c);
    }

    @IsTest
    private static void scheduleTest() {

        String cronExpression = '0 0 1 * * ?'; // Runs every day at 1 AM
        EUR_CRM_AccountGeolocationBatch scheduledJob = new EUR_CRM_AccountGeolocationBatch();
        Test.setMock(HttpCalloutMock.class, new EUR_CRM_AccountGeolocationBatchMockTest(200, false));
        Test.startTest();
        String jobId = System.schedule('EUR_CRM_AccountGeolocationBatch: Populate Account\'s geolocation', cronExpression, scheduledJob);
        Test.stopTest();

        List<CronTrigger> cronTriggers = selectCronTriggers(jobId);
        System.assertEquals(1, cronTriggers.size());
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String country, String city, String street, String postalCode) {
        Id recTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_NL_On_Trade').getRecordTypeId();
        return new EUR_CRM_Account__c(
                          Name = 'Test Account'
                        , EUR_CRM_Postal_Code__c = postalCode
                        , EUR_CRM_Country__c = country
                        , EUR_CRM_City__c = city
                        , EUR_CRM_Street__c = street
                        , RecordTypeId = recTypeId
         );
    }

    private static List<EUR_CRM_Account__c> makeAccounts() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();

        accounts.add(makeAccount('United States', 'Mountain View', 'Amphitheatre Pkwy 1600', '94043'));
        accounts.add(makeAccount('Test country', 'Test city', 'Test street 10', '00000'));
        return accounts;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
                SELECT Id
                        , Name
                        , EUR_CRM_Country__c
                        , EUR_CRM_City__c
                        , EUR_CRM_Street__c
                        , EUR_CRM_Outlet_Geolocation__c
                        , EUR_CRM_Outlet_Geolocation__Longitude__s
                        , EUR_CRM_Outlet_Geolocation__Latitude__s
                        , EUR_CRM_OutletGeolocationRecalculation__c
                FROM EUR_CRM_Account__c
        ];
    }

    private static List<CronTrigger> selectCronTriggers(String jobId) {
        return [
                SELECT Id
                FROM CronTrigger
                WHERE Id = :jobId
        ];
    }

    /* ========================================================= */
    /*     Callout
    /* ========================================================= */
    private static HttpResponse getInfoFromExternalService() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('GET');
        return new EUR_CRM_AccountGeolocationBatchMockTest(200, false).respond(req);
    }


}