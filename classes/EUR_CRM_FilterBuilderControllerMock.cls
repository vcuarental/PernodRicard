/**
 * Created by illia on 16.08.18.
 */

@IsTest
global class EUR_CRM_FilterBuilderControllerMock implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
        '"controllerValues" : { }, ' +
            '"defaultValue" : {'+
                '"attributes" : null,'+
                '"label" : "OFF TRADE",'+
                '"validFor" : [ ],'+
                '"value" : "OFF TRADE"'+
                '},'+
            '"eTag" : "8ec4c08a30b80d764db96ba0c24b6a6e",'+
            '"url" : "http://example.com/example/test",'+
            '"values" : [ {'+
                '"attributes" : null,'+
                '"label" : "OFF TRADE",'+
                '"validFor" : [ ],'+
                '"value" : "OFF TRADE"'+
                '} ]'+
                '}');
        res.setStatusCode(200);
        return res;
    }

}