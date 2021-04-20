/**
 * Created by osman on 21.10.2019.
 */

@isTest(seeAllData=FALSE)
public with sharing class EUR_TR_PushNotificationController_Test {

    @testSetup
    public static void setup(){

        RecordType recordType=[Select id,name,developerName from RecordType where sobjectType='EUR_TR_Announcement__c' and developerName='EUR_TR_Announcement'];
        EUR_TR_Announcement__c relatedAnnouncement=new EUR_TR_Announcement__c();
        relatedAnnouncement.ownerId=UserInfo.getUserId();
        relatedAnnouncement.Name='Dummy Related Announcement Name';
        relatedAnnouncement.recordTypeId=recordType.id;
        insert relatedAnnouncement;

        EUR_TR_Announcement__c eurTRAnnouncement=new EUR_TR_Announcement__c();
        eurTRAnnouncement.Name='Announcement Name';
        eurTRAnnouncement.OwnerId=UserInfo.getUserId();
        eurTRAnnouncement.EUR_TR_RelatedAnnouncement__c=relatedAnnouncement.id;
        insert eurTRAnnouncement;


    }


    @isTest
    public static void sendPushNotificationTest(){

        Map<Id,EUR_TR_Announcement__c> eurTRAnnouncementMap=new Map<Id, EUR_TR_Announcement__c>([SELECT id,ownerId,Name from EUR_TR_Announcement__c ]);
        List<Id> announcementIds=new List<Id>(eurTRAnnouncementMap.keySet());

        try{
            EUR_TR_PushNotificationController.sendPushNotification(announcementIds);
        }catch(Exception ex ){

        }


    }

}