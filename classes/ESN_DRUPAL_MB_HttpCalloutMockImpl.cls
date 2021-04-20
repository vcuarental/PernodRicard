public class ESN_DRUPAL_MB_HttpCalloutMockImpl implements HttpCalloutMock {

	public HttpResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
        System.debug('HTTPRequest req:' + req);
        System.debug('Endpoint:' + req.getEndPoint());

		res.setStatus('OK');
		res.setStatusCode(200);
		res.setHeader('Content-Type', 'image/jpg');
		res.setBody('https://mybrands.pernod-ricard.com/files/temporary/unmanaged/f676f218d99bb7b7daf6474969f49e70/private/styles/content_list/private/pr-media-browser/EOY15_Absolut_Electrik_GTR_Guideline.jpg');
 
        return res;
	}

}