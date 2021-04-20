/**
 * Created by osman on 10.11.2020.
 */

public with sharing class EUR_TR_RouteController {

    public class EUR_TR_RouteControllerException extends Exception {

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse createFavoriteRouteByFavoriteFilterFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Route__c route = (EUR_TR_Route__c) JSON.deserialize(requestBody, EUR_TR_Route__c.class);
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = createFavoriteRouteByFavoriteFilter(route);
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getFavoriteRoutesFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;
        try {
            serviceResponse.ExtensionData = getFavoriteRoutes();
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse deleteFavoriteRouteByIdFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Route__c favoriteRoute = (EUR_TR_Route__c) JSON.deserialize(requestBody, EUR_TR_Route__c.class);
        serviceResponse.Code = 1;
        try {
            deleteFavoriteRouteById(favoriteRoute);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse updateFavoriteRouteByIdFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Route__c favoriteRoute = (EUR_TR_Route__c) JSON.deserialize(requestBody, EUR_TR_Route__c.class);
        serviceResponse.Code = 1;
        try {
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = updateFavoriteRouteById(favoriteRoute);
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse addAccountToFavoriteRouteFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_RouteDetail__c favoriteRouteDetail = (EUR_TR_RouteDetail__c) JSON.deserialize(requestBody, EUR_TR_RouteDetail__c.class);
        serviceResponse.Code = 1;
        try {
            addAccountToFavoriteRoute(favoriteRouteDetail);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = null;
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse deleteAccountFromFavoriteRouteFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_RouteDetail__c favoriteRouteDetail = (EUR_TR_RouteDetail__c) JSON.deserialize(requestBody, EUR_TR_RouteDetail__c.class);
        serviceResponse.Code = 1;
        try {
            deleteAccountFromFavoriteRoute(favoriteRouteDetail);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse createFavoriteRouteFromMiddleware(String requestBody) {

        Savepoint savepoint = Database.setSavepoint();
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Route__c favoriteRoute = (EUR_TR_Route__c) JSON.deserialize(requestBody, EUR_TR_Route__c.class);
        serviceResponse.Code = 1;
        try {
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = createFavoriteRoute(favoriteRoute);
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getAccountsByFavoriteRouteFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Route__c favoriteRoute = (EUR_TR_Route__c) JSON.deserialize(requestBody, EUR_TR_Route__c.class);
        serviceResponse.Code = 1;
        try {
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getAccountsByFavoriteRoute(favoriteRoute);
        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse startRouteFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Route__c favoriteRoute = (EUR_TR_Route__c) JSON.deserialize(requestBody, EUR_TR_Route__c.class);
        serviceResponse.Code = 1;
        Savepoint savepoint = Database.setSavepoint();
        try {
            createVisitsByFavoriteRoute(favoriteRoute);
            serviceResponse.Message = 'Rota Oluşturuldu.';
        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }

    public static void deleteAccountFromFavoriteRoute(EUR_TR_RouteDetail__c favoriteRouteDetail) {

        if (favoriteRouteDetail == null) {
            throw new EUR_TR_RouteControllerException('Favori rota detayı boş olamaz');
        } else if (String.isBlank(favoriteRouteDetail.EUR_TR_RelatedRoute__c) || String.isBlank(favoriteRouteDetail.EUR_TR_RelatedAccount__c)) {
            throw new EUR_TR_RouteControllerException('Favori rota ve müşteri bilgisi boş olamaz');
        }

        System.debug(favoriteRouteDetail);

        Map<Id, EUR_TR_RouteDetail__c> accountToRouteDetailMap = new Map<Id, EUR_TR_RouteDetail__c>();

        List<EUR_TR_RouteDetail__c> routeDetails = [
                SELECT Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_RouteDetail__c
                WHERE EUR_TR_RelatedRoute__c = :favoriteRouteDetail.EUR_TR_RelatedRoute__c
        ];


        for (EUR_TR_RouteDetail__c routeDetail : routeDetails) {
            if (routeDetail.EUR_TR_RelatedAccount__c != null) {
                accountToRouteDetailMap.put(routeDetail.EUR_TR_RelatedAccount__c, routeDetail);
            }
        }

        if (!accountToRouteDetailMap.keySet().contains(favoriteRouteDetail.EUR_TR_RelatedAccount__c)) {
            throw new EUR_TR_RouteControllerException('Seçilen nokta favori rota içinde bulunamadı');
        }

        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();

        if (currentWorkedDay != null && currentWorkedDay.EUR_TR_RelatedFavoriteRoute__c == favoriteRouteDetail.EUR_TR_RelatedRoute__c) {
            throw new EUR_TR_RouteControllerException('Rota başladıktan sonra düzenleme yapılamaz.');
        }

        EUR_TR_RouteDetail__c foundRouteDetail = accountToRouteDetailMap.get(favoriteRouteDetail.EUR_TR_RelatedAccount__c);
        delete foundRouteDetail;

    }

    public static void addAccountToFavoriteRoute(EUR_TR_RouteDetail__c favoriteRouteDetail) {

        if (favoriteRouteDetail == null) {
            throw new EUR_TR_RouteControllerException('Favori rota detayı boş olamaz');
        } else if (String.isBlank(favoriteRouteDetail.EUR_TR_RelatedRoute__c) || String.isBlank(favoriteRouteDetail.EUR_TR_RelatedAccount__c)) {
            throw new EUR_TR_RouteControllerException('Favori rota ve müşteri bilgisi boş olamaz');
        }

        System.debug(favoriteRouteDetail);

        List<EUR_TR_RouteDetail__c> routeDetails = [
                SELECT Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_RouteDetail__c
                WHERE EUR_TR_RelatedRoute__c = :favoriteRouteDetail.EUR_TR_RelatedRoute__c
        ];

        Set<Id> accountIds = new Set<Id>();
        for (EUR_TR_RouteDetail__c routeDetail : routeDetails) {
            if (routeDetail.EUR_TR_RelatedAccount__c != null) {
                accountIds.add(routeDetail.EUR_TR_RelatedAccount__c);
            }
        }

        if (accountIds.contains(favoriteRouteDetail.EUR_TR_RelatedAccount__c)) {
            throw new EUR_TR_RouteControllerException('Listede olan nokta tekrar eklenemez');
        }

        EUR_TR_Definition__c workedDayDefinition = EUR_TR_WorkedDayController.getWorkedDayDefinition();
        if (accountIds.size() + 1 > workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c) {
            throw new EUR_TR_RouteControllerException(String.format('Rota Listesine en fazla {0} nokta eklenebilmektedir. Lütfen kontrol ediniz.', new List<String>{
                    String.valueOf(workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c)
            }));
        }

        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();
        if (currentWorkedDay != null && currentWorkedDay.EUR_TR_RelatedFavoriteRoute__c == favoriteRouteDetail.EUR_TR_RelatedRoute__c) {
            throw new EUR_TR_RouteControllerException('Rota başladıktan sonra düzenleme yapılamaz');
        }

        Id favoriteRouteDetailRecordTypeId = Schema.SObjectType.EUR_TR_RouteDetail__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRouteDetail').getRecordTypeId();
        favoriteRouteDetail.RecordTypeId = favoriteRouteDetailRecordTypeId;
        insert favoriteRouteDetail;

    }


    public static void deleteFavoriteRouteById(EUR_TR_Route__c favoriteRoute) {

        if (favoriteRoute == null) {
            throw new EUR_TR_RouteControllerException('Favori rota boş olamaz');
        } else if (String.isBlank(favoriteRoute.Id)) {
            throw new EUR_TR_RouteControllerException('Favori rota Id boş olamaz. ');
        }

        favoriteRoute = [
                SELECT Id, (SELECT Id,EUR_TR_RelatedAccount__c FROM EUR_TR_Route_Detail__r)
                FROM EUR_TR_Route__c
                WHERE Id = :favoriteRoute.Id AND
                OwnerId = :UserInfo.getUserId() AND RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

        List<EUR_TR_RouteDetail__c> routeDetails = favoriteRoute.EUR_TR_Route_Detail__r;
        Set<Id> routeAccountIds = new Set<Id>();
        if (!routeDetails.isEmpty()) {
            for (EUR_TR_RouteDetail__c routeDetail : routeDetails) {
                if (routeDetail.EUR_TR_RelatedAccount__c != null) {
                    routeAccountIds.add(routeDetail.EUR_TR_RelatedAccount__c);
                }
            }
        }

        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();

        if (currentWorkedDay != null && currentWorkedDay.EUR_TR_RelatedFavoriteRoute__c == favoriteRoute.Id) {
            throw new EUR_TR_RouteControllerException('Rota başladıktan sonra düzenleme yapılamaz');
        } else {
            delete favoriteRoute;
        }


    }

    public static EUR_TR_Route__c updateFavoriteRouteById(EUR_TR_Route__c favoriteRoute) {

        if (favoriteRoute == null) {
            throw new EUR_TR_RouteControllerException('Favori rota boş olamaz');
        } else if (String.isBlank(favoriteRoute.Id)) {
            throw new EUR_TR_RouteControllerException('Favori rota Id boş olamaz. ');
        }

        List<EUR_TR_Route__c> foundRoute = [
                SELECT Id,Name
                FROM EUR_TR_Route__c
                WHERE Id = :favoriteRoute.Id AND RecordType.DeveloperName = 'EUR_TR_FavoriteRoute' AND OwnerId = :UserInfo.getUserId()
                LIMIT 1
        ];

        if (String.isNotBlank(favoriteRoute.Name)) {
            foundRoute[0].Name = favoriteRoute.Name;
            update foundRoute;
        }

        return [
                SELECT Id,Name
                FROM EUR_TR_Route__c
                WHERE Id = :foundRoute[0].Id AND OwnerId = :UserInfo.getUserId() AND RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

    }

    public static EUR_TR_Route__c createFavoriteRoute(EUR_TR_Route__c favoriteRoute) {

        if (favoriteRoute == null) {
            throw new EUR_TR_RouteControllerException('Favori rota boş olamaz');
        } else if (String.isBlank(favoriteRoute.Name)) {
            throw new EUR_TR_RouteControllerException('Favori rota ismi boş bırakılamaz.');
        }

        if (String.isNotBlank(favoriteRoute.Name)) {
            favoriteRoute.OwnerId = UserInfo.getUserId();
            favoriteRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Route__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRoute').getRecordTypeId();
            insert favoriteRoute;
        }

        return [
                SELECT Id,Name
                FROM EUR_TR_Route__c
                WHERE Id = :favoriteRoute.Id AND OwnerId = :UserInfo.getUserId() AND RecordType.DeveloperName = 'EUR_TR_FavoriteRoute'
                LIMIT 1
        ];

    }

    public static Boolean checkIsDayStarted() {
        Boolean isDayStarted = true;
        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();
        if (currentWorkedDay == null) {
            isDayStarted = false;
        }
        return isDayStarted;
    }


    public static List<EUR_TR_RouteDetail__c> getAccountsByFavoriteRoute(EUR_TR_Route__c favoriteRoute) {

        if (String.isBlank(favoriteRoute.Id)) {
            throw new EUR_TR_RouteControllerException('Favori rota bilgisi boş gönderilemez.');
        }

        List<EUR_TR_RouteDetail__c> favoriteRouteDetails = [
                SELECT Id, EUR_TR_RelatedAccount__c, EUR_TR_RelatedAccount__r.Name,
                        EUR_TR_RelatedAccount__r.EUR_TR_Location__Latitude__s,
                        EUR_TR_RelatedAccount__r.EUR_TR_Location__Longitude__s, EUR_TR_VisitOrder__c,
                        EUR_TR_IsVisitedInToday__c, EUR_TR_VisitDateTime__c,
                        EUR_TR_RelatedAccount__r.EUR_TR_MATCY__c, EUR_TR_RelatedAccount__r.EUR_TR_MATLY__c,
                        EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c, EUR_TR_RelatedAccount__r.EUR_TR_FavoriteCount__c,
                        EUR_TR_RelatedAccount__r.EUR_TR_LastVisitedDate__c
                FROM EUR_TR_RouteDetail__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRouteDetail'
                AND EUR_TR_RelatedRoute__r.Owner.Id = :UserInfo.getUserId()
                AND EUR_TR_RelatedRoute__c = :favoriteRoute.Id
                ORDER BY EUR_TR_VisitOrder__c
        ];

        Set<Id> accountIds = new Set<Id>();
        for (EUR_TR_RouteDetail__c favoriteRouteDetail : favoriteRouteDetails) {
            if (favoriteRouteDetail.EUR_TR_RelatedAccount__c != null) {
                accountIds.add(favoriteRouteDetail.EUR_TR_RelatedAccount__c);
            }
        }

        Id currentUser = UserInfo.getUserId();
        String querySelect = 'SELECT ' +
                'Id, ' +
                'EUR_TR_MATCY__c, ' +
                'EUR_TR_MATLY__c, ' +
                'EUR_TR_LastVisitedDate__c, ' +
                'EUR_TR_FavoriteCount__c, ' +
                '(SELECT EUR_TR_StartDateTime__c FROM EUR_TR_Visits__r WHERE OwnerId = :currentUser order by EUR_TR_StartDateTime__c DESC LIMIT 1), ' +
                '(SELECT Id FROM EUR_TR_Route_Detail__r WHERE EUR_TR_RelatedRoute__r.OwnerId = :currentUser AND EUR_TR_RelatedRoute__r.EUR_TR_IsFavorite__c=TRUE)';
        String queryFrom = 'FROM EUR_TR_Account__c';
        String queryWhere = 'Where Id IN :accountIds';

        String query = String.format('{0} {1} {2}', new List<String>{
                querySelect,
                queryFrom,
                queryWhere
        });

        List<EUR_TR_Account__c> accounts = Database.query(query);

        Map<Id, AggregateResult> totalSalesMap = new Map<Id, AggregateResult>();
        String aggregateResultQuery =
                'SELECT EUR_TR_RelatedAccount__c, SUM(EUR_TR_MAT1__c) mat1, SUM(EUR_TR_MAT2__c) mat2 ' +
                        'FROM EUR_TR_AccountSalesMAT__c ' +
                        'WHERE EUR_TR_RelatedAccount__c IN :accountIds ' +
                        'GROUP BY EUR_TR_RelatedAccount__c';

        List<SObject> results = Database.query(aggregateResultQuery);
        for (SObject record : results) {
            Id relatedAccount = String.valueOf(record.get('EUR_TR_RelatedAccount__c'));
            if (!totalSalesMap.containsKey(relatedAccount)) {
                totalSalesMap.put(relatedAccount, (AggregateResult) record);
            }
        }

        Map<Id, EUR_TR_Account__c> accountMap = new Map<Id, EUR_TR_Account__c>();

        for (EUR_TR_Account__c account : accounts) {
            Decimal cy = 0;
            Decimal ly = 0;

            if (totalSalesMap.get(account.Id) != null) {
                cy = Decimal.valueOf(String.valueOf(totalSalesMap.get(account.Id).get('mat1')));
                ly = Decimal.valueOf(String.valueOf(totalSalesMap.get(account.Id).get('mat2')));
            }

            account.EUR_TR_MATCY__c = cy;
            account.EUR_TR_MATLY__c = ly;

            if (account.EUR_TR_Visits__r != null) {
                List<EUR_TR_Visit__c> visits = account.EUR_TR_Visits__r;
                if (visits.size() > 0) {
                    account.EUR_TR_LastVisitedDate__c = visits[0].EUR_TR_StartDateTime__c;
                } else {
                    account.EUR_TR_LastVisitedDate__c = null;
                }
            } else {
                account.EUR_TR_LastVisitedDate__c = null;
            }

            if (account.EUR_TR_Route_Detail__r != null) {
                List<EUR_TR_RouteDetail__c> favorites = account.EUR_TR_Route_Detail__r;
                account.EUR_TR_FavoriteCount__c = favorites.size();
            } else {
                account.EUR_TR_FavoriteCount__c = 0;
            }

            if (!accountMap.containsKey(account.Id)) {
                accountMap.put(account.Id, account);
            }
        }

        for (EUR_TR_RouteDetail__c favoriteRouteDetail : favoriteRouteDetails) {
            if (accountMap.containsKey(favoriteRouteDetail.EUR_TR_RelatedAccount__c)) {
                favoriteRouteDetail.EUR_TR_RelatedAccount__r.EUR_TR_MATCY__c = accountMap.get(favoriteRouteDetail.EUR_TR_RelatedAccount__c).EUR_TR_MATCY__c;
                favoriteRouteDetail.EUR_TR_RelatedAccount__r.EUR_TR_MATLY__c = accountMap.get(favoriteRouteDetail.EUR_TR_RelatedAccount__c).EUR_TR_MATLY__c;
                favoriteRouteDetail.EUR_TR_RelatedAccount__r.EUR_TR_FavoriteCount__c = accountMap.get(favoriteRouteDetail.EUR_TR_RelatedAccount__c).EUR_TR_FavoriteCount__c;
                favoriteRouteDetail.EUR_TR_RelatedAccount__r.EUR_TR_LastVisitedDate__c = accountMap.get(favoriteRouteDetail.EUR_TR_RelatedAccount__c).EUR_TR_LastVisitedDate__c;
            }
        }

        return favoriteRouteDetails;

    }

    public static EUR_TR_Route__c createFavoriteRouteByFavoriteFilter(EUR_TR_Route__c favoriteFilter) {

        if (favoriteFilter == null) {
            throw new EUR_TR_RouteControllerException('Favori filtresi boş gönderilemez.');
        } else if (String.isBlank(favoriteFilter.Id)) {
            throw new EUR_TR_RouteControllerException('Favori filtre Id bilgisi boş gönderilemez');
        }

        favoriteFilter = [SELECT Id,Name,EUR_TR_SelectedFilters__c FROM EUR_TR_Route__c WHERE Id = :favoriteFilter.Id];
        if (String.isBlank(favoriteFilter.EUR_TR_SelectedFilters__c)) {
            throw new EUR_TR_RouteControllerException('Seçilen favori filtre bulunamadı');
        }

        EUR_TR_AccountSearchController.AccountSearchRequest searchRequest = new EUR_TR_AccountSearchController.AccountSearchRequest();
        searchRequest.favouriteParams = favoriteFilter.EUR_TR_SelectedFilters__c;
        searchRequest.recordCount = 2000;

        EUR_TR_AccountSearchController.AccountSearchResponse searchResponse = EUR_TR_AccountSearchController.searchAccounts(searchRequest);
        List<EUR_TR_Account__c> accounts = searchResponse.accounts;

        EUR_TR_Definition__c workedDayDefinition = EUR_TR_WorkedDayController.getWorkedDayDefinition();

        if (accounts.size() > workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c) {
            throw new EUR_TR_RouteControllerException(String.format('' +
                    'Seçiminizde {0} nokta bulunmaktadır. Rota olarak kaydedebilmeniz için maksimum {1} nokta olmalıdır. ', new List<String>{
                    String.valueOf(accounts.size()), String.valueOf(workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c)
            }));
        }

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();
        favoriteRoute.Name = favoriteFilter.Name;
        favoriteRoute.EUR_TR_RelatedFavoriteFilter__c = favoriteFilter.Id;
        favoriteRoute.OwnerId = UserInfo.getUserId();
        favoriteRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Route__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRoute').getRecordTypeId();
        insert favoriteRoute;

        Id favoriteRouteDetailRecordTypeId = Schema.SObjectType.EUR_TR_RouteDetail__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRouteDetail').getRecordTypeId();
        EUR_TR_RouteDetail__c favoriteRouteDetail = new EUR_TR_RouteDetail__c();
        List<EUR_TR_RouteDetail__c> favoriteRouteDetails = new List<EUR_TR_RouteDetail__c>();
        for (EUR_TR_Account__c account : accounts) {
            favoriteRouteDetail = new EUR_TR_RouteDetail__c();
            favoriteRouteDetail.EUR_TR_RelatedAccount__c = account.Id;
            favoriteRouteDetail.EUR_TR_RelatedRoute__c = favoriteRoute.Id;
            favoriteRouteDetail.RecordTypeId = favoriteRouteDetailRecordTypeId;
            favoriteRouteDetails.add(favoriteRouteDetail);
        }
        if (!favoriteRouteDetails.isEmpty()) {
            insert favoriteRouteDetails;
        }

        return [
                SELECT Id,Name
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute' AND Id = :favoriteRoute.Id AND OwnerId = :UserInfo.getUserId()
        ];

    }

    public static void createVisitsByFavoriteRoute(EUR_TR_Route__c favoriteRoute) {

        if (String.isBlank(favoriteRoute.Id)) {
            throw new EUR_TR_RouteControllerException('Favori rota Id bilgisi boş gönderilemez');
        }

        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();

        if (currentWorkedDay == null) {
            //throw new EUR_TR_RouteControllerException('Lütfen rota başlatınız');
            EUR_TR_WorkedDayController.startDay();
            currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();
        }
        currentWorkedDay.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        update currentWorkedDay;

        favoriteRoute = [
                SELECT Id
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute' AND OwnerId = :UserInfo.getUserId() AND Id = :favoriteRoute.Id
                LIMIT 1
        ];

        List<EUR_TR_RouteDetail__c> favoriteRouteDetails = [
                SELECT Id,EUR_TR_RelatedAccount__c
                FROM EUR_TR_RouteDetail__c
                WHERE EUR_TR_RelatedRoute__c = :favoriteRoute.Id AND EUR_TR_RelatedAccount__c != NULL
        ];

        Set<Id> favoriteRouteAccountSet = new Set<Id>();
        for (EUR_TR_RouteDetail__c routeDetail : favoriteRouteDetails) {
            favoriteRouteAccountSet.add(routeDetail.EUR_TR_RelatedAccount__c);
        }

        if (favoriteRouteAccountSet.isEmpty()) {
            throw new EUR_TR_RouteControllerException('Rota başlatmak için en az 1 nokta seçilmelidir');
        }

        EUR_TR_Definition__c workedDayDefinition = EUR_TR_WorkedDayController.getWorkedDayDefinition();

        if (favoriteRouteAccountSet.size() > workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c) {
            throw new EUR_TR_RouteControllerException(String.format('' +
                    'Favori Rota Listesi  maksimum {0} nokta olacak şekilde kaydedilebilmektedir. Lütfen kontrol ediniz', new List<String>{
                    String.valueOf(workedDayDefinition.EUR_TR_MaxVisitableAccountNumber__c)
            }));
        }

        List<EUR_TR_Visit__c> visits = new List<EUR_TR_Visit__c>();
        EUR_TR_Visit__c visit = new EUR_TR_Visit__c();
        Id visitRecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Visit').getRecordTypeId();
        for (Id accountId : favoriteRouteAccountSet) {
            visit = new EUR_TR_Visit__c();
            visit.RecordTypeId = visitRecordTypeId;
            visit.EUR_TR_RelatedAccount__c = accountId;
            visit.EUR_TR_VisitType__c = 'In-Route';
            visit.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
            visit.EUR_TR_RelatedWorkedDay__c = currentWorkedDay.Id;
            visits.add(visit);
        }

        if (!visits.isEmpty()) {
            insert visits;
        }

    }

    public static List<FavoriteRouteWrapper> getFavoriteRoutes() {

        List<EUR_TR_Route__c> favoriteRoutes = [
                SELECT Id,Name
                FROM EUR_TR_Route__c
                WHERE RecordType.DeveloperName = 'EUR_TR_FavoriteRoute' AND OwnerId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
                LIMIT 2000
        ];

        EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();
        Id startedFavoriteRoute = null;
        if (currentWorkedDay != null) {
            startedFavoriteRoute = currentWorkedDay.EUR_TR_RelatedFavoriteRoute__c;
        }

        List<FavoriteRouteWrapper> favoriteRouteWrappers = new List<FavoriteRouteWrapper>();
        FavoriteRouteWrapper wrapper = new FavoriteRouteWrapper();

        for (EUR_TR_Route__c favoriteRoute : favoriteRoutes) {
            wrapper = new FavoriteRouteWrapper();
            if (startedFavoriteRoute != null && favoriteRoute.Id == startedFavoriteRoute) {
                wrapper.isStartedRoute = true;
            } else {
                wrapper.isStartedRoute = false;
            }
            wrapper.favoriteRoute = favoriteRoute;
            favoriteRouteWrappers.add(wrapper);
        }

        return favoriteRouteWrappers;

    }

    public static void deleteNotStartedRouteVisits(Set<Id> workedDayIds) {
        List<EUR_TR_Visit__c> notStartedRouteVisits = [
                SELECT Id
                FROM EUR_TR_Visit__c
                WHERE RecordType.DeveloperName = 'EUR_TR_Visit' AND EUR_TR_RelatedWorkedDay__c != NULL
                AND EUR_TR_StartDateTime__c = NULL AND EUR_TR_EndDateTime__c = NULL AND EUR_TR_RelatedWorkedDay__c IN :workedDayIds
                AND EUR_TR_RelatedWorkedDay__r.EUR_TR_EndDateTime__c != NULL AND EUR_TR_VisitType__c = 'In-Route'
        ];
        if (!notStartedRouteVisits.isEmpty()) {
            delete notStartedRouteVisits;
        }
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse UpdateFavoriteRouteDetailVisitOrder(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        List<EUR_TR_RouteDetail__c> RouteDetails = (List<EUR_TR_RouteDetail__c>) JSON.deserialize(requestBody, List<EUR_TR_RouteDetail__c>.class);
        serviceResponse.Code = 1;

        for (EUR_TR_RouteDetail__c route : RouteDetails) {
            if (String.isBlank(route.Id)) {
                throw new EUR_TR_RouteControllerException('Favori rota bilgisi boş gönderilemez.');
            } else if (route.EUR_TR_VisitOrder__c < 0) {
                throw new EUR_TR_RouteControllerException('Ziyaret sırası değeri değeri hatalı: ' + route.EUR_TR_VisitOrder__c);
            }
        }
        try {
            update RouteDetails;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = RouteDetails;
        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }
        return serviceResponse;
    }

    class FavoriteRouteWrapper {
        public EUR_TR_Route__c favoriteRoute { get; set; }
        public Boolean isStartedRoute { get; set; }
    }

}