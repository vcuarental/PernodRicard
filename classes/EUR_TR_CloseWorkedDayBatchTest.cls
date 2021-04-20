/**
 * Created by osman on 25.11.2020.
 */

@IsTest
private with sharing class EUR_TR_CloseWorkedDayBatchTest {

    @TestSetup
    static void setup() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'EUR TR Trade Tool User'];

        EUR_TR_Definition__c workedDayDefinition = new EUR_TR_Definition__c();
        workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c = 10;
        workedDayDefinition.Name = 'Gün Tanımları';
        workedDayDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        workedDayDefinition.EUR_TR_VisitHourDurationToClose__c = 1;
        insert workedDayDefinition;

        User areaManager = new User();
        areaManager.FirstName = 'area';
        areaManager.LastName = 'manager';
        areaManager.UserName = 'eur_tr_area_manager_test_user_to_batch99@pernod.com';
        areaManager.Alias = 'batch99';
        areaManager.Email = 'eur_tr_area_manager_test_user_to_batch99@pernod.com';
        areaManager.ProfileId = profile.Id;
        areaManager.EmailEncodingKey = 'UTF-8';
        areaManager.LanguageLocaleKey = 'en_US';
        areaManager.LocaleSidKey = 'tr_TR';
        areaManager.TimeZoneSidKey = 'Europe/Istanbul';
        insert areaManager;

        User salesChief = new User();
        salesChief.FirstName = 'sales';
        salesChief.LastName = 'chief';
        salesChief.UserName = 'tr_sales_chief_test_user_to_batch99@pernod.com';
        salesChief.Alias = 'ch9899';
        salesChief.Email = 'tr_sales_chief_test_user_to_batch99@pernod.com';
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
        areaManagerEmployee.EUR_TR_AutoClosedDayCount__c = 2;
        insert areaManagerEmployee;

        EUR_TR_Employee__c salesChiefEmployee = new EUR_TR_Employee__c();
        salesChiefEmployee.RecordTypeId = Schema.SObjectType.EUR_TR_Employee__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_SalesChief').getRecordTypeId();
        salesChiefEmployee.EUR_TR_RelatedUser__c = salesChief.Id;
        salesChiefEmployee.EUR_TR_ReportsTo_AreaManager__c = areaManagerEmployee.Id;
        salesChiefEmployee.EUR_TR_AutoClosedDayCount__c = 2;
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

        Date yesterdayDate = Date.today().addDays(-1);
        Datetime yesterdayDatetime = Datetime.newInstance(yesterdayDate.year(), yesterdayDate.month(), yesterdayDate.day(), 7, 0, 0);

        EUR_TR_Visit__c workedDay = new EUR_TR_Visit__c();
        workedDay.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        workedDay.EUR_TR_StartDateTime__c = yesterdayDatetime;
        workedDay.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        workedDay.OwnerId = salesChief.Id;
        insert workedDay;

        EUR_TR_Visit__c visitInRoute = new EUR_TR_Visit__c();
        visitInRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Visit').getRecordTypeId();
        visitInRoute.EUR_TR_RelatedWorkedDay__c = workedDay.Id;
        visitInRoute.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        visitInRoute.EUR_TR_StartDateTime__c = yesterdayDatetime.addHours(3);
        visitInRoute.EUR_TR_VisitType__c = 'In-Route';
        visitInRoute.OwnerId = salesChief.Id;
        insert visitInRoute;

    }

    @IsTest
    static void testCloseWorkedDayBatch() {

        Test.startTest();
        {
            Database.executeBatch(new EUR_TR_CloseWorkedDayBatch(), 1);
            List<EUR_TR_Visit__c> closedDayAndVisits = [
                    SELECT Id, (SELECT Id FROM EUR_TR_Visits__r WHERE EUR_TR_StartDateTime__c != NULL AND EUR_TR_EndDateTime__c != NULL)
                    FROM EUR_TR_Visit__c
                    WHERE EUR_TR_EndDateTime__c != NULL AND RecordType.DeveloperName = 'EUR_TR_WorkedDay'
            ];
            System.debug(JSON.serializePretty(closedDayAndVisits));
        }
        Test.stopTest();

    }

}