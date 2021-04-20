/**
 * Created by Ilarion Tokarskyi on 20.01.2021.
 */

@IsTest
private class EUR_CRM_DStarVisitWebhookHandlerTest {

    @IsTest
    static void positiveTest() {
        RestContext.request = setPostRestRequest(createWebhookBody());
        RestContext.response = new RestResponse();
        Test.setMock(HttpCalloutMock.class, new DStarVisitHttpCalloutMock());
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

    public class DStarVisitHttpCalloutMock implements HttpCalloutMock {

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
                '\t\t"subject": "DE.Visit.Bulk",\n' +
                '\t\t"data": {\n' +
                '\t\t  "ActionId": 1,\n' +
                '\t\t  "ActionName": "All",\n' +
                '\t\t  "EntityTypeId": 1,\n' +
                '\t\t  "SourceSystem": "DStar",\n' +
                '\t\t  "Affiliate": "DE",\t\t\t  \n' +
                '\t\t  "EntityTypeName": "Visit",\n' +
                '\t\t  "EntityId": null,\n' +
                '\t\t  "CreatedDate": "2020-12-16T08:27:30.803483Z",\n' +
                '\t\t  "UpdatedDate": "2020-12-16T08:27:30.803483Z"\n' +
                '\t\t},\n' +
                '\t\t"eventType": "Microsoft.Resources.ResourceActionSuccess",\n' +
                '\t\t"dataVersion": "1",\n' +
                '\t\t"metadataVersion": "1",\n' +
                '\t\t"eventTime": "2020-12-16T08:27:30.8347535Z",\n' +
                '\t\t"topic": "/subscriptions/0e95efb5..."\n' +
                '\t  }';
    }
    static String createResponseBody() {
        return '[\n' +
                '  {\n' +
                '    "visitInternalId": "125487",\n' +
                '    "weekStartDate": "2020/12/07",\n' +
                '    "visitType": "promotion_preparation",\n' +
                '    "visitRank": "4",\n' +
                '    "promotionLocalData": {"promotionScore": "0.5"},\n' +
                '    "outlet": {\n' +
                '      "outletExternalId": "0010Q000016vvPAQAY",\n' +
                '      "outletName": "FRANPRIX VOLTAIRE",\n' +
                '      "address": "17 rue de Montbéliard",\n' +
                '      "city": "PARIS",\n' +
                '      "zipCode": "75251",\n' +
                '      "bannerExternalId": "98984",\n' +
                '      "bannerName": "FRANPRIX",\n' +
                '      "outletLocalData": {}\n' +
                '    },\n' +
                '    "lastVisitDate": "2019-04-02",\n' +
                '    "salesRepresentant": {\n' +
                '      "salesRepresentantExternalId": "39885764-5717-4562-b314-28963466afa6",\n' +
                '      "salesRepresentantName": "Jean DUPONT",\n' +
                '      "salesRepresentantLocalData": {}\n' +
                '    },\n' +
                '    "promotions": [\n' +
                '      {\n' +
                '        "promotionExternalId": "FR-8785",\n' +
                '        "promotionName": "Noël en fête",\n' +
                '        "startDate": "2020-12-08",\n' +
                '        "endDate": "2020-12-24",\n' +
                '        "preparationStartDate": "2020-11-25",\n' +
                '        "preparationEndDate": "2020-12-06",\n' +
                '        "recommendedProduct": [\n' +
                '          {\n' +
                '            "product": {\n' +
                '              "productExternalId": "0010Q000016vvPAQAY",\n' +
                '              "ean": "40234567890123",\n' +
                '              "brandName": "Jameson",\n' +
                '              "productName": "Jameson Reserve 70 cl",\n' +
                '              "productQuality": "Jameson Select Reserve",\n' +
                '              "productQualitySize": "0.7",\n' +
                '              "productCategory": "Spirits"\n' +
                '            },\n' +
                '            "score": "45",\n' +
                '            "recommendedProductLocalData": {}\n' +
                '          }\n' +
                '        ]\n' +
                '      }\n' +
                '    ],\n' +
                '    "perfectStoreData": {"totalScore": "0.5"},\n' +
                '    "visitLocalData": {}\n' +
                '  }\n' +
                ']';
    }
}