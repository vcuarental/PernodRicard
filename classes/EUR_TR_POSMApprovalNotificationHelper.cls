/**
 * Created by osman on 6.10.2020.
 */

public with sharing class EUR_TR_POSMApprovalNotificationHelper {

    public static void sendNotificationByPOSMApprovalRecord(EUR_TR_Approval__c approval, Boolean isSentEmailSuccessfully) {

        approval = [
                SELECT
                        Id,
                        EUR_TR_Approver__r.Name,
                        EUR_TR_Submitter__r.Name,
                        EUR_TR_Approver__r.Email,
                        EUR_TR_Submitter__r.Email,
                        EUR_TR_ApprovalProcessType__c,
                        EUR_TR_ApprovalStatus__c,
                        EUR_TR_RelatedPOSM__r.Name
                FROM EUR_TR_Approval__c
                WHERE Id = :approval.Id
        ];

        if (approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.PENDING) {
            sendPendingNotification(approval, isSentEmailSuccessfully);
        } else if (approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.APPROVED || approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.REJECTED) {
            sendApproveOrRejectNotification(approval);
        }


    }

    public static void sendNotificationByPOSMRecord(EUR_TR_POSM__c POSMRecord, String notificationMessage) {

        POSMRecord = [
                SELECT
                        Id,
                        Name
                FROM EUR_TR_POSM__c
                WHERE Id = :POSMRecord.Id
        ];

        EUR_TR_Announcement__c submitterAnnouncement = new EUR_TR_Announcement__c();
        submitterAnnouncement.OwnerId = UserInfo.getUserId();
        submitterAnnouncement.EUR_TR_POSMRelatedApproval__c = null;
        submitterAnnouncement.EUR_TR_AnnouncementText__c = notificationMessage;

        insert new List<EUR_TR_Announcement__c>{
                submitterAnnouncement
        };

        EUR_TR_Announcement__c submitterTargetAnnouncement = new EUR_TR_Announcement__c();
        submitterTargetAnnouncement.OwnerId = UserInfo.getUserId();
        submitterTargetAnnouncement.EUR_TR_RelatedAnnouncement__c = submitterAnnouncement.Id;
        submitterTargetAnnouncement.EUR_TR_POSMRelatedApproval__c = null;
        submitterTargetAnnouncement.EUR_TR_IsRead__c = false;
        submitterTargetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();


        // target announcements
        insert new List<EUR_TR_Announcement__c>{
                submitterTargetAnnouncement
        };

        sendNotification(new Set<Id>{
                submitterTargetAnnouncement.Id
        });

    }

    public static List<String> getNotificationMessages(EUR_TR_Approval__c approval) {

        EUR_TR_Account__c relatedAccount = [
                SELECT Id,
                        EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name
                FROM EUR_TR_Approval__c
                WHERE Id = :approval.Id
        ][0].EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r;

        // approver - 0
        // submitter - 1
        List<String> notificationMessages = new List<String>();
        String approverMessage = '';
        String submitterMessage = '';

        if (approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.PENDING) {

            String bodyToActor = '{0} için {1} işlemi onayınızı beklemektedir.';
            approverMessage = String.format(bodyToActor, new List<String>{
                    relatedAccount.Name,
                    approval.EUR_TR_ApprovalProcessType__c
            });

            if (approval.EUR_TR_ApprovalProcessType__c == 'Revize Talebi') {
                submitterMessage = 'İşleminiz geri gönderilmiştir.';
                submitterMessage = String.format(submitterMessage, new List<String>{
                        relatedAccount.Name,
                        approval.EUR_TR_ApprovalProcessType__c
                });
            } else {
                submitterMessage = '{0} için {1} işleminiz onaya gönderilmiştir.';
                submitterMessage = String.format(submitterMessage, new List<String>{
                        relatedAccount.Name,
                        approval.EUR_TR_ApprovalProcessType__c
                });
            }


        } else if (approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.APPROVED || approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.REJECTED) {

            submitterMessage = '{0} için {1} işleminiz {2}.';
            if (approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.REJECTED) {
                submitterMessage = String.format(submitterMessage, new List<String>{
                        relatedAccount.Name,
                        approval.EUR_TR_ApprovalProcessType__c,
                        'reddedilmiştir'
                });
            } else if (approval.EUR_TR_ApprovalStatus__c == EUR_TR_POSMApprovalController.APPROVED) {
                submitterMessage = String.format(submitterMessage, new List<String>{
                        relatedAccount.Name,
                        approval.EUR_TR_ApprovalProcessType__c,
                        'onaylanmıştır'
                });
            }

        }

        notificationMessages = new List<String>{
                approverMessage, submitterMessage
        };

        return notificationMessages;

    }

    private static void sendApproveOrRejectNotification(EUR_TR_Approval__c approval) {

        List<String> notificationMessages = getNotificationMessages(approval);
        String submitterNotificationMessage = notificationMessages.get(1);


        EUR_TR_Announcement__c submitterAnnouncement = new EUR_TR_Announcement__c();
        submitterAnnouncement.OwnerId = approval.EUR_TR_Submitter__r.Id;
        submitterAnnouncement.EUR_TR_POSMRelatedApproval__c = approval.Id;
        submitterAnnouncement.EUR_TR_AnnouncementText__c = submitterNotificationMessage;

        insert submitterAnnouncement;

        EUR_TR_Announcement__c submitterTargetAnnouncement = new EUR_TR_Announcement__c();
        submitterTargetAnnouncement.OwnerId = approval.EUR_TR_Submitter__r.Id;
        submitterTargetAnnouncement.EUR_TR_RelatedAnnouncement__c = submitterAnnouncement.Id;
        submitterTargetAnnouncement.EUR_TR_POSMRelatedApproval__c = approval.Id;
        submitterTargetAnnouncement.EUR_TR_IsRead__c = false;
        submitterTargetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();

        insert submitterTargetAnnouncement;

        sendNotification(new Set<Id>{
                submitterTargetAnnouncement.Id
        });

    }

    private static void sendPendingNotification(EUR_TR_Approval__c approval, Boolean isSentEmailSuccessfully) {

        List<String> notificationMessages = getNotificationMessages(approval);
        String approverNotificationMessage = notificationMessages.get(0);
        String submitterNotificationMessage = notificationMessages.get(1);

        EUR_TR_Announcement__c approverAnnouncement = new EUR_TR_Announcement__c();
        approverAnnouncement.OwnerId = approval.EUR_TR_Approver__r.Id;
        approverAnnouncement.EUR_TR_POSMRelatedApproval__c = approval.Id;
        if (isSentEmailSuccessfully != null) {
            approverAnnouncement.EUR_TR_POSM_EmailStatus__c = isSentEmailSuccessfully ? 'Gönderildi' : 'Gönderilemedi';
        }
        approverAnnouncement.EUR_TR_AnnouncementText__c = approverNotificationMessage;

        EUR_TR_Announcement__c submitterAnnouncement = new EUR_TR_Announcement__c();
        submitterAnnouncement.OwnerId = approval.EUR_TR_Submitter__r.Id;
        submitterAnnouncement.EUR_TR_POSMRelatedApproval__c = approval.Id;
        submitterAnnouncement.EUR_TR_AnnouncementText__c = submitterNotificationMessage;

        // parent announcements
        insert new List<EUR_TR_Announcement__c>{
                approverAnnouncement, submitterAnnouncement
        };

        EUR_TR_Announcement__c approverTargetAnnouncement = new EUR_TR_Announcement__c();
        approverTargetAnnouncement.OwnerId = approval.EUR_TR_Approver__r.Id;
        approverTargetAnnouncement.EUR_TR_RelatedAnnouncement__c = approverAnnouncement.Id;
        approverTargetAnnouncement.EUR_TR_POSMRelatedApproval__c = approval.Id;
        approverTargetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();

        EUR_TR_Announcement__c submitterTargetAnnouncement = new EUR_TR_Announcement__c();
        submitterTargetAnnouncement.OwnerId = approval.EUR_TR_Submitter__r.Id;
        submitterTargetAnnouncement.EUR_TR_RelatedAnnouncement__c = submitterAnnouncement.Id;
        submitterTargetAnnouncement.EUR_TR_POSMRelatedApproval__c = approval.Id;
        submitterTargetAnnouncement.EUR_TR_IsRead__c = false;
        submitterTargetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();


        // target announcements
        insert new List<EUR_TR_Announcement__c>{
                approverTargetAnnouncement, submitterTargetAnnouncement
        };

        sendNotification(new Set<Id>{
                approverTargetAnnouncement.Id, submitterTargetAnnouncement.Id
        });

    }

    private static void sendNotification(Set<Id> announcementIds) {

        List<EUR_TR_Announcement__c> targetAnnouncements = [
                SELECT OwnerId,EUR_TR_POSMRelatedApproval__c, EUR_TR_AnnouncementText__c
                FROM EUR_TR_Announcement__c
                WHERE Id IN :announcementIds
        ];
        Set<String> users = null;
        Messaging.PushNotification msg = null;
        Map<String, String> payloadBody = null;
        for (EUR_TR_Announcement__c targetAnnouncement : targetAnnouncements) {
            users = new Set<String>();
            msg = new Messaging.PushNotification();
            payloadBody = new Map<String, String>();
            payloadBody.put('type', 'POSM');
            payloadBody.put('id', targetAnnouncement.Id);
            if (targetAnnouncement.EUR_TR_POSMRelatedApproval__c != null) {
                payloadBody.put('approvalId', targetAnnouncement.EUR_TR_POSMRelatedApproval__c);
            }
            Map<String, Object> payload = Messaging.PushNotificationPayload.apple(targetAnnouncement.EUR_TR_AnnouncementText__c, '', null, payloadBody);
            msg.setPayload(payload);
            users.add(targetAnnouncement.OwnerId);
            if (!Test.isRunningTest()) {
                msg.send('EUR_TR_TradeTool_IOS_Tablet', users);
            }
        }
    }

}