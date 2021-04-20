/**
 * Created by osman on 11.11.2020.
 */

@IsTest
private with sharing class EUR_TR_RouteControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Definition__c dailyWorkDefinition = new EUR_TR_Definition__c();
        dailyWorkDefinition.EUR_TR_MaxVisitableAccountNumber__c = 10;
        dailyWorkDefinition.Name = 'Rota Tanımı';
        dailyWorkDefinition.RecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        insert dailyWorkDefinition;

        EUR_TR_Account__c activeAccount = new EUR_TR_Account__c();
        activeAccount.Name = 'test acc 1';
        activeAccount.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        activeAccount.EUR_TR_ActivityPoints__c = 'Absolut';
        activeAccount.EUR_TR_SubType__c = 'Pavyon';
        activeAccount.EUR_TR_Group__c = 'ACEM';
        activeAccount.EUR_TR_Channel__c = 'Otel';
        activeAccount.EUR_TR_ONTB__c = 'Boğaz';
        activeAccount.EUR_TR_OTPros__c = 'Premium';
        activeAccount.EUR_TR_OTSponsorship__c = 'Tanımsız';
        activeAccount.EUR_TR_OTType__c = 'Hotel';
        activeAccount.EUR_TR_Range__c = 'S2';
        activeAccount.EUR_TR_SponsorshipStatus__c = 'PR İskontolu';
        activeAccount.EUR_TR_Class__c = 'Tanimsiz';
        activeAccount.EUR_TR_Type__c = '2HEDEFLİ';
        activeAccount.EUR_TR_Status__c = 'Aktif';
        insert activeAccount;

        EUR_TR_Account__c passiveAccount = new EUR_TR_Account__c();
        passiveAccount.Name = 'test acc 1';
        passiveAccount.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        passiveAccount.EUR_TR_ActivityPoints__c = 'Absolut';
        passiveAccount.EUR_TR_SubType__c = 'Pavyon';
        passiveAccount.EUR_TR_Group__c = 'ACEM';
        passiveAccount.EUR_TR_Channel__c = 'Otel';
        passiveAccount.EUR_TR_ONTB__c = 'Boğaz';
        passiveAccount.EUR_TR_OTPros__c = 'Premium';
        passiveAccount.EUR_TR_OTSponsorship__c = 'Tanımsız';
        passiveAccount.EUR_TR_OTType__c = 'Hotel';
        passiveAccount.EUR_TR_Range__c = 'S2';
        passiveAccount.EUR_TR_SponsorshipStatus__c = 'PR İskontolu';
        passiveAccount.EUR_TR_Class__c = 'Tanimsiz';
        passiveAccount.EUR_TR_Type__c = '2HEDEFLİ';
        passiveAccount.EUR_TR_Status__c = 'Pasif';
        insert passiveAccount;


        EUR_TR_Account__c newAccountToFavoriteRoute = new EUR_TR_Account__c();
        newAccountToFavoriteRoute.Name = 'test acc 1';
        newAccountToFavoriteRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        newAccountToFavoriteRoute.EUR_TR_ActivityPoints__c = 'Absolut';
        newAccountToFavoriteRoute.EUR_TR_SubType__c = 'Pavyon';
        newAccountToFavoriteRoute.EUR_TR_Group__c = 'ACEM';
        newAccountToFavoriteRoute.EUR_TR_Channel__c = 'MOT';
        newAccountToFavoriteRoute.EUR_TR_ONTB__c = 'Boğaz';
        newAccountToFavoriteRoute.EUR_TR_OTPros__c = 'Premium';
        newAccountToFavoriteRoute.EUR_TR_OTSponsorship__c = 'Tanımsız';
        newAccountToFavoriteRoute.EUR_TR_OTType__c = 'Hotel';
        newAccountToFavoriteRoute.EUR_TR_Range__c = 'S2';
        newAccountToFavoriteRoute.EUR_TR_SponsorshipStatus__c = 'PR İskontolu';
        newAccountToFavoriteRoute.EUR_TR_Class__c = 'Tanimsiz';
        newAccountToFavoriteRoute.EUR_TR_Type__c = '2HEDEFLİ';
        newAccountToFavoriteRoute.EUR_TR_Status__c = 'Pasif';
        insert newAccountToFavoriteRoute;

        EUR_TR_Route__c favoriteFilter = new EUR_TR_Route__c();
        favoriteFilter.EUR_TR_SelectedFilters__c = '{"key":"channels","value":["Otel"]} , {"key":"statuses","value":["Aktif","Pasif"]}';
        favoriteFilter.Name = 'Favori filtresi';
        favoriteFilter.RecordTypeId = Schema.SObjectType.EUR_TR_Route__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_RouteTemplate').getRecordTypeId();
        insert favoriteFilter;


    }

    @IsTest
    static void testCreateFavoriteRouteByFavoriteFilterFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        Test.startTest();
        {
            EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));
        }
        Test.stopTest();

    }

    @IsTest
    static void testCreateFavoriteRouteByFavoriteFilterFromMiddleware_error() {

        EUR_TR_Route__c favoriteFilter = new EUR_TR_Route__c();
        Test.startTest();
        {
            try {
                EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetFavoriteRoutesFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        Test.startTest();
        {
            EUR_TR_RouteController.getFavoriteRoutesFromMiddleware('');
        }
        Test.stopTest();
    }


    @IsTest
    static void testDeleteFavoriteRouteByIdFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_RouteController.deleteFavoriteRouteByIdFromMiddleware(JSON.serialize(favoriteRoute));
        }
        Test.stopTest();

    }

    @IsTest
    static void testDeleteFavoriteRouteByIdFromMiddleware_error() {

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.deleteFavoriteRouteByIdFromMiddleware(JSON.serialize(favoriteRoute));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testUpdateFavoriteRouteByIdFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        favoriteRoute.Name = 'update';

        Test.startTest();
        {
            EUR_TR_RouteController.updateFavoriteRouteByIdFromMiddleware(JSON.serialize(favoriteRoute));
        }
        Test.stopTest();

    }

    @IsTest
    static void testUpdateFavoriteRouteByIdFromMiddleware_error() {

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();
        favoriteRoute.Name = 'update';

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.updateFavoriteRouteByIdFromMiddleware(JSON.serialize(favoriteRoute));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testAddAccountToFavoriteRouteFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        EUR_TR_Account__c accountToFavoriteRoute = [
                SELECT Id
                FROM EUR_TR_Account__c
                WHERE EUR_TR_Channel__c = 'MOT'
                LIMIT 1
        ];

        EUR_TR_RouteDetail__c routeDetail = new EUR_TR_RouteDetail__c();
        routeDetail.EUR_TR_RelatedAccount__c = accountToFavoriteRoute.Id;
        routeDetail.EUR_TR_RelatedRoute__c = favoriteRoute.Id;

        favoriteRoute.Name = 'update';

        Test.startTest();
        {
            EUR_TR_RouteController.addAccountToFavoriteRouteFromMiddleware(JSON.serialize(routeDetail));
        }
        Test.stopTest();

    }


    @IsTest
    static void testAddAccountToFavoriteRouteFromMiddleware_error() {


        EUR_TR_RouteDetail__c routeDetail = new EUR_TR_RouteDetail__c();
        routeDetail.EUR_TR_RelatedAccount__c = null;
        routeDetail.EUR_TR_RelatedRoute__c = null;

        Test.startTest();
        {
            EUR_TR_RouteController.addAccountToFavoriteRouteFromMiddleware(JSON.serialize(routeDetail));
        }
        Test.stopTest();

    }

    @IsTest
    static void testDeleteAccountFromFavoriteRouteFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        EUR_TR_Account__c accountToDeleteFromFavoriteRoute = [
                SELECT Id
                FROM EUR_TR_Account__c
                WHERE EUR_TR_Channel__c = 'Otel'
                LIMIT 1
        ];

        EUR_TR_RouteDetail__c routeDetail = new EUR_TR_RouteDetail__c();
        routeDetail.EUR_TR_RelatedAccount__c = accountToDeleteFromFavoriteRoute.Id;
        routeDetail.EUR_TR_RelatedRoute__c = favoriteRoute.Id;

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.deleteAccountFromFavoriteRouteFromMiddleware(JSON.serialize(routeDetail));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testDeleteAccountFromFavoriteRouteFromMiddleware_error() {

        EUR_TR_RouteDetail__c routeDetail = new EUR_TR_RouteDetail__c();
        routeDetail.EUR_TR_RelatedAccount__c = null;
        routeDetail.EUR_TR_RelatedRoute__c = null;

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.deleteAccountFromFavoriteRouteFromMiddleware(JSON.serialize(routeDetail));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testCreateFavoriteRouteFromMiddleware() {

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();
        favoriteRoute.Name = 'Route From List';

        Test.startTest();
        {
            EUR_TR_RouteController.createFavoriteRouteFromMiddleware(JSON.serialize(favoriteRoute));
        }
        Test.stopTest();

    }

    @IsTest
    static void testCreateFavoriteRouteFromMiddleware_error() {

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();
        favoriteRoute.Name = 'Route From List';

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.createFavoriteRouteFromMiddleware(JSON.serialize(favoriteRoute));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetAccountsByFavoriteRouteFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_RouteController.getAccountsByFavoriteRouteFromMiddleware(JSON.serialize(favoriteRoute));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetAccountsByFavoriteRouteFromMiddleware_error() {

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.getAccountsByFavoriteRouteFromMiddleware(JSON.serialize(favoriteRoute));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }


    @IsTest
    static void testStartRouteFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_RouteController.startRouteFromMiddleware(JSON.serialize(favoriteRoute));
        }
        Test.stopTest();

    }

    @IsTest
    static void testStartRouteFromMiddleware_error() {

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();

        Test.startTest();
        {
            try {
                EUR_TR_RouteController.startRouteFromMiddleware(JSON.serialize(favoriteRoute));
            } catch (Exception ex) {
                System.assert(ex.getMessage() != null);
            }
        }
        Test.stopTest();

    }

    @IsTest
    static void testDeleteNotStartedRouteVisits() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        EUR_TR_RouteController.startRouteFromMiddleware(JSON.serialize(favoriteRoute));

        EUR_TR_Visit__c workedDay = [
                SELECT Id
                FROM EUR_TR_Visit__c
                WHERE RecordType.DeveloperName = 'EUR_TR_WorkedDay' AND EUR_TR_EndDateTime__c = NULL
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_RouteController.deleteNotStartedRouteVisits(new Set<Id>{
                    workedDay.Id
            });
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateRouteDetailVisitOrderFromMiddleware() {

        EUR_TR_Route__c favoriteFilter = getFavoriteFilter();
        EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(JSON.serialize(favoriteFilter));

        EUR_TR_Route__c favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        EUR_TR_Account__c accountToFavoriteRoute = [
                SELECT Id
                FROM EUR_TR_Account__c
                WHERE EUR_TR_Channel__c = 'MOT'
                LIMIT 1
        ];

        List<EUR_TR_RouteDetail__c> routeDetails = new List<EUR_TR_RouteDetail__c>();
        EUR_TR_RouteDetail__c routeDetail1 = new EUR_TR_RouteDetail__c();
        routeDetail1.EUR_TR_RelatedAccount__c = accountToFavoriteRoute.Id;
        routeDetail1.EUR_TR_RelatedRoute__c = favoriteRoute.Id;
        routeDetail1.EUR_TR_VisitOrder__c = 1;
        routeDetails.add(routeDetail1);

        EUR_TR_RouteDetail__c routeDetail2 = new EUR_TR_RouteDetail__c();
        routeDetail2.EUR_TR_RelatedAccount__c = accountToFavoriteRoute.Id;
        routeDetail2.EUR_TR_RelatedRoute__c = favoriteRoute.Id;
        routeDetail2.EUR_TR_VisitOrder__c = 2;

        routeDetails.add(routeDetail2);
        insert routeDetails;
        Test.startTest();
        {
            EUR_TR_RouteController.UpdateFavoriteRouteDetailVisitOrder(JSON.serialize(routeDetails));
        }
        Test.stopTest();
    }

    private static EUR_TR_Route__c getFavoriteFilter() {
        return [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_RouteTemplate'
                LIMIT 1
        ];
    }


}