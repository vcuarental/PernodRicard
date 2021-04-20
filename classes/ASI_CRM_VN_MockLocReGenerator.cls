@isTest
global class ASI_CRM_VN_MockLocReGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','text/xml');
        res.setBody('<GeocodeResponse>'
                       +'<status>OK</status>'
                        +'<result>'
                         +'<type>street_address</type>' 
                          +'<formatted_address>1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA</formatted_address>'
                          +'<address_component>'
                          +'<long_name>1600</long_name>' 
                          +'<short_name>1600</short_name>' 
                         +'<type>street_number</type>'  
                          +'</address_component>'
                         +'<address_component>' 
                          +'<long_name>Amphitheatre Pkwy</long_name>' 
                         +'<short_name>Amphitheatre Pkwy</short_name>'  
                         +'<type>route</type>'  
                         +'</address_component>' 
                         +'</result>'
                         +'</GeocodeResponse>');
        res.setStatusCode(200);
        return res;
    }
}