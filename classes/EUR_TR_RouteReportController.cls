/**
 * Created by osman on 13.11.2020.
 */

public with sharing class EUR_TR_RouteReportController {

    public class EUR_TR_RouteReportControllerException extends Exception {

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getRouteReportFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        RouteReportRequestModel routeReportRequestModel = (RouteReportRequestModel) JSON.deserialize(requestBody, RouteReportRequestModel.class);
        serviceResponse.Code = 1;
        try {
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getRouteReport(routeReportRequestModel);
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }


    public static WorkedDaySummaryReport getRouteReport(RouteReportRequestModel routeReportRequestModel) {

        Set<Id> reportOwnerIds = new Set<Id>();
        Date reportStartDate = routeReportRequestModel.reportStartDate;
        Date reportEndDate = routeReportRequestModel.reportEndDate;

        if (reportStartDate != null && reportEndDate != null && reportStartDate.addYears(1) < reportEndDate) {
            throw new EUR_TR_RouteReportControllerException('Rapor aralığı 1 yıldan büyük olamaz.');
        } else if (reportStartDate != null && reportEndDate == null) {
            reportEndDate = reportStartDate.addYears(1);
        } else if (reportStartDate == null && reportEndDate != null) {
            reportStartDate = reportEndDate.addYears(-1);
        } else if (reportStartDate == null && reportEndDate == null) {
            reportStartDate = Date.today().addYears(-1);
            reportEndDate = Date.today();
        }


        if (routeReportRequestModel.salesChiefIds != null && !routeReportRequestModel.salesChiefIds.isEmpty()) {

            List<EUR_TR_Employee__c> salesChiefEmployees = [
                    SELECT Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_SalesChief' AND Id IN :routeReportRequestModel.salesChiefIds
                    AND EUR_TR_RelatedUser__c != NULL
            ];

            for (EUR_TR_Employee__c employee : salesChiefEmployees) {
                reportOwnerIds.add(employee.EUR_TR_RelatedUser__c);
            }

        } else if (routeReportRequestModel.areaManagerIds != null && !routeReportRequestModel.areaManagerIds.isEmpty()) {

            List<EUR_TR_Employee__c> salesChiefEmployees = [
                    SELECT Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_SalesChief' AND EUR_TR_ReportsTo_AreaManager__c = :routeReportRequestModel.areaManagerIds
                    AND EUR_TR_RelatedUser__c != NULL
            ];

            List<EUR_TR_Employee__c> areaManagers = [
                    SELECT
                            Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_AreaManager' AND EUR_TR_RelatedUser__c != NULL AND Id IN :routeReportRequestModel.areaManagerIds
            ];

            for (EUR_TR_Employee__c employee : salesChiefEmployees) {
                reportOwnerIds.add(employee.EUR_TR_RelatedUser__c);
            }

            for (EUR_TR_Employee__c employee : areaManagers) {
                reportOwnerIds.add(employee.EUR_TR_RelatedUser__c);
            }
        } else {
            // current user is sales chief
            List<EUR_TR_Employee__c> salesChiefEmployees = [
                    SELECT Id,EUR_TR_RelatedUser__c
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_RelatedUser__c = :UserInfo.getUserId() AND RecordType.DeveloperName = 'EUR_TR_SalesChief'
                    AND EUR_TR_RelatedUser__c != NULL AND EUR_TR_RelatedUser__r.UserRole.DeveloperName = 'EUR_TR_SalesChiefs'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if (!salesChiefEmployees.isEmpty()) {
                reportOwnerIds.add(salesChiefEmployees.get(0).EUR_TR_RelatedUser__c);
            }
        }

        reportOwnerIds.add(UserInfo.getUserId());

        String querySelect = '' +
                'SELECT ' +
                'Id,' +
                'Owner.Name,' +
                'EUR_TR_StartDateTime__c,' +
                'EUR_TR_EndDateTime__c,' +
                'EUR_TR_TotalTimeFormatted__c,' +
                'EUR_TR_TotalPassedVisitDurationFormatted__c,' +
                'EUR_TR_PassedDurationOnTheWayFormatted__c,' +
                'EUR_TR_TotalVisitedAccountCountInRoute__c,' +
                'EUR_TR_TotalVisitedAccountCountOffRoute__c,' +
                'EUR_TR_WorkedDayStatus__c ,' +
                'EUR_TR_TotalTime__c ,' +
                'EUR_TR_TotalPassedVisitsDurationMinute__c ,' +
                'EUR_TR_PassedDurationMinuteOnTheWay__c ,' +
                'EUR_TR_RoutePercentage__c,' +
                'EUR_TR_TotalRouteAccountCount__c,' +
                'EUR_TR_TotalAccountCountInRoute__c,' +
                'EUR_TR_TotalAccountCountOffRoute__c,' +
                'EUR_TR_TotalVisitedRouteAccountCount__c  ';

        String queryFrom = 'FROM EUR_TR_Visit__c ';
        String queryWhere = 'WHERE RecordType.DeveloperName=\'EUR_TR_WorkedDay\' ';
        if (reportStartDate != null) {
            queryWhere += 'AND DAY_ONLY(CreatedDate) >= :reportStartDate ';
        }
        if (reportEndDate != null) {
            queryWhere += 'AND DAY_ONLY(CreatedDate) <= :reportEndDate ';
        }
        if (reportOwnerIds != null && !reportOwnerIds.isEmpty()) {
            queryWhere += 'AND OwnerId IN : reportOwnerIds ';
        }

        String queryOrderBy = 'ORDER BY CreatedDate ';
        String queryLimit = 'LIMIT 50000';

        String query = String.format('{0} {1} {2} {3} {4} ', new List<String>{
                querySelect,
                queryFrom,
                queryWhere,
                queryOrderBy,
                queryLimit
        });

        System.debug(query);

        List<EUR_TR_Visit__c> workedDays = Database.query(query);

        Decimal totalWorkedDayDuration = 0;
        Decimal totalPassedVisitDuration = 0;
        Decimal totalPassedDurationOnTheWay = 0;
        Decimal totalVisitCountInRoute = 0;
        Decimal totalVisitCountOffRoute = 0;
        Decimal totalAccountCountInRoute = 0;
        Decimal totalRoutePercentage = 0;
        Decimal notNullRoutePercentageRowCount = 0;

        for (EUR_TR_Visit__c workedDay : workedDays) {

            if (workedDay.EUR_TR_TotalTime__c != null) {
                totalWorkedDayDuration += workedDay.EUR_TR_TotalTime__c;
            }

            if (workedDay.EUR_TR_TotalPassedVisitsDurationMinute__c != null) {
                totalPassedVisitDuration += workedDay.EUR_TR_TotalPassedVisitsDurationMinute__c;
            }

            if (workedDay.EUR_TR_PassedDurationMinuteOnTheWay__c != null) {
                totalPassedDurationOnTheWay += workedDay.EUR_TR_PassedDurationMinuteOnTheWay__c;
            }

            if (workedDay.EUR_TR_TotalVisitedAccountCountInRoute__c != null) {
                totalVisitCountInRoute += workedDay.EUR_TR_TotalVisitedAccountCountInRoute__c;
            }

            if (workedDay.EUR_TR_TotalVisitedAccountCountOffRoute__c != null) {
                totalVisitCountOffRoute += workedDay.EUR_TR_TotalVisitedAccountCountOffRoute__c;
            }

            if (workedDay.EUR_TR_TotalAccountCountInRoute__c != null) {
                totalAccountCountInRoute += workedDay.EUR_TR_TotalAccountCountInRoute__c;
            }

            if (workedDay.EUR_TR_RoutePercentage__c != null) {
                notNullRoutePercentageRowCount++;
                totalRoutePercentage += workedDay.EUR_TR_RoutePercentage__c;
            }

        }


        WorkedDaySummaryReport workedDaySummaryReport = new WorkedDaySummaryReport();
        workedDaySummaryReport.workedDays = workedDays;
        workedDaySummaryReport.totalWorkedDayDuration = formatPassedDuration(totalWorkedDayDuration);
        workedDaySummaryReport.totalPassedVisitDuration = formatPassedDuration(totalPassedVisitDuration);
        workedDaySummaryReport.totalPassedDurationOnTheWay = formatPassedDuration(totalPassedDurationOnTheWay);
        if (totalVisitCountInRoute == null) {
            totalVisitCountInRoute = 0;
        }
        workedDaySummaryReport.totalVisitCountInRoute = totalVisitCountInRoute;
        if (totalVisitCountOffRoute == null) {
            totalVisitCountOffRoute = 0;
        }
        workedDaySummaryReport.totalVisitCountOffRoute = totalVisitCountOffRoute;
        workedDaySummaryReport.totalAccountCountInRoute = totalAccountCountInRoute;
        if (totalRoutePercentage == 0) {
            workedDaySummaryReport.averageRoutePercentage = 0;
        } else {
            workedDaySummaryReport.averageRoutePercentage = (totalRoutePercentage / notNullRoutePercentageRowCount).setScale(2);
        }


        return workedDaySummaryReport;

    }

    private static String formatPassedDuration(Decimal totalResult) {
        if (totalResult < 60) {
            return String.format('{0} Dk.', new List<String>{
                    String.valueOf(totalResult)
            });
        } else {
            Decimal minutes = Math.mod(Integer.valueOf(totalResult), 60);
            Decimal hours = (totalResult / 60).round(System.RoundingMode.DOWN);
            return String.format('{0} Sa. {1} Dk.', new List<String>{
                    String.valueOf(hours),
                    String.valueOf(minutes)
            });
        }
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getRouteReportDetailByIdFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        serviceResponse.Code = 1;
        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_RouteReportControllerException('Rapor Id boş bırakılamaz');
            }

            EUR_TR_Visit__c workedDay = (EUR_TR_Visit__c) JSON.deserialize(requestBody, EUR_TR_Visit__c.class);
            if (String.isBlank(workedDay.Id)) {
                throw new EUR_TR_RouteReportControllerException('Rapor Id boş bırakılamaz');
            }

            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getRouteReportDetailById(workedDay);

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }


    public static RouteReportDetailSummaryReport getRouteReportDetailById(EUR_TR_Visit__c workedDay) {

        List<EUR_TR_Visit__c> foundWorkedDay = [
                SELECT Id,EUR_TR_RoutePercentage__c,
                        EUR_TR_TotalVisitedRouteAccountCount__c,
                        EUR_TR_TotalRouteAccountCount__c,
                        EUR_TR_TotalAccountCountInRoute__c,
                        EUR_TR_TotalAccountCountOffRoute__c,
                        EUR_TR_TotalVisitedAccountCountInRoute__c,
                        EUR_TR_TotalVisitedAccountCountOffRoute__c
                FROM EUR_TR_Visit__c
                WHERE Id = :workedDay.Id AND RecordType.DeveloperName = 'EUR_TR_WorkedDay'
        ];

        if (foundWorkedDay.isEmpty()) {
            throw new EUR_TR_RouteReportControllerException('İlgili gün bulunamadı.Lütfen sistem yöneciniz ile iletişime geçiniz');
        }

        workedDay = foundWorkedDay.get(0);

        List<EUR_TR_Visit__c> visits = [
                SELECT
                        Id,
                        EUR_TR_RelatedAccount__c,
                        EUR_TR_Description__c,
                        EUR_TR_StartDateTime__c,
                        EUR_TR_EndDateTime__c,
                        EUR_TR_StartLocation__c,
                        EUR_TR_EndLocation__c,
                        toLabel(EUR_TR_VisitPurpose__c),
                        EUR_TR_VisitType__c,
                        EUR_TR_TotalTime__c,
                        EUR_TR_TotalTimeFormatted__c,
                        Owner.Name,
                        EUR_TR_WorkedDayStatus__c,
                        EUR_TR_RelatedAccount__r.Name,
                        EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c,
                        EUR_TR_RelatedAccount__r.EUR_TR_Location__c
                FROM EUR_TR_Visit__c
                WHERE EUR_TR_RelatedWorkedDay__c = :foundWorkedDay.get(0).Id
        ];

        RouteReportDetailSummaryReport routeReportDetailSummaryReport = new RouteReportDetailSummaryReport();
        routeReportDetailSummaryReport.visits = visits;
        routeReportDetailSummaryReport.workedDay = workedDay;

        return routeReportDetailSummaryReport;
    }

    public static void calculateWorkedDaySummaryReport(Set<Id> workedDayIds) {

        // Sorgu akışı
        /***
         * 1- Güne göre gruplama yapılıp ziyaret sorgusu yapılır. Sorgu sonucu  günlük ziyarette geçen süre hesaplanır. Gün ve ziyarette geçen süre maplenir.
         * 2- Gün sorgusu yapılır.Sorgu sonucu ile gün başlangıç ve bitiş süresi arasındaki süre hesaplanır.(Yolda geçen süre hesaplamak için kullanılır.)
         * 3- Güne göre gruplama yapılıp , rota içi filtresi ile beraber ziyaret sorgusu yapılır.Sorgu sonucu ile rota içi ziyaret sayısı hesaplanır.
         * 4- Güne göre gruplama yapılıp , rota dışı filtresi ile beraber ziyaret sorgusu yapılır.Sorgu sonucu ile rota dışı ziyaret sayısı hesaplanır.
         */

        String aggregateResultQueryToPassedVisitDuration = 'SELECT ' +
                'EUR_TR_RelatedWorkedDay__c, ' +
                'SUM(EUR_TR_TotalTime__c) totalPassedVisitsDuration ' +
                'FROM EUR_TR_Visit__c ' +
                'WHERE ' +
                'RecordType.DeveloperName = \'EUR_TR_Visit\' AND ' +
                'EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__r.EUR_TR_EndDateTime__c != NULL AND ' +
                'OwnerId != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__c != NULL ';
        if (workedDayIds != null && !workedDayIds.isEmpty()) {
            aggregateResultQueryToPassedVisitDuration += 'AND EUR_TR_RelatedWorkedDay__c IN :workedDayIds ';
        }
        aggregateResultQueryToPassedVisitDuration += 'GROUP BY EUR_TR_RelatedWorkedDay__c';

        System.debug(aggregateResultQueryToPassedVisitDuration);
        List<AggregateResult> aggregateResultsToDuration = Database.query(aggregateResultQueryToPassedVisitDuration);

        Map<Id, AggregateResult> workedDayToVisitSummaryAggregateResultMap = new Map<Id, AggregateResult>();
        Id workedDayId = null;
        for (AggregateResult aggregateResult : aggregateResultsToDuration) {
            workedDayId = (Id) aggregateResult.get('EUR_TR_RelatedWorkedDay__c');
            workedDayToVisitSummaryAggregateResultMap.put(workedDayId, aggregateResult);
        }

        String workedDayQuery = 'SELECT ' +
                'OwnerId,' +
                'EUR_TR_TotalTime__c,' +
                'EUR_TR_RelatedWorkedDay__c ' +
                'FROM EUR_TR_Visit__c ' +
                'WHERE ' +
                'RecordType.DeveloperName = \'EUR_TR_WorkedDay\' AND ' +
                'EUR_TR_EndDateTime__c != NULL AND ' +
                'OwnerId != NULL ';
        if (workedDayIds != null && !workedDayIds.isEmpty()) {
            workedDayQuery += 'AND Id IN :workedDayIds ';
        }
        System.debug(workedDayQuery);
        List<EUR_TR_Visit__c> workedDays = Database.query(workedDayQuery);


        Set<Id> groupedWorkedDayIds = workedDayToVisitSummaryAggregateResultMap.keySet();

        // calculated the number of account in route visits.
        String aggregateResultQueryToInRouteVisits = '' +
                'SELECT COUNT(EUR_TR_RelatedAccount__c) totalVisitedCountInRoute ,' +
                'EUR_TR_RelatedWorkedDay__c ' +
                'FROM EUR_TR_Visit__c ' +
                'WHERE ' +
                'EUR_TR_RelatedAccount__c != NULL AND ' +
                'EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__r.EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_VisitType__c = \'In-Route\' AND ' +
                'EUR_TR_RelatedWorkedDay__r.Id IN :groupedWorkedDayIds ' +
                'GROUP BY EUR_TR_RelatedWorkedDay__c ' ;


        List<AggregateResult> aggregateResultsToInRouteVisits = Database.query(aggregateResultQueryToInRouteVisits);

        Map<Id, AggregateResult> workedDayToInRouteVisitAggregateResultMap = new Map<Id, AggregateResult>();
        for (AggregateResult aggregateResult : aggregateResultsToInRouteVisits) {
            workedDayToInRouteVisitAggregateResultMap.put((Id) aggregateResult.get('EUR_TR_RelatedWorkedDay__c'), aggregateResult);
        }

        // calculated the number of account off route visits.
        String aggregateResultQueryToOffRouteVisits = '' +
                'SELECT COUNT(EUR_TR_RelatedAccount__c) totalVisitedCountOffRoute ,' +
                'EUR_TR_RelatedWorkedDay__c ' +
                'FROM EUR_TR_Visit__c ' +
                'WHERE ' +
                'EUR_TR_RelatedAccount__c != NULL AND ' +
                'EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__r.EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_VisitType__c = \'Off-Route\' AND ' +
                'EUR_TR_RelatedWorkedDay__r.Id IN :groupedWorkedDayIds ' +
                'GROUP BY EUR_TR_RelatedWorkedDay__c ' ;

        System.debug(aggregateResultQueryToOffRouteVisits);
        List<AggregateResult> aggregateResultsToOffRouteVisits = Database.query(aggregateResultQueryToOffRouteVisits);

        Map<Id, AggregateResult> workedDayToOffRouteVisitAggregateResultMap = new Map<Id, AggregateResult>();
        for (AggregateResult aggregateResult : aggregateResultsToOffRouteVisits) {
            workedDayToOffRouteVisitAggregateResultMap.put((Id) aggregateResult.get('EUR_TR_RelatedWorkedDay__c'), aggregateResult);
        }

        // calculated total account count off-route
        String aggregateResultQueryToTotalAccountCountOffRoute = '' +
                'SELECT COUNT(EUR_TR_RelatedAccount__c) totalAccountCountOffRoute ,' +
                'EUR_TR_RelatedWorkedDay__c ' +
                'FROM EUR_TR_Visit__c ' +
                'WHERE ' +
                'EUR_TR_RelatedAccount__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__c != NULL AND ' +
                'EUR_TR_VisitType__c = \'Off-Route\' AND ' +
                'EUR_TR_RelatedWorkedDay__r.EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__r.Id IN :groupedWorkedDayIds ' +
                'GROUP BY EUR_TR_RelatedWorkedDay__c ' ;

        System.debug(aggregateResultQueryToTotalAccountCountOffRoute);
        List<AggregateResult> aggregateResultsToTotalAccountCountOffRoute = Database.query(aggregateResultQueryToTotalAccountCountOffRoute);

        Map<Id, AggregateResult> workedDayToTotalAccountCountOffRouteAggregateResultMap = new Map<Id, AggregateResult>();
        for (AggregateResult aggregateResult : aggregateResultsToTotalAccountCountOffRoute) {
            workedDayToTotalAccountCountOffRouteAggregateResultMap.put((Id) aggregateResult.get('EUR_TR_RelatedWorkedDay__c'), aggregateResult);
        }

        // calculated total account count in-route
        String aggregateResultQueryToTotalVisitCountInRoute = '' +
                'SELECT COUNT(EUR_TR_RelatedAccount__c) totalAccountCountInRoute ,' +
                'EUR_TR_RelatedWorkedDay__c ' +
                'FROM EUR_TR_Visit__c ' +
                'WHERE ' +
                'EUR_TR_RelatedAccount__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__c != NULL AND ' +
                'EUR_TR_VisitType__c = \'In-Route\' AND ' +
                'EUR_TR_RelatedWorkedDay__r.EUR_TR_EndDateTime__c != NULL AND ' +
                'EUR_TR_RelatedWorkedDay__r.Id IN :groupedWorkedDayIds ' +
                'GROUP BY EUR_TR_RelatedWorkedDay__c ' ;

        System.debug(aggregateResultQueryToTotalVisitCountInRoute);
        List<AggregateResult> aggregateResultsToTotalVisitCountInRoute = Database.query(aggregateResultQueryToTotalVisitCountInRoute);

        Map<Id, AggregateResult> workedDayToTotalAccountCountInRouteAggregateResultMap = new Map<Id, AggregateResult>();
        for (AggregateResult aggregateResult : aggregateResultsToTotalVisitCountInRoute) {
            workedDayToTotalAccountCountInRouteAggregateResultMap.put((Id) aggregateResult.get('EUR_TR_RelatedWorkedDay__c'), aggregateResult);
        }


        Decimal totalVisitedCountInRoute = null;
        Decimal totalVisitedCountOffRoute = null;
        Decimal totalAccountCountInRoute = null;
        Decimal totalAccountCountOffRoute = null;
        Decimal totalWorkedDayDuration = null;
        Decimal totalPassedVisitsDuration = null;
        for (EUR_TR_Visit__c workedDay : workedDays) {

            if (workedDay.EUR_TR_TotalTime__c == null) {
                continue;
            }

            totalWorkedDayDuration = workedDay.EUR_TR_TotalTime__c;
            totalPassedVisitsDuration = 0;
            AggregateResult visitSummaryAggregateResult = workedDayToVisitSummaryAggregateResultMap.get(workedDay.Id);
            if (visitSummaryAggregateResult != null) {
                totalPassedVisitsDuration = (Decimal) visitSummaryAggregateResult.get('totalPassedVisitsDuration');
                if (totalPassedVisitsDuration == null) {
                    totalPassedVisitsDuration = 0;
                }
            }
            workedDay.EUR_TR_TotalPassedVisitsDurationMinute__c = totalPassedVisitsDuration;
            workedDay.EUR_TR_PassedDurationMinuteOnTheWay__c = totalWorkedDayDuration - totalPassedVisitsDuration;

            AggregateResult inRouteAggregateResult = workedDayToInRouteVisitAggregateResultMap.get(workedDay.Id);
            totalVisitedCountInRoute = 0;
            if (inRouteAggregateResult != null) {
                totalVisitedCountInRoute = (Decimal) inRouteAggregateResult.get('totalVisitedCountInRoute');
                if (totalVisitedCountInRoute == null) {
                    totalVisitedCountInRoute = 0;
                }
            }
            workedDay.EUR_TR_TotalVisitedAccountCountInRoute__c = totalVisitedCountInRoute;

            AggregateResult offRouteAggregateResult = workedDayToOffRouteVisitAggregateResultMap.get(workedDay.Id);
            totalVisitedCountOffRoute = 0;
            if (offRouteAggregateResult != null) {
                totalVisitedCountOffRoute = (Decimal) offRouteAggregateResult.get('totalVisitedCountOffRoute');
                if (totalVisitedCountOffRoute == null) {
                    totalVisitedCountOffRoute = 0;
                }
            }
            workedDay.EUR_TR_TotalVisitedAccountCountOffRoute__c = totalVisitedCountOffRoute;

            totalAccountCountInRoute = 0;
            AggregateResult accountCountInRouteAggregateResult = workedDayToTotalAccountCountInRouteAggregateResultMap.get(workedDay.Id);
            if (accountCountInRouteAggregateResult != null) {
                totalAccountCountInRoute = (Decimal) accountCountInRouteAggregateResult.get('totalAccountCountInRoute');
                if (totalAccountCountInRoute == null) {
                    totalAccountCountInRoute = 0;
                }
            }
            workedDay.EUR_TR_TotalAccountCountInRoute__c = totalAccountCountInRoute;

            totalAccountCountOffRoute = 0;
            AggregateResult accountCountOffRouteAggregateResult = workedDayToTotalAccountCountOffRouteAggregateResultMap.get(workedDay.Id);
            if (accountCountOffRouteAggregateResult != null) {
                totalAccountCountOffRoute = (Decimal) accountCountOffRouteAggregateResult.get('totalAccountCountOffRoute');
                if (totalAccountCountOffRoute == null) {
                    totalAccountCountOffRoute = 0;
                }
            }
            workedDay.EUR_TR_TotalAccountCountOffRoute__c = totalAccountCountOffRoute;


        }

        if (!workedDays.isEmpty()) {
            update workedDays;
        }


    }

    public class RouteReportRequestModel {
        public Set<Id> areaManagerIds { get; set; }
        public Set<Id> salesChiefIds { get; set; }
        public Date reportStartDate { get; set; }
        public Date reportEndDate { get; set; }
    }

    public class WorkedDaySummaryReport {
        public List<EUR_TR_Visit__c> workedDays { get; set; }
        public String totalWorkedDayDuration { get; set; }
        public String totalPassedVisitDuration { get; set; }
        public String totalPassedDurationOnTheWay { get; set; }
        public Decimal totalVisitCountInRoute { get; set; }
        public Decimal totalVisitCountOffRoute { get; set; }
        public Decimal totalAccountCountInRoute { get; set; }
        public Decimal averageRoutePercentage { get; set; }

    }

    public class RouteReportDetailSummaryReport {
        public List<EUR_TR_Visit__c> visits { get; set; }
        public EUR_TR_Visit__c workedDay { get; set; }
    }


}