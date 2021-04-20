/**
 * Created by osman on 19.11.2020.
 */

@IsTest
private with sharing class EUR_TR_RouteReportControllerTest {

    @TestSetup
    static void setup() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'EUR TR Trade Tool User'];

        User areaManager = new User();
        areaManager.FirstName = 'area';
        areaManager.LastName = 'manager';
        areaManager.UserName = 'eur_tr_area_manager_test_user@pernod.com';
        areaManager.Alias = 'are9899';
        areaManager.Email = 'eur_tr_area_manager_test_user@pernod.com';
        areaManager.ProfileId = profile.Id;
        areaManager.EmailEncodingKey = 'UTF-8';
        areaManager.LanguageLocaleKey = 'en_US';
        areaManager.LocaleSidKey = 'tr_TR';
        areaManager.TimeZoneSidKey = 'Europe/Istanbul';
        insert areaManager;

        User salesChief = new User();
        salesChief.FirstName = 'sales';
        salesChief.LastName = 'chief';
        salesChief.UserName = 'tr_sales_chief_test_user@pernod.com';
        salesChief.Alias = 'ch9899';
        salesChief.Email = 'tr_sales_chief_test_user@pernod.com';
        salesChief.ProfileId = profile.Id;
        salesChief.EmailEncodingKey = 'UTF-8';
        salesChief.LanguageLocaleKey = 'en_US';
        salesChief.LocaleSidKey = 'tr_TR';
        salesChief.TimeZoneSidKey = 'Europe/Istanbul';
        insert salesChief;

        EUR_TR_Employee__c areaManagerEmployee = new EUR_TR_Employee__c();
        areaManagerEmployee.Name = 'Area Manager';
        areaManagerEmployee.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AreaManager').getRecordTypeId();
        areaManagerEmployee.EUR_TR_RelatedUser__c = areaManager.Id;
        insert areaManagerEmployee;

        EUR_TR_Employee__c salesChiefEmployee = new EUR_TR_Employee__c();
        salesChiefEmployee.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();
        salesChiefEmployee.EUR_TR_RelatedUser__c = salesChief.Id;
        salesChiefEmployee.EUR_TR_ReportsTo_AreaManager__c = areaManagerEmployee.Id;
        insert salesChiefEmployee;

        EUR_TR_Account__c activeAccount = new EUR_TR_Account__c();
        activeAccount.Name = 'test acc 1';
        activeAccount.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        activeAccount.EUR_TR_ActivityPoints__c = 'Absolut';
        insert activeAccount;


        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();
        favoriteRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Route__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRoute').getRecordTypeId();
        favoriteRoute.Name = 'Favori Rota';
        favoriteRoute.OwnerId = salesChief.Id;
        insert favoriteRoute;

        EUR_TR_RouteDetail__c favoriteRouteDetail = new EUR_TR_RouteDetail__c();
        favoriteRouteDetail.RecordTypeId = Schema.SObjectType.EUR_TR_RouteDetail__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRouteDetail').getRecordTypeId();
        favoriteRouteDetail.EUR_TR_RelatedAccount__c = activeAccount.Id;
        favoriteRouteDetail.EUR_TR_RelatedRoute__c = favoriteRoute.Id;
        insert favoriteRouteDetail;

        EUR_TR_Visit__c workedDay = new EUR_TR_Visit__c();
        workedDay.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        workedDay.EUR_TR_StartDateTime__c = Datetime.now();
        workedDay.EUR_TR_EndDateTime__c = Datetime.now().addHours(4);
        workedDay.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        workedDay.OwnerId = salesChief.Id;
        insert workedDay;

        EUR_TR_Visit__c visitInRoute = new EUR_TR_Visit__c();
        visitInRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Visit').getRecordTypeId();
        visitInRoute.EUR_TR_RelatedWorkedDay__c = workedDay.Id;
        visitInRoute.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        visitInRoute.EUR_TR_StartDateTime__c = Datetime.now().addMinutes(20);
        visitInRoute.EUR_TR_EndDateTime__c = visitInRoute.EUR_TR_StartDateTime__c.addMinutes(40);
        visitInRoute.EUR_TR_VisitType__c = 'In-Route';
        visitInRoute.OwnerId = salesChief.Id;
        insert visitInRoute;

        EUR_TR_Visit__c visitOffRoute = new EUR_TR_Visit__c();
        visitOffRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Visit').getRecordTypeId();
        visitOffRoute.EUR_TR_RelatedWorkedDay__c = workedDay.Id;
        visitOffRoute.EUR_TR_StartDateTime__c = Datetime.now().addMinutes(70);
        visitOffRoute.EUR_TR_EndDateTime__c = visitInRoute.EUR_TR_StartDateTime__c.addMinutes(100);
        visitOffRoute.OwnerId = salesChief.Id;
        visitOffRoute.EUR_TR_VisitType__c = 'Off-Route';
        insert visitOffRoute;


    }

    @IsTest
    static void testGetRouteReportFromMiddleware() {

        EUR_TR_RouteReportController.RouteReportRequestModel requestModel = new EUR_TR_RouteReportController.RouteReportRequestModel();
        EUR_TR_Employee__c areaManager = [SELECT Id FROM EUR_TR_Employee__c WHERE RecordType.DeveloperName = 'EUR_TR_AreaManager'];
        requestModel.areaManagerIds = new Set<Id>{
                areaManager.Id
        };

        Test.startTest();
        {
            EUR_TR_RouteReportController.getRouteReportFromMiddleware(JSON.serialize(requestModel));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetRouteReportFromMiddleware_error() {

        EUR_TR_RouteReportController.RouteReportRequestModel requestModel = new EUR_TR_RouteReportController.RouteReportRequestModel();
        EUR_TR_Employee__c areaManager = [SELECT Id FROM EUR_TR_Employee__c WHERE RecordType.DeveloperName = 'EUR_TR_AreaManager'];
        requestModel.areaManagerIds = new Set<Id>{
                areaManager.Id
        };
        requestModel.reportStartDate = Date.today();
        requestModel.reportEndDate = Date.today().addYears(3);

        Test.startTest();
        {
            try {
                EUR_TR_RouteReportController.getRouteReportFromMiddleware(JSON.serialize(requestModel));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testCalculateWorkedDaySummaryReport() {

        Map<Id, EUR_TR_Visit__c> workedDayMap = new Map<Id, EUR_TR_Visit__c>([
                SELECT Id
                FROM EUR_TR_Visit__c
                WHERE RecordType.DeveloperName = 'EUR_TR_WorkedDay'
        ]);

        Test.startTest();
        {
            EUR_TR_RouteReportController.calculateWorkedDaySummaryReport(workedDayMap.keySet());
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetRouteReportDetailByIdFromMiddleware() {

        EUR_TR_Visit__c workedDay = [SELECT Id FROM EUR_TR_Visit__c WHERE RecordType.DeveloperName = 'EUR_TR_WorkedDay'];
        Test.startTest();
        {
            EUR_TR_RouteReportController.getRouteReportDetailByIdFromMiddleware(JSON.serializePretty(workedDay));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetRouteReportDetailByIdFromMiddleware_error() {

        EUR_TR_Visit__c workedDay = [SELECT Id FROM EUR_TR_Visit__c WHERE RecordType.DeveloperName = 'EUR_TR_WorkedDay'];
        Test.startTest();
        {
            workedDay.Id = null;
            EUR_TR_RouteReportController.getRouteReportDetailByIdFromMiddleware(JSON.serializePretty(workedDay));
        }
        Test.stopTest();

    }


}