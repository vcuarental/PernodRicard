public class RSS_CA{
    public static String errorMsg {get; private set;}
    //empty constructor
    public RSS_CA(){}
    
    //gets the data from the provided RSS feedURL
    public static RSSChannel_CA getRSSData(string feedURL) {
        try{
            Http h = new Http();
            HttpRequest req = buildWebServiceRequest(feedURL);
            HttpResponse res = invokeWebService(h, req);
            RSSChannel_CA result = new RSSChannel_CA();
            result = handleWebServiceResponse(res);
            return result;
         }catch(CalloutException e){
            System.debug(e.getMessage());
            errorMsg = 'An error occurred. Unable to display feed at this time. Please reload the page or try again later';
            return null;
         }  
    }
    
    //build the web service request and related data
    public static HttpRequest buildWebServiceRequest(String feedURL){
        try{
            HttpRequest req = new HttpRequest();
            req.setTimeout(15000);
            req.setEndpoint(feedURL);
            req.setMethod('GET');
            return req;
        }catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = 'An error occurred. Unable to display feed at this time. Please reload the page or try again later';
            return null;
        }
    }
    
    //invokes the webservice
    public static HttpResponse invokeWebService(Http h, HttpRequest req){
        try{
            HttpResponse res = h.send(req);
            return res;
        }catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = 'An error occurred. Unable to display feed at this time. Please reload the page or try again later';
            return null;
        }
    }
    
    //handle the HTTP Response
    public static RSSChannel_CA handleWebServiceResponse(HttpResponse res){
        try{
            Dom.Document doc = new Dom.Document();
            doc = res.getBodyDocument();
            
            Dom.XMLNode rss = doc.getRootElement();
            //first child element of rss feed is always channel
            Dom.XMLNode channel = rss.getChildElements()[0];
            
            RSSChannel_CA result = new RSSChannel_CA();
            
            list<RSSItem_CA> rssItems = new list<RSSItem_CA>();
            
            //for each node inside channel
            for(Dom.XMLNode elements : channel.getChildElements()) {
                if('title' == elements.getName()) {
                    result.title = elements.getText();
                }
                if('link' == elements.getName()) {
                    result.link = elements.getText();
                }
                if('description' == elements.getName()) {
                    result.description = elements.getText();
                }
                if('category' == elements.getName()) {
                    result.category = elements.getText();
                }
                if('copyright' == elements.getName()) {
                    result.copyright = elements.getText();
                }
                if('docs' == elements.getName()) {
                    result.docs = elements.getText();
                }
                if('image' == elements.getName()) {
                    RSSImage_CA img = new RSSImage_CA();
                    //for each node inside image
                    for(Dom.XMLNode xmlImage : elements.getChildElements()) {
                        if('url' == xmlImage.getName()) {
                            img.url = xmlImage.getText();
                        }
                        if('title' == xmlImage.getName()) {
                            img.title = xmlImage.getText();
                        }
                        if('link' == xmlImage.getName()) {
                            img.link = xmlImage.getText();
                        }
                    }
                    result.image = img;
                }
                
                if('item' == elements.getName()) {
                    RSSItem_CA rssItem = new RSSItem_CA();
                    //for each node inside item
                    for(Dom.XMLNode xmlItem : elements.getChildElements()) {
                        if('title' == xmlItem.getName()) {
                            rssItem.title = xmlItem.getText();
                        }
                        if('guid' == xmlItem.getName()) {
                            rssItem.guid = xmlItem.getText();
                        }
                        if('link' == xmlItem.getName()) {
                            rssItem.link = xmlItem.getText();
                        }
                        if('description' == xmlItem.getName()) {
                            rssItem.description = xmlItem.getText();
                        }
                        if('pubDate' == xmlItem.getName()) {
                            rssItem.pubDate = xmlItem.getText();
                            rssItem.pubDate = rssItem.pubDate.substring(0, rssItem.pubDate.length()-13);
                        }
                        if('source' == xmlItem.getName()) {
                            rssItem.source = xmlItem.getText();
                        }
                    }
                    //for each item, add to rssItem list
                    rssItems.add(rssItem);
                }         
            }
            //finish RSSChannel object by adding the list of all rss items
            result.items = rssItems;
            
            return result;
        }catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = 'An error occurred. Unable to display feed at this time. Please reload the page or try again later';
            return null;
        }
    }
}