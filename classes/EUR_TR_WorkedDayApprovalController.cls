/**
 * Created by osman on 7.01.2021.
 */

public with sharing class EUR_TR_WorkedDayApprovalController {

    class EUR_TR_WorkedDayApprovalControllerException extends Exception {
    }


    public static EUR_TR_MiddlewareController.PostServiceResponse createWorkedDayApprovalRequestFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = createWorkedDayApprovalRequest();
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_Approval__c createWorkedDayApprovalRequest() {

        List<EUR_TR_Visit__c> workedDays = [
                SELECT Id
                FROM EUR_TR_Visit__c
                WHERE EUR_TR_StartDateTime__c = TODAY AND
                EUR_TR_EndDateTime__c = TODAY AND
                EUR_TR_EndDateTime__c != NULL AND
                RecordType.DeveloperName = 'EUR_TR_WorkedDay' AND
                OwnerId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];

        if (workedDays.isEmpty()) {
            throw new EUR_TR_WorkedDayApprovalControllerException('Lütfen sistem yöneticiniz ile iletişime geçiniz');
        }

        User currentUser = [SELECT Id,ManagerId FROM User WHERE Id = :UserInfo.getUserId()];

        if (String.isBlank(currentUser.ManagerId)) {
            throw new EUR_TR_WorkedDayApprovalControllerException('Yeniden gün başlatmak için talep oluşturulamadı.Kullanıcının yönetici bilgisi bulunamadı.Lütfen sistem yöneticiniz ile iletişime geçiniz.');
        }

        EUR_TR_Approval__c approval = new EUR_TR_Approval__c();
        approval.Name = 'Yeniden Gün Başlatma Talebi';
        approval.EUR_TR_Submitter__c = UserInfo.getUserId();
        approval.EUR_TR_Approver__c = currentUser.ManagerId;
        approval.OwnerId = currentUser.ManagerId;
        approval.EUR_TR_ApprovalStatus__c = 'Bekliyor';
        approval.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDayApproval').getRecordTypeId();
        approval.EUR_TR_RelatedWorkedDay__c = workedDays.get(0).Id;
        insert approval;

        return approval;

    }

    @AuraEnabled
    public static void handleAction(Id approvalId, String actionName) {

        Savepoint savepoint = Database.setSavepoint();
        try {

            System.debug(approvalId + ' $ ' + actionName);

            if (approvalId == null) {
                throw new EUR_TR_WorkedDayApprovalControllerException('Onay kaydı bulunamadı.Lütfen sistem yönecisiniz ile iletişime geçiniz');
            }
            if (actionName == null) {
                throw new EUR_TR_WorkedDayApprovalControllerException('Aksiyon bulunamadı.Lütfen sistem yönecisiniz ile iletişime geçiniz');
            }

            EUR_TR_Approval__c approval = getApprovalById(approvalId);
            if (approval.EUR_TR_ApprovalStatus__c == 'Bekliyor') {
                if (actionName == 'Onayla') {
                    approveWorkedDayApprovalRequest(approvalId);
                } else if (actionName == 'Reddet') {
                    rejectWorkedDayApprovalRequest(approvalId);
                } else {
                    throw new EUR_TR_WorkedDayApprovalControllerException('Bilinmeyen aksiyon, lütfen sistem yöneticisi ile iletişime geçiniz');
                }
            } else {
                throw new EUR_TR_WorkedDayApprovalControllerException('Uygun aksiyon bulunamadı.Lütfen sistem yöneticiniz ile iletişime geçiniz');
            }

        } catch (Exception ex) {
            Database.rollback(savepoint);
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }

    }

    private static void approveWorkedDayApprovalRequest(Id approvalId) {

        try {
            EUR_TR_Approval__c approval = getApprovalById(approvalId);
            approval.EUR_TR_ApprovalStatus__c = 'Onaylandı';
            update approval;
            createApprovalHistory(approval);
            sendNotificationToSubmitter(approval);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new EUR_TR_WorkedDayApprovalControllerException(ex.getMessage());
        }

    }

    private static void rejectWorkedDayApprovalRequest(Id approvalId) {

        try {
            EUR_TR_Approval__c approval = getApprovalById(approvalId);
            approval.EUR_TR_ApprovalStatus__c = 'Reddedildi';
            update approval;
            createApprovalHistory(approval);
            sendNotificationToSubmitter(approval);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new EUR_TR_WorkedDayApprovalControllerException(ex.getMessage());
        }

    }


    private static void createApprovalHistory(EUR_TR_Approval__c approval) {

        EUR_TR_Approval__c approvalHistory = new EUR_TR_Approval__c();
        approvalHistory.Name = String.format('{0} {1}', new List<String>{
                'Talep Geçmişi', Datetime.now().format()
        });
        approvalHistory.EUR_TR_RelatedApproval__c = approval.Id;
        approvalHistory.EUR_TR_Submitter__c = approval.EUR_TR_Submitter__c;
        approvalHistory.EUR_TR_Approver__c = approval.EUR_TR_Approver__c;
        approvalHistory.RecordTypeId = Schema.SObjectType.EUR_TR_Approval__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDayApprovalHistory').getRecordTypeId();
        approvalHistory.EUR_TR_ApprovalStatus__c = approval.EUR_TR_ApprovalStatus__c;
        approvalHistory.EUR_TR_RelatedWorkedDay__c = approval.EUR_TR_RelatedWorkedDay__c;
        insert approvalHistory;

    }

    private static void sendNotificationToSubmitter(EUR_TR_Approval__c approval) {

        EUR_TR_Announcement__c submitterAnnouncement = new EUR_TR_Announcement__c();
        submitterAnnouncement.OwnerId = approval.EUR_TR_Submitter__c;
        submitterAnnouncement.Name = String.format('Yeniden gün başlatma talebiniz {0}.', new List<String>{
                approval.EUR_TR_ApprovalStatus__c.toLowerCase()
        });
        submitterAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Announcement').getRecordTypeId();
        submitterAnnouncement.EUR_TR_AnnouncementSource__c = 'WorkedDay';
        insert submitterAnnouncement;

        EUR_TR_Announcement__c submitterTargetAnnouncement = new EUR_TR_Announcement__c();
        submitterTargetAnnouncement.OwnerId = approval.EUR_TR_Submitter__c;
        submitterTargetAnnouncement.EUR_TR_RelatedAnnouncement__c = submitterAnnouncement.Id;
        submitterTargetAnnouncement.EUR_TR_IsRead__c = false;
        submitterTargetAnnouncement.RecordTypeId = Schema.SObjectType.EUR_TR_Announcement__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AnnouncementTarget').getRecordTypeId();
        insert submitterTargetAnnouncement;


        EUR_TR_PushNotificationController.sendPushNotification(new List<Id>{
                submitterAnnouncement.Id
        });


    }

    private static EUR_TR_Approval__c getApprovalById(Id approvalId) {
        return [
                SELECT Id,EUR_TR_RelatedApproval__c,EUR_TR_Submitter__c,EUR_TR_Approver__c,EUR_TR_ApprovalStatus__c,EUR_TR_RelatedWorkedDay__c
                FROM EUR_TR_Approval__c
                WHERE Id = :approvalId AND RecordType.DeveloperName = 'EUR_TR_WorkedDayApproval'
                LIMIT 1
        ];
    }

}