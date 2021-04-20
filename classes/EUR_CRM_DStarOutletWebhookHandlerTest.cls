/**
 * Created by Ilarion Tokarskyi on 20.01.2021.
 */

@IsTest
private class EUR_CRM_DStarOutletWebhookHandlerTest {
    @IsTest
    static void positiveTest() {
        RestContext.request = setPostRestRequest(createWebhookBody());
        RestContext.response = new RestResponse();
        Test.setMock(HttpCalloutMock.class, new DStarOutletHttpCalloutMock());
        Test.startTest();
        EUR_CRM_WebhookREST.handlePost();
        Test.stopTest();
    }

    @IsTest
    static void negativeTest() {
        RestContext.request = setPostRestRequest(createWebhookBody());
        RestContext.request.requestBody = Blob.valueOf('}}}');
        RestContext.response = new RestResponse();
        Test.startTest();
        EUR_CRM_WebhookREST.handlePost();
        Test.stopTest();
    }

    @IsTest
    static void webhookValidationTest() {
        RestContext.request = setPostRestRequest(createValidateBody());
        RestContext.response = new RestResponse();
        Test.startTest();
        EUR_CRM_WebhookREST.handlePost();
        Test.stopTest();
    }

    public class DStarOutletHttpCalloutMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBodyAsBlob(Blob.valueOf(createResponseBody()));
            response.setStatusCode(200);
            return response;
        }
    }

    private static RestRequest setPostRestRequest(String body) {
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(body);
        return request;
    }

    static String createWebhookBody() {
        return '{\n' +
                '\t\t"id": "1a853e40-fb43-4eea-ba73-902ea32bc7f0",\n' +
                '\t\t"subject": "DE.Outlet.Insert",\n' +
                '\t\t"data": {\n' +
                '\t\t  "ActionId": 1,\n' +
                '\t\t  "ActionName": "Insert",\n' +
                '\t\t  "EntityTypeId": 1,\n' +
                '\t\t  "SourceSystem": "DStar",\n' +
                '\t\t  "Affiliate": "DE",\n' +
                '\t\t  "EntityTypeName": "Outlet",\n' +
                '\t\t  "EntityId": "9843",\n' +
                '\t\t  "CreatedDate": "2020-12-16T08:27:30.803483Z",\n' +
                '\t\t  "UpdatedDate": "2020-12-16T08:27:30.803483Z"\n' +
                '\t\t},\n' +
                '\t\t"eventType": "Microsoft.Resources.ResourceActionSuccess",\n' +
                '\t\t"dataVersion": "1",\n' +
                '\t\t"metadataVersion": "1",\n' +
                '\t\t"eventTime": "2020-12-16T08:27:30.8347535Z",\n' +
                '\t\t"topic": "/subscriptions/0e95efb5-2252..."\n' +
                '\t  }';
    }
    static String createValidateBody() {
        return '[\n' +
                '  {\n' +
                '    "id": "2d1781af-3a4c-4d7c-bd0c-e34b19da4e66",\n' +
                '    "topic": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",\n' +
                '    "subject": "",\n' +
                '    "data": {\n' +
                '      "validationCode": "512d38b6-c7b8-40c8-89fe-f46f9e9622b6",\n' +
                '      "validationUrl": "https://rp-eastus2.eventgrid.azure.net:553/eventsubscriptions/estest/validate?id=512d38b6-c7b8-40c8-89fe-f46f9e9622b6&t=2018-04-26T20:30:54.4538837Z&apiVersion=2018-05-01-preview&token=1A1A1A1A"\n' +
                '    },\n' +
                '    "eventType": "Microsoft.EventGrid.SubscriptionValidationEvent",\n' +
                '    "eventTime": "2018-01-25T22:12:19.4556811Z",\n' +
                '    "metadataVersion": "1",\n' +
                '    "dataVersion": "1"\n' +
                '  }\n' +
                ']';
    }
    static String createResponseBody() {
        return '[\n' +
                '  {\n' +
                '    "outlet": {\n' +
                '      "outletExternalId": "0010Q000016vvPAQAY",\n' +
                '      "outletName": "FRANPRIX VOLTAIRE",\n' +
                '      "address": "17 rue de Montbéliard",\n' +
                '      "city": "PARIS",\n' +
                '      "zipCode": "75251",\n' +
                '      "bannerExternalId": "98984",\n' +
                '      "bannerName": "FRANPRIX",\n' +
                '      "outletLocalData": {},\n' +
                '      "outletAssortments": [\n' +
                '      {\n' +
                '        "product": {\n' +
                '          "productExternalId": "0010Q000016vvPAQAY",\n' +
                '          "ean": "40234567890123",\n' +
                '          "brandName": "Jameson",\n' +
                '          "productName": "Jameson Reserve 70 cl",\n' +
                '          "productQuality": "Jameson Select Reserve",\n' +
                '          "productQualitySize": "0.7",\n' +
                '          "productCategory": "Spirits"\n' +
                '        },\n' +
                '        "rank": 12,\n' +
                '        "mandatory": true,\n' +
                '        "outletAssortmentLocalData": {' +
                '           "categoryRankPr": "2",'+
                '           "categoryRank": "2",'+
                '           "stateRank": "2",'+
                '           "averageNumberOfFacings": "2",'+
                '           "presenceInSimilarStores": "2.2",'+
                '           "isHouseOfBrands": true,'+
                '           "productDropshippingStatus": "shipping"'+
                '           }\n' +
                '      }\n' +
                '    ],\n' +
                '    "outletOutOfStocks": [\n' +
                '      {\n' +
                '        "product": {\n' +
                '          "productExternalId": "DE706865",\n' +
                '          "ean": "40234567890123",\n' +
                '          "brandName": "Jameson",\n' +
                '          "productName": "Jameson Reserve 70 cl",\n' +
                '          "productQuality": "Jameson Select Reserve",\n' +
                '          "productQualitySize": "0.7",\n' +
                '          "productCategory": "Spirits"\n' +
                '        },\n' +
                '        "localData": {}\n' +
                '      }\n' +
                '    ]},\n' +
                '    "outletKpiLocalData": {"segmentation": {' +
                '       "financialCategory": "category",\n' +
                '       "environmentType": "category",\n' +
                '       "physicalInfo": "category",\n' +
                '       "dropshippingStatus": "category",\n' +
                '       "storeSize": "2",\n' +
                '       "annualTarget": "2",\n' +
                '       "currentVisitNumber": "2",\n' +
                '       "lastFacingNumber": "2",\n' +
                '       "sellOutPotentialFood": "2.2",\n' +
                '       "foodRatio": "2.2",\n' +
                '       "currentVisitTarget": "2.2"}}\n' +
                '  }\n' +
                ']';
    }
}