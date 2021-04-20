@IsTest (IsParallel = true)
private class EUR_CRM_EventCreationForVisitServiceTest {


    /* ======================================================================= */
    /*     Create Event - Positive tests (Country rollout is completed)
    /* ======================================================================= */
    @IsTest
    private static void createSingleEventPositiveTest() {
        
        final String ACC_NM = 'TestNamePlz';
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        account.Name = ACC_NM;
        insert account;

        System.assertEquals(0, selectVisits().size());
        System.assertEquals(0, selectEvents().size());

        Test.startTest();
        insert makeVisits(account, 1);
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(1, visits.size());
        System.assertEquals(1, events.size());

        System.assertEquals(events[0].OwnerId, visits[0].OwnerId);
        System.assertEquals(events[0].StartDateTime, visits[0].EUR_CRM_Start_Datetime__c);
        System.assertEquals(events[0].EndDateTime, visits[0].EUR_CRM_End_Datetime__c);
        System.assertEquals(events[0].WhatId, visits[0].EUR_CRM_Account__c);
        System.assertEquals(events[0].EUR_CRM_Visit__c, visits[0].Id);
        System.assertEquals(events[0].PR_Customer_Response__c, visits[0].EUR_CRM_Customer_Response__c);
        
        System.assertEquals(events[0].Subject, visits[0].EUR_CRM_Account__r.Name);       
        System.assertEquals(events[0].Subject, ACC_NM);   
    }

    @IsTest
    private static void createMultipleEventsPositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        System.assertEquals(0, selectVisits().size());
        System.assertEquals(0, selectEvents().size());

        Test.startTest();
        insert makeVisits(account, 10);
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(10, visits.size());
        System.assertEquals(10, events.size());

        Map<Id, EUR_CRM_Visit__c> visitsByIds = new Map<Id, EUR_CRM_Visit__c>(visits);
        for (Event evt : events) {
            EUR_CRM_Visit__c visit = visitsByIds.get(evt.EUR_CRM_Visit__c);
            System.assertEquals(evt.OwnerId, visit.OwnerId);
            System.assertEquals(evt.StartDateTime, visit.EUR_CRM_Start_Datetime__c);
            System.assertEquals(evt.EndDateTime, visit.EUR_CRM_End_Datetime__c);
            System.assertEquals(evt.WhatId, visit.EUR_CRM_Account__c);
            System.assertEquals(evt.EUR_CRM_Visit__c, visit.Id);
            System.assertEquals(evt.PR_Customer_Response__c, visit.EUR_CRM_Customer_Response__c);
        }
    }


    /* =========================================================================== */
    /*     Create Event - Negative tests (Country rollout is not completed)
    /* =========================================================================== */
    @IsTest
    private static void createSingleNegativeTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_LV_DIR_OFF_Trade');
        insert account;

        System.assertEquals(0, selectVisits().size());
        System.assertEquals(0, selectEvents().size());

        Test.startTest();
        insert makeVisits(account, 1);
        Test.stopTest();

        System.assertEquals(1, selectVisits().size());
        System.assertEquals(0, selectEvents().size());

        delete selectVisits();
    }

    @IsTest
    private static void createMultipleNegativeTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_LV_DIR_OFF_Trade');
        insert account;

        System.assertEquals(0, selectVisits().size());
        System.assertEquals(0, selectEvents().size());

        Test.startTest();
        insert makeVisits(account, 10);
        Test.stopTest();

        System.assertEquals(10, selectVisits().size());
        System.assertEquals(0, selectEvents().size());

        delete selectVisits();
    }


    /* ======================================================================= */
    /*     Update Event - Positive tests (Country rollout is completed)
    /* ======================================================================= */
 
    @IsTest
    private static void updateStartDateSinglePositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        EUR_CRM_Visit__c visit = makeVisits(account, 1)[0];
        insert visit;

        System.assertEquals(1, selectVisits().size());
        System.assertEquals(1, selectEvents().size());

        Test.startTest();
        visit.EUR_CRM_Start_Datetime__c = visit.EUR_CRM_Start_Datetime__c.addHours(2);
        
        update visit;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(1, visits.size());
        System.assertEquals(1, events.size());

        System.assertEquals(events[0].StartDateTime, visits[0].EUR_CRM_Start_Datetime__c);
        System.assertEquals(events[0].EndDateTime, visits[0].EUR_CRM_End_Datetime__c);
    }

    @IsTest
    private static void updateStartDateMultiplePositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        List<EUR_CRM_Visit__c> visitsToInsert =  makeVisits(account, 10);
        insert visitsToInsert;

        System.assertEquals(10, selectVisits().size());
        System.assertEquals(10, selectEvents().size());

        Test.startTest();
        for (EUR_CRM_Visit__c visit : visitsToInsert) {
            visit.EUR_CRM_Start_Datetime__c = visit.EUR_CRM_Start_Datetime__c.addHours(2);
        }
        update visitsToInsert;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(10, visits.size());
        System.assertEquals(10, events.size());

        Map<Id, EUR_CRM_Visit__c> visitsByIds = new Map<Id, EUR_CRM_Visit__c>(visits);
        for (Event evt : events) {
            EUR_CRM_Visit__c visit = visitsByIds.get(evt.EUR_CRM_Visit__c);
            System.assertEquals(evt.StartDateTime, visit.EUR_CRM_Start_Datetime__c);
            System.assertEquals(evt.EndDateTime, visit.EUR_CRM_End_Datetime__c);
        }
    }

    @IsTest
    private static void updateEndDateSinglePositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        EUR_CRM_Visit__c visit = makeVisits(account, 1)[0];
        insert visit;

        System.assertEquals(1, selectVisits().size());
        System.assertEquals(1, selectEvents().size());

        Test.startTest();
        visit.EUR_CRM_End_Datetime__c = visit.EUR_CRM_End_Datetime__c.addDays(2);
        update visit;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(1, visits.size());
        System.assertEquals(1, events.size());

        System.assertEquals(events[0].StartDateTime, visits[0].EUR_CRM_Start_Datetime__c);
        System.assertEquals(events[0].EndDateTime, visits[0].EUR_CRM_End_Datetime__c);
    }

    @IsTest
    private static void updateEndDateMultiplePositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        List<EUR_CRM_Visit__c> visitsToInsert =  makeVisits(account, 10);
        insert visitsToInsert;

        System.assertEquals(10, selectVisits().size());
        System.assertEquals(10, selectEvents().size());

        Test.startTest();
        for (EUR_CRM_Visit__c visit : visitsToInsert) {
            visit.EUR_CRM_End_Datetime__c = visit.EUR_CRM_End_Datetime__c.addDays(2);
        }
        update visitsToInsert;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(10, visits.size());
        System.assertEquals(10, events.size());

        Map<Id, EUR_CRM_Visit__c> visitsByIds = new Map<Id, EUR_CRM_Visit__c>(visits);
        for (Event evt : events) {
            EUR_CRM_Visit__c visit = visitsByIds.get(evt.EUR_CRM_Visit__c);
            System.assertEquals(evt.StartDateTime, visit.EUR_CRM_Start_Datetime__c);
            System.assertEquals(evt.EndDateTime, visit.EUR_CRM_End_Datetime__c);
        }
    }

    @IsTest
    private static void updateBothDatesSinglePositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        EUR_CRM_Visit__c visit = makeVisits(account, 1)[0];
        insert visit;

        System.assertEquals(1, selectVisits().size());
        System.assertEquals(1, selectEvents().size());

        Test.startTest();
        visit.EUR_CRM_Start_Datetime__c = visit.EUR_CRM_Start_Datetime__c.addDays(2);
        visit.EUR_CRM_End_Datetime__c = visit.EUR_CRM_End_Datetime__c.addDays(2);
        update visit;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(1, visits.size());
        System.assertEquals(1, events.size());

        System.assertEquals(events[0].StartDateTime, visits[0].EUR_CRM_Start_Datetime__c);
        System.assertEquals(events[0].EndDateTime, visits[0].EUR_CRM_End_Datetime__c);
    }

    @IsTest
    private static void updateBothDatesMultiplePositiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        List<EUR_CRM_Visit__c> visitsToInsert =  makeVisits(account, 10);
        insert visitsToInsert;

        System.assertEquals(10, selectVisits().size());
        System.assertEquals(10, selectEvents().size());

        Test.startTest();
        for (EUR_CRM_Visit__c visit : visitsToInsert) {
            visit.EUR_CRM_Start_Datetime__c = visit.EUR_CRM_Start_Datetime__c.addDays(2);
            visit.EUR_CRM_End_Datetime__c = visit.EUR_CRM_End_Datetime__c.addDays(2);
        }
        update visitsToInsert;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(10, visits.size());
        System.assertEquals(10, events.size());

        Map<Id, EUR_CRM_Visit__c> visitsByIds = new Map<Id, EUR_CRM_Visit__c>(visits);
        for (Event evt : events) {
            EUR_CRM_Visit__c visit = visitsByIds.get(evt.EUR_CRM_Visit__c);
            System.assertEquals(evt.StartDateTime, visit.EUR_CRM_Start_Datetime__c);
            System.assertEquals(evt.EndDateTime, visit.EUR_CRM_End_Datetime__c);
        }
    }

    @IsTest
    private static void updateAccountSingleNegativeTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        EUR_CRM_Visit__c visit = makeVisits(account, 1)[0];
        insert visit;

        System.assertEquals(1, selectVisits().size());
        System.assertEquals(1, selectEvents().size());

        Test.startTest();
        visit.EUR_CRM_Account__c = null;
        update visit;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(1, visits.size());
        System.assertEquals(1, events.size());

        System.assertEquals(events[0].StartDateTime, visits[0].EUR_CRM_Start_Datetime__c);
        System.assertEquals(events[0].EndDateTime, visits[0].EUR_CRM_End_Datetime__c);
    }

    @IsTest
    private static void updateAccountMultipNegasitiveTest() {
        EUR_CRM_Account__c account = makeAccount('EUR_NL_Off_Trade');
        insert account;

        List<EUR_CRM_Visit__c> visitsToInsert =  makeVisits(account, 10);
        insert visitsToInsert;

        System.assertEquals(10, selectVisits().size());
        System.assertEquals(10, selectEvents().size());

        Test.startTest();
        for (EUR_CRM_Visit__c visit : visitsToInsert) {
            visit.EUR_CRM_Account__c = null;
        }
        update visitsToInsert;
        Test.stopTest();

        List<EUR_CRM_Visit__c> visits = selectVisits();
        List<Event> events = selectEvents();

        System.assertEquals(10, visits.size());
        System.assertEquals(10, events.size());

        Map<Id, EUR_CRM_Visit__c> visitsByIds = new Map<Id, EUR_CRM_Visit__c>(visits);
        for (Event evt : events) {
            EUR_CRM_Visit__c visit = visitsByIds.get(evt.EUR_CRM_Visit__c);
            System.assertEquals(evt.StartDateTime, visit.EUR_CRM_Start_Datetime__c);
            System.assertEquals(evt.EndDateTime, visit.EUR_CRM_End_Datetime__c);
        }
    }


    /* ========================================================= */
    /*     High Level Makers
    /* ========================================================= */
    private static List<EUR_CRM_Visit__c> makeVisits(EUR_CRM_Account__c acc, Integer numberOfVisits) {
        List<EUR_CRM_Visit__c> visits = new List<EUR_CRM_Visit__c>();
        for (Integer i = 0; i < numberOfVisits; i++) {
            visits.add(makeVisit(acc));
        }
        return visits;
    }


    /* ========================================================= */
    /*     Low Level Makers
    /* ========================================================= */
    private static EUR_CRM_Visit__c makeVisit(EUR_CRM_Account__c acc) {
        return new EUR_CRM_Visit__c(
            EUR_CRM_Start_Datetime__c = Datetime.now()
        ,   EUR_CRM_End_Datetime__c = Datetime.now().addDays(1)
        ,   EUR_CRM_Account__c = acc.Id
        );
    }

    private static EUR_CRM_Account__c makeAccount(String rtDevName) {
        return new EUR_CRM_Account__c(
            Name = 'test'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rtDevName).getRecordTypeId()
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Visit__c> selectVisits() {
        return [
            SELECT Id
            ,   OwnerId
            ,   EUR_CRM_Start_Datetime__c
            ,   EUR_CRM_End_Datetime__c
            ,   EUR_CRM_Account__c
            ,   EUR_CRM_Customer_Response__c
            ,   EUR_CRM_Account__r.Name
            FROM EUR_CRM_Visit__c
        ];
    }

    private static List<Event> selectEvents() {
        return [
            SELECT Id
            ,   OwnerId
            ,   StartDateTime
            ,   EndDateTime
            ,   WhatId
            ,   EUR_CRM_Visit__c
            ,   PR_Customer_Response__c
            ,   Subject
            FROM Event
        ];
    }

}