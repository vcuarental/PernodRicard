/**
 * Created by osman on 15.01.2021.
 */

public with sharing class EUR_TR_IncentiveController {

    public static EUR_TR_MiddlewareController.PostServiceResponse getActiveIncentivesByAccountIdFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_IncentiveControllerException('Nokta bilgisi boş bırakılamaz');
            }

            EUR_TR_Account__c account = (EUR_TR_Account__c) JSON.deserialize(requestBody, EUR_TR_Account__c.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getActiveIncentivesByAccountId(account);

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }

    public static List<EUR_TR_Incentive__c> getActiveIncentivesByAccountId(EUR_TR_Account__c account) {

        if (String.isBlank(account.Id)) {
            throw new EUR_TR_IncentiveControllerException('Nokta bilgisi boş bırakılamaz');
        }

        return [
                SELECT
                        Id,
                        EUR_TR_RelatedAccount__r.Name,
                        EUR_TR_RelatedAccount__c,
                        EUR_TR_StartDate__c,
                        EUR_TR_EndDate__c,
                        EUR_TR_Brand__c,
                        EUR_TR_Description__c,
                        EUR_TR_DoNotShowMeAgain__c
                FROM EUR_TR_Incentive__c
                WHERE EUR_TR_StartDate__c <= TODAY AND EUR_TR_EndDate__c > TODAY AND EUR_TR_DoNotShowMeAgain__c = FALSE AND EUR_TR_RelatedAccount__c = :account.Id
                ORDER BY EUR_TR_StartDate__c
        ];

    }


    public static EUR_TR_MiddlewareController.PostServiceResponse getAllIncentivesByAccountIdFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_IncentiveControllerException('Nokta bilgisi boş bırakılamaz');
            }

            IncentiveFilterRequest incentiveFilterRequest = (IncentiveFilterRequest) JSON.deserialize(requestBody, IncentiveFilterRequest.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getAllIncentivesByAccountId(incentiveFilterRequest);

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }

    public static List<EUR_TR_Incentive__c> getAllIncentivesByAccountId(IncentiveFilterRequest incentiveFilterRequest) {

        if (incentiveFilterRequest.accountId == null || String.isBlank(incentiveFilterRequest.accountId)) {
            throw new EUR_TR_IncentiveControllerException('Nokta bilgisi boş bırakılamaz');
        }

        List<EUR_TR_Account__c> foundAccount = [SELECT Id FROM EUR_TR_Account__c WHERE Id = :incentiveFilterRequest.accountId LIMIT 1];
        if (foundAccount.isEmpty()) {
            throw new EUR_TR_IncentiveControllerException('Nokta bilgisi bulunamadı.');
        }

        Id accountId = incentiveFilterRequest.accountId;

        if (incentiveFilterRequest.orderBy == null) {
            incentiveFilterRequest.orderBy = IncentiveFilterOrderBy.startDate;
        }
        if (incentiveFilterRequest.orderDirection == null) {
            incentiveFilterRequest.orderDirection = IncentiveOrderDirection.descending;
        }

        String querySelect = 'SELECT Id, ' +
                'EUR_TR_RelatedAccount__r.Name, ' +
                'EUR_TR_RelatedAccount__c, ' +
                'EUR_TR_StartDate__c, ' +
                'EUR_TR_EndDate__c, ' +
                'EUR_TR_Brand__c, ' +
                'EUR_TR_Description__c, ' +
                'EUR_TR_DoNotShowMeAgain__c ';
        String queryFrom = 'FROM EUR_TR_Incentive__c ';
        String queryWhere = 'WHERE EUR_TR_RelatedAccount__c = :accountId ';
        String queryOrderBy = '{0} {1} {2}';
        String orderByField = '';
        if (incentiveFilterRequest.orderBy == IncentiveFilterOrderBy.startDate) {
            orderByField = 'EUR_TR_StartDate__c';
        } else if (incentiveFilterRequest.orderBy == IncentiveFilterOrderBy.endDate) {
            orderByField = 'EUR_TR_EndDate__c';
        }
        queryOrderBy = String.format(queryOrderBy, new List<String>{
                'ORDER BY',
                orderByField,
                incentiveFilterRequest.orderDirection == IncentiveOrderDirection.ascending ? 'ASC' : 'DESC'
        });

        String query = '{0} {1} {2} {3} ';
        query = String.format(query, new List<String>{
                querySelect,
                queryFrom,
                queryWhere,
                queryOrderBy
        });

        System.debug(query);

        List<EUR_TR_Incentive__c> incentives = new List<EUR_TR_Incentive__c>();
        for (EUR_TR_Incentive__c incentive : Database.query(query)) {
            incentives.add(incentive);
        }

        return incentives;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse doNotShowMeSelectedIncentivesFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_IncentiveControllerException('Incentive listesi boş gönderilemez.');
            }

            List<EUR_TR_Incentive__c> incentives = (List<EUR_TR_Incentive__c>) JSON.deserialize(requestBody, List<EUR_TR_Incentive__c>.class);
            doNotShowMeSelectedIncentives(incentives);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }


    public static void doNotShowMeSelectedIncentives(List<EUR_TR_Incentive__c> incentives) {

        if (incentives.isEmpty()) {
            throw new EUR_TR_IncentiveControllerException('Incentive listesi boş gönderilemez.');
        }

        if (incentives.size() > 10000) {
            throw new EUR_TR_IncentiveControllerException('Lütfen sistem yönecisiniz ile iletişime geçiniz');
        }

        for (EUR_TR_Incentive__c incentive : incentives) {
            if (String.isBlank(incentive.Id)) {
                throw new EUR_TR_IncentiveControllerException('Incentive bilgisi boş gönderilemez.');
            }
            incentive.EUR_TR_DoNotShowMeAgain__c = true;
        }

        update incentives;

    }

    public enum IncentiveFilterOrderBy {
        startDate, endDate
    }

    public enum IncentiveOrderDirection {
        ascending, descending
    }

    public class IncentiveFilterRequest {
        public IncentiveFilterOrderBy orderBy { get; set; }
        public IncentiveOrderDirection orderDirection { get; set; }
        public Id accountId { get; set; }
    }

    public class EUR_TR_IncentiveControllerException extends Exception {
    }

}