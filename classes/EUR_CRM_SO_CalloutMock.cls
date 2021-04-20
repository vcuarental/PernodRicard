/*
*    Description    :    Apex test class for EUR_CRM_SO_CalloutHelper
*
*    Version    Author    Date        Description
*    1.0        Sid       12/31/2015  Initial Draft
*/

@isTest
public class EUR_CRM_SO_CalloutMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest pObjRequest){
        
        HttpResponse oHttpResponse = new HttpResponse();
        oHttpResponse.setStatusCode(200);
        oHttpResponse.setStatus('OK');
        
        return oHttpResponse;
    }
}