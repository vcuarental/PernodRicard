public class ChatterWallImageProxy {
    private string domain = 'eu1.salesforce.com';
    private PageReference page;
    private string session;
    private string result;
    private string imageId;
    private string mimeType;

    public ChatterWallImageProxy() {
        this.session = userInfo.getSessionId();
        this.page = ApexPages.currentPage();
        this.imageId = page.getParameters().get('id');
        this.mimeType = page.getParameters().get('mimeType');
    }
    
    public void retrieve() {
        http client = new http();
        httprequest request = new httprequest();
        request.setEndpoint('https://' + this.domain + '/services/data/v25.0/chatter/files/' + this.imageId + '/rendition?type=THUMB720BY480');
        request.setMethod('GET');
        request.setHeader('Authorization', 'OAuth ' + this.session);
        request.setTimeout(60000);
        httpresponse response = client.send(request);
        response.setHeader('Content-Type', this.mimeType);
        this.result = EncodingUtil.Base64Encode(response.getBodyAsBlob());
    }
    
    public string getResult() {
        return this.result;
    }
}