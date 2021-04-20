@isTest
public with sharing class MMPJ_XRM_MarketingCloudAPIMock implements HttpCalloutMock {

	private final HttpResponse response;
    private HttpRequest request;

    public MMPJ_XRM_MarketingCloudAPIMock(HttpResponse response) {
        this.response = response;
    }



	public HttpResponse respond(HttpRequest request) {
        this.request = request;
        return response;
    }

}