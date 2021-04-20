/**
 * Created by Murat Can on 21/09/2020.
 */

@IsTest
private class EUR_TR_OJTControllerTest {

    @TestSetup
    static void setupTest() {
        EUR_TR_Account__c account = new EUR_TR_Account__c();

        account.Name = 'Test OJT';
        account.EUR_TR_PresellerName__c = 'Test OJT';

        insert account;

        EUR_TR_Employee__c employee = new EUR_TR_Employee__c();

        employee.Name = 'Test OJT';
        employee.EUR_TR_RelatedUser__c = UserInfo.getUserId();

        insert employee;

        EUR_TR_Definition__c configuration = new EUR_TR_Definition__c();

        configuration.EUR_TR_OJTDayCheckInterval__c = 30;
        configuration.EUR_TR_OJTDayCheckIntervalForFuture__c = 15;
        configuration.EUR_TR_OJTDayCheckInterval__c = 6;
        configuration.EUR_TR_MinimumRequiredOJTVisit__c = 2;
        configuration.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OJT').getRecordTypeId();

        insert configuration;
    }

    @IsTest
    static void testPlanAndVisits() {
        EUR_TR_OJT__c ojtRequest = new EUR_TR_OJT__c();

        ojtRequest.EUR_TR_PlanedStartTime__c = Datetime.now();
        ojtRequest.EUR_TR_PlanedEndTime__c = Datetime.now();
        ojtRequest.EUR_TR_Preseller__c = getEmployeeId();

        Test.startTest();

        /** Test -> createOJTPlan **/
        EUR_TR_OJTController.createOJTPlanFromMiddleware(JSON.serialize(ojtRequest));

        ojtRequest = [
                SELECT Id, EUR_TR_PlanedStartTime__c, EUR_TR_PlanedEndTime__c, EUR_TR_Preseller__c
                FROM EUR_TR_OJT__c
                WHERE EUR_TR_Preseller__c = :ojtRequest.EUR_TR_Preseller__c
                AND EUR_TR_Status__c = 'Planlandı'
        ];

        /** Test -> listOJTPlans **/
        EUR_TR_OJTController.OJTRequest listOJTPlansRequest = new EUR_TR_OJTController.OJTRequest();

        listOJTPlansRequest.pageNumber = 1;
        listOJTPlansRequest.pageSize = 5;

        EUR_TR_OJTController.listOJTPlansPlansFromMiddleware(JSON.serialize(listOJTPlansRequest));

        /** Test -> startOJTPlan **/
        EUR_TR_OJTController.startOJTPlanFromMiddleware(JSON.serialize(ojtRequest));

        /** Test -> listOJTAccountsByRelatedPlan **/
        EUR_TR_OJTController.OJTRequest listOJTAccountsRequestByName = new EUR_TR_OJTController.OJTRequest();

        listOJTAccountsRequestByName.pageSize = 5;
        listOJTAccountsRequestByName.pageNumber = 1;
        listOJTAccountsRequestByName.data = new EUR_TR_OJT__c(EUR_TR_RelatedDay__c = ojtRequest.Id);
        listOJTAccountsRequestByName.orderBy = EUR_TR_OJTController.OrderByFields.name;
        listOJTAccountsRequestByName.searchTerm = 'test';

        List<EUR_TR_OJT__c> plans = EUR_TR_OJTController.listOJTAccountsByRelatedPlanFromMiddleware(JSON.serialize(listOJTAccountsRequestByName)).Data;

        EUR_TR_OJTController.OJTRequest listOJTAccountsRequestByLocation = new EUR_TR_OJTController.OJTRequest();

        listOJTAccountsRequestByLocation.pageSize = 5;
        listOJTAccountsRequestByLocation.pageNumber = 1;
        listOJTAccountsRequestByLocation.data = new EUR_TR_OJT__c(EUR_TR_RelatedDay__c = ojtRequest.Id);
        listOJTAccountsRequestByLocation.orderBy = EUR_TR_OJTController.OrderByFields.location;
        listOJTAccountsRequestByLocation.latitude = 12.123;
        listOJTAccountsRequestByLocation.longitude = 12.123;

        EUR_TR_OJTController.listOJTAccountsByRelatedPlanFromMiddleware(JSON.serialize(listOJTAccountsRequestByLocation));

        /** Test -> startOJTCustomerVisit **/
        EUR_TR_OJT__c ojtVisit = (EUR_TR_OJT__c) EUR_TR_OJTController.startOJTCustomerVisitFromMiddleware(JSON.serialize(plans[0])).ExtensionData;

        /** Test -> endOJTCustomerVisit **/
        EUR_TR_OJTController.endOJTCustomerVisitFromMiddleware(JSON.serialize(ojtVisit));

        /** Test -> endOJTPlan **/
        EUR_TR_OJTController.endOJTPlanFromMiddleware(JSON.serialize(ojtRequest));

        /** Test -> sendOJTEmail **/
        EUR_TR_OJTController.OJTActionRequestAfterOJTComplete ojtActionRequestAfterOJTCompleteRequest = new EUR_TR_OJTController.OJTActionRequestAfterOJTComplete();

        ojtRequest.EUR_TR_Note__c = 'Note';
        ojtActionRequestAfterOJTCompleteRequest.data = ojtRequest;
        ojtActionRequestAfterOJTCompleteRequest.emailAddress = 'test@test.com';
        ojtActionRequestAfterOJTCompleteRequest.sendEmail = true;
        ojtActionRequestAfterOJTCompleteRequest.addNote = true;

        //makeOJTActionsAfterOJTComplete.
        EUR_TR_OJTController.makeOJTActionsAfterOJTComplete(JSON.serialize(ojtActionRequestAfterOJTCompleteRequest));

        EUR_TR_OJTController.OJTRequest sendOjtEmailRequest = new EUR_TR_OJTController.OJTRequest();

        sendOjtEmailRequest.emailAddress = 'test@test.com';
        sendOjtEmailRequest.data = ojtRequest;

        EUR_TR_OJTController.sendOJTEmailFromMiddleware(JSON.serialize(sendOjtEmailRequest));

        /** Test -> deleteOJTPlan **/
        EUR_TR_OJTController.deleteOJTPlanFromMiddleware(JSON.serialize(ojtRequest));

        Test.stopTest();
    }

    @IsTest
    static void testOJTDateValidations() {
        EUR_TR_Employee__c chief = new EUR_TR_Employee__c();

        chief.Name = 'Test OJT chief';
        chief.EUR_TR_RelatedUser__c = UserInfo.getUserId();
        chief.RecordTypeId = UserInfo.getUserId();
        chief.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();

        insert chief;

        EUR_TR_Employee__c preseller1 = new EUR_TR_Employee__c();

        preseller1.Name = 'Test OJT preseller1';
        preseller1.EUR_TR_RelatedUser__c = UserInfo.getUserId();
        preseller1.EUR_TR_ReportsTo_Chief__c = chief.Id;
        preseller1.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Preseller').getRecordTypeId();

        insert preseller1;

        EUR_TR_Employee__c preseller2 = new EUR_TR_Employee__c();

        preseller2.Name = 'Test OJT preseller2';
        preseller2.EUR_TR_RelatedUser__c = UserInfo.getUserId();
        preseller2.EUR_TR_ReportsTo_Chief__c = chief.Id;
        preseller2.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Preseller').getRecordTypeId();

        insert preseller2;

        EUR_TR_OJT__c ojtRequest1 = new EUR_TR_OJT__c();

        ojtRequest1.EUR_TR_PlanedStartTime__c = Datetime.now();
        ojtRequest1.EUR_TR_PlanedEndTime__c = Datetime.now();
        ojtRequest1.EUR_TR_Preseller__c = getEmployeeId();

        EUR_TR_OJTController.createOJTPlanFromMiddleware(JSON.serialize(ojtRequest1));

        Test.startTest();

        EUR_TR_OJT__c ojtRequest2 = new EUR_TR_OJT__c();

        ojtRequest2.EUR_TR_PlanedStartTime__c = Datetime.now().addDays(5);
        ojtRequest2.EUR_TR_PlanedEndTime__c = Datetime.now().addDays(5);
        ojtRequest2.EUR_TR_Preseller__c = getEmployeeId();


        EUR_TR_OJTController.createOJTPlanFromMiddleware(JSON.serialize(ojtRequest2));

        Test.stopTest();
    }

    @IsTest
    static void testGetUserIdFromEmployeeId() {
        EUR_TR_OJTController.getUserIdFromEmployeeId(getEmployeeId());
    }

    @IsTest
    static void getOrganizationScores_SuccessTest() {
        User chiefUser = [SELECT Id, Name,ManagerId FROM User WHERE UserRole.DeveloperName LIKE 'EUR_TR_SalesChiefs' AND IsActive = true LIMIT 1];

        EUR_TR_Employee__c areaManager = new EUR_TR_Employee__c();
        areaManager.Name = 'Test Area Manager';
        areaManager.EUR_TR_RelatedUser__c = chiefUser.ManagerId;
        areaManager.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AreaManager').getRecordTypeId();
        insert areaManager;

        EUR_TR_Employee__c chief = new EUR_TR_Employee__c();
        chief.Name = 'Test Chief';
        chief.EUR_TR_RelatedUser__c = chiefUser.Id;
        chief.EUR_TR_ReportsTo_AreaManager__c = areaManager.Id;
        chief.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();
        insert chief;

        EUR_TR_Employee__c preSeller = new EUR_TR_Employee__c();
        preSeller.Name = 'Test PreSeller';
        preSeller.EUR_TR_ReportsTo_Chief__c = chief.Id;
        preSeller.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Preseller').getRecordTypeId();
        insert preSeller;


        //Create OJT Plan
        EUR_TR_OJT__c ojtPlan = new EUR_TR_OJT__c();
        ojtPlan.EUR_TR_PlanedStartTime__c = Datetime.now().addHours(-3);
        ojtPlan.EUR_TR_PlanedEndTime__c = Datetime.now().addHours(1);
        ojtPlan.EUR_TR_Preseller__c = preSeller.Id;
        ojtPlan.OwnerId = chiefUser.Id;
        EUR_TR_OJTController.createOJTPlan(ojtPlan);

        //Start OJT Plan
        EUR_TR_OJTController.startOJTPlan(ojtPlan);

        //Start OJT Detail
        EUR_TR_OJT__c ojtDetail = new EUR_TR_OJT__c();
        ojtDetail.EUR_TR_Account__c = getAccountId();
        ojtDetail.EUR_TR_RelatedDay__c = ojtPlan.Id;
        EUR_TR_OJTController.startOJTCustomerVisit(ojtDetail);

        //End OJT
        for (Integer i = 1; i <= 10; i++) {
            EUR_TR_OJT__c question = new EUR_TR_OJT__c();
            question.Name = 'Test Quesiton ' + i;
            question.RecordTypeId = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Question').getRecordTypeId();
            question.EUR_TR_MinScore__c = i;
            question.EUR_TR_IsActive__c = true;
            insert question;

            EUR_TR_OJT__c answer = new EUR_TR_OJT__c();
            answer.Name = 'Test Answer ' + i;
            answer.RecordTypeId = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Answer').getRecordTypeId();
            answer.EUR_TR_Score__c = i + 1;
            answer.EUR_TR_RelatedDetail__c = ojtDetail.Id;
            answer.EUR_TR_RelatedQuestion__c = question.Id;
            insert answer;
        }
        EUR_TR_OJT__c ojtEndVisit = [
                SELECT Id, EUR_TR_Account__c, EUR_TR_Preseller__c, EUR_TR_Score__c, EUR_TR_RelatedQuestion__c, (
                        SELECT Id,EUR_TR_Score__c,EUR_TR_RelatedQuestion__c
                        FROM EUR_TR_Answers__r
                )
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtDetail.Id
        ];
        for (EUR_TR_OJT__c answer : ojtEndVisit.EUR_TR_Answers__r) {
            answer.Id = null;
        }
        EUR_TR_OJTController.endOJTCustomerVisit(ojtEndVisit);
        EUR_TR_OJTController.endOJTPlan(ojtPlan);

        Test.startTest();
        EUR_TR_OJT__c endedOjtDetail = [
                SELECT Id, EUR_TR_Account__c, EUR_TR_Preseller__c, EUR_TR_Score__c, EUR_TR_RelatedQuestion__c,EUR_TR_Status__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtDetail.Id
        ];
        System.assertEquals('Tamamlandı', endedOjtDetail.EUR_TR_Status__c);
        System.assertEquals(65, endedOjtDetail.EUR_TR_Score__c);

        EUR_TR_OJT__c endedOjtPlan = [
                SELECT Id, EUR_TR_Preseller__c, EUR_TR_Score__c,EUR_TR_Status__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtPlan.Id
        ];
        System.assertEquals('Tamamlandı', endedOjtPlan.EUR_TR_Status__c);
        System.assertEquals(65, endedOjtPlan.EUR_TR_Score__c);

        EUR_TR_OJTController.OJTRequest request = new EUR_TR_OJTController.OJTRequest();
        System.runAs(chiefUser) {
            EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_OJTController.getOJTOrganizationScoresFromMiddleware(JSON.serialize(request));
            System.assertEquals(1, response.Code);
        }
        System.runAs(new User(Id = chiefUser.ManagerId)) {
            EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_OJTController.getOJTOrganizationScoresFromMiddleware(JSON.serialize(request));
            System.assertEquals(1, response.Code);
        }
        EUR_TR_MiddlewareController.PostServiceResponse response = EUR_TR_OJTController.getOJTOrganizationScoresFromMiddleware(JSON.serialize(request));
        System.assertEquals(1, response.Code);
        Test.stopTest();
    }

    @IsTest
    static void testGetPresellerList() {
        Test.startTest();

        EUR_TR_OJTController.getPresellerListFromMiddleware('');

        Test.stopTest();
    }

    @IsTest
    static void testListOJTQuestions() {
        Test.startTest();

        EUR_TR_OJTController.listOJTQuestionsFromMiddleware('');

        Test.stopTest();
    }

    @IsTest
    static void testGetOJTConfigurations() {
        Test.startTest();

        EUR_TR_OJTController.getOJTConfigurationsFromMiddleware('');

        Test.stopTest();
    }

    @IsTest
    static void testGetPresellerOJTPlanReportFromMiddleware() {
        Test.startTest();

        EUR_TR_OJTController.OJTRequest ojtRequest = new EUR_TR_OJTController.OJTRequest();

        ojtRequest.queryStartDate = Date.today().addDays(-30);
        ojtRequest.queryEndDate = Date.today().addDays(30);
        ojtRequest.data = new EUR_TR_OJT__c();
        ojtRequest.data.EUR_TR_Preseller__c = getEmployeeId();
        ojtRequest.pageSize = 1;
        ojtRequest.pageNumber = 1;

        EUR_TR_OJTController.getPresellerOJTPlanReportFromMiddleware(JSON.serialize(ojtRequest));

        Test.stopTest();
    }

    @IsTest
    static void testGetOJTVisitsByPlanReportFromMiddleware() {
        EUR_TR_OJT__c ojtRequest = new EUR_TR_OJT__c();

        ojtRequest.EUR_TR_PlanedStartTime__c = Datetime.now();
        ojtRequest.EUR_TR_PlanedEndTime__c = Datetime.now();
        ojtRequest.EUR_TR_Preseller__c = getEmployeeId();

        Test.startTest();

        EUR_TR_OJTController.createOJTPlan(ojtRequest);

        ojtRequest = [
                SELECT Id, EUR_TR_PlanedStartTime__c, EUR_TR_PlanedEndTime__c, EUR_TR_Preseller__c
                FROM EUR_TR_OJT__c
                WHERE EUR_TR_Preseller__c = :ojtRequest.EUR_TR_Preseller__c
                AND EUR_TR_Status__c = 'Planlandı'
                LIMIT 1
        ];

        EUR_TR_OJTController.OJTRequest request = new EUR_TR_OJTController.OJTRequest();
        request.data = ojtRequest;

        EUR_TR_OJTController.getOJTVisitDetailsFromMiddleware(JSON.serialize(ojtRequest));

        Test.stopTest();
    }

    @IsTest
    static void negativeTests() {
        Test.startTest();

        EUR_TR_OJTController.createOJTPlanFromMiddleware('{}');
        EUR_TR_OJTController.listOJTPlansPlansFromMiddleware('{}');
        EUR_TR_OJTController.startOJTPlanFromMiddleware('{}');
        EUR_TR_OJTController.listOJTAccountsByRelatedPlanFromMiddleware('{}');
        EUR_TR_OJTController.startOJTCustomerVisitFromMiddleware('{}');
        EUR_TR_OJTController.endOJTPlanFromMiddleware('{}');
        EUR_TR_OJTController.getPresellerOJTPlanReportFromMiddleware('{}');
        EUR_TR_OJTController.sendOJTEmailFromMiddleware('{}');
        EUR_TR_OJTController.getOJTVisitsByPlanReportFromMiddleware('{}');
        EUR_TR_OJTController.getOJTVisitDetailsFromMiddleware('{}');

        Test.stopTest();
    }

    static Id getAccountId() {
        return [SELECT Id FROM EUR_TR_Account__c WHERE Name = 'Test OJT'].Id;
    }

    static Id getEmployeeId() {
        return [SELECT Id FROM EUR_TR_Employee__c WHERE Name = 'Test OJT' LIMIT 1].Id;
    }

}