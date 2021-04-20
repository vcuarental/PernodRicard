/**
 * Created by osman on 31.10.2019.
 */

@IsTest(SeeAllData=false)
public with sharing class EUR_TR_SchedulerController_Test {

    public static final String EUR_TR_RECORD_TYPE_DEVELOPER_NAME = 'EUR_TR_Task';

    @isTest
    public static void executeMethodTestToCensusController() {
        RecordType r = [select Id from RecordType where DeveloperName = 'ApplicationConfiguration'][0];
        EUR_TR_ApplicationConfiguration__c eurTRConfiguration = new EUR_TR_ApplicationConfiguration__c();
        eurTRConfiguration.EUR_TR_Census_Url__c = 'https://www.dummy-web-service.com/api/CensusScores';
        eurTRConfiguration.EUR_TR_Census_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_Census_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.EUR_TR_RemPeople_Url__c = 'https://www.dummy-web-service.com/api/rempeopleservice';
        eurTRConfiguration.EUR_TR_RemPeople_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_RemPeople_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.RecordTypeId = r.Id;
        insert eurTRConfiguration;

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_SchedulerController eurtrSchedulerController = new EUR_TR_SchedulerController();
        String dummyCronExpression = '0 0 23 * * ?';
        Test.startTest();
        {
            System.schedule('EUR_TR_SchedulerController' + System.now(), dummyCronExpression, eurtrSchedulerController);
        }
        Test.stopTest();


    }


    @isTest
    public static void remPeopleControllerUtilTest() {
        RecordType r = [select Id from RecordType where DeveloperName = 'ApplicationConfiguration'][0];
        EUR_TR_ApplicationConfiguration__c eurTRConfiguration = new EUR_TR_ApplicationConfiguration__c();
        eurTRConfiguration.EUR_TR_Census_Url__c = 'https://www.dummy-web-service.com/api/CensusScores';
        eurTRConfiguration.EUR_TR_Census_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_Census_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.EUR_TR_RemPeople_Url__c = 'https://www.dummy-web-service.com/api/rempeopleservice';
        eurTRConfiguration.EUR_TR_RemPeople_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_RemPeople_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.RecordTypeId = r.Id;
        insert eurTRConfiguration;

        Test.setMock(HttpCalloutMock.class, new EUR_TR_RemPeopleServiceMock_Test());
        Test.startTest();
        {
            EUR_TR_RemPeopleControllerUtil.doCallout();
        }
        Test.stopTest();

    }

    @isTest
    public static void censusControllerPeopleControllerUtilTest() {
        RecordType r = [select Id from RecordType where DeveloperName = 'ApplicationConfiguration'][0];
        EUR_TR_ApplicationConfiguration__c eurTRConfiguration = new EUR_TR_ApplicationConfiguration__c();
        eurTRConfiguration.EUR_TR_Census_Url__c = 'https://www.dummy-web-service.com/api/CensusScores';
        eurTRConfiguration.EUR_TR_Census_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_Census_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.EUR_TR_RemPeople_Url__c = 'https://www.dummy-web-service.com/api/rempeopleservice';
        eurTRConfiguration.EUR_TR_RemPeople_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_RemPeople_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.RecordTypeId = r.Id;
        insert eurTRConfiguration;

        Test.setMock(HttpCalloutMock.class, new EUR_TR_CensusServiceMock_Test());
        Test.startTest();
        {
            EUR_TR_CensusControllerUtil.doCallout();
        }
        Test.stopTest();


    }

    @isTest
    public static void taskTransferBatchTestToActiveTask() {
        RecordType r = [select Id from RecordType where DeveloperName = 'ApplicationConfiguration'][0];
        EUR_TR_ApplicationConfiguration__c eurTRConfiguration = new EUR_TR_ApplicationConfiguration__c();
        eurTRConfiguration.EUR_TR_Census_Url__c = 'https://www.dummy-web-service.com/api/CensusScores';
        eurTRConfiguration.EUR_TR_Census_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_Census_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.EUR_TR_RemPeople_Url__c = 'https://www.dummy-web-service.com/api/rempeopleservice';
        eurTRConfiguration.EUR_TR_RemPeople_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_RemPeople_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.RecordTypeId = r.Id;
        insert eurTRConfiguration;

        Schema.DescribeSObjectResult taskSchema = Schema.SObjectType.Task;
        Map<String, Schema.RecordTypeInfo> taskRecordTypeInfo = taskSchema.getRecordTypeInfosByDeveloperName();
        RecordTypeInfo taskEURTRRecordTypeInfo = taskRecordTypeInfo.get(EUR_TR_RECORD_TYPE_DEVELOPER_NAME);


        EUR_TR_Account__c eurtrAccount = new EUR_TR_Account__c();
        eurtrAccount.Name = 'Tekna Test User';
        eurtrAccount.EUR_TR_DistributorName__c = 'ANKA';
        eurtrAccount.EUR_TR_AccountCode__c = 'ANKA';
        insert eurtrAccount;

        EUR_TR_Distributor__c eurtrDistributor = new EUR_TR_Distributor__c();
        eurtrDistributor.Name = 'ANKA';
        eurtrDistributor.EUR_TR_BranchId__c = 'Dummy_External_ID';
        eurtrDistributor.EUR_TR_RegisteredName__c = 'Dummy Registered Name';
        eurtrDistributor.EUR_TR_BranchCode__c = 'Dummy Branch Code';
        insert eurtrDistributor;


        List<Task> tasks = new List<Task>();
        // Preseller - Salesforce ; PR_Activity_Type__c
        // Started - Canceled ; Status
        Task task = new Task();
        task.PR_Activity_Type__c = 'Salesforce';
        task.whatId = eurtrAccount.id;
        task.PR_DateTime__c = null;
        task.ActivityDate = Date.today();
        task.subject = 'Test Subject';
        task.Description = 'Test Description';
        task.recordTypeId = taskEURTRRecordTypeInfo.getRecordTypeId();
        task.Status = 'Started';
        tasks.add(task);


        Task task3 = new Task();
        task3.PR_Activity_Type__c = 'Preseller';
        task3.whatId = eurtrAccount.id;
        task.PR_DateTime__c = null;
        task3.ActivityDate = Date.today();
        task3.subject = 'Test Subject';
        task3.Description = 'Test Description';
        task3.recordTypeId = taskEURTRRecordTypeInfo.getRecordTypeId();
        task3.Status = 'Started';
        tasks.add(task3);

        EUR_TR_OJT__c ojtDay = new EUR_TR_OJT__c();

        ojtDay.RecordTypeId = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OJTDay').getRecordTypeId();
        ojtDay.EUR_TR_PlanedStartTime__c = Datetime.now().addHours(-3);
        ojtDay.EUR_TR_PlanedEndTime__c = Datetime.now().addHours(3);
        ojtDay.EUR_TR_Status__c = 'Tamamlandı';

        insert ojtDay;

        EUR_TR_OJT__c ojtVisit = new EUR_TR_OJT__c();

        ojtVisit.EUR_TR_Account__c = eurtrAccount.Id;
        ojtVisit.EUR_TR_RelatedDay__c = ojtDay.Id;
        ojtVisit.EUR_TR_Status__c = 'Tamamlandı';
        ojtVisit.EUR_TR_ActualStartTime__c = Datetime.now().addHours(-1);
        ojtVisit.EUR_TR_ActualEndTime__c = Datetime.now();
        ojtVisit.RecordTypeId = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OJTDetail').getRecordTypeId();

        insert ojtVisit;

        Task ojtTask = new Task();

        ojtTask.PR_Activity_Type__c = 'Preseller';
        ojtTask.WhatId = ojtDay.Id;
        ojtTask.ActivityDate = Date.today();
        ojtTask.PR_DateTime__c = null;
        ojtTask.Subject = 'Test Subject OJT';
        ojtTask.Description = 'Test Description OJT';
        ojtTask.Status = 'Completed';
        ojtTask.Cliente__c = 'OJT';
        ojtTask.recordTypeId = taskEURTRRecordTypeInfo.getRecordTypeId();

        tasks.add(ojtTask);

        insert tasks;

        //
        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        Test.startTest();
        {
            Database.executeBatch(new EUR_TR_TaskTransferBatch(EUR_TR_TaskTransferBatch.RunModes.Other), 5);
        }
        Test.stopTest();
    }


    @isTest
    public static void taskTransferBatchTestToCancelTask() {
        RecordType r = [select Id from RecordType where DeveloperName = 'ApplicationConfiguration'][0];
        EUR_TR_ApplicationConfiguration__c eurTRConfiguration = new EUR_TR_ApplicationConfiguration__c();
        eurTRConfiguration.EUR_TR_Census_Url__c = 'https://www.dummy-web-service.com/api/CensusScores';
        eurTRConfiguration.EUR_TR_Census_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_Census_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.EUR_TR_RemPeople_Url__c = 'https://www.dummy-web-service.com/api/rempeopleservice';
        eurTRConfiguration.EUR_TR_RemPeople_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_RemPeople_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.RecordTypeId = r.Id;
        insert eurTRConfiguration;

        Schema.DescribeSObjectResult taskSchema = Schema.SObjectType.Task;
        Map<String, Schema.RecordTypeInfo> taskRecordTypeInfo = taskSchema.getRecordTypeInfosByDeveloperName();
        RecordTypeInfo taskEURTRRecordTypeInfo = taskRecordTypeInfo.get(EUR_TR_RECORD_TYPE_DEVELOPER_NAME);


        EUR_TR_Account__c eurtrAccount = new EUR_TR_Account__c();
        eurtrAccount.Name = 'Tekna Test User';
        eurtrAccount.EUR_TR_DistributorName__c = 'ANKA';
        eurtrAccount.EUR_TR_AccountCode__c = 'ANKA';
        insert eurtrAccount;

        EUR_TR_Distributor__c eurtrDistributor = new EUR_TR_Distributor__c();
        eurtrDistributor.Name = 'ANKA';
        eurtrDistributor.EUR_TR_BranchId__c = 'Dummy_External_ID';
        eurtrDistributor.EUR_TR_RegisteredName__c = 'Dummy Registered Name';
        eurtrDistributor.EUR_TR_BranchCode__c = 'Dummy Branch Code';
        insert eurtrDistributor;


        List<Task> tasks = new List<Task>();


        Task task2 = new Task();
        task2.PR_Activity_Type__c = 'Preseller';
        task2.whatId = eurtrAccount.id;
        task2.ActivityDate = Date.today();
        task2.PR_DateTime__c = NULL;
        task2.subject = 'Test Subject';
        task2.Description = 'Test Description';
        task2.recordTypeId = taskEURTRRecordTypeInfo.getRecordTypeId();
        task2.Status = 'Canceled';
        tasks.add(task2);

        EUR_TR_OJT__c ojtDay = new EUR_TR_OJT__c();

        ojtDay.RecordTypeId = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OJTDay').getRecordTypeId();
        ojtDay.EUR_TR_PlanedStartTime__c = Datetime.now().addHours(-3);
        ojtDay.EUR_TR_PlanedEndTime__c = Datetime.now().addHours(3);
        ojtDay.EUR_TR_Status__c = 'Tamamlandı';

        insert ojtDay;

        EUR_TR_OJT__c ojtVisit = new EUR_TR_OJT__c();

        ojtVisit.EUR_TR_Account__c = eurtrAccount.Id;
        ojtVisit.EUR_TR_RelatedDay__c = ojtDay.Id;
        ojtVisit.EUR_TR_Status__c = 'Tamamlandı';
        ojtVisit.EUR_TR_ActualStartTime__c = Datetime.now().addHours(-1);
        ojtVisit.EUR_TR_ActualEndTime__c = Datetime.now();
        ojtVisit.RecordTypeId = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OJTDetail').getRecordTypeId();

        insert ojtVisit;

        Task ojtTask = new Task();

        ojtTask.PR_Activity_Type__c = 'Preseller';
        ojtTask.WhatId = ojtDay.Id;
        ojtTask.ActivityDate = Date.today();
        ojtTask.PR_DateTime__c = null;
        ojtTask.Subject = 'Test Subject OJT';
        ojtTask.Description = 'Test Description OJT';
        ojtTask.Status = 'Canceled';
        ojtTask.Cliente__c = 'OJT';
        ojtTask.recordTypeId = taskEURTRRecordTypeInfo.getRecordTypeId();

        tasks.add(ojtTask);

        insert tasks;

        //
        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        Test.startTest();
        {
            Database.executeBatch(new EUR_TR_TaskTransferBatch(EUR_TR_TaskTransferBatch.RunModes.Cancel), 5);
        }
        Test.stopTest();
    }


}