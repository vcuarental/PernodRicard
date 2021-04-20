/**
 * Created by osman on 29.01.2021.
 */

public with sharing class EUR_TR_SurveyNotificationBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    Set<Id> targetNotificationIds;

    public EUR_TR_SurveyNotificationBatch(Set<Id> targetNotificationIds) {
        this.targetNotificationIds = targetNotificationIds;
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        System.debug('EUR_TR_SurveyNotificationBatch is started');
        return Database.getQueryLocator([
                SELECT Id,OwnerId,EUR_TR_RelatedSurvey__c,Name,EUR_TR_AnnouncementText__c,EUR_TR_RelatedSurvey__r.EUR_TR_TargetRelatedTemplate__c
                FROM EUR_TR_Announcement__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AnnouncementTarget' AND Id IN :targetNotificationIds
        ]);
    }

    public void execute(Database.BatchableContext param1, List<EUR_TR_Announcement__c> targetAnnouncements) {

        Messaging.PushNotification pushNotification = null;
        Map<String, String> payloadBody = null;
        for (EUR_TR_Announcement__c targetAnnouncement : targetAnnouncements) {
            if (targetAnnouncement.EUR_TR_RelatedSurvey__r.EUR_TR_TargetRelatedTemplate__c != null) {
                pushNotification = new Messaging.PushNotification();
                payloadBody = new Map<String, String>();
                payloadBody.put('type', 'Survey');
                payloadBody.put('id', targetAnnouncement.Id);
                if (targetAnnouncement.EUR_TR_RelatedSurvey__r.EUR_TR_TargetRelatedTemplate__c != null) {
                    payloadBody.put('surveyId', targetAnnouncement.EUR_TR_RelatedSurvey__r.EUR_TR_TargetRelatedTemplate__c);
                }
                Map<String, Object> payload = Messaging.PushNotificationPayload.apple(targetAnnouncement.EUR_TR_AnnouncementText__c, '', null, payloadBody);
                pushNotification.setPayload(payload);
                if (!Test.isRunningTest()) {
                    pushNotification.send('EUR_TR_TradeTool_IOS_Tablet', new Set<String>{
                            targetAnnouncement.OwnerId
                    });
                }
            }

        }
    }

    public void finish(Database.BatchableContext param1) {
        System.debug('EUR_TR_SurveyNotificationBatch is completed');
    }


}