/**
 * Created by osman on 21.10.2019.
 */

global class EUR_TR_SMSServiceMock_Test implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest httpRequest) {

        String expectedURL = 'https://www.dummy-web-service.com/api/smsservice';
        String actualURL = httpRequest.getEndpoint();
        System.assert(actualURL.contains(expectedURL));

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(200);
        httpResponse.setHeader('Content-Type', 'text/xml');
        return httpResponse;

    }

}