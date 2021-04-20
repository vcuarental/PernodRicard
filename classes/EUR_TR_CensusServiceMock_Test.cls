/**
 * Created by osman on 21.10.2019.
 */

global class EUR_TR_CensusServiceMock_Test implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest httpRequest) {

        String expectedURL = 'https://www.dummy-web-service.com/api/CensusScores';
        String actualURL = httpRequest.getEndpoint();
        System.assertEquals(expectedURL, actualURL);

        HttpResponse httpResponse = new HttpResponse();
        // JSON Response is prepared by request model
        String JSONBodString = '{\r\n    \"error\": \"\",\r\n    \"items\": [\r\n        {\r\n            \"companyCode\": \"value1\",\r\n            \"name\": \"value2\",\r\n            \"nameOnBoard\": \"value1\",\r\n            \"lat\": 14.3,\r\n            \"lng\": 13.4,\r\n            \"channelName\": \"value1\",\r\n            \"distributionType\": \"value2\",\r\n            \"remId\": 12345,\r\n            \"censusScore\": 54.22,\r\n            \"completedDateTime\": \"2019-03-24T09:59:56+00:00\",\r\n            \"photos\": [\r\n                \"DummyPhoto1\",\r\n                \"DummyPhoto2\",\r\n                \"DummyPhoto3\"\r\n            ]\r\n        }\r\n    ]\r\n}';
        httpResponse.setBody(JSONBodString);
        httpResponse.setStatusCode(200);
        return httpResponse;

    }

}