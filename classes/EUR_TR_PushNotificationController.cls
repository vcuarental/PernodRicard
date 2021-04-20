public with sharing class EUR_TR_PushNotificationController {
    public EUR_TR_PushNotificationController() {

    }

    @InvocableMethod
    public static List<ID> sendPushNotification(List<Id> announcementIds) {
        List<EUR_TR_Announcement__c> targets = [select OwnerId, EUR_TR_RelatedAnnouncement__r.Name from EUR_TR_Announcement__c where EUR_TR_RelatedAnnouncement__c =:announcementIds];
        Messaging.PushNotification msg = new Messaging.PushNotification();
        Map<String, String> payloadBody = new Map<String,String>();
        payloadBody.put('type', 'announcement');
        payloadBody.put('id', announcementIds[0]);
        Map<String, Object> payload = Messaging.PushNotificationPayload.apple(targets[0].EUR_TR_RelatedAnnouncement__r.Name, '', null, payloadBody);
        msg.setPayload(payload);
        Set<String> users = new Set<String>();
        for (EUR_TR_Announcement__c a: targets){
            users.add(a.OwnerId);
        }
        if (!Test.isRunningTest()) {
            msg.send('EUR_TR_TradeTool_IOS_Tablet', users);
        }
        return announcementIds;
    }
}