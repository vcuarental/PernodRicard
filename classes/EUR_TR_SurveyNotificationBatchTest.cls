/**
 * Created by osman on 29.01.2021.
 */


@IsTest
public with sharing class EUR_TR_SurveyNotificationBatchTest {

    @TestSetup
    static void setup() {

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
        targetSurvey.OwnerId = UserInfo.getUserId();
        targetSurvey.EUR_TR_TargetRelatedTemplate__c = templateMasterSurveyToBeforeDayEnd.Id;
        targetSurvey.EUR_TR_IsCompleted__c = false;
        targetSurvey.EUR_TR_Mandatory__c = templateMasterSurveyToBeforeDayStart.EUR_TR_Mandatory__c;
        insert targetSurvey;

        String announcementMessage = 'Atanmış anketiniz bulunmaktadır';
        EUR_TR_Announcement__c announcement = new EUR_TR_Announcement__c();
        announcement.OwnerId = UserInfo.getUserId();
        announcement.Name = announcementMessage;
        announcement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Announcement').getRecordTypeId();
        insert announcement;

        EUR_TR_Announcement__c targetAnnouncement = new EUR_TR_Announcement__c();
        targetAnnouncement.OwnerId = UserInfo.getUserId();
        targetAnnouncement.EUR_TR_RelatedAnnouncement__c = announcement.Id;
        targetAnnouncement.EUR_TR_IsRead__c = false;
        targetAnnouncement.EUR_TR_RelatedSurvey__c = targetSurvey.Id;
        targetAnnouncement.EUR_TR_AnnouncementText__c = announcementMessage;
        targetAnnouncement.Name = announcementMessage;
        targetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();
        insert targetAnnouncement;

    }

    @IsTest
    static void testBatch() {

        Map<Id, EUR_TR_Announcement__c> announcementMap = new Map<Id, EUR_TR_Announcement__c>([
                SELECT Id
                FROM EUR_TR_Announcement__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AnnouncementTarget'
        ]);

        Test.startTest();
        {
            Database.executeBatch(new EUR_TR_SurveyNotificationBatch(announcementMap.keySet()), 1);
        }
        Test.stopTest();
    }

}