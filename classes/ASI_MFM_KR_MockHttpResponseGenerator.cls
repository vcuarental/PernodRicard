@isTest
global class ASI_MFM_KR_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "access_token": "abc" }');
        res.setStatusCode(200);
        return res;
    }
}