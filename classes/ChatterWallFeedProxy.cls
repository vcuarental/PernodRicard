public class ChatterWallFeedProxy {
    private string domain = 'eu1.salesforce.com';
    private PageReference page;
    private string session;
    private string result;
    private string groupId;

    public ChatterWallFeedProxy() {
        this.session = userInfo.getSessionId();
        this.page = ApexPages.currentPage();
        this.groupId = page.getParameters().get('id');
        if (groupId == null) this.groupId = userInfo.getUserId();
    }
    
    public void retrieve() {
        http client = new http();
        httprequest request = new httprequest();
        request.setEndpoint('https://' + this.domain + '/services/data/v25.0/chatter/feeds/record/' + this.groupId + '/feed-items/');
        request.setMethod('GET');
        request.setHeader('Authorization', 'OAuth ' + this.session);
        request.setTimeout(60000);
        httpresponse response = client.send(request);
        this.result = response.getBody();
    }
    
    public string getResult() {
        return this.result;    
    }
}