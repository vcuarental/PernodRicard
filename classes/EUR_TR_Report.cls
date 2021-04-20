/**
 * Created by Murat Can on 23/10/2020.
 */

public with sharing class EUR_TR_Report {

    private static List<EUR_TR_Employee__c> getPresellers(ReportRequest reportRequest) {
        List<EUR_TR_Employee__c> presellers = new List<EUR_TR_Employee__c>();

        if (reportRequest.presellerIds != null && !reportRequest.presellerIds.isEmpty()) {
            presellers = [
                    SELECT Id, Name
                    FROM EUR_TR_Employee__c
                    WHERE Id IN :reportRequest.presellerIds
                    AND RecordType.DeveloperName = 'EUR_TR_Preseller'
            ];
        } else if (reportRequest.salesChiefIds != null && !reportRequest.salesChiefIds.isEmpty()) {
            presellers = [
                    SELECT Id, Name
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_ReportsTo_Chief__c IN :reportRequest.salesChiefIds
                    AND RecordType.DeveloperName = 'EUR_TR_Preseller'
            ];
        } else if (reportRequest.areaManagerIds != null && !reportRequest.areaManagerIds.isEmpty()) {
            presellers = [
                    SELECT Id, Name
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_ReportsTo_Chief__r.EUR_TR_ReportsTo_AreaManager__c IN :reportRequest.areaManagerIds
                    AND RecordType.DeveloperName = 'EUR_TR_Preseller'
            ];
        } else {
            presellers = [
                    SELECT Id, Name
                    FROM EUR_TR_Employee__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_Preseller'
            ];
        }

        return presellers;
    }

    private static List<String> getPresellerNames(List<EUR_TR_Employee__c> presellers) {
        List<String> presellerNames = new List<String>();

        for (EUR_TR_Employee__c preseller : presellers) {
            presellerNames.add(preseller.Name);
        }

        return presellerNames;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getSalesTrendsReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        ReportRequest request = (ReportRequest) JSON.deserialize(requestBody, ReportRequest.class);

        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        serviceResponse.ExtensionData = getSalesTrendsReport(request);

        return serviceResponse;
    }

    // Bayi Gelişimi

    public static AggregateResult getSalesTrendsReport(ReportRequest reportRequest) {
        List<EUR_TR_Employee__c> presellers = getPresellers(reportRequest);

        String brand;
        String brandQuality;
        String brandQualitySize;

        EUR_TR_AccountSalesMAT__c MATDataFilter = reportRequest.MATData;
        if (MATDataFilter != null) {
            brand = MATDataFilter.EUR_TR_Brand__c;
            brandQuality = MATDataFilter.EUR_TR_BrandQuality__c;
            brandQualitySize = MATDataFilter.EUR_TR_BrandQualitySize__c;
        }

        String query = 'SELECT SUM(EUR_TR_LE1Amount__c) EUR_TR_LE1Amount__c, ' +
                ' SUM(EUR_TR_LE3Amount__c) EUR_TR_LE3Amount__c, ' +
                ' SUM(EUR_TR_LE6Amount__c) EUR_TR_LE6Amount__c, ' +
                ' SUM(EUR_TR_LE9Amount__c) EUR_TR_LE9Amount__c, ' +
                ' SUM(EUR_TR_LE12Amount__c) EUR_TR_LE12Amount__c, ' +
                ' SUM(EUR_TR_LYLE1Amount__c) EUR_TR_LYLE1Amount__c, ' +
                ' SUM(EUR_TR_LYLE3Amount__c) EUR_TR_LYLE3Amount__c, ' +
                ' SUM(EUR_TR_LYLE6Amount__c) EUR_TR_LYLE6Amount__c, ' +
                ' SUM(EUR_TR_LYLE9Amount__c) EUR_TR_LYLE9Amount__c, ' +
                ' SUM(EUR_TR_LYLE12Amount__c) EUR_TR_LYLE12Amount__c ' +
                ' FROM EUR_TR_SalesReport__c ' +
                ' WHERE RecordType.DeveloperName = \'EUR_TR_Preseller_Sales_Trend\' ' +
                ' AND EUR_TR_Preseller__c IN :presellers ';

        if (String.isNotBlank(brand)) {
            query += 'AND EUR_TR_Brand__c = :brand ';
            if (String.isNotBlank(brandQuality)) {
                query += 'AND EUR_TR_BrandQuality__c = :brandQuality ';
                if (String.isNotBlank(brandQualitySize)) {
                    query += 'AND EUR_TR_BrandQualitySize__c = :brandQualitySize ';
                }
            }
        }

        System.debug(query);

        return Database.query(query);
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getMATByBrandReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        ReportRequest request = (ReportRequest) JSON.deserialize(requestBody, ReportRequest.class);

        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        serviceResponse.ExtensionData = getMATByBrandReport(request);


        return serviceResponse;
    }

    // MAT
    public static List<AggregateResult> getMATByBrandReport(ReportRequest reportRequest) {
        List<EUR_TR_Employee__c> presellers = getPresellers(reportRequest);
        List<AggregateResult> mats = [
                SELECT EUR_TR_Brand__c,
                        SUM(EUR_TR_MAT1__c) EUR_TR_MAT1__c,
                        SUM(EUR_TR_MAT2__c) EUR_TR_MAT2__c,
                        SUM(EUR_TR_MAT3__c) EUR_TR_MAT3__c,
                        SUM(EUR_TR_MAT4__c) EUR_TR_MAT4__c,
                        SUM(EUR_TR_MAT5__c) EUR_TR_MAT5__c
                FROM EUR_TR_SalesReport__c
                WHERE RecordType.DeveloperName = 'EUR_TR_Preseller_MAT'
                AND EUR_TR_Preseller__c IN:presellers
                GROUP BY EUR_TR_Brand__c
                ORDER BY SUM(EUR_TR_MAT1__c) DESC
                LIMIT 6
        ];
        return mats;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getProfitabilityReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        ReportRequest request = (ReportRequest) JSON.deserialize(requestBody, ReportRequest.class);

        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        serviceResponse.ExtensionData = getProfitabilityReport(request);

        return serviceResponse;
    }

    // Karlılık
    public static List<AggregateResult> getProfitabilityReport(ReportRequest reportRequest) {
        List<EUR_TR_Employee__c> presellers = getPresellers(reportRequest);

        List<AggregateResult> profitability = [
                SELECT EUR_TR_Year__c,
                        SUM(EUR_TR_TotalAmount__c) EUR_TR_TotalAmount__c,
                        SUM(EUR_TR_ProfitAmount__c) EUR_TR_ProfitAmount__c
                FROM EUR_TR_SalesReport__c
                WHERE RecordType.DeveloperName = 'EUR_TR_PreSeller_Profitability'
                AND EUR_TR_Preseller__c IN:presellers
                GROUP BY EUR_TR_Year__c
        ];

        return profitability;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getProfitabilityDetailReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        ReportRequest request = (ReportRequest) JSON.deserialize(requestBody, ReportRequest.class);

        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        serviceResponse.ExtensionData = getProfitabilityDetailReport(request);


        return serviceResponse;
    }

    // Karlılık Detay
    public static List<AggregateResult> getProfitabilityDetailReport(ReportRequest reportRequest) {
        List<EUR_TR_Employee__c> presellers = getPresellers(reportRequest);
        List<String> presellerNames = getPresellerNames(presellers);
        System.debug('presellerNames: ' + presellerNames);

        List<AggregateResult> profitabilityDetails = [
                SELECT EUR_TR_Year__c, EUR_TR_Quarter__c,
                        SUM(EUR_TR_TotalAmount__c) EUR_TR_TotalAmount__c,
                        SUM(EUR_TR_ProfitAmount__c) EUR_TR_ProfitAmount__c
                FROM EUR_TR_AccountProfitability__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AccountProfitability'
                AND EUR_TR_RelatedAccount__r.EUR_TR_PresellerName__c IN :presellerNames
                GROUP BY EUR_TR_Year__c, EUR_TR_Quarter__c
                ORDER BY EUR_TR_Year__c, EUR_TR_Quarter__c
        ];

        return profitabilityDetails;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getMATReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            ReportRequest request = (ReportRequest) JSON.deserialize(requestBody, ReportRequest.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getMATReport(request);
        } catch (Exception exc) {
            System.debug('exc: ' + exc);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    // MAT Raporu
    public static List<AggregateResult> getMATReport(ReportRequest reportRequest) {
        List<EUR_TR_Employee__c> preSellers = getPresellers(reportRequest);

        String query = 'SELECT SUM(EUR_TR_MAT1__c) EUR_TR_MAT1__c' +
                ', SUM(EUR_TR_MAT2__c) EUR_TR_MAT2__c' +
                ', SUM(EUR_TR_MAT3__c) EUR_TR_MAT3__c' +
                ', SUM(EUR_TR_MAT4__c) EUR_TR_MAT4__c' +
                ', SUM(EUR_TR_MAT5__c) EUR_TR_MAT5__c ' +
                'FROM EUR_TR_SalesReport__c ' +
                'WHERE RecordType.DeveloperName = \'EUR_TR_Preseller_MAT\' ' +
                'AND EUR_TR_Preseller__c IN:preSellers ';

        String brand, brandQuality, brandQualitySize;
        if (reportRequest.MATData != null) {
            brand = reportRequest.MATData.EUR_TR_Brand__c;
            brandQuality = reportRequest.MATData.EUR_TR_BrandQuality__c;
            brandQualitySize = reportRequest.MATData.EUR_TR_BrandQualitySize__c;
        }
        if (String.isNotBlank(brand)) {
            query += 'AND EUR_TR_Brand__c = :brand ';
            if (String.isNotBlank(brandQuality)) {
                query += 'AND EUR_TR_BrandQuality__c = :brandQuality ';
                if (String.isNotBlank(brandQualitySize)) {
                    query += 'AND EUR_TR_BrandQualitySize__c = :brandQualitySize ';
                }
            }
        }
        System.debug(query);
        return Database.query(query);
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getTargetReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            EUR_TR_Target__c request = (EUR_TR_Target__c) JSON.deserialize(requestBody, EUR_TR_Target__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getTargetReport(request);
        } catch (Exception exc) {
            System.debug('exc: ' + exc);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static Map<String, List<EUR_TR_Target__c>> getTargetReport(EUR_TR_Target__c request) {
        if (String.isBlank(request.EUR_TR_Period__c)) {
            throw new ReportException('Dönem bilgisi boş olamaz.');
        }

        EUR_TR_Employee__c employee;
        if (String.isBlank(request.EUR_TR_RelatedEmployee__c)) {
            List<EUR_TR_Employee__c> employees = [
                    SELECT Id
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_RelatedUser__c = :UserInfo.getUserId()
            ];

            if (employees.isEmpty()) {
                throw new ReportException('Mevcut kullanıcıya ait bir çalışan kaydı bulunamadı.');
            }

            employee = employees[0];
        } else {
            employee = new EUR_TR_Employee__c(Id = request.EUR_TR_RelatedEmployee__c);
        }

        List<EUR_TR_Target__c> targets = [
                SELECT RecordType.DeveloperName,
                        EUR_TR_ActualAmount__c,
                        EUR_TR_Brand__c,
                        EUR_TR_CustomSortOrder__c,
                        EUR_TR_EmployeeName__c,
                        EUR_TR_ExternalId__c,
                        EUR_TR_Month__c,
                        EUR_TR_Period__c,
                        EUR_TR_RemainingAmount__c,
                        EUR_TR_TargetAmount__c,
                        EUR_TR_TargetPercentage__c,
                        EUR_TR_RelatedEmployee__r.Id,
                        EUR_TR_RelatedEmployee__r.Name,
                        Id
                FROM EUR_TR_Target__c
                WHERE EUR_TR_RelatedEmployee__c = :employee.Id
                AND EUR_TR_Period__c = :request.EUR_TR_Period__c
                ORDER BY EUR_TR_Month__c
        ];

        Map<String, List<EUR_TR_Target__c>> targetsByPeriod = new Map<String, List<EUR_TR_Target__c>>();
        for (EUR_TR_Target__c target : targets) {
            switch on target.RecordType.DeveloperName {
                when 'EUR_TR_Target' {
                    if (targetsByPeriod.containsKey('QuarterTotal')) {
                        targetsByPeriod.get('QuarterTotal').add(target);
                    } else {
                        targetsByPeriod.put('QuarterTotal', new List<EUR_TR_Target__c>{
                                target
                        });
                    }
                }

                when 'EUR_TR_Mothly_Target' {
                    if (String.isBlank(target.EUR_TR_Month__c)) {
                        throw new ReportException('Aylık hedef kaydında ay bilgisi bulunamadı.');
                    }

                    if (targetsByPeriod.containsKey(target.EUR_TR_Month__c)) {
                        targetsByPeriod.get(target.EUR_TR_Month__c).add(target);
                    } else {
                        targetsByPeriod.put(target.EUR_TR_Month__c, new List<EUR_TR_Target__c>{
                                target
                        });
                    }
                }
            }
        }

        return targetsByPeriod;
    }

    public class ReportException extends Exception {
    }

    public class ReportRequest {
        public Set<Id> areaManagerIds { get; set; }
        public Set<Id> salesChiefIds { get; set; }
        public Set<Id> presellerIds { get; set; }
        public EUR_TR_AccountSalesMAT__c MATData { get; set; }
    }
}