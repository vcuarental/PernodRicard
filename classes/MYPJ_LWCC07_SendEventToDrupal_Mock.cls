global with sharing class MYPJ_LWCC07_SendEventToDrupal_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest pRequest) {
        
        // Create a fake response
        HttpResponse vResponse = new HttpResponse();
        vResponse.setHeader('Content-Type', 'application/json');
        vResponse.setStatusCode(200);
        vResponse.setBody('{"langcode":"ja-jp","salesforce_id":"7019E000000n2yWQAQ","place_address":"9, rue Forest, Paris 75018","city":"Paris","booking_number":"","place_name":"Le Dernier Étage","end_date_and_time":"","title":"Experience in the cloud","start_date_and_time":"2020-06-10T05:45:00"}');

        return vResponse;
    }
}