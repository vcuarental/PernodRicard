global class EUR_CRM_PIMIntegrationMockGenerator implements HttpCalloutMock {

    private static final String URL_BASE = 'https://assets.pernod-ricard.io/pim/production/v2/';
    
    global HTTPResponse respond(HTTPRequest req) {
//        System.assert(req.getEndpoint().containsIgnoreCase(URL_BASE));
//        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }

}