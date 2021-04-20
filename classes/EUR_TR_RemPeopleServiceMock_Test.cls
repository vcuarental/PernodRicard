/**
 * Created by osman on 21.10.2019.
 */
@IsTest
global class EUR_TR_RemPeopleServiceMock_Test implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest httpRequest) {

        String expectedURL = 'https://www.dummy-web-service.com/api/rempeopleservice';
        String actualURL = httpRequest.getEndpoint();
        System.assertEquals(expectedURL, actualURL);

        HttpResponse httpResponse = new HttpResponse();
        // JSON Response is prepared by response model
        String JSONBodString = '{\r\n    \"error\": \"\",\r\n    \"items\": [\r\n        {\r\n            \"companyCode\": \"85221\",\r\n            \"remId\": 564175,\r\n            \"bluepassScore\": 69.52,\r\n            \"completedDateTime\": \"2019-03-24T09:59:56+00:00\",\r\n            \"myWhiskeyScore\": 42.86,\r\n            \"myVodkaScore\": 96.8,\r\n            \"whiteCriteriaScore\": 0,\r\n            \"myTequilaScore\": 100,\r\n            \"placementScore\": 100,\r\n            \"passportAvailabilityScore\": 0,\r\n            \"photos\": [\r\n                \"DummyPhoto1\",\r\n                \"DummyPhoto2\",\r\n                \"DummyPhoto3\"\r\n            ]\r\n        }\r\n    ]\r\n}';
        httpResponse.setBody(JSONBodString);
        httpResponse.setStatusCode(200);
        return httpResponse;

    }

}