/**
 * Created by illia on 15.08.18.
 */

global with sharing class EUR_CRM_AmazonImagesMockGenerator implements HttpCalloutMock {

    private static final String URL_BASE = 'https://s3-eu-west-1.amazonaws.com/';

    global HTTPResponse respond(HTTPRequest req) {
        System.assert(req.getEndpoint().containsIgnoreCase(URL_BASE));
        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }

}