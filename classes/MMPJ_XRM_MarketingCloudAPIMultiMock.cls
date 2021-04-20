public with sharing class MMPJ_XRM_MarketingCloudAPIMultiMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

	public MMPJ_XRM_MarketingCloudAPIMultiMock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpCalloutMock mock = requests.get(req.getEndpoint());
		if (mock != null) {
			return mock.respond(req);
		} else {
			throw new AuraException('Endpoint isn\'t defined... (endpoint="' + req.getEndpoint() + '")');
		}
    }
}