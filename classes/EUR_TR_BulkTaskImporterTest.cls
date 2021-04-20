/**
 * Created by Murat Can on 17/09/2020.
 */

@IsTest
private class EUR_TR_BulkTaskImporterTest {

    @TestSetup
    static void setup() {
        User fastTrackUser = new User();

        fastTrackUser.FirstName = 'Test';
        fastTrackUser.LastName = 'Test';
        fastTrackUser.Username = 'test@' + UserInfo.getOrganizationId().toLowerCase() + '.test';
        fastTrackUser.Email = 'test@' + UserInfo.getOrganizationId().toLowerCase() + '.test';
        fastTrackUser.EmailEncodingKey = 'ISO-8859-1';
        fastTrackUser.Alias = 'Tst';
        fastTrackUser.TimeZoneSidKey = 'America/Los_Angeles';
        fastTrackUser.LocaleSidKey = 'en_US';
        fastTrackUser.LanguageLocaleKey = 'en_US';
        fastTrackUser.ProfileId = [
                SELECT Id
                FROM Profile
                LIMIT 1
        ].Id;

        insert fastTrackUser;
    }

    @IsTest
    static void testSaveTasks() {
        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.EUR_TR_AccountCode__c = 'Test';

        insert account;

        EUR_TR_Employee__c employee = new EUR_TR_Employee__c();

        employee.Name = 'Test';
        employee.EUR_TR_EmployeeNumber__c = 0;
        employee.EUR_TR_SalesChiefNumber__c = 1;
        employee.EUR_TR_AreaManagerNumber__c = 2;
        employee.EUR_TR_RelatedUser__c = UserInfo.getUserId();

        insert employee;

        EUR_TR_Definition__c predefinedTask = new EUR_TR_Definition__c();

        predefinedTask.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OJT').getRecordTypeId();
        predefinedTask.Name = 'Test';
        predefinedTask.EUR_TR_ActivityDate__c = Date.today();
        predefinedTask.EUR_TR_TaskDescription__c = 'Test';

        insert predefinedTask;

        List<EUR_TR_BulkTaskImporter.TaskWrapper> fastTrackTasks = new List<EUR_TR_BulkTaskImporter.TaskWrapper>();
        for (Integer index = 0; index < 3; index++) {

            EUR_TR_BulkTaskImporter.TaskWrapper taskWrapper = new EUR_TR_BulkTaskImporter.TaskWrapper();

            taskWrapper.ActivityDate = Date.today().addDays(index);
            taskWrapper.Description = 'Test Description ' + index;
            taskWrapper.Cliente = 'Test Cliente ' + index;
            taskWrapper.What_EUR_TR_AccountCode = 'Test';
            taskWrapper.Username = 'test@' + UserInfo.getOrganizationId().toLowerCase() + '.test';

            fastTrackTasks.add(taskWrapper);
        }

        List<EUR_TR_BulkTaskImporter.TaskWrapper> presellerTasks = new List<EUR_TR_BulkTaskImporter.TaskWrapper>();
        for (Integer index = 0; index < 3; index++) {

            EUR_TR_BulkTaskImporter.TaskWrapper taskWrapper = new EUR_TR_BulkTaskImporter.TaskWrapper();

            taskWrapper.ActivityDate = Date.today().addDays(index);
            taskWrapper.Description = 'Test Description ' + index;
            taskWrapper.Cliente = 'Test Cliente ' + index;
            taskWrapper.What_EUR_TR_AccountCode = 'Test';

            presellerTasks.add(taskWrapper);
        }

        List<EUR_TR_BulkTaskImporter.File> files = new List<EUR_TR_BulkTaskImporter.File>();
        EUR_TR_BulkTaskImporter.File file = new EUR_TR_BulkTaskImporter.File();

        file.fileName = 'Test File';
        file.base64Data = 'Test base64 Data';

        files.add(file);

        Test.startTest();

        EUR_TR_BulkTaskImporter.saveTasks(fastTrackTasks, null, 'fastTrack', files);
        EUR_TR_BulkTaskImporter.saveTasks(presellerTasks, predefinedTask.Id, 'preseller', files);

        Test.stopTest();
    }

    @IsTest
    static void testGetPredefinedTasksFromMiddleware() {
        Test.startTest();

        EUR_TR_Definition__c request = new EUR_TR_Definition__c();
        request.RecordType = new RecordType(DeveloperName = 'EUR_TR_PredefinedTaskPreseller');

        EUR_TR_BulkTaskImporter.getPredefinedTasksFromMiddleware(JSON.serialize(request));

        Test.stopTest();
    }
}