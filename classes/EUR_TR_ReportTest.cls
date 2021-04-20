/**
 * Created by Murat Can on 26/10/2020.
 */

@IsTest
private class EUR_TR_ReportTest {

    @TestSetup
    static void setupData() {
        EUR_TR_Employee__c areaManager = new EUR_TR_Employee__c();

        areaManager.Name = 'Test_AM';
        areaManager.EUR_TR_AreaManagerNumber__c = 1;
        areaManager.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AreaManager').getRecordTypeId();

        insert areaManager;

        EUR_TR_Employee__c salesChief = new EUR_TR_Employee__c();

        salesChief.Name = 'Test_SC';
        salesChief.EUR_TR_SalesChiefNumber__c = 2;
        salesChief.EUR_TR_ReportsTo_AreaManager__c = areaManager.Id;
        salesChief.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();

        insert salesChief;

        EUR_TR_Employee__c preseller = new EUR_TR_Employee__c();

        preseller.Name = 'Test_PR';
        preseller.EUR_TR_EmployeeNumber__c = 3;
        preseller.EUR_TR_ReportsTo_Chief__c = salesChief.Id;
        preseller.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Preseller').getRecordTypeId();

        insert preseller;


        EUR_TR_Account__c account = new EUR_TR_Account__c();

        account.Name = 'Test';
        account.EUR_TR_AreaManagerName__c = 'Test_AM';
        account.EUR_TR_SalesChiefName__c = 'Test_SC';
        account.EUR_TR_PresellerName__c = 'Test_PR';

        insert account;

        EUR_TR_SalesTrend__c salesTrend = new EUR_TR_SalesTrend__c();

        salesTrend.EUR_TR_LE1Amount__c = 10;
        salesTrend.EUR_TR_LE3Amount__c = 10;
        salesTrend.EUR_TR_LE6Amount__c = 10;
        salesTrend.EUR_TR_LE9Amount__c = 10;
        salesTrend.EUR_TR_LE12Amount__c = 10;
        salesTrend.EUR_TR_LYLE1Amount__c = 10;
        salesTrend.EUR_TR_LYLE3Amount__c = 10;
        salesTrend.EUR_TR_LYLE6Amount__c = 10;
        salesTrend.EUR_TR_LYLE9Amount__c = 10;
        salesTrend.EUR_TR_LYLE12Amount__c = 10;
        salesTrend.RecordTypeId = Schema.SObjectType.EUR_TR_SalesTrend__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesTrend').getRecordTypeId();

        insert salesTrend;

        EUR_TR_AccountSalesMAT__c salesMatByBrand = new EUR_TR_AccountSalesMAT__c();

        salesMatByBrand.EUR_TR_RelatedAccount__c = account.Id;
        salesMatByBrand.EUR_TR_MAT1__c = 10;
        salesMatByBrand.EUR_TR_MAT2__c = 10;
        salesMatByBrand.EUR_TR_MAT3__c = 10;
        salesMatByBrand.EUR_TR_MAT4__c = 10;
        salesMatByBrand.EUR_TR_MAT5__c = 10;

        insert salesMatByBrand;

        EUR_TR_AccountSalesMAT__c salesMat = new EUR_TR_AccountSalesMAT__c();

        salesMat.EUR_TR_RelatedAccount__c = account.Id;
        salesMat.EUR_TR_MAT1__c = 10;
        salesMat.EUR_TR_MAT2__c = 10;
        salesMat.EUR_TR_MAT3__c = 10;
        salesMat.EUR_TR_MAT4__c = 10;
        salesMat.EUR_TR_MAT5__c = 10;
        salesMat.EUR_TR_Brand__c = 'Test EUR_TR_Brand__c';
        salesMat.EUR_TR_BrandQuality__c = 'Test EUR_TR_BrandQuality__c';
        salesMat.EUR_TR_BrandQualitySize__c = 'Test EUR_TR_BrandQualitySize__c';

        insert salesMat;

        EUR_TR_AccountProfitability__c accountProfitability = new EUR_TR_AccountProfitability__c();

        accountProfitability.EUR_TR_RelatedAccount__c = account.Id;
        accountProfitability.EUR_TR_TotalAmount__c = 10;
        accountProfitability.EUR_TR_ProfitAmount__c = 10;
        accountProfitability.EUR_TR_Year__c = '20';
        accountProfitability.EUR_TR_Quarter__c = 'Q1';
        accountProfitability.RecordTypeId = Schema.SObjectType.EUR_TR_AccountProfitability__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AccountProfitability').getRecordTypeId();

        insert accountProfitability;
    }

    @IsTest
    static void testGetSalesTrendsReport() {
        List<EUR_TR_Employee__c> employees = getEmployees();

        Test.startTest();

        for (EUR_TR_Employee__c employee : employees) {
            EUR_TR_Report.ReportRequest reportRequest = new EUR_TR_Report.ReportRequest();

            reportRequest.MATData = new EUR_TR_AccountSalesMAT__c();
            reportRequest.MATData.EUR_TR_Brand__c = 'Test EUR_TR_Brand__c';
            reportRequest.MATData.EUR_TR_BrandQuality__c = 'Test EUR_TR_BrandQuality__c';
            reportRequest.MATData.EUR_TR_BrandQualitySize__c = 'Test EUR_TR_BrandQualitySize__c';

            switch on employee.RecordType.DeveloperName {
                when 'EUR_TR_Preseller' {
                    reportRequest.presellerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getSalesTrendsReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_SalesChief' {
                    reportRequest.salesChiefIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getSalesTrendsReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_AreaManager' {
                    reportRequest.areaManagerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getSalesTrendsReportFromMiddleware(JSON.serialize(reportRequest));
                }
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetMATByBrandReport() {
        List<EUR_TR_Employee__c> employees = getEmployees();

        Test.startTest();

        for (EUR_TR_Employee__c employee : employees) {
            EUR_TR_Report.ReportRequest reportRequest = new EUR_TR_Report.ReportRequest();

            switch on employee.RecordType.DeveloperName {
                when 'EUR_TR_Preseller' {
                    reportRequest.presellerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getMATByBrandReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_SalesChief' {
                    reportRequest.salesChiefIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getMATByBrandReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_AreaManager' {
                    reportRequest.areaManagerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getMATByBrandReportFromMiddleware(JSON.serialize(reportRequest));
                }
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetProfitabilityReport() {
        List<EUR_TR_Employee__c> employees = getEmployees();

        Test.startTest();

        for (EUR_TR_Employee__c employee : employees) {
            EUR_TR_Report.ReportRequest reportRequest = new EUR_TR_Report.ReportRequest();

            switch on employee.RecordType.DeveloperName {
                when 'EUR_TR_Preseller' {
                    reportRequest.presellerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getProfitabilityReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_SalesChief' {
                    reportRequest.salesChiefIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getProfitabilityReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_AreaManager' {
                    reportRequest.areaManagerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getProfitabilityReportFromMiddleware(JSON.serialize(reportRequest));
                }
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetProfitabilityDetailReport() {
        List<EUR_TR_Employee__c> employees = getEmployees();

        Test.startTest();

        for (EUR_TR_Employee__c employee : employees) {
            EUR_TR_Report.ReportRequest reportRequest = new EUR_TR_Report.ReportRequest();

            switch on employee.RecordType.DeveloperName {
                when 'EUR_TR_Preseller' {
                    reportRequest.presellerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getProfitabilityDetailReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_SalesChief' {
                    reportRequest.salesChiefIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getProfitabilityDetailReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_AreaManager' {
                    reportRequest.areaManagerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getProfitabilityDetailReportFromMiddleware(JSON.serialize(reportRequest));
                }
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetMATReport() {
        List<EUR_TR_Employee__c> employees = getEmployees();

        Test.startTest();

        for (EUR_TR_Employee__c employee : employees) {
            EUR_TR_Report.ReportRequest reportRequest = new EUR_TR_Report.ReportRequest();

            reportRequest.MATData = new EUR_TR_AccountSalesMAT__c();
            reportRequest.MATData.EUR_TR_Brand__c = 'Test EUR_TR_Brand__c';
            reportRequest.MATData.EUR_TR_BrandQuality__c = 'Test EUR_TR_BrandQuality__c';
            reportRequest.MATData.EUR_TR_BrandQualitySize__c = 'Test EUR_TR_BrandQualitySize__c';

            switch on employee.RecordType.DeveloperName {
                when 'EUR_TR_Preseller' {
                    reportRequest.presellerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getMATReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_SalesChief' {
                    reportRequest.salesChiefIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getMATReportFromMiddleware(JSON.serialize(reportRequest));
                }
                when 'EUR_TR_AreaManager' {
                    reportRequest.areaManagerIds = new Set<Id>{employee.Id};
                    EUR_TR_Report.getMATReportFromMiddleware(JSON.serialize(reportRequest));
                }
            }
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetTargetReport() {
        EUR_TR_Employee__c employee = new EUR_TR_Employee__c();

        employee.Name = 'Test_TargetReport';
        employee.EUR_TR_SalesChiefNumber__c = 3;
        employee.EUR_TR_RelatedUser__c = UserInfo.getUserId();
        employee.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();

        insert employee;

        EUR_TR_Target__c target = new EUR_TR_Target__c();

        target.RecordTypeId = Schema.SObjectType.EUR_TR_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Target').getRecordTypeId();
        target.EUR_TR_Period__c = 'FY2021Q1';
        target.EUR_TR_RelatedEmployee__c = employee.Id;
        target.EUR_TR_ActualAmount__c = 150;
        target.EUR_TR_TargetAmount__c = 150;

        insert target;

        List<EUR_TR_Target__c> monthlyTargets = new List<EUR_TR_Target__c>();

        EUR_TR_Target__c monthlyTarget1 = new EUR_TR_Target__c();

        monthlyTarget1.RecordTypeId = Schema.SObjectType.EUR_TR_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Mothly_Target').getRecordTypeId();
        monthlyTarget1.EUR_TR_Month__c = '1';
        monthlyTarget1.EUR_TR_Period__c = 'FY2021Q1';
        monthlyTarget1.EUR_TR_RelatedEmployee__c = employee.Id;
        monthlyTarget1.EUR_TR_ActualAmount__c = 50;
        monthlyTarget1.EUR_TR_TargetAmount__c = 50;
        monthlyTargets.add(monthlyTarget1);

        EUR_TR_Target__c monthlyTarget2 = new EUR_TR_Target__c();

        monthlyTarget2.RecordTypeId = Schema.SObjectType.EUR_TR_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Mothly_Target').getRecordTypeId();
        monthlyTarget1.EUR_TR_Month__c = '2';
        monthlyTarget2.EUR_TR_Period__c = 'FY2021Q1';
        monthlyTarget2.EUR_TR_RelatedEmployee__c = employee.Id;
        monthlyTarget2.EUR_TR_ActualAmount__c = 50;
        monthlyTarget2.EUR_TR_TargetAmount__c = 50;
        monthlyTargets.add(monthlyTarget2);

        EUR_TR_Target__c monthlyTarget3 = new EUR_TR_Target__c();

        monthlyTarget3.RecordTypeId = Schema.SObjectType.EUR_TR_Target__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Mothly_Target').getRecordTypeId();
        monthlyTarget1.EUR_TR_Month__c = '3';
        monthlyTarget3.EUR_TR_Period__c = 'FY2021Q1';
        monthlyTarget3.EUR_TR_RelatedEmployee__c = employee.Id;
        monthlyTarget3.EUR_TR_ActualAmount__c = 50;
        monthlyTarget3.EUR_TR_TargetAmount__c = 50;
        monthlyTargets.add(monthlyTarget3);

        insert monthlyTargets;

        Test.startTest();

        EUR_TR_Target__c request = new EUR_TR_Target__c(
                EUR_TR_Period__c = 'FY2021Q1',
                EUR_TR_RelatedEmployee__c = employee.Id
        );
        EUR_TR_Report.getTargetReportFromMiddleware(JSON.serialize(request));

        EUR_TR_Target__c requestEmptyEmployee = new EUR_TR_Target__c(
                EUR_TR_Period__c = 'FY2021Q1'
        );
        EUR_TR_Report.getTargetReportFromMiddleware(JSON.serialize(requestEmptyEmployee));

        Test.stopTest();
    }

    static List<EUR_TR_Employee__c> getEmployees() {
        return [
                SELECT Id, Name, RecordType.DeveloperName
                FROM EUR_TR_Employee__c
        ];
    }
}