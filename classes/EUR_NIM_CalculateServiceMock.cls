@isTest
global class EUR_NIM_CalculateServiceMock implements HttpCalloutMock 
{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) 
	{
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"salesorg":"1100","orderTotalPrice":2100,"lines":[{"quantity":10,"material":"10113050","netPrice":10,"itemTotalPrice":100}],"account":"29682"}');
        response.setStatusCode(200);
        return response;
    }
}