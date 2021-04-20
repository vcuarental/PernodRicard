/**
 * Created by osman on 16.12.2020.
 */

public with sharing class EUR_TR_UserSurveyAssignmentController {


    class EUR_TR_UserSurveyAssignmentControllerException extends Exception {
    }


    @AuraEnabled
    public static List<EUR_TR_SurveyAssignmentController.PicklistEntry> getSurveyOptions() {

        List<EUR_TR_Survey__c> surveys = [
                SELECT Id,EUR_TR_Description__c,EUR_TR_ValidFrom__c,EUR_TR_ValidThru__c
                FROM EUR_TR_Survey__c
                WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster' AND
                EUR_TR_CaptureMoment__c IN ('BeforeDayEnd', 'BeforeDayStart') AND EUR_TR_CaptureMoment__c != NULL
                AND EUR_TR_ValidThru__c >= TODAY
        ];

        List<EUR_TR_SurveyAssignmentController.PicklistEntry> picklistEntries = new List<EUR_TR_SurveyAssignmentController.PicklistEntry>();
        for (EUR_TR_Survey__c survey : surveys) {
            EUR_TR_SurveyAssignmentController.PicklistEntry picklistEntry = new EUR_TR_SurveyAssignmentController.PicklistEntry();
            picklistEntry.label = String.format('{0} - ({1} - {2})', new List<String>{
                    survey.EUR_TR_Description__c, String.valueOf(survey.EUR_TR_ValidFrom__c), String.valueOf(survey.EUR_TR_ValidThru__c)
            });
            picklistEntry.value = survey.Id;
            picklistEntries.add(picklistEntry);
        }

        return picklistEntries;
        //return EUR_TR_SurveyAssignmentController.getSurveyOptions();

    }

    @AuraEnabled
    public static void assignSurveyToUsers(UserSurveyAssignmentRequest userSurveyAssignmentRequest) {

        Savepoint sp = Database.setSavepoint();

        try {

            System.debug(JSON.serializePretty(userSurveyAssignmentRequest));
            if (String.isBlank(userSurveyAssignmentRequest.selectedMasterSurveyTemplateId)) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Lütfen anket seçiniz!');
            }
            if (userSurveyAssignmentRequest.isAllSelected && (userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment == null || String.isBlank(userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment))) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Lütfen sistem yönecisi ile iletişime geçiniz');
            }
            if (userSurveyAssignmentRequest.isAllSelected == false && (userSurveyAssignmentRequest.users == null || userSurveyAssignmentRequest.users.isEmpty())) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Lütfen en az bir kullanıcı seçiniz');
            }


            List<User> users = new List<User>();
            if (userSurveyAssignmentRequest.isAllSelected) {
                users = Database.query(userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment);
            } else {
                users = userSurveyAssignmentRequest.users;
            }

            if (users.isEmpty()) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Anket atama işlemi için kullanıcı bulunmadı');
            }

            System.debug(userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment);
            System.debug(users.size());

            EUR_TR_Survey__c templateMaster = [
                    SELECT Id,EUR_TR_Mandatory__c
                    FROM EUR_TR_Survey__c
                    WHERE Id = :userSurveyAssignmentRequest.selectedMasterSurveyTemplateId
            ];

            Map<String, EUR_TR_Survey__c> existingTargetSurveysMap = getActiveExistAssignedTargetSurveys(userSurveyAssignmentRequest.selectedMasterSurveyTemplateId, users);
            List<EUR_TR_Survey__c> targetSurveys = new List<EUR_TR_Survey__c>();

            Id templateTargetRecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
            for (User user : users) {
                if (!existingTargetSurveysMap.containsKey(user.Id + '_' + templateMaster.Id)) {
                    targetSurveys.add(new EUR_TR_Survey__c(RecordTypeId = templateTargetRecordTypeId,
                            OwnerId = user.Id,
                            EUR_TR_TargetRelatedTemplate__c = templateMaster.Id,
                            EUR_TR_IsCompleted__c = false,
                            EUR_TR_Mandatory__c = templateMaster.EUR_TR_Mandatory__c));
                }
            }

            if (!targetSurveys.isEmpty()) {
                insert targetSurveys;
                Map<Id, Id> userToSurveyMap = new Map<Id, Id>();
                for (EUR_TR_Survey__c targetSurvey : targetSurveys) {
                    userToSurveyMap.put(targetSurvey.OwnerId, targetSurvey.Id);
                }
                if (!userToSurveyMap.isEmpty()) {
                    sendSurveyNotificationsByUserIds(userToSurveyMap);
                }

            }


        } catch (Exception ex) {
            System.debug('Error Message : ' + ex.getMessage());
            System.debug('Trace : ' + ex.getStackTraceString());
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void removeAssignedSurveysToUsers(UserSurveyAssignmentRequest userSurveyAssignmentRequest) {

        Savepoint sp = Database.setSavepoint();
        try {

            if (String.isBlank(userSurveyAssignmentRequest.selectedMasterSurveyTemplateId)) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Lütfen anket seçiniz!');
            }
            if (userSurveyAssignmentRequest.isAllSelected && (userSurveyAssignmentRequest.surveyAssignmentQueryToRemoveAllAssignment == null || String.isBlank(userSurveyAssignmentRequest.surveyAssignmentQueryToRemoveAllAssignment))) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Lütfen sistem yönecisi ile iletişime geçiniz');
            }
            if (!userSurveyAssignmentRequest.isAllSelected && (userSurveyAssignmentRequest.targetSurveys == null || userSurveyAssignmentRequest.targetSurveys.isEmpty())) {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Lütfen anket ataması silmek için en az 1 adet seçim yapınız.');
            }

            System.debug('selectedMasterSurveyTemplateId : ' + userSurveyAssignmentRequest.selectedMasterSurveyTemplateId);

            List<EUR_TR_Survey__c> targetSurveys = new List<EUR_TR_Survey__c>();
            if (userSurveyAssignmentRequest.isAllSelected) {
                targetSurveys = Database.query(userSurveyAssignmentRequest.surveyAssignmentQueryToRemoveAllAssignment);
            } else {
                targetSurveys = userSurveyAssignmentRequest.targetSurveys;
            }

            System.debug(userSurveyAssignmentRequest.surveyAssignmentQueryToRemoveAllAssignment);
            System.debug(targetSurveys.size());

            if (!targetSurveys.isEmpty()) {
                delete targetSurveys;
            } else {
                throw new EUR_TR_UserSurveyAssignmentControllerException('Silinecek kayıt bulunamadı');
            }


        } catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }


    }

    @AuraEnabled
    public static List<PicklistModelWrapper> getUserPicklistFieldsWithValues() {
        List<EUR_TR_DataPagerController.ObjectField> objectAllFields = EUR_TR_DataPagerController.getAllFields('User');
        List<PicklistModelWrapper> wrappers = new List<PicklistModelWrapper>();
        for (EUR_TR_DataPagerController.ObjectField field : objectAllFields) {
            if (field.type == 'PICKLIST') {
                wrappers.add(getPreparedPicklistFieldModel('User', field.value));
            }
        }
        return wrappers;
    }

    public static PicklistModelWrapper getPreparedPicklistFieldModel(String objectName, String fieldName) {

        List<Schema.PicklistEntry> picklistEntries = Schema.getGlobalDescribe()
                .get(objectName)
                .getDescribe()
                .fields
                .getMap()
                .get(fieldName)
                .getDescribe()
                .getPicklistValues();


        PicklistModelWrapper wrapper = new PicklistModelWrapper();
        wrapper.labelValueMap = new Map<String, String>();
        wrapper.fieldName = fieldName;
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                wrapper.labelValueMap.put(entry.getValue(), entry.getLabel());
            }
        }

        return wrapper;
    }

    private static Map<String, EUR_TR_Survey__c> getActiveExistAssignedTargetSurveys(Id selectedMasterSurveyTemplateId, List<User> users) {

        Id templateTargetRecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();

        Set<Id> userIds = new Set<Id>();
        for (User user : users) {
            userIds.add(user.Id);
        }

        List<EUR_TR_Survey__c> existTargetSurveys = [
                SELECT Id,OwnerId,EUR_TR_TargetRelatedTemplate__c
                FROM EUR_TR_Survey__c
                WHERE RecordTypeId = :templateTargetRecordTypeId
                AND EUR_TR_IsCompleted__c = FALSE
                AND OwnerId IN :userIds
                AND EUR_TR_TargetRelatedTemplate__c = :selectedMasterSurveyTemplateId
        ];

        Map<String, EUR_TR_Survey__c> existingTargetSurveysMap = new Map<String, EUR_TR_Survey__c>();
        for (EUR_TR_Survey__c existingTargetSurvey : existTargetSurveys) {
            String key = existingTargetSurvey.OwnerId + '_' + existingTargetSurvey.EUR_TR_TargetRelatedTemplate__c;
            if (!existingTargetSurveysMap.containsKey(key)) {
                existingTargetSurveysMap.put(key, existingTargetSurvey);
            }
        }

        return existingTargetSurveysMap;

    }

    private static void sendSurveyNotificationsByUserIds(Map<Id, Id> userToSurveyMap) {

        List<AsyncApexJob> activeSurveyNotificationBatches = [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,CreatedDate,ParentJobId
                FROM AsyncApexJob
                WHERE ApexClass.Name = 'EUR_TR_SurveyNotificationBatch'
                AND Status != 'Completed'
                AND ParentJobId = NULL
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        if (!activeSurveyNotificationBatches.isEmpty()) {
            throw new EUR_TR_UserSurveyAssignmentControllerException('Yaptığınız atama işlemi için bildirim gönderme işlemi devam ediyor.Lütfen daha sonra tekrar deneyiniz');
        }

        if (!userToSurveyMap.isEmpty()) {

            String announcementMessage = 'Size atanmış bir anketiniz bulunmaktadır';
            EUR_TR_Announcement__c announcement = new EUR_TR_Announcement__c();
            announcement.OwnerId = UserInfo.getUserId();
            announcement.Name = announcementMessage;
            announcement.EUR_TR_AnnouncementText__c = announcementMessage;
            announcement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Announcement').getRecordTypeId();
            insert announcement;

            List<EUR_TR_Announcement__c> targetAnnouncements = new List<EUR_TR_Announcement__c>();
            for (Id userId : userToSurveyMap.keySet()) {
                Id assignedSurvey = userToSurveyMap.get(userId);
                if (assignedSurvey != null) {
                    EUR_TR_Announcement__c targetAnnouncement = new EUR_TR_Announcement__c();
                    targetAnnouncement.OwnerId = userId;
                    targetAnnouncement.EUR_TR_RelatedAnnouncement__c = announcement.Id;
                    targetAnnouncement.EUR_TR_IsRead__c = false;
                    targetAnnouncement.EUR_TR_RelatedSurvey__c = assignedSurvey;
                    targetAnnouncement.EUR_TR_AnnouncementText__c = announcementMessage;
                    targetAnnouncement.Name = announcementMessage;
                    targetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();
                    targetAnnouncements.add(targetAnnouncement);
                }
            }

            if (!targetAnnouncements.isEmpty()) {
                insert targetAnnouncements;
            }

            if (!targetAnnouncements.isEmpty()) {
                Set<Id> targetAnnouncementIds = new Set<Id>();
                for (EUR_TR_Announcement__c targetAnnouncement : targetAnnouncements) {
                    targetAnnouncementIds.add(targetAnnouncement.Id);
                }
                Database.executeBatch(new EUR_TR_SurveyNotificationBatch(targetAnnouncementIds), 1);
            }

        }

    }

    public class PicklistModelWrapper {
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public Map<String, String> labelValueMap { get; set; }
    }

    public class UserSurveyAssignmentRequest {
        @AuraEnabled
        public List<User> users { get; set; }
        @AuraEnabled
        public Id selectedMasterSurveyTemplateId { get; set; }
        @AuraEnabled
        public List<EUR_TR_Survey__c> targetSurveys { get; set; }
        @AuraEnabled
        public String surveyAssignmentQueryToRemoveAllAssignment { get; set; }
        @AuraEnabled
        public String surveyAssignmentQueryToAllUserAssignment { get; set; }
        @AuraEnabled
        public Boolean isAllSelected { get; set; }
    }

}