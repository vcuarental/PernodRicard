@IsTest (IsParallel = true)
private class EUR_CRM_AccountLastVisitDateServiceTest {


    @TestSetup
    private static void setupMethod() {
        Test.startTest();

        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        accounts.add(makeAccount(null));
        accounts.add(makeAccount(Datetime.now().addYears(-1)));
        insert accounts;
        
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Create Single Visit per Single Account
    /* ========================================================= */
    @IsTest
    private static void createSingleVisitPerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addMinutes(-1));
        insert visit;

        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
    }

//    @IsTest
//    private static void createSingleVisitInvalidRTperSingleAccountTest() {
//        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();
//
//        EUR_CRM_Visit__c visit = makeVisit('EUR_BG_Visit', account.Id, Datetime.now().addMinutes(-1));
//        insert visit;
//
//        account = selectAccounts()[0];
//        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);
//    }

    @IsTest
    private static void createSingleVisitWithPastStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addHours(-1));
        insert visit;

        account = selectAccountWithLastVisitDate();
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void createSingleVisitWithFutureStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addDays(1));
        insert visit;

        account = selectAccountWithLastVisitDate();
        System.assertNotEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
        System.assertNotEquals(null, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void createSingleVisitWithEmptyStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, null);
        insert visit;

        account = selectAccountWithLastVisitDate();
        System.assertNotEquals(null, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void createSingleVisitSeveralTimesPerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        Test.startTest();
        Id rtId = selectRecordTypesIdWhereDeveloperName('EUR_CH_Visit');
        EUR_CRM_Visit__c visit = makeVisit(rtId, account.Id, Datetime.now().addDays(-1));
        insert visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit = makeVisit(rtId, account.Id, Datetime.now().addDays(-3));
        insert visit;
        account = selectAccounts()[0];
        System.assertNotEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit = makeVisit(rtId, account.Id, Datetime.now().addHours(-1));
        insert visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit = makeVisit(rtId, account.Id, Datetime.now().addHours(-3));
        insert visit;
        account = selectAccounts()[0];
        System.assertNotEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit = makeVisit(rtId, account.Id, Datetime.now().addHours(1));
        insert visit;
        account = selectAccounts()[0];
        System.assertNotEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit = makeVisit(rtId, account.Id, Datetime.now().addHours(3));
        insert visit;
        account = selectAccounts()[0];
        System.assertNotEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit = makeVisit(rtId, account.Id, Datetime.now().addMinutes(-30));
        insert visit;
        account = selectAccounts()[0];
        //System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Create Multiple Visits per Single Account
    /* ========================================================= */
    @IsTest
    private static void createMultipleVisitsPerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        List<EUR_CRM_Visit__c> visits = makeVisits('EUR_CH_Visit', account.Id, 8);
        insert visits;

        account = selectAccounts()[0];
        //System.assertEquals(visits[0].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
    }

//    @IsTest
//    private static void createMultipleVisitsInvalidRTperSingleAccountTest() {
//        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();
//
//        List<EUR_CRM_Visit__c> visits = new List<EUR_CRM_Visit__c>();
//        visits.add(makeVisit('EUR_BG_Visit', account.Id, Datetime.now().addMinutes(-1)));
//        visits.add(makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addMinutes(-3)));
//        insert visits;
//
//        account = selectAccounts()[0];
//        System.assertEquals(visits[1].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
//    }

    @IsTest
    private static void createMultipleVisitsWithEmptyStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithLastVisitDate();

        List<EUR_CRM_Visit__c> visits = makeVisits('EUR_CH_Visit', account.Id, 8);
        for (EUR_CRM_Visit__c visit : visits) {
            visit.EUR_CRM_Start_Datetime__c = null;
        }
        insert visits;

        account = selectAccountWithLastVisitDate();
        System.assertNotEquals(null, account.EUR_CRM_Last_Visit_Date__c);
    }


    /* ========================================================= */
    /*     Update Single Visit per Single Account
    /* ========================================================= */
    @IsTest
    private static void updateSingleVisitPerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addMinutes(-3));
        insert visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addMinutes(-1);
        update visit;

        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void updateSingleVisitToPastStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addHours(1));
        insert visit;
        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-1);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void updateSingleVisitToFutureStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addDays(-1));
        insert visit;

        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addDays(1);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void updateSingleVisitWithEmptyStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        EUR_CRM_Visit__c visit = makeVisit('EUR_CH_Visit', account.Id, Datetime.now().addDays(-1));
        insert visit;

        account = selectAccounts()[0];
        System.assertNotEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = null;
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);
    }

    @IsTest
    private static void updateSingleVisitSeveralTimesPerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        Test.startTest();
        Id rtId = selectRecordTypesIdWhereDeveloperName('EUR_CH_Visit');
        EUR_CRM_Visit__c visit = makeVisit(rtId, account.Id, Datetime.now().addDays(-1));
        insert visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-3);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-1);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
        Test.stopTest();

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-3);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addHours(1);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addHours(3);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visit.EUR_CRM_Start_Datetime__c = Datetime.now().addMinutes(-30);
        update visit;
        account = selectAccounts()[0];
        System.assertEquals(visit.EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);
    }


    /* ========================================================= */
    /*     Update Multiple Visits per Single Account
    /* ========================================================= */
    @IsTest
    private static void updateMultipleVisitsFromEmptyStartDatePerSingleAccountTest() {
        EUR_CRM_Account__c account = selectAccountWithEmptyLastVisitDate();

        Test.startTest();
        List<EUR_CRM_Visit__c> visits = makeVisits('EUR_CH_Visit', account.Id, 8);
        for (EUR_CRM_Visit__c visit : visits) {
            visit.EUR_CRM_Start_Datetime__c = null;
        }
        insert visits;

        account = selectAccounts()[0];
        System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visits[0].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-3);
        visits[1].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-2);
        visits[2].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-1);
        visits[3].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-3);
        update visits;

        account = selectAccounts()[0];
        //System.assertEquals(visits[2].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visits[4].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-3);
        visits[5].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-2);
        visits[6].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-4);
        visits[7].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-3);
        update visits;

        account = selectAccounts()[0];
        //System.assertEquals(visits[5].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visits[0].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(1);
        visits[1].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-2);
        visits[2].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(2);
        visits[3].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-3);
        visits[4].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-1);
        visits[5].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-4);
        visits[6].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-7);
        visits[7].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-8);
        update visits;
        Test.stopTest();

        account = selectAccounts()[0];
        //System.assertEquals(visits[4].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visits[0].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(1);
        visits[1].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(3);
        visits[2].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(2);
        visits[3].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(5);
        visits[4].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(2);
        visits[5].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(7);
        visits[6].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(5);
        visits[7].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(2);
        update visits;

        account = selectAccounts()[0];
        //System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visits[3].EUR_CRM_Start_Datetime__c = Datetime.now().addHours(-3);
        update visits[3];
        account = selectAccounts()[0];
        //System.assertEquals(visits[3].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visits[3].EUR_CRM_Start_Datetime__c = null;
        update visits[3];
        account = selectAccounts()[0];
        //System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);

        visits[0].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-3);
        visits[1].EUR_CRM_Start_Datetime__c = Datetime.now().addDays(-1);
        update visits;

        account = selectAccounts()[0];
        //System.assertEquals(visits[1].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        visits[1].EUR_CRM_Start_Datetime__c = null;
        update visits[1];
        account = selectAccounts()[0];
        //System.assertEquals(visits[0].EUR_CRM_Start_Datetime__c, account.EUR_CRM_Last_Visit_Date__c);

        for (EUR_CRM_Visit__c visit : visits) {
            visit.EUR_CRM_Start_Datetime__c = null;
        }
        update visits;

        account = selectAccounts()[0];
        //System.assertEquals(null, account.EUR_CRM_Last_Visit_Date__c);
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Visit__c> makeVisits(String rtDevName, Id accId, Integer count) {
        Id rtId = selectRecordTypesIdWhereDeveloperName(rtDevName);
        List<EUR_CRM_Visit__c> visits = new List<EUR_CRM_Visit__c>();
        for (Integer i = 0; i < count / 2; i++) {
            visits.add(makeVisit(rtId, accId, Datetime.now().addDays(-1 * (i + 1))));
        }
        for (Integer i = 0; i < count / 2; i++) {
            visits.add(makeVisit(rtId, accId, Datetime.now().addDays(i + 1)));
        }
        return visits;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(Datetime dt) {
        return new EUR_CRM_Account__c(
            Name = 'Test Account'
        ,   EUR_CRM_Last_Visit_Date__c = dt
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_Visit__c makeVisit(String rtDevName, Id accId, Datetime dt) {
        EUR_CRM_Visit__c visit = makeVisitSkeleton(accId, dt);
        visit.RecordTypeId = selectRecordTypesIdWhereDeveloperName(rtDevName);
        visit.EUR_CRM_Status__c = 'Finished';
        return visit;
    }

    private static EUR_CRM_Visit__c makeVisit(Id rtId, Id accId, Datetime dt) {
        EUR_CRM_Visit__c visit = makeVisitSkeleton(accId, dt);
        visit.RecordTypeId = rtId;
        visit.EUR_CRM_Status__c = 'Finished';
        return visit;
    }

    private static EUR_CRM_Visit__c makeVisitSkeleton(Id accId, Datetime dt) {
        return new EUR_CRM_Visit__c(
            EUR_CRM_Account__c = accId
        ,   EUR_CRM_Start_Datetime__c = dt
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static EUR_CRM_Account__c selectAccountWithEmptyLastVisitDate() {
        return [
            SELECT Id
            ,   EUR_CRM_Last_Visit_Date__c
            FROM EUR_CRM_Account__c
            WHERE EUR_CRM_Last_Visit_Date__c = NULL
            LIMIT 1
        ][0];
    }
    private static EUR_CRM_Account__c selectAccountWithLastVisitDate() {
        return [
            SELECT Id
            ,   EUR_CRM_Last_Visit_Date__c
            FROM EUR_CRM_Account__c
            WHERE EUR_CRM_Last_Visit_Date__c != NULL
            LIMIT 1
        ][0];
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            ,   EUR_CRM_Last_Visit_Date__c
            FROM EUR_CRM_Account__c
        ];
    }

    private static Id selectRecordTypesIdWhereDeveloperName(String devName) {
        return [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :devName
                AND SobjectType = 'EUR_CRM_Visit__c'
            LIMIT 1
        ][0].Id;
    }

}