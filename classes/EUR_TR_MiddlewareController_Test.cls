/**
 * Created by osman on 21.10.2019.
 */

@IsTest(SeeAllData=false)
private with sharing class EUR_TR_MiddlewareController_Test {

    private static final String HTTP_POST_REQUEST_TYPE = 'POST';
    private static final String EMPTY_REQUEST_BODY = '';

    @TestSetup
    static void setup() {
        createTestData();
    }


    @IsTest
    static void editNoteByIdTest() {


        List<Note> notes = [SELECT Id, Body, Title FROM Note WHERE ParentId != NULL];
        List<Note> notesToValidation = new List<Note>();
        String requestBody = JSON.serialize(notes);

        // editNoteById
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editNoteById', requestBody);

        // id is blank
        Note note = notes.get(0);
        note.id = null;
        notesToValidation.add(note);
        requestBody = JSON.serialize(notesToValidation);
        makeTestCallout('POST', 'editNoteById', requestBody);

        // noteBody is blank
        note = notes.get(0);
        note.Body = '';
        notesToValidation = new List<Note>();
        notesToValidation.add(note);
        requestBody = JSON.serialize(notesToValidation);
        makeTestCallout('POST', 'editNoteById', requestBody);

        // title is blank
        note = notes.get(0);
        note.Title = '';
        notesToValidation = new List<Note>();
        notesToValidation.add(note);
        requestBody = JSON.serialize(notesToValidation);
        makeTestCallout('POST', 'editNoteById', requestBody);

        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout('POST', 'editNoteById', requestBody);

        // request is empty
        makeTestCallout('POST', 'editNoteById', EMPTY_REQUEST_BODY);

    }

    //  - 
    @IsTest
    static void addNoteByAccountTest() {

        List<EUR_TR_Account__c> eurtrAccounts = [
                SELECT Id
                FROM EUR_TR_Account__c
        ];

        Note note = new Note();
        note.ParentId = eurtrAccounts.get(0).Id;
        note.Title = 'My Title';
        note.Body = 'My Body';

        List<Note> notes = new List<Note>();
        notes.add(note);


        String requestBody = JSON.serialize(notes);

        // all parameters are passed
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addNoteByAccount', requestBody);


        // ParentId is empty
        List<Note> notesToValidation = new List<Note>();
        Note noteToValidation = notes.get(0);
        noteToValidation.ParentId = null;
        notesToValidation.add(noteToValidation);
        requestBody = JSON.serialize(noteToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addNoteByAccount', requestBody);

        // Body is empty
        noteToValidation = notes.get(0);
        noteToValidation.Body = '';
        notesToValidation = new List<Note>();
        notesToValidation.add(noteToValidation);
        requestBody = JSON.serialize(noteToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addNoteByAccount', requestBody);

        // Title is empty
        noteToValidation = notes.get(0);
        noteToValidation.Title = '';
        notesToValidation = new List<Note>();
        notesToValidation.add(noteToValidation);
        requestBody = JSON.serialize(noteToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addNoteByAccount', requestBody);

        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addNoteByAccount', requestBody);


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addNoteByAccount', EMPTY_REQUEST_BODY);


    }

    @IsTest
    static void listRemPeopleByRelatedAccountIdTest() {


        List<EUR_TR_RemPeople__c> eurtrRemPeoples = [SELECT Id,EUR_TR_RelatedAccount__c FROM EUR_TR_RemPeople__c];
        String requestBody = JSON.serialize(eurtrRemPeoples);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRemPeopleByRelatedAccountId', requestBody);

        // EUR_TR_RelatedAccount__c is null or empty
        List<EUR_TR_RemPeople__c> eurtrRemPeoplesToValidation = new List<EUR_TR_RemPeople__c>();
        EUR_TR_RemPeople__c eurtrRemPeople = eurtrRemPeoples.get(0);
        eurtrRemPeople.EUR_TR_RelatedAccount__c = null;
        eurtrRemPeoplesToValidation.add(eurtrRemPeople);
        requestBody = JSON.serialize(eurtrRemPeoplesToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRemPeopleByRelatedAccountId', requestBody);

        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRemPeopleByRelatedAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRemPeopleByRelatedAccountId', EMPTY_REQUEST_BODY);


    }

    @IsTest
    static void getAccountByIdTest() {


        List<EUR_TR_Account__c> eurtrAccounts = [
                SELECT Id
                FROM EUR_TR_Account__c
        ];
        String requestBody = JSON.serialize(eurtrAccounts);

        // Id parameter is passed
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'getAccountById', requestBody);

        // Id parameter is not passed
        List<EUR_TR_Account__c> eurtrAccountsToValidation = new List<EUR_TR_Account__c>();
        eurtrAccountsToValidation.add(new EUR_TR_Account__c(id = null));
        requestBody = JSON.serialize(eurtrAccountsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'getAccountById', requestBody);

        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'getAccountById', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'getAccountById', EMPTY_REQUEST_BODY);


    }

    @IsTest
    static void editContactByIdTest() {


        List<Contact> contacts = [
                SELECT Id,FirstName,LastName,Phone,Email,EUR_TR_Type__c,EUR_TR_RelatedAccount__c,EUR_TR_KVKKVerificationCode__c,EUR_TR_KVKKVerificationDate__c,EUR_TR_KVKKApproved__c
                FROM Contact
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.Contact, 'EUR_TR_Contact') AND EUR_TR_RelatedAccount__c != NULL
        ];
        String requestBody = JSON.serialize(contacts);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', requestBody);


        List<Contact> contactsToValidation = null;
        Contact contact = null;

        // Id is empty
        contact = contacts.get(0);
        contact.id = null;
        contactsToValidation = new List<Contact>();
        contactsToValidation.add(contact);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', requestBody);

        // FirstName is empty
        contact = contacts.get(0);
        contact.FirstName = '';
        contactsToValidation = new List<Contact>();
        contactsToValidation.add(contact);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', requestBody);

        // lastName is empty
        contact = contacts.get(0);
        contact.LastName = '';
        contactsToValidation = new List<Contact>();
        contactsToValidation.add(contact);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', requestBody);

        // EUR_TR_Type__c is empty
        contact = contacts.get(0);
        contact.EUR_TR_Type__c = '';
        contactsToValidation = new List<Contact>();
        contactsToValidation.add(contact);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', requestBody);

        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editContactById', EMPTY_REQUEST_BODY);

    }

    @IsTest
    static void addContactToRelatedAccountTest() {

        List<Contact> contacts = [
                SELECT Id,FirstName,LastName,EUR_TR_RelatedAccount__c,Phone,Email,EUR_TR_Type__c,EUR_TR_KVKKVerificationCode__c,EUR_TR_KVKKVerificationDate__c,EUR_TR_KVKKApproved__c
                FROM Contact
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.Contact, 'EUR_TR_Contact') AND EUR_TR_RelatedAccount__c != NULL
        ];
        String requestBody = JSON.serialize(contacts);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);


        List<Contact> contactsToValidation = null;
        Contact contactToValidation = null;

        // EUR_TR_RelatedAccount__c is blank
        contactsToValidation = new List<Contact>();
        contactToValidation = contacts.get(0);
        contactToValidation.EUR_TR_RelatedAccount__c = null;
        contactsToValidation.add(contactToValidation);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);


        // FirstName is blank
        contactsToValidation = new List<Contact>();
        contactToValidation = contacts.get(0);
        contactToValidation.FirstName = '';
        contactsToValidation.add(contactToValidation);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);


        // LastName is blank
        contactsToValidation = new List<Contact>();
        contactToValidation = contacts.get(0);
        contactToValidation.LastName = '';
        contactsToValidation.add(contactToValidation);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);

        // EUR_TR_KVKKVerificationCode__c is blank
        contactsToValidation = new List<Contact>();
        contactToValidation = contacts.get(0);
        contactToValidation.EUR_TR_KVKKVerificationCode__c = '';
        contactsToValidation.add(contactToValidation);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);

        // EUR_TR_Type__c is blank
        contactsToValidation = new List<Contact>();
        contactToValidation = contacts.get(0);
        contactToValidation.EUR_TR_Type__c = '';
        contactsToValidation.add(contactToValidation);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);

        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addContactToRelatedAccount', EMPTY_REQUEST_BODY);


    }

    @IsTest
    static void listContactsByRelatedAccountTest() {

        List<Contact> contacts = [
                SELECT Id,FirstName,LastName,Phone,Email,EUR_TR_Type__c,EUR_TR_RelatedAccount__c,EUR_TR_KVKKVerificationCode__c,EUR_TR_KVKKVerificationDate__c,EUR_TR_KVKKApproved__c
                FROM Contact
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.Contact, 'EUR_TR_Contact') AND EUR_TR_RelatedAccount__c != NULL
        ];
        String requestBody = JSON.serialize(contacts);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listContactsByRelatedAccount', requestBody);

        // request is empty
        List<Contact> contactsToValidation = null;
        Contact contactToValidation = null;

        // EUR_TR_RelatedAccount__c is blank
        contactsToValidation = new List<Contact>();
        contactToValidation = contacts.get(0);
        contactToValidation.EUR_TR_RelatedAccount__c = null;
        contactsToValidation.add(contactToValidation);
        requestBody = JSON.serialize(contactsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listContactsByRelatedAccount', requestBody);


        // throw error
        requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listContactsByRelatedAccount', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listContactsByRelatedAccount', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listAccountsByLocationTest() {


        List<EUR_TR_Account__c> eurtrAccounts = [
                SELECT Id,Name,EUR_TR_DistributorName__c,EUR_TR_AccountCode__c,EUR_TR_Location__Latitude__s,EUR_TR_Location__Longitude__s
                FROM EUR_TR_Account__c
        ];
        String requestBody = JSON.serialize(eurtrAccounts);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByLocation', requestBody);

        List<EUR_TR_Account__c> eurtrAccountsToValidation = null;
        EUR_TR_Account__c eurtrAccountToValidation = null;

        // EUR_TR_Location__Latitude__s is blank
        eurtrAccountToValidation = eurtrAccounts.get(0);
        eurtrAccountToValidation.EUR_TR_Location__Latitude__s = null;
        eurtrAccountsToValidation = new List<EUR_TR_Account__c>();
        eurtrAccountsToValidation.add(eurtrAccountToValidation);
        requestBody = JSON.serialize(eurtrAccountsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByLocation', requestBody);

        // EUR_TR_Location__Longitude__s is blank
        eurtrAccountToValidation = eurtrAccounts.get(0);
        eurtrAccountToValidation.EUR_TR_Location__Longitude__s = null;
        eurtrAccountsToValidation = new List<EUR_TR_Account__c>();
        eurtrAccountsToValidation.add(eurtrAccountToValidation);
        requestBody = JSON.serialize(eurtrAccountsToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByLocation', requestBody);

        // throw exception
        requestBody = JSON.serialize(new List<Account>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByLocation', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByLocation', EMPTY_REQUEST_BODY);


        // unknown method callout
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'dummyMethodName', requestBody);

    }


    @IsTest
    static void saveSurveyAnswersTest() {


        List<EUR_TR_Survey__c> eurtrSurveys = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_RelatedSurveyTemplate__c,EUR_TR_Description__c,EUR_TR_Mandatory__c
                FROM EUR_TR_Survey__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateTarget')
                AND EUR_TR_RelatedSurveyTemplate__c != NULL and EUR_TR_SurveyRelatedTemplate__c != null
        ];
        String requestBody = JSON.serialize(eurtrSurveys);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'saveSurveyAnswers', requestBody);


        // EUR_TR_SurveyRelatedTemplate__c is blank
        List<EUR_TR_Survey__c> eurtrSurveysToValidation = new List<EUR_TR_Survey__c>();
        EUR_TR_Survey__c eurtrSurveyToValidation = eurtrSurveys.get(0);
        eurtrSurveyToValidation.EUR_TR_SurveyRelatedTemplate__c = null;
        eurtrSurveysToValidation.add(eurtrSurveyToValidation);
        requestBody = JSON.serialize(eurtrSurveysToValidation);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'saveSurveyAnswers', requestBody);

        // throw exception
        requestBody = JSON.serialize(new List<Account>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'saveSurveyAnswers', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'saveSurveyAnswers', EMPTY_REQUEST_BODY);


    }

    @isTest
    static void saveSurveyAnswerTestSuccess() {
        List<EUR_TR_Survey__c> eurtrSurveys = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_RelatedSurveyTemplate__c,EUR_TR_SurveyRelatedTemplate__c,EUR_TR_Description__c,EUR_TR_Mandatory__c
                FROM EUR_TR_Survey__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateTarget')
                AND EUR_TR_SurveyRelatedTemplate__c != null
        ];
        String requestBody = JSON.serialize(eurtrSurveys);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'saveSurveyAnswers', requestBody);
    }


    @IsTest
    static void listTasksByOwnerIdByKindTest() {


        List<Task> tasks = [
                SELECT
                        Id,OwnerId,WhatId,PR_Activity_Type__c,RecurrenceInterval,Type
                FROM Task
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.Task, 'EUR_TR_Task')
        ];

        EUR_TR_MiddlewareController.TaskRequest taskRequest = new EUR_TR_MiddlewareController.TaskRequest();
        taskRequest.task = tasks.get(0);
        taskRequest.task.RecurrenceInterval = 1;
        taskRequest.pageSize = 10;
        taskRequest.pageNumber = 1;
        String requestBody = JSON.serialize(taskRequest);

        // All parameters are passed.
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', requestBody);

        // All parameters are passed.
        taskRequest.task.RecurrenceInterval = 2;
        taskRequest.pageSize = 10;
        taskRequest.pageNumber = 1;
        requestBody = JSON.serialize(taskRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', requestBody);


        // All parameters are passed.
        taskRequest.task.RecurrenceInterval = 3;
        taskRequest.pageSize = 10;
        taskRequest.pageNumber = 1;
        requestBody = JSON.serialize(taskRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', requestBody);

        Task taskToValidation = null;

        // OwnerId is blank.
        taskToValidation = tasks.get(0);
        taskToValidation.OwnerId = null;
        taskRequest.task = taskToValidation;
        requestBody = JSON.serialize(taskRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', requestBody);

        // PR_Activity_Type__c is blank.
        taskToValidation = tasks.get(0);
        taskToValidation.PR_Activity_Type__c = '';
        taskRequest.task = taskToValidation;
        requestBody = JSON.serialize(taskRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', requestBody);

        // throw exception
        requestBody = JSON.serialize(new List<Account>());
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', requestBody);


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByOwnerIdByKind', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void addTaskByAccountIdTest() {


        List<EUR_TR_Account__c> eurtrAccounts = [
                SELECT
                        Id
                FROM EUR_TR_Account__c
        ];


        Task task = new Task();
        task.WhatId = eurtrAccounts.get(0).Id;
        task.OwnerId = UserInfo.getUserId();
        task.ActivityDate = Date.today() + 1;
        task.Description = 'Dummy Desc';
        task.PR_Activity_Type__c = 'Salesforce';

        String requestBody = JSON.serialize(task);

        // All parameters are passed.
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);

        List<Task> tasksToValidation = null;
        Task taskToValidation = null;
        {
            // WhatId is blank.
            taskToValidation = task;
            taskToValidation.WhatId = null;
            tasksToValidation = new List<Task>();
            tasksToValidation.add(taskToValidation);
            requestBody = JSON.serialize(tasksToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);

            // PR_Activity_Type__c is blank.
            taskToValidation = new Task();
            taskToValidation = task;
            taskToValidation.PR_Activity_Type__c = '';
            tasksToValidation = new List<Task>();
            tasksToValidation.add(taskToValidation);
            requestBody = JSON.serialize(tasksToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);

            // Description is blank.
            taskToValidation = new Task();
            taskToValidation = task;
            taskToValidation.Description = '';
            tasksToValidation = new List<Task>();
            tasksToValidation.add(taskToValidation);
            requestBody = JSON.serialize(tasksToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);

            // ActivityDate is blank.
            taskToValidation = new Task();
            taskToValidation = task;
            taskToValidation.ActivityDate = null;
            tasksToValidation = new List<Task>();
            tasksToValidation.add(taskToValidation);
            requestBody = JSON.serialize(tasksToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);

            // OwnerId is blank.
            taskToValidation = new Task();
            taskToValidation = task;
            taskToValidation.OwnerId = null;
            tasksToValidation = new List<Task>();
            tasksToValidation.add(taskToValidation);
            requestBody = JSON.serialize(tasksToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', requestBody);
        }

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addTaskByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void completeTaskByIdTest() {


        List<Task> listOfTask = [
                SELECT
                        Id,OwnerId,WhatId,PR_Activity_Type__c,PR_Achievement_Detail__c,Status
                FROM Task
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.Task, 'EUR_TR_Task')
        ];
        Task task = listOfTask.get(0);
        task.Status = 'Completed';
        task.PR_Achievement_Detail__c = 'Kapali';

        String requestBody = JSON.serialize(task);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'completeTaskById', requestBody);

        Task taskToValidation = null;
        {
            // Id is blank.
            taskToValidation = listOfTask.get(0);
            taskToValidation.Id = null;
            requestBody = JSON.serialize(taskToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'completeTaskById', requestBody);


            // PR_Achievement_Detail__c is blank.
            taskToValidation = listOfTask.get(0);
            taskToValidation.PR_Achievement_Detail__c = '';
            requestBody = JSON.serialize(taskToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'completeTaskById', requestBody);


            // Status is blank.
            taskToValidation = listOfTask.get(0);
            taskToValidation.Status = '';
            requestBody = JSON.serialize(taskToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'completeTaskById', requestBody);


            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'completeTaskById', requestBody);
        }


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'completeTaskById', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void addPosmByAccountIdTest() {


        List<EUR_TR_Account__c> eurtrAccounts = [
                SELECT
                        Id
                FROM EUR_TR_Account__c
        ];
        EUR_TR_Account__c eurtrAccount = eurtrAccounts.get(0);


        EUR_TR_POSM__c eurTrPosm = new EUR_TR_POSM__c();
        {
            eurTrPosm.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
            eurTrPosm.EUR_TR_POSMType__c = 'Raf İçi';
            eurTrPosm.EUR_TR_PlacementDate__c = Datetime.now();
            eurTrPosm.EUR_TR_Brand__c = 'Olmeca';
            eurTrPosm.EUR_TR_BrandOther__c = 'Diğer';
            eurTrPosm.EUR_TR_Budget__c = 10;

        }
        List<EUR_TR_POSM__c> eurTrPosms = new List<EUR_TR_POSM__c>();
        eurTrPosms.add(eurTrPosm);

        String requestBody = JSON.serialize(eurTrPosms);

        // All parameters are passed.
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', requestBody);

        List<EUR_TR_POSM__c> eurTrPosmsToValidation = null;
        EUR_TR_POSM__c eurTrPosmToValidation = null;
        {
            // EUR_TR_RelatedAccount__c is blank.
            eurTrPosmToValidation = eurTrPosms.get(0);
            eurTrPosmToValidation.EUR_TR_RelatedAccount__c = null;
            eurTrPosmsToValidation = new List<EUR_TR_POSM__c>();
            eurTrPosmsToValidation.add(eurTrPosmToValidation);
            requestBody = JSON.serialize(eurTrPosmsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', requestBody);

            // EUR_TR_POSMType__c is blank.
            eurTrPosmToValidation = eurTrPosms.get(0);
            eurTrPosmToValidation.EUR_TR_POSMType__c = '';
            eurTrPosmsToValidation = new List<EUR_TR_POSM__c>();
            eurTrPosmsToValidation.add(eurTrPosmToValidation);
            requestBody = JSON.serialize(eurTrPosmsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', requestBody);

            // EUR_TR_PlacementDate__c is blank.
            eurTrPosmToValidation = eurTrPosms.get(0);
            eurTrPosmToValidation.EUR_TR_PlacementDate__c = null;
            eurTrPosmsToValidation = new List<EUR_TR_POSM__c>();
            eurTrPosmsToValidation.add(eurTrPosmToValidation);
            requestBody = JSON.serialize(eurTrPosmsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', requestBody);

            // EUR_TR_Brand__c is blank.
            eurTrPosmToValidation = eurTrPosms.get(0);
            eurTrPosmToValidation.EUR_TR_Brand__c = '';
            eurTrPosmsToValidation = new List<EUR_TR_POSM__c>();
            eurTrPosmsToValidation.add(eurTrPosmToValidation);
            requestBody = JSON.serialize(eurTrPosmsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', requestBody);

        }

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addPosmByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listRoutesByOwnerIdByFavoriteTest() {


        List<EUR_TR_Route__c> eurtrRoutes = [
                SELECT
                        Id,OwnerId,EUR_TR_IsFavorite__c
                FROM EUR_TR_Route__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Route__c, 'EUR_TR_RouteTemplate')
        ];
        String requestBody = JSON.serialize(eurtrRoutes);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRoutesByOwnerIdByFavorite', requestBody);

        List<EUR_TR_Route__c> eurtrRoutesToValidation = null;
        EUR_TR_Route__c eurtrRouteToValidation = null;
        {
            // OwnerId is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.OwnerId = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutesToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRoutesByOwnerIdByFavorite', requestBody);


            // EUR_TR_IsFavorite__c is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.EUR_TR_IsFavorite__c = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutesToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRoutesByOwnerIdByFavorite', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRoutesByOwnerIdByFavorite', requestBody);

        }


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRoutesByOwnerIdByFavorite', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void addRouteByOwnerIdTest() {


        EUR_TR_Route__c eurtrRoute = new EUR_TR_Route__c();
        eurtrRoute.OwnerId = UserInfo.getUserId();
        eurtrRoute.EUR_TR_IsFavorite__c = true;
        eurtrRoute.Name = 'Dummy Name';
        eurtrRoute.EUR_TR_SelectedFilters__c = '{"key":"latitude","value":"40.96948242187499"} , {"key":"longitude","value":"29.09527003304906"} , {"key":"brand","value":"ABSOLUT VODKA"} , {"key":"sku","value":"ABSOLUT 100 VODKA 70 CL"} , {"key":"invoicestatus","value":"Son 3 Ay"}';

        List<EUR_TR_Route__c> eurtrRoutes = new List<EUR_TR_Route__c>();
        eurtrRoutes.add(eurtrRoute);

        String requestBody = JSON.serialize(eurtrRoutes);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addRouteByOwnerId', requestBody);

        List<EUR_TR_Route__c> eurtrRoutesToValidation = null;
        EUR_TR_Route__c eurtrRouteToValidation = null;
        {
            // Name is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.Name = '';
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutesToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addRouteByOwnerId', requestBody);

            // OwnerId is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.OwnerId = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutesToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addRouteByOwnerId', requestBody);

            // EUR_TR_IsFavorite__c is blank
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.EUR_TR_IsFavorite__c = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutesToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addRouteByOwnerId', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addRouteByOwnerId', requestBody);

        }


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addRouteByOwnerId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void removeRouteByIdTest() {

        List<EUR_TR_Route__c> eurtrRoutes = [
                SELECT
                        Id,OwnerId,EUR_TR_IsFavorite__c,EUR_TR_SelectedFilters__c,Name
                FROM EUR_TR_Route__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Route__c, 'EUR_TR_RouteTemplate')
        ];
        String requestBody = JSON.serialize(eurtrRoutes);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeRouteById', requestBody);

        List<EUR_TR_Route__c> eurtrRoutesToValidation = null;
        EUR_TR_Route__c eurtrRouteToValidation = null;
        {
            // Id is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.Id = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutes);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeRouteById', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeRouteById', requestBody);

        }


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeRouteById', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listAccountsByOwnerIdByRouteIdTest() {


        List<EUR_TR_Route__c> eurtrRoutes = [
                SELECT
                        Id,OwnerId,EUR_TR_IsFavorite__c,EUR_TR_SelectedFilters__c,Name
                FROM EUR_TR_Route__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Route__c, 'EUR_TR_RouteTemplate')
        ];
        String requestBody = JSON.serialize(eurtrRoutes);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByOwnerIdByRouteId', requestBody);

        List<EUR_TR_Route__c> eurtrRoutesToValidation = null;
        EUR_TR_Route__c eurtrRouteToValidation = null;
        {
            // Id is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.Id = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutes);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByOwnerIdByRouteId', requestBody);

            // OwnerId is blank.
            eurtrRouteToValidation = eurtrRoutes.get(0);
            eurtrRouteToValidation.OwnerId = null;
            eurtrRoutesToValidation = new List<EUR_TR_Route__c>();
            eurtrRoutesToValidation.add(eurtrRouteToValidation);
            requestBody = JSON.serialize(eurtrRoutes);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByOwnerIdByRouteId', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByOwnerIdByRouteId', requestBody);

        }

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByOwnerIdByRouteId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void addAccountToRouteByAccountIdByRouteIdTest() {


        List<EUR_TR_RouteDetail__c> eurtrRouteDetails = [
                SELECT
                        Id,EUR_TR_RelatedRoute__c,EUR_TR_RelatedAccount__c,EUR_TR_VisitOrder__c
                FROM EUR_TR_RouteDetail__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_RouteDetail__c, 'EUR_TR_RouteDetailTemplate')
        ];
        String requestBody = JSON.serialize(eurtrRouteDetails);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addAccountToRouteByAccountIdByRouteId', requestBody);

        List<EUR_TR_RouteDetail__c> eurtrRouteDetailsToValidation = null;
        EUR_TR_RouteDetail__c eurtrRouteDetailToValidation = null;

        {
            // EUR_TR_RelatedRoute__c is blank.
            eurtrRouteDetailToValidation = eurtrRouteDetails.get(0);
            eurtrRouteDetailsToValidation = new List<EUR_TR_RouteDetail__c>();
            eurtrRouteDetailsToValidation.add(eurtrRouteDetailToValidation);
            requestBody = JSON.serialize(eurtrRouteDetailsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addAccountToRouteByAccountIdByRouteId', requestBody);

            // EUR_TR_RelatedRoute__c is blank.
            eurtrRouteDetailToValidation = eurtrRouteDetails.get(0);
            eurtrRouteDetailToValidation.EUR_TR_RelatedAccount__c = null;
            eurtrRouteDetailsToValidation = new List<EUR_TR_RouteDetail__c>();
            eurtrRouteDetailsToValidation.add(eurtrRouteDetailToValidation);
            requestBody = JSON.serialize(eurtrRouteDetailsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addAccountToRouteByAccountIdByRouteId', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addAccountToRouteByAccountIdByRouteId', requestBody);

        }


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'addAccountToRouteByAccountIdByRouteId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void removeAccountInRouteByAccountIdByRouteIdTest() {


        List<EUR_TR_RouteDetail__c> eurtrRouteDetails = [
                SELECT
                        Id,EUR_TR_RelatedRoute__c,EUR_TR_RelatedAccount__c,EUR_TR_VisitOrder__c
                FROM EUR_TR_RouteDetail__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_RouteDetail__c, 'EUR_TR_RouteDetailTemplate')
        ];
        String requestBody = JSON.serialize(eurtrRouteDetails);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeAccountInRouteByAccountIdByRouteId', requestBody);

        List<EUR_TR_RouteDetail__c> eurtrRouteDetailsToValidation = null;
        EUR_TR_RouteDetail__c eurtrRouteDetailToValidation = null;

        {
            // EUR_TR_RelatedRoute__c is blank.
            eurtrRouteDetailToValidation = eurtrRouteDetails.get(0);
            eurtrRouteDetailsToValidation = new List<EUR_TR_RouteDetail__c>();
            eurtrRouteDetailsToValidation.add(eurtrRouteDetailToValidation);
            requestBody = JSON.serialize(eurtrRouteDetailsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeAccountInRouteByAccountIdByRouteId', requestBody);

            // EUR_TR_RelatedAccount__c is blank.
            eurtrRouteDetailToValidation = eurtrRouteDetails.get(0);
            eurtrRouteDetailToValidation.EUR_TR_RelatedAccount__c = null;
            eurtrRouteDetailsToValidation = new List<EUR_TR_RouteDetail__c>();
            eurtrRouteDetailsToValidation.add(eurtrRouteDetailToValidation);
            requestBody = JSON.serialize(eurtrRouteDetailsToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeAccountInRouteByAccountIdByRouteId', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeAccountInRouteByAccountIdByRouteId', requestBody);

        }


        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeAccountInRouteByAccountIdByRouteId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listMATReportByAccountIdByBrandTest() {


        List<EUR_TR_AccountSalesMAT__c> eurtrAccountSalesMATS = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountSalesMAT__c
        ];
        String requestBody = JSON.serialize(eurtrAccountSalesMATS);

        // All parameters  are passed.
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listMATReportByAccountIdByBrand', requestBody);


        List<EUR_TR_AccountSalesMAT__c> eurtrAccountSalesMATSToValidation = null;
        EUR_TR_AccountSalesMAT__c eurtrAccountSalesMATToValidation = null;
        {
            // EUR_TR_RelatedAccount__c is blank.
            eurtrAccountSalesMATToValidation = eurtrAccountSalesMATS.get(0);
            eurtrAccountSalesMATToValidation.EUR_TR_RelatedAccount__c = null;
            eurtrAccountSalesMATSToValidation = new List<EUR_TR_AccountSalesMAT__c>();
            eurtrAccountSalesMATSToValidation.add(eurtrAccountSalesMATToValidation);
            requestBody = JSON.serialize(eurtrAccountSalesMATSToValidation);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listMATReportByAccountIdByBrand', requestBody);

            // throw exception
            requestBody = JSON.serialize(new List<EUR_TR_Account__c>());
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listMATReportByAccountIdByBrand', requestBody);
        }

        // Request is empty.
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listMATReportByAccountIdByBrand', EMPTY_REQUEST_BODY);


    }

    @IsTest
    static void GETServiceExposedTest() {

        RestRequest request = new RestRequest();
        request.requestURI = getRequestURL();
        request.httpMethod = 'GET';
        RestResponse response = prepareRESTResponse();
        RestContext.request = request;
        RestContext.response = response;
        EUR_TR_MiddlewareController.getServiceExposed();

    }


    @IsTest
    static void listAccountNotesTest() {


        List<Note> notes = [SELECT Id,ParentId FROM Note WHERE ParentId != NULL];
        String requestBody = JSON.serialize(notes);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountNotes', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountNotes', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void removeNoteTest() {

        List<Note> notes = [SELECT Id, Body, Title FROM Note WHERE ParentId != NULL];
        String requestBody = JSON.serialize(notes);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeNote', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'removeNote', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listSettingsTest() {

        List<EUR_TR_ApplicationConfiguration__c> eurTRConfigurations = [SELECT Id,Name FROM EUR_TR_ApplicationConfiguration__c WHERE RecordType.DeveloperName = 'ApplicationConfiguration'];
        String requestBody = JSON.serialize(eurTRConfigurations);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSettings', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSettings', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void editSettingsTest() {

        List<EUR_TR_ApplicationConfiguration__c> eurTRConfigurations = [SELECT Id,Name,EUR_TR_AutoStartVisit__c FROM EUR_TR_ApplicationConfiguration__c WHERE RecordType.DeveloperName = 'ApplicationConfiguration'];
        String requestBody = JSON.serialize(eurTRConfigurations);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editSettings', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editSettings', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listPicklistByNameTest() {

        // all condition must be passed to service
        EUR_TR_MiddlewareController.PicklistRequest picklistRequest = new EUR_TR_MiddlewareController.PicklistRequest();
        picklistRequest.Name = 'VisitPurpose';
        String requestBody = JSON.serialize(picklistRequest);

        // Name is blank
        picklistRequest.Name = '';
        requestBody = JSON.serialize(picklistRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPicklistByName', requestBody);

        // Name is VisitPurpose
        picklistRequest.Name = 'VisitPurpose';
        requestBody = JSON.serialize(picklistRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPicklistByName', requestBody);

        // Name is POSMBrand
        picklistRequest.Name = 'POSMBrand';
        requestBody = JSON.serialize(picklistRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPicklistByName', requestBody);

        // Name is POSMType
        picklistRequest.Name = 'POSMType';
        requestBody = JSON.serialize(picklistRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPicklistByName', requestBody);

        // Name is TaskStatus
        picklistRequest.Name = 'TaskStatus';
        requestBody = JSON.serialize(picklistRequest);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPicklistByName', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPicklistByName', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void startVisitByAccountTest() {


        List<EUR_TR_Visit__c> eurtrRemPeoples = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_StartLocation__Latitude__s,EUR_TR_StartLocation__Longitude__s,EUR_TR_VisitPurpose__c
                FROM EUR_TR_Visit__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Visit__c, 'EUR_TR_Visit')
        ];
        String requestBody = JSON.serialize(eurtrRemPeoples);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'startVisitByAccount', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'startVisitByAccount', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void endVisitByIdTest() {


        List<EUR_TR_Visit__c> eurtrRemPeoples = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_StartLocation__Latitude__s,EUR_TR_StartLocation__Longitude__s,EUR_TR_VisitPurpose__c
                FROM EUR_TR_Visit__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Visit__c, 'EUR_TR_Visit')
        ];
        String requestBody = JSON.serialize(eurtrRemPeoples);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'endVisitById', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'endVisitById', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listVisitsByAccountIdTest() {


        List<EUR_TR_Visit__c> eurtrRemPeoples = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_StartLocation__Latitude__s,EUR_TR_StartLocation__Longitude__s,EUR_TR_VisitPurpose__c
                FROM EUR_TR_Visit__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Visit__c, 'EUR_TR_Visit') AND EUR_TR_RelatedAccount__c != NULL
        ];
        String requestBody = JSON.serialize(eurtrRemPeoples);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listVisitsByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listVisitsByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listDebtAgingByAccountIdTest() {


        List<EUR_TR_DebtAging__c> eurtrDebtAgings = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_DebtAging__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_DebtAging__c, 'EUR_TR_DebtAging')
        ];
        String requestBody = JSON.serialize(eurtrDebtAgings);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listDebtAgingByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listDebtAgingByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listDebtAgingSummaryByAccountIdTest() {


        List<EUR_TR_DebtAging__c> eurtrDebtAgings = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_DebtAging__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_DebtAging__c, 'EUR_TR_DebtAging')
        ];
        String requestBody = JSON.serialize(eurtrDebtAgings);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listDebtAgingSummaryByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listDebtAgingSummaryByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listAgreementByAccountIdTest() {


        List<EUR_TR_AccountAgreementBrand__c> eurtrAccountAgreementBrands = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountAgreementBrand__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountAgreementBrand__c, 'EUR_TR_AccountAgreementBrand')
        ];
        String requestBody = JSON.serialize(eurtrAccountAgreementBrands);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAgreementByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAgreementByAccountId', EMPTY_REQUEST_BODY);


    }


    //
    @IsTest
    static void listBountyRealizationByAccountIdTest() {


        List<EUR_TR_AccountBountyRealization__c> eurtrAccountBountyRealizations = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountBountyRealization__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountBountyRealization__c, 'EUR_TR_AccountBountyRealization')
        ];
        String requestBody = JSON.serialize(eurtrAccountBountyRealizations);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBountyRealizationByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBountyRealizationByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listRepVisitByAccountIdTest() {

        List<EUR_TR_Visit__c> eurtrVisits = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_StartLocation__Latitude__s,EUR_TR_StartLocation__Longitude__s,EUR_TR_VisitPurpose__c
                FROM EUR_TR_Visit__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Visit__c, 'EUR_TR_Visit')
        ];
        String requestBody = JSON.serialize(eurtrVisits);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRepVisitByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRepVisitByAccountId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listRangeByAccountIdTest() {


        List<EUR_TR_AccountRange__c> eurtrAccountRanges = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountRange__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountRange__c, 'EUR_TR_AccountRange')
        ];
        String requestBody = JSON.serialize(eurtrAccountRanges);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRangeByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRangeByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listInvoiceSummaryByAccountIdTest() {


        List<EUR_TR_InvoiceSummary__c> eurtrInvoiceSummaries = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_InvoiceSummary__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_InvoiceSummary__c, 'EUR_TR_InvoiceSummary')
        ];
        String requestBody = JSON.serialize(eurtrInvoiceSummaries);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listInvoiceSummaryByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listInvoiceSummaryByAccountId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listTargetRealizationByEmployeeIdTest() {


        List<EUR_TR_TargetRealization__c> eurtrTargetRealizations = [
                SELECT
                        Id,EUR_TR_Representative__c
                FROM EUR_TR_TargetRealization__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_TargetRealization__c, 'EUR_TR_TargetRealization')
        ];
        String requestBody = JSON.serialize(eurtrTargetRealizations);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTargetRealizationByEmployeeId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTargetRealizationByEmployeeId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listSalesTrendByAccountIdTest() {


        List<EUR_TR_SalesTrend__c> eurtrSalesTrends = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_SalesTrend__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_SalesTrend__c, 'EUR_TR_SalesTrend')
        ];
        String requestBody = JSON.serialize(eurtrSalesTrends);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSalesTrendByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSalesTrendByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listSalesTrendDetailsByAccountIdTest() {


        List<EUR_TR_SalesTrend__c> eurtrSalesTrends = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_SalesTrend__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_SalesTrend__c, 'EUR_TR_SalesTrend')
        ];
        String requestBody = JSON.serialize(eurtrSalesTrends);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSalesTrendDetailsByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSalesTrendByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listMATReportByAccountIdTest() {


        List<EUR_TR_AccountSalesMAT__c> eurtrAccountSalesMATS = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_Brand__c,EUR_TR_BrandQuality__c,EUR_TR_BrandQualitySize__c
                FROM EUR_TR_AccountSalesMAT__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountSalesMAT__c, 'EUR_TR_AccountSalesMAT')
        ];
        String requestBody = JSON.serialize(eurtrAccountSalesMATS);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listMATReportByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listMATReportByAccountId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listAccountsByParametersTest() {

        EUR_TR_MiddlewareController.AccountRequest accountRequest = new EUR_TR_MiddlewareController.AccountRequest();
        addFilterRequestParam(accountRequest, 'totalpoint-min', '1'); // 0
        addFilterRequestParam(accountRequest, 'totalpoint-max', '100'); // 1
        addFilterRequestParam(accountRequest, 'whiskey-min', '10'); // 2
        addFilterRequestParam(accountRequest, 'vodka-min', '10'); // 3
        addFilterRequestParam(accountRequest, 'shelf-min', '10'); // 4
        addFilterRequestParam(accountRequest, 'avl-min', '10'); // 5
        addFilterRequestParam(accountRequest, 'white-min', '10'); // 6
        addFilterRequestParam(accountRequest, 'name', 'ALİ AYDIN/AYDIN BUFE'); // 7
        addFilterRequestParam(accountRequest, 'type', '3YAYGIN DAĞILIM'); // 8
        addFilterRequestParam(accountRequest, 'class', 'E'); // 9
        addFilterRequestParam(accountRequest, 'status', 'Pasif'); // 10
        addFilterRequestParam(accountRequest, 'distributor', 'AYDA MESRUBAT GIDA IÇ.LTD. STI'); // 11
        addFilterRequestParam(accountRequest, 'channel', 'Off'); // 12
        addFilterRequestParam(accountRequest, 'city', 'IZMIR'); // 13
        addFilterRequestParam(accountRequest, 'district', 'ÖDEMIS'); // 14
        addFilterRequestParam(accountRequest, 'range', '0-No Range'); // 15
        addFilterRequestParam(accountRequest, 'census', '10'); // 16
        addFilterRequestParam(accountRequest, 'period', 'MAT'); // 17
        {
            addFilterRequestParam(accountRequest, 'brandshare-min', '1'); // 18
            addFilterRequestParam(accountRequest, 'incdecpercluster', '+ %21+'); // 19
            addFilterRequestParam(accountRequest, 'indeccasecluster', '0-10'); // 20
            addFilterRequestParam(accountRequest, 'volume-min', '100'); // 21
        }
        addFilterRequestParam(accountRequest, 'brand', 'OLMECA BLANCO'); // 22
        addFilterRequestParam(accountRequest, 'sku', 'ABSOLUT VODKA 35 CL'); // 23
        addFilterRequestParam(accountRequest, 'existnonexist', 'VAR-VAR'); // 24
        addFilterRequestParam(accountRequest, 'outofscope', '1'); // 25
        addFilterRequestParam(accountRequest, 'matlast6', 'MAT'); // 26


        String requestBody = JSON.serialize(accountRequest);

        // period,brand,sku is not blank
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);
        {
            // period  - MAT
            List<EUR_TR_MiddlewareController.AccountRequestParam> accountRequestParams = accountRequest.params;
            accountRequestParams.get(17).Value = 'MAT';
            accountRequestParams.get(24).Key = '';
            accountRequest.params = accountRequestParams;
            requestBody = JSON.serialize(accountRequest);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period - MTD
            accountRequestParams.get(17).Value = 'MTD';
            accountRequest.params = accountRequestParams;
            requestBody = JSON.serialize(accountRequest);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period - QTD
            accountRequestParams.get(17).Value = 'QTD';
            accountRequest.params = accountRequestParams;
            requestBody = JSON.serialize(accountRequest);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period - YTD
            accountRequestParams.get(17).Value = 'YTD';
            accountRequest.params = accountRequestParams;
            requestBody = JSON.serialize(accountRequest);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);
        }


        // period,brand is not blank , sku is null
        EUR_TR_MiddlewareController.AccountRequest accountRequest2 = accountRequest;
        List<EUR_TR_MiddlewareController.AccountRequestParam> accountRequestParams2 = accountRequest2.params;
        accountRequestParams2.remove(23); // sku is removed from search parameters
        {
            // period  - MAT
            accountRequestParams2.get(17).Value = 'MAT';
            accountRequest2.params = accountRequestParams2;
            requestBody = JSON.serialize(accountRequest2);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period - MTD
            accountRequestParams2.get(17).Value = 'MTD';
            accountRequest2.params = accountRequestParams2;
            requestBody = JSON.serialize(accountRequest2);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period - QTD
            accountRequestParams2.get(17).Value = 'QTD';
            accountRequest2.params = accountRequestParams2;
            requestBody = JSON.serialize(accountRequest2);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period - YTD
            accountRequestParams2.get(17).Value = 'YTD';
            accountRequest2.params = accountRequestParams2;
            requestBody = JSON.serialize(accountRequest2);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

        }


        // period,sku is not blank , brand is null
        EUR_TR_MiddlewareController.AccountRequest accountRequest3 = accountRequest;
        List<EUR_TR_MiddlewareController.AccountRequestParam> accountRequestParams3 = accountRequest3.params;
        accountRequestParams3.remove(22); // brand is removed from search parameters
        {
            // period  - MAT
            accountRequestParams3.get(17).Value = 'MAT';
            accountRequest3.params = accountRequestParams3;
            requestBody = JSON.serialize(accountRequest3);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period  - MTD
            accountRequestParams3.get(17).Value = 'MTD';
            accountRequest3.params = accountRequestParams3;
            requestBody = JSON.serialize(accountRequest3);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);


            // period  - QTD
            accountRequestParams3.get(17).Value = 'QTD';
            accountRequest3.params = accountRequestParams3;
            requestBody = JSON.serialize(accountRequest3);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);

            // period  - YTD
            accountRequestParams3.get(17).Value = 'YTD';
            accountRequest3.params = accountRequestParams3;
            requestBody = JSON.serialize(accountRequest3);
            makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', requestBody);
        }

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAccountsByParameters', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listFilterParametersTest() {


        Account acc = new Account();
        acc.FirstName = 'Dummy';
        List<Account> accounts = new List<Account>();
        accounts.add(acc);

        String requestBody = JSON.serialize(accounts);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listFilterParameters', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listFilterParameters', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listSurveysByAccountIdTest() {


        List<EUR_TR_Survey__c> eurtrSurveys = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_Survey__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateTarget')
        ];
        String requestBody = JSON.serialize(eurtrSurveys);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSurveysByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSurveysByAccountId', EMPTY_REQUEST_BODY);

    }


    //
    @IsTest
    static void listSurveysDetailsByIdTest() {


        List<EUR_TR_Survey__c> eurtrSurveys = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c,EUR_TR_RelatedSurveyTemplate__c
                FROM EUR_TR_Survey__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateTarget')
                AND EUR_TR_RelatedSurveyTemplate__c != NULL
        ];
        String requestBody = JSON.serialize(eurtrSurveys);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSurveysDetailsById', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listSurveysDetailsById', EMPTY_REQUEST_BODY);


    }


    //
    @IsTest
    static void listTOPSKUByAccountIdTest() {


        List<EUR_TR_AccountSales__c> eurtrAccountSales = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountSales__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountSales__c, 'EUR_TR_AccountSales') AND EUR_TR_RelatedAccount__c != NULL
        ];
        String requestBody = JSON.serialize(eurtrAccountSales);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTOPSKUByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTOPSKUByAccountId', EMPTY_REQUEST_BODY);

    }

    //
    @IsTest
    static void listLast5InvByAccountIdTest() {


        List<EUR_TR_Invoice__c> eurtrInvoices = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_Invoice__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Invoice__c, 'EUR_TR_Invoice')
        ];
        String requestBody = JSON.serialize(eurtrInvoices);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listLast5InvByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listLast5InvByAccountId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listBrandsByOwnerIdTest() {

        List<EUR_TR_SKU__c> eurTrSkus = [
                SELECT
                        Id
                FROM EUR_TR_SKU__c
        ];

        String requestBody = JSON.serialize(eurTrSkus);
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBrandsByOwnerId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBrandsByOwnerId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listBrandQualitiesByBrandTest() {


        List<EUR_TR_SKU__c> eurTrSkus = [
                SELECT
                        Id,EUR_TR_Brand__c
                FROM EUR_TR_SKU__c
                WHERE EUR_TR_Brand__c != NULL
        ];
        String requestBody = JSON.serialize(eurTrSkus);

        RestRequest request = prepareRestRequest('POST', 'listBrandQualitiesByBrand', requestBody);
        RestResponse response = prepareRESTResponse();
        RestContext.request = request;
        RestContext.response = response;
        EUR_TR_MiddlewareController.postServiceExposed();
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBrandQualitiesByBrand', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBrandQualitiesByBrand', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listBrandQualitySizesByBrandQualityTest() {


        List<EUR_TR_SKU__c> eurTrSkus = [
                SELECT
                        Id,EUR_TR_Brand__c,EUR_TR_BrandQuality__c
                FROM EUR_TR_SKU__c
                WHERE EUR_TR_Brand__c != NULL
        ];
        String requestBody = JSON.serialize(eurTrSkus);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBrandQualitySizesByBrandQuality', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listBrandQualitySizesByBrandQuality', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listProfitabilityByAccountIdTest() {


        List<EUR_TR_AccountProfitability__c> eurtrAccountProfitabilities = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountProfitability__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountProfitability__c, 'EUR_TR_AccountProfitability')
        ];
        String requestBody = JSON.serialize(eurtrAccountProfitabilities);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listProfitabilityByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listProfitabilityByAccountId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listProfitabilityByAccountIdGroupedTest() {


        List<EUR_TR_AccountProfitability__c> eurtrAccountProfitabilities = [
                SELECT
                        Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_AccountProfitability__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_AccountProfitability__c, 'EUR_TR_AccountProfitability')
        ];
        String requestBody = JSON.serialize(eurtrAccountProfitabilities);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listProfitabilityByAccountIdGrouped', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listProfitabilityByAccountIdGrouped', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listTasksByAccountIdByKindTest() {


        List<Task> tasks = [
                SELECT
                        Id,WhatId,PR_Activity_Type__c
                FROM Task
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.Task, 'EUR_TR_Task')
        ];

        EUR_TR_MiddlewareController.TaskRequest taskRequest = new EUR_TR_MiddlewareController.TaskRequest();
        taskRequest.task = tasks.get(0);
        taskRequest.task.RecurrenceInterval = 1;
        taskRequest.pageSize = 10;
        taskRequest.pageNumber = 1;
        String requestBody = JSON.serialize(taskRequest);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByAccountIdByKind', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTasksByAccountIdByKind', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listRelatedUsersByAccountIdTest() {


        List<EUR_TR_Account__c> eurtrAccounts = [
                SELECT Id
                FROM EUR_TR_Account__c
        ];
        String requestBody = JSON.serialize(eurtrAccounts);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRelatedUsersByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listRelatedUsersByAccountId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listPosmByAccountIdTest() {


        List<EUR_TR_POSM__c> POSMRecords = [
                SELECT
                        Id,Name,EUR_TR_RelatedAccount__c
                FROM EUR_TR_POSM__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_POSM__c, 'EUR_TR_POSM')
        ];
        String requestBody = JSON.serialize(POSMRecords);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPosmByAccountId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listPosmByAccountId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void editRouteByIdTest() {


        List<EUR_TR_Route__c> eurtrRoutes = [
                SELECT
                        Id,OwnerId,EUR_TR_IsFavorite__c,EUR_TR_SelectedFilters__c,Name
                FROM EUR_TR_Route__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Route__c, 'EUR_TR_RouteTemplate')
        ];
        String requestBody = JSON.serialize(eurtrRoutes);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editRouteById', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'editRouteById', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void listTargetsByOwnerIdTest() {


        List<EUR_TR_Target__c> tasks = [
                SELECT
                        Id,OwnerId
                FROM EUR_TR_Target__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Target__c, 'EUR_TR_Target')
        ];
        String requestBody = JSON.serialize(tasks);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTargetsByOwnerId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTargetsByOwnerId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listEmployeesByUserIdTest() {


        List<EUR_TR_Employee__c> eurtrEmployees = [
                SELECT
                        Id,OwnerId
                FROM EUR_TR_Employee__c
        ];
        String requestBody = JSON.serialize(eurtrEmployees);

        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listEmployeesByUserId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listEmployeesByUserId', EMPTY_REQUEST_BODY);


    }


    @IsTest
    static void listAnnouncementsByOwnerIdTest() {


        List<EUR_TR_Announcement__c> eurtrAnnouncements = [
                SELECT
                        Id,OwnerId
                FROM EUR_TR_Announcement__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Announcement__c, 'EUR_TR_AnnouncementTarget')
        ];
        String requestBody = JSON.serialize(eurtrAnnouncements);


        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAnnouncementsByOwnerId', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listAnnouncementsByOwnerId', EMPTY_REQUEST_BODY);

    }


    @IsTest
    static void getAnnouncementByIdTest() {

        List<EUR_TR_Announcement__c> eurtrAnnouncements = [
                SELECT
                        Id,OwnerId
                FROM EUR_TR_Announcement__c
                WHERE RecordTypeId = :getRecordTypeId(Schema.SObjectType.EUR_TR_Announcement__c, 'EUR_TR_Announcement')
        ];
        EUR_TR_MiddlewareController.getAnnouncementById(eurtrAnnouncements.get(0).Id);
    }

    @IsTest
    static void getAnnouncementByIdFromMiddlewareTest() {

        List<EUR_TR_Announcement__c> announcements = [
                SELECT Id,EUR_TR_RelatedAnnouncement__c
                FROM EUR_TR_Announcement__c
                WHERE EUR_TR_RelatedAnnouncement__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        {
            System.debug(JSON.serializePretty(announcements));
            EUR_TR_MiddlewareController.getAnnouncementByIdFromMiddleware(JSON.serialize(announcements.get(0)));
        }
        Test.stopTest();

    }


    @IsTest
    static void getFilesByLinkedEntityIdTest() {
        EUR_TR_Account__c eurtrAccount = [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
        EUR_TR_MiddlewareController.getFilesByLinkedEntityId(eurtrAccount.Id);
    }


    // check
    @IsTest
    static void sendSMSByPhoneNumberByCodeTest() {

        Test.setMock(HttpCalloutMock.class, new EUR_TR_SMSServiceMock_Test());

        String requestBody = '{\r\n\t\"Code\":\"999\",\r\n\t\"PhoneNumber\":\"5534603501\"\r\n}';
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'sendSMSByPhoneNumberByCode', requestBody);

        // request is empty
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'sendSMSByPhoneNumberByCode', EMPTY_REQUEST_BODY);

        // phoneNumber is empty
        requestBody = '{\r\n\t\"Code\":\"999\",\r\n\t\"PhoneNumber\":\"\"\r\n}';
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'sendSMSByPhoneNumberByCode', requestBody);

        // Code is empty
        requestBody = '{\r\n\t\"Code\":\"\",\r\n\t\"PhoneNumber\":\"5534603501\"\r\n}';
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'sendSMSByPhoneNumberByCode', requestBody);

    }


    static void createTestData() {
        // All Data is initialized here


        EUR_TR_Account__c eurtrAccount = new EUR_TR_Account__c();
        eurtrAccount.Name = 'Tekna Test User2';
        eurtrAccount.EUR_TR_DistributorName__c = 'ANKA';
        eurtrAccount.EUR_TR_AccountCode__c = 'ANKA';
        eurtrAccount.EUR_TR_Location__Latitude__s = 13.0429;
        eurtrAccount.EUR_TR_Location__Longitude__s = 80.2739;
        eurtrAccount.EUR_TR_SalesChiefName__c = 'Dummy Sales Chief Name';
        eurtrAccount.EUR_TR_AreaManagerName__c = 'Dummy Sales Manager Name';

        insert eurtrAccount;

        List<Contact> contacts = new List<Contact>();
        // Contact Record  - with related Account
        Contact contact = new Contact();
        contact.FirstName = 'Test User FFName';
        contact.LastName = 'Test User LLName';
        contact.Phone = '5534603501';
        contact.EUR_TR_MobilePhone__c = '5534603501';
        contact.Email = 'osman.tuna@teknaIt.com';
        contact.EUR_TR_Type__c = 'Employee';
        contact.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        contact.RecordTypeId = getRecordTypeId(Schema.SObjectType.Contact, 'EUR_TR_Contact');
        contact.EUR_TR_KVKKVerificationCode__c = '1234';
        contact.EUR_TR_KVKKVerificationDate__c = Datetime.now();
        contacts.add(contact);


        // Contact Record  - without related Account
        Contact contact2 = new Contact();
        contact2.FirstName = 'Test User FFName';
        contact2.LastName = 'Test User LLName';
        contact2.Phone = '5534603501';
        contact2.EUR_TR_MobilePhone__c = '5534603501';
        contact2.Email = 'osman.tuna@teknaIt.com';
        contact2.EUR_TR_Type__c = 'Employee';
        contact2.RecordTypeId = getRecordTypeId(Schema.SObjectType.Contact, 'EUR_TR_Contact');
        contacts.add(contact2);

        insert contacts;


        EUR_TR_RemPeople__c eurtrRemPeople = new EUR_TR_RemPeople__c();
        eurtrRemPeople.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        insert eurtrRemPeople;

        Note note = new Note();
        note.ParentId = eurtrAccount.Id;
        note.Title = 'My Title';
        note.Body = 'My Body';

        insert note;


        EUR_TR_ApplicationConfiguration__c eurTRConfiguration = new EUR_TR_ApplicationConfiguration__c();
        eurTRConfiguration.EUR_TR_RemPeople_Url__c = 'https://www.dummy-web-service.com/api/rempeopleservice';
        eurTRConfiguration.EUR_TR_RemPeople_Username__c = 'dummyUserName@tekna.com';
        eurTRConfiguration.EUR_TR_RemPeople_Password__c = 'dummyCensusPassword';
        eurTRConfiguration.EUR_TR_GPSVerificationRange__c = 12133.22;
        eurTRConfiguration.EUR_TR_SMS_Service_Url__c = 'https://www.dummy-web-service.com/api/smsservice';
        eurTRConfiguration.EUR_TR_AutoStartVisit__c = true;

        insert eurTRConfiguration;

        EUR_TR_Visit__c eurtrVisit = new EUR_TR_Visit__c();
        eurtrVisit.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrVisit.EUR_TR_StartLocation__Latitude__s = 14.535;
        eurtrVisit.EUR_TR_StartLocation__Longitude__s = 80.2739;
        eurtrVisit.EUR_TR_VisitPurpose__c = '4';
        eurtrVisit.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Visit__c, 'EUR_TR_Visit');

        insert eurtrVisit;

        EUR_TR_DebtAging__c eurtrDebtAging = new EUR_TR_DebtAging__c();
        eurtrDebtAging.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrDebtAging.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_DebtAging__c, 'EUR_TR_DebtAging');

        insert eurtrDebtAging;

        EUR_TR_AccountAgreementBrand__c eurtrAccountAgreementBrand = new EUR_TR_AccountAgreementBrand__c();
        eurtrAccountAgreementBrand.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrAccountAgreementBrand.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_AccountAgreementBrand__c, 'EUR_TR_AccountAgreementBrand');

        insert eurtrAccountAgreementBrand;

        EUR_TR_AccountBountyRealization__c eurtrAccountBountyRealization = new EUR_TR_AccountBountyRealization__c();
        eurtrAccountBountyRealization.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrAccountBountyRealization.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_AccountBountyRealization__c, 'EUR_TR_AccountBountyRealization');

        insert eurtrAccountBountyRealization;

        EUR_TR_RepVisit__c eurtrRepVisit = new EUR_TR_RepVisit__c();
        eurtrRepVisit.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_RepVisit__c, 'EUR_TR_RepVisit');
        eurtrRepVisit.EUR_TR_RelatedAccount__c = eurtrAccount.Id;

        insert eurtrRepVisit;

        EUR_TR_AccountRange__c eurtrAccountRange = new EUR_TR_AccountRange__c();
        eurtrAccountRange.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_AccountRange__c, 'EUR_TR_AccountRange');
        eurtrAccountRange.EUR_TR_RelatedAccount__c = eurtrAccount.Id;

        insert eurtrAccountRange;


        EUR_TR_InvoiceSummary__c eurtrInvoiceSummary = new EUR_TR_InvoiceSummary__c();
        eurtrInvoiceSummary.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_InvoiceSummary__c, 'EUR_TR_InvoiceSummary');
        eurtrInvoiceSummary.EUR_TR_RelatedAccount__c = eurtrAccount.Id;

        insert eurtrInvoiceSummary;

        EUR_TR_Employee__c eurtrEmployee = new EUR_TR_Employee__c();
        eurtrEmployee.OwnerId = UserInfo.getUserId();
        eurtrEmployee.Name = 'Dummy Sales Chief Name';
        insert eurtrEmployee;

        EUR_TR_TargetRealization__c eurtrTargetRealization = new EUR_TR_TargetRealization__c();
        eurtrTargetRealization.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_TargetRealization__c, 'EUR_TR_TargetRealization');
        eurtrTargetRealization.EUR_TR_Representative__c = eurtrEmployee.Id;

        insert eurtrTargetRealization;

        EUR_TR_SalesTrend__c eurtrSalesTrend = new EUR_TR_SalesTrend__c();
        eurtrSalesTrend.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrSalesTrend.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_SalesTrend__c, 'EUR_TR_SalesTrend');

        insert eurtrSalesTrend;

        EUR_TR_AccountSalesMAT__c eurtrAccountSalesMAT = new EUR_TR_AccountSalesMAT__c();
        eurtrAccountSalesMAT.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrAccountSalesMAT.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_AccountSalesMAT__c, 'EUR_TR_AccountSalesMAT');
        eurtrAccountSalesMAT.EUR_TR_BrandQuality__c = 'Good';
        eurtrAccountSalesMAT.EUR_TR_BrandQualitySize__c = '10';

        insert eurtrAccountSalesMAT;


        EUR_TR_District__c eurtrDistrict = new EUR_TR_District__c();
        eurtrDistrict.Name = 'Torbalı';
        eurtrDistrict.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_District__c, 'EUR_TR_District');
        eurtrDistrict.EUR_TR_CityName__c = 'izmir';

        insert eurtrDistrict;


        EUR_TR_Survey__c question = new EUR_TR_Survey__c();
        question.EUR_TR_Description__c = 'Dummy DEsc';
        question.EUR_TR_QuestionOrder__c = 1;
        question.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateDetail');
        question.EUR_TR_PictureRequired__c = false;

        insert question;

        EUR_TR_Survey__c masterTemplate = new EUR_TR_Survey__c();
        masterTemplate.EUR_TR_Description__c = 'Dummy DEsc 2';
        masterTemplate.EUR_TR_QuestionOrder__c = 1;
        masterTemplate.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateMaster');
        masterTemplate.EUR_TR_PictureRequired__c = false;

        insert masterTemplate;

        EUR_TR_Survey__c template = new EUR_TR_Survey__c();
        template.EUR_TR_Description__c = 'Dummy DEsc 2';
        template.EUR_TR_QuestionOrder__c = 1;
        template.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateMaster');
        template.EUR_TR_PictureRequired__c = false;

        insert template;


        EUR_TR_Survey__c eurtrSurvey = new EUR_TR_Survey__c();
        eurtrSurvey.EUR_TR_Mandatory__c = true;
        eurtrSurvey.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrSurvey.EUR_TR_ForAllCountry__c = true;
        eurtrSurvey.EUR_TR_ValidFrom__c = Date.today() - 1;
        eurtrSurvey.EUR_TR_ValidThru__c = Date.today() + 1;
        eurtrSurvey.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Survey__c, 'EUR_TR_TemplateTarget');
        eurtrSurvey.EUR_TR_RelatedTemplateDetail__c = question.Id;
        eurtrSurvey.EUR_TR_RelatedSurveyTemplate__c = template.Id;
        eurtrSurvey.EUR_TR_SurveyRelatedTemplate__c = masterTemplate.Id;

        insert eurtrSurvey;


        List<EUR_TR_AccountSales__c> eurtrAccountSales = new List<EUR_TR_AccountSales__c>();
        {
            EUR_TR_AccountSales__c eurtrAccountSale = new EUR_TR_AccountSales__c();
            eurtrAccountSale.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
            eurtrAccountSale.EUR_TR_Period__c = 'MAT';
            eurtrAccountSales.add(eurtrAccountSale);

            EUR_TR_AccountSales__c eurtrAccountSales2 = new EUR_TR_AccountSales__c();
            eurtrAccountSales2.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
            eurtrAccountSales2.EUR_TR_Period__c = 'MTD';
            eurtrAccountSales.add(eurtrAccountSales2);

            EUR_TR_AccountSales__c eurtrAccountSales3 = new EUR_TR_AccountSales__c();
            eurtrAccountSales3.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
            eurtrAccountSales3.EUR_TR_Period__c = 'QTD';
            eurtrAccountSales.add(eurtrAccountSales3);
        }
        insert eurtrAccountSales;


        EUR_TR_SKU__c eurTrSku = new EUR_TR_SKU__c();
        eurTrSku.EUR_TR_BrandQualitySize__c = '10';
        eurTrSku.EUR_TR_ImageUrl__c = 'https://dummyImageURL';
        eurTrSku.EUR_TR_Status__c = 'Aktif';
        eurTrSku.EUR_TR_Brand__c = 'JACK DANIELS';
        eurTrSku.EUR_TR_BrandQuality__c = 'JACK DANIELS';

        insert eurTrSku;


        EUR_TR_Invoice__c eurtrInvoice = new EUR_TR_Invoice__c();
        eurtrInvoice.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurtrInvoice.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Invoice__c, 'EUR_TR_Invoice');
        insert eurtrInvoice;


        EUR_TR_AccountProfitability__c eurtrAccountProfitability = new EUR_TR_AccountProfitability__c();
        eurtrAccountProfitability.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_AccountProfitability__c, 'EUR_TR_AccountProfitability');
        eurtrAccountProfitability.EUR_TR_Year__c = '1995';
        eurtrAccountProfitability.EUR_TR_RelatedAccount__c = eurtrAccount.Id;

        insert eurtrAccountProfitability;

        Task task = new Task();
        task.PR_Activity_Type__c = 'Salesforce';
        task.WhatId = eurtrAccount.Id;
        task.Subject = 'Dummy';
        task.ActivityDate = Date.today();
        task.OwnerId = UserInfo.getUserId();
        task.RecordTypeId = getRecordTypeId(Schema.SObjectType.Task, 'EUR_TR_Task');


        insert task;

        EUR_TR_POSM__c eurTrPosm = new EUR_TR_POSM__c();
        eurTrPosm.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_POSM__c, 'EUR_TR_POSM');
        eurTrPosm.EUR_TR_RelatedAccount__c = eurtrAccount.Id;
        eurTrPosm.OwnerId = UserInfo.getUserId();

        insert eurTrPosm;

        EUR_TR_Route__c eurtrRoute = new EUR_TR_Route__c();
        eurtrRoute.OwnerId = UserInfo.getUserId();
        eurtrRoute.EUR_TR_IsFavorite__c = true;
        eurtrRoute.Name = 'Dummy Name';
        eurtrRoute.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Route__c, 'EUR_TR_RouteTemplate');
        eurtrRoute.EUR_TR_SelectedFilters__c = '{"key":"latitude","value":"40.96948242187499"} , {"key":"longitude","value":"29.09527003304906"} , {"key":"brand","value":"ABSOLUT VODKA"} , {"key":"sku","value":"ABSOLUT 100 VODKA 70 CL"} , {"key":"invoicestatus","value":"Son 3 Ay"}';

        insert eurtrRoute;

        EUR_TR_RouteDetail__c eurtrRouteDetail = new EUR_TR_RouteDetail__c();
        eurtrRouteDetail.EUR_TR_RelatedRoute__c = eurtrRoute.Id;
        eurtrRouteDetail.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_RouteDetail__c, 'EUR_TR_RouteDetailTemplate');
        eurtrRouteDetail.EUR_TR_VisitOrder__c = 10;

        insert eurtrRouteDetail;


        EUR_TR_Target__c eurtrTarget = new EUR_TR_Target__c();
        eurtrTarget.EUR_TR_RelatedEmployee__c = eurtrEmployee.Id;
        eurtrTarget.OwnerId = UserInfo.getUserId();
        eurtrTarget.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Target__c, 'EUR_TR_Target');

        insert eurtrTarget;


        EUR_TR_Announcement__c relatedAnnouncement = new EUR_TR_Announcement__c();
        relatedAnnouncement.OwnerId = UserInfo.getUserId();
        relatedAnnouncement.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Announcement__c, 'EUR_TR_Announcement');

        insert relatedAnnouncement;

        EUR_TR_Announcement__c eurtrAnnouncement = new EUR_TR_Announcement__c();
        eurtrAnnouncement.OwnerId = UserInfo.getUserId();
        eurtrAnnouncement.RecordTypeId = getRecordTypeId(Schema.SObjectType.EUR_TR_Announcement__c, 'EUR_TR_AnnouncementTarget');
        eurtrAnnouncement.EUR_TR_RelatedAnnouncement__c = relatedAnnouncement.Id;


        insert eurtrAnnouncement;


        ContentVersion contentVersion = new ContentVersion(
                Title = 'Test Title',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Dummy_Test_Blob_Data'),
                IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = eurtrAccount.Id;
        contentDocumentLink.ContentDocumentId = documents[0].Id;
        contentDocumentLink.ShareType = 'V';
        insert contentDocumentLink;
    }

    @IsTest
    static void testRemoveFileById() {
        ContentVersion contentVersion = new ContentVersion();

        contentVersion.Title = 'Test';
        contentVersion.PathOnClient = 'testRemoveFileById.jpg';
        contentVersion.VersionData = Blob.valueOf('Test');
        contentVersion.IsMajorVersion = true;

        insert contentVersion;

        Test.startTest();

        // Test Positive
        EUR_TR_MiddlewareController.removeFileById(JSON.serialize([
                SELECT Id
                FROM ContentDocument
                LIMIT 1
        ][0]));

        // Test Negative
        EUR_TR_MiddlewareController.removeFileById(JSON.serialize(new ContentDocument()));

        Test.stopTest();
    }

    @IsTest
    static void testGetRoleAndProfileInformation() {
        Test.startTest();

        {
            RestRequest request = prepareRestRequest('POST', 'getRoleAndProfileInformation', '');
            RestResponse response = prepareRESTResponse();
            RestContext.request = request;
            RestContext.response = response;
            EUR_TR_MiddlewareController.postServiceExposed();
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetAnnouncementById() {

        EUR_TR_Announcement__c target = [
                SELECT Id,EUR_TR_RelatedAnnouncement__c
                FROM EUR_TR_Announcement__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AnnouncementTarget' and EUR_TR_RelatedAnnouncement__c != NULL
                LIMIT 1
        ];
        Test.startTest();
        {
            RestRequest request = prepareRestRequest('POST', 'getAnnouncementById', JSON.serialize(target));
            RestResponse response = prepareRESTResponse();
            RestContext.request = request;
            RestContext.response = response;
            EUR_TR_MiddlewareController.postServiceExposed();
        }
        Test.stopTest();

    }

    @IsTest
    static void test_EUR_TR_RouteControllerTestMethods() {

        // Actual Test Class => EUR_TR_RouteControllerTest
        callControllerMethodsAsMock(new List<String>{
                'createFavoriteRouteByFavoriteFilter',
                'createFavoriteRouteByFavoriteFilter',
                'getFavoriteRoutes',
                'deleteFavoriteRouteById',
                'updateFavoriteRouteById',
                'addAccountToFavoriteRoute',
                'deleteAccountFromFavoriteRoute',
                'createFavoriteRoute',
                'getAccountsByFavoriteRoute',
                'startRoute',
                'UpdateFavoriteRouteDetailVisitOrder',
                'updateRouteDetailVisitOrder'
        });

    }

    @IsTest
    static void test_EUR_TR_RouteReportControllerMethods() {

        // Actual Test Class => EUR_TR_RouteReportControllerTest
        callControllerMethodsAsMock(new List<String>{
                'getRouteReport',
                'getRouteReportDetailById'
        });

    }

    @IsTest
    static void test_EUR_TR_WorkedDayApprovalControllerMethods() {

        // Actual Test Class => EUR_TR_WorkedDayApprovalController
        callControllerMethodsAsMock(new List<String>{
                'createWorkedDayApprovalRequest'
        });

    }

    @IsTest
    static void test_EUR_TR_WorkedDayControllerMethods() {

        // Actual Test Class => EUR_TR_WorkedDayController
        callControllerMethodsAsMock(new List<String>{
                'startDay',
                'endDay',
                'checkIsDayStarted',
                'getNotClosedVisitsByCurrentWorkedDay'
        });

    }

    @IsTest
    static void test_EUR_TR_POSMApprovalControllerMethods() {

        // Actual Test class => EUR_TR_POSMApprovalControllerTest
        callControllerMethodsAsMock(new List<String>{
                'createPOSMRequest',
                'handleApprovalAction',
                'getPOSMApprovalRecords',
                'getPOSMApprovalRecordHistory',
                'getPOSMDetailByApprovalId',
                'isApprovalProcessRequiredByPOSMFields',
                'getApprovalActors'
        });

    }

    @IsTest
    static void test_EUR_TR_POSMControllerMethods() {

        // Actual Test class => EUR_TR_POSMControllerTest
        callControllerMethodsAsMock(new List<String>{
                'getPOSMTypes'
        });

    }

    @IsTest
    static void test_EUR_TR_CrossComplianceControllerMethods() {

        // Actual Test Class : EUR_TR_CrossComplianceControllerTest
        callControllerMethodsAsMock(new List<String>{
                'getCrossComplianceByAccountId'
        });

    }

    @IsTest
    static void test_EUR_TR_RangeSKUAvailabilityControllerMethods() {

        // Actual Test Class : EUR_TR_RangeSKUAvailabilityControllerTest
        callControllerMethodsAsMock(new List<String>{
                'getRangeSKUAvailabilityPercentages',
                'getSKUAvailabilityFilters',
                'getListOfSKUByAvailabilityFilter'

        });

    }

    @IsTest
    static void test_EUR_TR_IncentiveControllerMethods() {

        // Actual Test Class : EUR_TR_IncentiveController
        callControllerMethodsAsMock(new List<String>{
                'getActiveIncentivesByAccountId',
                'doNotShowMeSelectedIncentives',
                'getAllIncentivesByAccountId'

        });

    }

    @IsTest
    static void test_EUR_TR_OJTControllerMethods() {

        // Actual Test Class => EUR_TR_OJTControllerTest
        callControllerMethodsAsMock(new List<String>{
                'listOJTQuestions',
                'listSurveysByUserId',
                'createOJTPlan',
                'listOJTAccountsByRelatedPlan',
                'startOJTCustomerVisit',
                'endOJTCustomerVisit',
                'getPresellerList',
                'listOJTPlans',
                'startOJTPlan',
                'deleteOJTPlan',
                'endOJTPlan',
                'getPresellerOJTPlanReport',
                'getOJTVisitsByPlanReport',
                'getOJTVisitDetails',
                'getOJTConfigurations',
                'makeOJTActionsAfterOJTComplete',
                'getOJTOrganizationScores'
        });

    }

    @IsTest
    static void test_EUR_TR_ReportMethods() {

        // Actual Test Class => EUR_TR_ReportTest
        callControllerMethodsAsMock(new List<String>{
                'getTargetReport',
                'getSalesTrendsReport',
                'getMATByBrandReport',
                'getProfitabilityReport',
                'getProfitabilityDetailReport',
                'getMATReport'
        });

    }

    @IsTest
    static void test_EUR_TR_AccountSearchControllerMethods() {

        // Actual Test Class => EUR_TR_AccountSearchControllerTest
        callControllerMethodsAsMock(new List<String>{
                'searchAccounts',
                'orderAccounts'
        });

    }

    @IsTest
    static void test_EUR_TR_BulkTaskImporterMethods() {

        // Actual Test Class => EUR_TR_BulkTaskImporterTest
        callControllerMethodsAsMock(new List<String>{
                'getPredefinedTasks'
        });

    }


    @IsTest
    static void testGetPicklistValues() {

        EUR_TR_MiddlewareController.RequestPicklist requestBody = new EUR_TR_MiddlewareController.RequestPicklist();
        requestBody.fieldName = 'EUR_TR_Channel__c';
        requestBody.objectName = 'EUR_TR_Account__c';
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'getPicklistValues', JSON.serialize(requestBody));

    }

    @IsTest
    static void testListTRUsers() {
        EUR_TR_Account__c account = new EUR_TR_Account__c();

        account.Name = 'test acc 12';
        account.EUR_TR_Status__c = 'Aktif';
        account.EUR_TR_AccountCode__c = '123';
        account.EUR_TR_TopExManagerName__c = UserInfo.getName();

        insert account;
        makeTestCallout(HTTP_POST_REQUEST_TYPE, 'listTRUsers', JSON.serialize(account));
    }


    private static Id getRecordTypeId(Schema.DescribeSObjectResult sObjectResult, String recordTypeDeveloperName) {

        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = sObjectResult.getRecordTypeInfosByDeveloperName();
        RecordTypeInfo recordTypeInfo = recordTypeInfoMap.get(recordTypeDeveloperName);
        return recordTypeInfo.getRecordTypeId();
    }

    private static RestRequest prepareRestRequest(String methodType, String methodName, String requestBody) {
        RestRequest request = new RestRequest();
        request.requestURI = getRequestURL();
        request.httpMethod = methodType;
        request.params.put('MethodName', methodName);
        request.requestBody = Blob.valueOf(requestBody);
        return request;
    }

    private static String getRequestURL() {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/EUR_TR_MIddleware';
    }

    private static RestResponse prepareRESTResponse() {
        RestResponse response = new RestResponse();
        {
            response.addHeader('Content-Type', 'application/json');
        }
        return response;
    }

    private static void addFilterRequestParam(EUR_TR_MiddlewareController.AccountRequest accountRequest, String paramKey, String paramValue) {
        EUR_TR_MiddlewareController.AccountRequestParam requestParam = new EUR_TR_MiddlewareController.AccountRequestParam();
        requestParam.key = paramKey;
        requestParam.value = paramValue;
        if (accountRequest.params == null) {
            accountRequest.params = new List<EUR_TR_MiddlewareController.AccountRequestParam>();
        }
        accountRequest.params.add(requestParam);
    }

    private static void makeTestCallout(String methodType, String methodName, String requestBody) {
        RestRequest request = prepareRestRequest(methodType, methodName, requestBody);
        RestResponse response = prepareRESTResponse();
        RestContext.request = request;
        RestContext.response = response;
        EUR_TR_MiddlewareController.postServiceExposed();
    }

    /**
     * @param methodNames
     * The purpose of the method is just only mock call. If you have separated test class,you can use this methods.
     */
    private static void callControllerMethodsAsMock(List<String> methodNames) {
        for (String methodName : methodNames) {
            String requestBody = '';
            RestRequest request = prepareRestRequest('POST', methodName, JSON.serialize(requestBody));
            RestResponse response = prepareRESTResponse();
            RestContext.request = request;
            RestContext.response = response;
            EUR_TR_MiddlewareController.postServiceExposed();
        }
    }


}