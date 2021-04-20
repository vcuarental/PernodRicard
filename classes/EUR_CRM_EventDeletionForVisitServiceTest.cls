@IsTest (IsParallel = true)
private class EUR_CRM_EventDeletionForVisitServiceTest {

    @TestSetup
    static void setup() {
        EUR_CRM_Account__c acc = makeAccount();
        insert acc;
        insert makeVisits(acc, 10);
    }

    @IsTest
    static void testSetup() {
        System.assertEquals(1, selectAccounts().size());
        System.assertEquals(10, selectVisits().size());
        System.assertEquals(10, selectEvents().size());
    }


    @IsTest
    static void testSingleDeletion() {
        delete selectVisits()[0];
        System.assertEquals(9, selectVisits().size());
        System.assertEquals(9, selectEvents().size());
    }

    @IsTest
    static void testMultipleDeletion() {
        delete selectVisits();
        System.assertEquals(0, selectVisits().size());
        System.assertEquals(0, selectEvents().size());
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

    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'test'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Visit__c> selectVisits() {
        return [
            SELECT Id
            FROM EUR_CRM_Visit__c
        ];
    }

    private static List<Event> selectEvents() {
        return [
            SELECT Id
            FROM Event
        ];
    }

    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
            SELECT Id
            FROM EUR_CRM_Account__c
        ];
    }

}