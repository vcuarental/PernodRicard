/**
 * Created by osman on 24.12.2020.
 */

@IsTest
private with sharing class EUR_TR_UserSurveyAssignmentContTest {

    @TestSetup
    static void setup() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'EUR TR Trade Tool User'];

        User user = new User();
        user.FirstName = 'vesium test';
        user.LastName = 'vesium test';
        user.UserName = 'pernodtestuser-survey@pernod.com';
        user.Alias = 'survey99';
        user.Email = 'pernodtestuser-survey@pernod.com';
        user.ProfileId = profile.Id;
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'tr_TR';
        user.TimeZoneSidKey = 'Europe/Istanbul';
        insert user;

        EUR_TR_Survey__c templateMasterSurveyToBeforeDayEnd = new EUR_TR_Survey__c();
        templateMasterSurveyToBeforeDayEnd.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();
        templateMasterSurveyToBeforeDayEnd.EUR_TR_ValidFrom__c = Date.today().addDays(-3);
        templateMasterSurveyToBeforeDayEnd.EUR_TR_CaptureMoment__c = 'BeforeDayEnd';
        templateMasterSurveyToBeforeDayEnd.EUR_TR_Mandatory__c = true;
        insert templateMasterSurveyToBeforeDayEnd;

        EUR_TR_Survey__c templateMasterSurveyToBeforeDayStart = new EUR_TR_Survey__c();
        templateMasterSurveyToBeforeDayStart.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();
        templateMasterSurveyToBeforeDayStart.EUR_TR_ValidFrom__c = Date.today().addDays(-3);
        templateMasterSurveyToBeforeDayStart.EUR_TR_CaptureMoment__c = 'BeforeDayStart';
        templateMasterSurveyToBeforeDayEnd.EUR_TR_Mandatory__c = true;
        insert templateMasterSurveyToBeforeDayStart;

        EUR_TR_Survey__c targetSurvey = new EUR_TR_Survey__c();
        targetSurvey.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
        targetSurvey.OwnerId = user.Id;
        targetSurvey.EUR_TR_TargetRelatedTemplate__c = templateMasterSurveyToBeforeDayEnd.Id;
        targetSurvey.EUR_TR_IsCompleted__c = false;
        targetSurvey.EUR_TR_Mandatory__c = templateMasterSurveyToBeforeDayStart.EUR_TR_Mandatory__c;
        insert targetSurvey;

    }

    @IsTest
    static void testGetSurveyOptions() {

        Test.startTest();
        {
            EUR_TR_UserSurveyAssignmentController.getSurveyOptions();
        }
        Test.stopTest();

    }

    @IsTest
    static void testAssignSurveyToUsers_assign_selected_users() {

        List<User> users = [SELECT Id FROM User WHERE Username = 'pernodtestuser-survey@pernod.com'];
        EUR_TR_Survey__c templateMasterSurveyToBeforeDayStart = [
                SELECT Id
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_CaptureMoment__c = 'BeforeDayStart'
                LIMIT 1
        ];

        EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest userSurveyAssignmentRequest = new EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest();
        userSurveyAssignmentRequest.isAllSelected = false;
        userSurveyAssignmentRequest.users = users;
        userSurveyAssignmentRequest.selectedMasterSurveyTemplateId = templateMasterSurveyToBeforeDayStart.Id;

        Test.startTest();
        {
            EUR_TR_UserSurveyAssignmentController.assignSurveyToUsers(userSurveyAssignmentRequest);
        }
        Test.stopTest();

    }

    @IsTest
    static void testAssignSurveyToUsers_assign_all_filtered_users() {

        List<User> users = [SELECT Id FROM User WHERE Username = 'pernodtestuser-survey@pernod.com'];
        EUR_TR_Survey__c templateMasterSurveyToBeforeDayStart = [
                SELECT Id
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_CaptureMoment__c = 'BeforeDayStart'
                LIMIT 1
        ];

        EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest userSurveyAssignmentRequest = new EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest();
        userSurveyAssignmentRequest.isAllSelected = true;
        userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment = 'SELECT Id FROM User WHERE Username = \'pernodtestuser-survey@pernod.com\'';
        userSurveyAssignmentRequest.selectedMasterSurveyTemplateId = templateMasterSurveyToBeforeDayStart.Id;

        Test.startTest();
        {
            EUR_TR_UserSurveyAssignmentController.assignSurveyToUsers(userSurveyAssignmentRequest);
        }
        Test.stopTest();

    }

    @IsTest
    static void testAssignSurveyToUsers_error() {

        EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest userSurveyAssignmentRequest = new EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest();

        Test.startTest();
        {
            try {
                EUR_TR_UserSurveyAssignmentController.assignSurveyToUsers(userSurveyAssignmentRequest);
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testRemoveAssignedSurveysToUsers_all() {

        EUR_TR_Survey__c templateMasterSurveyToBeforeDayStart = [
                SELECT Id
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_CaptureMoment__c = 'BeforeDayStart'
                LIMIT 1
        ];

        EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest userSurveyAssignmentRequest = new EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest();
        userSurveyAssignmentRequest.isAllSelected = true;
        userSurveyAssignmentRequest.selectedMasterSurveyTemplateId = templateMasterSurveyToBeforeDayStart.Id;
        userSurveyAssignmentRequest.surveyAssignmentQueryToRemoveAllAssignment = 'SELECT Id FROM EUR_TR_Survey__c WHERE EUR_TR_CaptureMoment__c = \'BeforeDayStart\' ';

        Test.startTest();
        {
            EUR_TR_UserSurveyAssignmentController.removeAssignedSurveysToUsers(userSurveyAssignmentRequest);
        }
        Test.stopTest();

    }

    @IsTest
    static void testRemoveAssignedSurveysToUsers_selectedUsers() {

        EUR_TR_Survey__c templateMasterSurveyToBeforeDayStart = [
                SELECT Id
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_CaptureMoment__c = 'BeforeDayStart'
                LIMIT 1
        ];

        List<EUR_TR_Survey__c> targetSurveys = [
                SELECT Id
                FROM EUR_TR_Survey__c
                WHERE RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
        ];

        EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest userSurveyAssignmentRequest = new EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest();
        userSurveyAssignmentRequest.isAllSelected = false;
        userSurveyAssignmentRequest.selectedMasterSurveyTemplateId = templateMasterSurveyToBeforeDayStart.Id;
        userSurveyAssignmentRequest.targetSurveys = targetSurveys;

        Test.startTest();
        {
            EUR_TR_UserSurveyAssignmentController.removeAssignedSurveysToUsers(userSurveyAssignmentRequest);
        }
        Test.stopTest();

    }

    @IsTest
    static void testRemoveAssignedSurveysToUsers_error() {

        EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest userSurveyAssignmentRequest = new EUR_TR_UserSurveyAssignmentController.UserSurveyAssignmentRequest();

        Test.startTest();
        {
            try {
                EUR_TR_UserSurveyAssignmentController.removeAssignedSurveysToUsers(userSurveyAssignmentRequest);
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }

        }
        Test.stopTest();

    }

    @IsTest
    static void testGetUserPicklistFieldsWithValues() {

        Test.startTest();
        {
            EUR_TR_UserSurveyAssignmentController.getUserPicklistFieldsWithValues();
        }
        Test.stopTest();

    }


}