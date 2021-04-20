@IsTest (IsParallel = true)
private class EUR_CRM_VisitSyncWithEventServiceTest {

    @TestSetup
    static void setup() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_Account__c account = makeAccount();
            insert account;

            insert makeVisit(account.Id);
        }
    }

    @IsTest
    static void testSetup() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            System.assertEquals(1, selectVisits().size());
            System.assertEquals(1, selectEvents().size());
        }
    }

    @IsTest
    static void singleEventTest() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            Event evt = selectEvents()[0];

            Test.startTest();
            evt.PR_Customer_Response__c = 'Yes';
            update evt;
            Test.stopTest();

            EUR_CRM_Visit__c visit = selectVisits()[0];
            System.assertEquals(evt.PR_Customer_Response__c, visit.EUR_CRM_Customer_Response__c);
        }
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount() {
        return new EUR_CRM_Account__c(
            Name = 'test'
        ,   EUR_CRM_Postal_Code__c = '1122'
        ,   RecordTypeId = EUR_CRM_RecordTypeHelper_v2.getRTByDevName('EUR_CRM_Account__c', 'EUR_LV_DIR_OFF_Trade')
        );
    }

    private static EUR_CRM_Visit__c makeVisit(Id accId) {
        return new EUR_CRM_Visit__c(
            EUR_CRM_Account__c = accId
        ,   EUR_CRM_Start_Datetime__c = Datetime.now()
        ,   EUR_CRM_End_Datetime__c = Datetime.now().addDays(1)
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Visit__c> selectVisits() {
        return [
            SELECT Id
            ,   EUR_CRM_Customer_Response__c
            FROM EUR_CRM_Visit__c
        ];
    }

    private static List<Event> selectEvents() {
        return [
            SELECT Id
            ,   PR_Customer_Response__c
            FROM Event
        ];
    }

    private static List<User> getEMEAandEURsystemAdminUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'EUR System Admin'
                AND UserRole.Name = 'EMEA'
            LIMIT 1
        ];
    }

}