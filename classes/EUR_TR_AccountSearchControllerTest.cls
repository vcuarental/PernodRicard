/**
 * Created by ali.kucuk@teknait.com on 9/11/2020.
 */

@IsTest
private class EUR_TR_AccountSearchControllerTest {

    @TestSetup
    public static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'Yıldız';
        account.EUR_TR_DistributorName__c = 'ANKA';
        account.EUR_TR_AccountCode__c = '76997';
        account.EUR_TR_Location__Latitude__s = 13.0429;
        account.EUR_TR_Location__Longitude__s = 80.2739;
        account.EUR_TR_SalesChiefName__c = 'Sales Chief Name';
        account.EUR_TR_AreaManagerName__c = 'Sales Manager Name';

        insert account;

        EUR_TR_RemPeople__c remPeople = new EUR_TR_RemPeople__c();
        remPeople.EUR_TR_RelatedAccount__c = account.Id;
        remPeople.EUR_TR_BluePassScore__c = 20;
        insert remPeople;

        EUR_TR_AccountSalesMAT__c accountSalesMAT = new EUR_TR_AccountSalesMAT__c();
        accountSalesMAT.EUR_TR_RelatedAccount__c = account.Id;
        accountSalesMAT.RecordTypeId = Schema.SObjectType.EUR_TR_AccountSalesMAT__c.getRecordTypeInfosByName().get('EUR_TR_AccountSalesMAT').getRecordTypeId();
        accountSalesMAT.EUR_TR_BrandQuality__c = 'Good';
        accountSalesMAT.EUR_TR_BrandQualitySize__c = '10';
        accountSalesMAT.EUR_TR_MAT1__c = 12;
        accountSalesMAT.EUR_TR_MAT2__c = 20;


        insert accountSalesMAT;

        EUR_TR_Route__c favoriteRoute = new EUR_TR_Route__c();
        favoriteRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Route__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRoute').getRecordTypeId();
        favoriteRoute.Name = 'Favori Rota';
        favoriteRoute.OwnerId = UserInfo.getUserId();
        insert favoriteRoute;

        EUR_TR_RouteDetail__c favoriteRouteDetail = new EUR_TR_RouteDetail__c();
        favoriteRouteDetail.RecordTypeId = Schema.SObjectType.EUR_TR_RouteDetail__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_FavoriteRouteDetail').getRecordTypeId();
        favoriteRouteDetail.EUR_TR_RelatedAccount__c = account.Id;
        favoriteRouteDetail.EUR_TR_RelatedRoute__c = favoriteRoute.Id;
        insert favoriteRouteDetail;

        DateTime now = Datetime.now();
        EUR_TR_Visit__c workedDay = new EUR_TR_Visit__c();
        workedDay.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_WorkedDay').getRecordTypeId();
        workedDay.EUR_TR_StartDateTime__c = now;
        workedDay.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        workedDay.OwnerId = UserInfo.getUserId();
        insert workedDay;

        EUR_TR_Visit__c visitInRoute = new EUR_TR_Visit__c();
        visitInRoute.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Visit').getRecordTypeId();
        visitInRoute.EUR_TR_RelatedWorkedDay__c = workedDay.Id;
        visitInRoute.EUR_TR_RelatedFavoriteRoute__c = favoriteRoute.Id;
        visitInRoute.EUR_TR_StartDateTime__c = now.addHours(3);
        visitInRoute.EUR_TR_VisitType__c = 'In-Route';
        visitInRoute.EUR_TR_RelatedAccount__c = account.Id;
        visitInRoute.OwnerId = UserInfo.getUserId();
        insert visitInRoute;

        EUR_TR_CrossCompliance__c crossCompliance = new EUR_TR_CrossCompliance__c();
        crossCompliance.EUR_TR_RelatedAccount__c = account.Id;
        crossCompliance.EUR_TR_AbsCross__c = true;
        crossCompliance.EUR_TR_BFWJWRL__c = true;
        crossCompliance.EUR_TR_CR12JD__c = true;
        crossCompliance.EUR_TR_PassBells__c = true;
        crossCompliance.EUR_TR_WyboCross__c = true;
        crossCompliance.EUR_TR_ExternalId__c = account.EUR_TR_AccountCode__c;
        insert crossCompliance;

        EUR_TR_Incentive__c incentive = new EUR_TR_Incentive__c();
        incentive.EUR_TR_RelatedAccount__c = account.Id;
        incentive.EUR_TR_Brand__c = 'JAMESON';
        incentive.EUR_TR_Description__c = 'JMS';
        incentive.EUR_TR_StartDate__c = Date.today();
        incentive.EUR_TR_EndDate__c = Date.today().addDays(3);
        insert incentive;


    }

    @IsTest
    static void test_searchAccounts() {

        String requestBody = '{"searchTerm":"Yıldız","types":["3YAYGIN DAĞILIM","4YEREL ZİNCİR","2HEDEFLİ"],"crossCompliance":["EUR_TR_CR12JD__c", "EUR_TR_BFWJWRL__c"],"classes":["Tanimsiz","MAVİ","ALTIN","BRONZ","GÜMÜŞ","Diğer","A"],"statuses":["Aktif","Pasif"],"distributors":["ESKİŞEHİR HALİL ENDERER","HALİL ENDERER","BERFİN TİCARET","BAYSAL MARMARİS"],"channels":["Off"],"cities":["ISTANBUL/ASYA","ISTANBUL/AVR"],"districts":["AVCILAR","BAGCILAR","BAHCELIEVLER","BAKIRKOY","BASAKSEHIR","BAYRAMPASA","BESIKTAS","BEYKOZ","BEYLIKDUZU","BEYOGLU","BÜYÜKÇEKMECE","EMINONU","ESENLER","ESENYURT"],"latitude":41.0193,"longitude":28.6564,"radiusKm":10,"outOfScope":true,"census":true,"productFilters":[{"matLast6":"MAT","existNonExists":["VAR-VAR","VAR-YOK","YOK-VAR","YOK-YOK"],"isIncentiveAccount":"Evet", "incentiveBrands":["JAMESON"],"period":"MAT","brands":["CHIVAS 12 YO","CHIVAS 18 YO","CHIVAS 25 YO","BALLANTINE\'S ULTRA PREMIUMS"],"skus":["CHIVAS 18 YO / 0.50 CL","CHIVAS 18 YO / 0.70 L","CHIVAS 25 YO / 0.70 L","CHIVAS EXTRA / 0,70 L"],"brandShareMin":0.01,"brandShareMax":9999999,"cluster":["- %21+","- %11-%20","- 0-%10","+ %11-%20","+ %21+"],"caseCluster":["- 11-20","<-21","0-10","11-20","+21","<-10"],"volumeMin":0,"volumeMax":999999,"invoiceStatus":"Son 3 Ay"}],"bluePassScoreMin":1,"bluePassScoreMax":100,"whiskeyScoreMin":1,"whiskeyScoreMax":100,"vodkaScoreMin":1,"vodkaScoreMax":100,"placementScoreMin":1,"placementScoreMax":100,"availabilityScoreMin":1,"availabilityScoreMax":100,"whiteCriteriaScoreMin":1,"whiteCriteriaScoreMax":100,"rangeCompliance":["%0-%20","%21-40","%41-60","%61-80","%81+"],"visitFrequency":["Bu Hafta","+1 hafta","+2 hafta","+3 hafta","+1 ay","+3 ay","+6 ay"],"orderBy":"location","orderDirection":"Ascending","recordCount":10,"exportData":false}';
        Test.startTest();
        EUR_TR_AccountSearchController.searchAccounts(requestBody);
        Test.stopTest();

    }

    @IsTest
    static void testSearchAccounts_routeAccounts() {

        String requestBody = '{"searchTerm":"Yıldız","recordCount":10,"exportData":false}';
        Test.startTest();
        {
            EUR_TR_AccountSearchController.searchAccounts(requestBody);
        }
        Test.stopTest();

    }

    @IsTest
    static void testOrderAccounts() {

        EUR_TR_AccountSearchController.AccountOrderRequest orderRequest = new EUR_TR_AccountSearchController.AccountOrderRequest();
        EUR_TR_Account__c account = [SELECT id FROM EUR_TR_Account__c LIMIT 1];
        orderRequest.accounts = new List<String>{
                account.Id
        };
        orderRequest.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.Name;
        orderRequest.orderDirection = EUR_TR_AccountSearchController.AccountSearchOrderDirection.ascending;

        Test.startTest();
        {
            EUR_TR_AccountSearchController.OrderAccounts(JSON.serialize(orderRequest));
            orderRequest.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.bluePassScore;
            EUR_TR_AccountSearchController.OrderAccounts(JSON.serialize(orderRequest));
            orderRequest.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.salesVolume;
            EUR_TR_AccountSearchController.OrderAccounts(JSON.serialize(orderRequest));
        }
        Test.stopTest();

    }

    @IsTest
    static void testSearchAccounts_orderBySalesVolume() {

        EUR_TR_AccountSearchController.AccountSearchRequest request = new EUR_TR_AccountSearchController.AccountSearchRequest();
        request.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.salesVolume;
        request.orderDirection = EUR_TR_AccountSearchController.AccountSearchOrderDirection.ascending;
        request.recordCount = 10;
        Test.startTest();
        EUR_TR_AccountSearchController.searchAccounts(JSON.serialize(request));
        Test.stopTest();

    }

    @IsTest
    static void testSearchAccounts_orderByGrowth() {

        EUR_TR_AccountSearchController.AccountSearchRequest request = new EUR_TR_AccountSearchController.AccountSearchRequest();
        request.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.growth;
        request.orderDirection = EUR_TR_AccountSearchController.AccountSearchOrderDirection.ascending;
        request.recordCount = 10;
        Test.startTest();
        EUR_TR_AccountSearchController.searchAccounts(JSON.serialize(request));
        Test.stopTest();

    }

    @IsTest
    static void testSearchAccounts_orderByBluePassScore() {

        EUR_TR_AccountSearchController.AccountSearchRequest request = new EUR_TR_AccountSearchController.AccountSearchRequest();
        request.orderBy = EUR_TR_AccountSearchController.AccountSearchOrderBy.bluePassScore;
        request.orderDirection = EUR_TR_AccountSearchController.AccountSearchOrderDirection.ascending;
        request.recordCount = 10;
        Test.startTest();
        EUR_TR_AccountSearchController.searchAccounts(JSON.serialize(request));
        Test.stopTest();

    }

    @IsTest
    static void testSearchAccounts_byFavouriteParams() {
        EUR_TR_AccountSearchController.AccountSearchRequest request = new EUR_TR_AccountSearchController.AccountSearchRequest();
        request.favouriteParams = '{"value":["1RAF ANLAŞMALI"],"key":"types"} ,{"key":"crossCompliance","value":["EUR_TR_CR12JD__c", "EUR_TR_BFWJWRL__c"]}, {"key":"classes","value":["MAVİ","ALTIN","BRONZ","GÜMÜŞ"]} , {"key":"distributors","value":["AKTAŞLAR","ANKA","AVRUPA SATIŞ","AYDA MESRUBAT GIDA IÇ.LTD. STI","AYDOGAR"]} , {"value":["ADANA","ADIYAMAN"],"key":"cities"} , {"key":"district","value":["ALADAG","CEYHAN","DÜZIÇI"]} , {"value":["MAT"],"key":"period"} , {"key":"brands","value":["ABSOLUT VODKA"]} , {"key":"sku","value":["ABSOLUT VODKA 100 CL"]} , {"key":"ranges","value":["P1","P2","S1"]} , {"value":["Son 12 Ay"],"key":"invoicestatus"} , {"key":"rangecompliance","value":["%0-%20","%21-40","%41-60"]} , {"key":"statuses","value":["Aktif","Pasif"]} , {"key":"location","value":true} , {"value":30.050819396972656,"key":"distance"},{"key":"latitude","value":"40.98096999999996"} , {"key":"longitude","value":"29.08932800000005"},{"key":"radiusKm","value":30.050819396972656},{"key":"incentiveBrands","value":["JAMESON"]},{"key":"isIncentiveAccount","value":"Evet"}';

        request.recordCount = 10;
        Test.startTest();
        EUR_TR_AccountSearchController.searchAccounts(JSON.serialize(request));
        Test.stopTest();
    }

}