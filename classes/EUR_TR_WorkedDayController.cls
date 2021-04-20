/**
 * Created by osman on 1.12.2020.
 */

public with sharing class EUR_TR_WorkedDayController {

    public class EUR_TR_WorkedDayControllerException extends Exception {

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse startDayFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = startDay();
        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse endDayFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = closeDay();
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }


    public static EUR_TR_MiddlewareController.PostServiceResponse checkIsDayStartedFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        Savepoint savepoint = Database.setSavepoint();
        try {
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            Boolean isDayStarted = checkIsDayStarted();
            EUR_TR_Visit__c currentWorkedDay = getCurrentWorkedDay();
            Map<String, Object> result = new Map<String, Object>{
                    'isDayStarted' => isDayStarted,
                    'startedDayInformation' => currentWorkedDay != null ? currentWorkedDay : null
            };
            serviceResponse.ExtensionData = result;
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }


    public static EUR_TR_Visit__c startDay() {

        EUR_TR_Visit__c currentWorkedDay = getCurrentWorkedDay();

        if (currentWorkedDay != null) {
            throw new EUR_TR_WorkedDayControllerException('Açık gününüz bulunmaktadır,tekrar gün başlatılamaz.');
        }

        if (currentWorkedDay == null) {

            List<EUR_TR_Visit__c> closedWorkedDay = [
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
            if (!closedWorkedDay.isEmpty()) {

                List<EUR_TR_Approval__c> approval = [
                        SELECT Id,EUR_TR_ApprovalStatus__c
                        FROM EUR_TR_Approval__c
                        WHERE EUR_TR_RelatedWorkedDay__c = :closedWorkedDay.get(0).Id
                        AND RecordType.DeveloperName = 'EUR_TR_WorkedDayApproval'
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                ];

                if (approval.isEmpty()) {
                    throw new EUR_TR_WorkedDayControllerException('Günü kapattıktan sonra aynı gün içerisinde tekrar başlatamazsınız. Sistem yöneticinizden onay almanız gerekmektedir.');
                } else {
                    if (approval.get(0).EUR_TR_ApprovalStatus__c == 'Bekliyor') {
                        throw new EUR_TR_WorkedDayControllerException('Aynı gün içinde yeniden gün başlatmak için oluşturduğunuz talebiniz devam ediyor.Lütfen daha sonra tekrar deneyiniz');
                    } else if (approval.get(0).EUR_TR_ApprovalStatus__c == 'Reddedildi') {
                        throw new EUR_TR_WorkedDayControllerException('Aynı gün içinde yeniden gün başlatmak için oluşturduğunuz talebiniz reddedildi.Bu işlemi gerçekleştiremezsiniz');
                    }
                }

            }


        }

        EUR_TR_Visit__c dailyWork = new EUR_TR_Visit__c();
        dailyWork.EUR_TR_StartDateTime__c = Datetime.now();
        dailyWork.OwnerId = UserInfo.getUserId();
        dailyWork.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        insert dailyWork;

        return [
                SELECT Id,Name,OwnerId,Owner.Name,EUR_TR_StartDateTime__c
                FROM EUR_TR_Visit__c
                WHERE Id = :dailyWork.Id
                LIMIT 1
        ];

    }

    public static EUR_TR_Visit__c closeDay() {

        EUR_TR_Visit__c currentWorkedDay = getCurrentWorkedDay();
        if (currentWorkedDay == null) {
            throw new EUR_TR_WorkedDayControllerException('Kapatılacak gün bulunamadı.Bu işlemi yapabilmek için lütfen önce gün başlatınız.');
        }

        currentWorkedDay.EUR_TR_EndDateTime__c = Datetime.now();
        update currentWorkedDay;

        /*
        EUR_TR_RouteController.deleteNotStartedRouteVisits(new Set<Id>{
                currentWorkedDay.Id
        });
         */

        EUR_TR_RouteReportController.calculateWorkedDaySummaryReport(new Set<Id>{
                currentWorkedDay.Id
        });


        return [
                SELECT Id,Name,OwnerId,Owner.Name,EUR_TR_StartDateTime__c,EUR_TR_EndDateTime__c
                FROM EUR_TR_Visit__c
                WHERE Id = :currentWorkedDay.Id
                LIMIT 1
        ];

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getNotClosedVisitsByCurrentWorkedDayFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = getNotClosedVisitsByCurrentWorkedDay();
        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static List<EUR_TR_Visit__c> getNotClosedVisitsByCurrentWorkedDay() {

        EUR_TR_Visit__c currentWorkedDay = getCurrentWorkedDay();
        if (currentWorkedDay == null) {
            throw new EUR_TR_WorkedDayControllerException('Gün bulunamadı.Bu işlemi yapabilmek için lütfen önce gün başlatınız.');
        }

        List<EUR_TR_Visit__c> notClosedVisits = [
                SELECT
                        Id,
                        EUR_TR_RelatedAccount__c,
                        EUR_TR_VisitType__c,
                        EUR_TR_VisitPurpose__c,
                        EUR_TR_Description__c,
                        EUR_TR_StartDateTime__c,
                        EUR_TR_EndDateTime__c,
                        EUR_TR_WorkedDayStatus__c
                FROM EUR_TR_Visit__c
                WHERE EUR_TR_RelatedWorkedDay__c = :currentWorkedDay.Id AND EUR_TR_EndDateTime__c = NULL AND RecordType.DeveloperName = 'EUR_TR_Visit'
        ];

        return notClosedVisits;

    }


    public static EUR_TR_Visit__c getCurrentWorkedDay() {
        List<EUR_TR_Visit__c> workedDays = [
                SELECT Id, EUR_TR_RelatedFavoriteRoute__c,EUR_TR_StartDateTime__c
                FROM EUR_TR_Visit__c
                WHERE
                OwnerId = :UserInfo.getUserId() AND RecordType.DeveloperName = 'EUR_TR_WorkedDay' AND EUR_TR_EndDateTime__c = NULL
                AND EUR_TR_StartDateTime__c = TODAY
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        if (workedDays.isEmpty()) {
            return null;
        }
        return workedDays.get(0);
    }

    public static Boolean checkIsDayStarted() {
        Boolean isDayStarted = true;
        EUR_TR_Visit__c currentWorkedDay = getCurrentWorkedDay();
        if (currentWorkedDay == null) {
            isDayStarted = false;
        }
        return isDayStarted;
    }

    public static EUR_TR_Definition__c getWorkedDayDefinition() {

        List<EUR_TR_Definition__c> routeDefinitions = [
                SELECT Id,EUR_TR_MaxVisitableAccountNumber__c,EUR_TR_VisitHourDurationToClose__c
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_WorkedDay' AND EUR_TR_MaxVisitableAccountNumber__c != NULL
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];

        if (routeDefinitions.isEmpty()) {
            throw new EUR_TR_WorkedDayControllerException('Rota tanımı bulunamadı.Lütfen sistem yöneticiniz ile iletişime geçiniz.');
        }

        return routeDefinitions.get(0);

    }


}