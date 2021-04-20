//Test class for testing methods related to the following custom RSS classes:
//RSS, RSSNewsReader, RSSItem, RSSImage, RSSChannel, RSSInsightsExtension, RSSCorbyStocksExtension
@isTest
public class RSS_CA_Test{
    @isTest
    static void doTest(){
        //create some test objects
        RSSImage_CA testRSSImage = new RSSImage_CA(); 
        RSSItem_CA testRSSItem = new RSSItem_CA();
        RSSChannel_CA testRSSChannel = new RSSChannel_CA();
        List<RSSItem_CA> testRSSItems = new List<RSSItem_CA>();
        RSSNewsReader_CA testRSSNewsReader = new RSSNewsReader_CA();
        RSSInsightsExtension_CA testRSSInsightsExt = new RSSInsightsExtension_CA(testRSSNewsReader);
        RSSCorbyStocksExtension_CA testRSSCorbyStocksExt = new RSSCorbyStocksExtension_CA(testRSSNewsReader);
        RSS_CA testRSS = new RSS_CA();
        
        //set the properties of the RSSImage to some test values
        testRSSImage.setUrl('http://www.theRSSImageUrl.com');
        testRSSImage.setTitle('This is the RSSImage Title.');
        testRSSImage.setLink('http://www.theRSSImageLink.com');
        //test the RSSImage getters after using the setters above
        System.assertEquals('http://www.theRSSImageUrl.com', testRSSImage.getUrl());
        System.assertEquals('This is the RSSImage Title.', testRSSImage.getTitle());
        System.assertEquals('http://www.theRSSImageLink.com', testRSSImage.getLink());
        
        //set the properties of the RSSItem to some test values
        testRSSItem.setTitle('This is the RSSItem Title.');
        testRSSItem.setGuid('12345');
        testRSSItem.setLink('http://www.theRSSItemLink.com');
        testRSSItem.setDescription('This is the RSSItem description.');
        testRSSItem.setPubDate('Thu, 22 Aug 2013');
        testRSSItem.setSource('This is the RSSItem source.');
        //test the RSSItem getters after using the setters above
        System.assertEquals('This is the RSSItem Title.', testRSSItem.getTitle());
        System.assertEquals('12345', testRSSItem.getGuid());
        System.assertEquals('http://www.theRSSItemLink.com', testRSSItem.getLink());
        System.assertEquals('This is the RSSItem description.', testRSSItem.getDescription());
        System.assertEquals('Thu, 22 Aug 2013', testRSSItem.getPubDate());
        System.assertEquals('This is the RSSItem source.', testRSSItem.getSource());
        
        //add the RSSItem to the List
        testRSSItems.add(testRSSItem);
        //set the properties of the RSSChannel to some test values
        testRSSChannel.setTitle('This is the RSSChannel Title.');
        testRSSChannel.setLink('http://www.theRSSChannelLink.com');
        testRSSChannel.setDescription('This is the RSSChannel description.');
        testRSSChannel.setAuthor('R.S.S. Channel');
        testRSSChannel.setCategory('This is the RSSChannel category.');
        testRSSChannel.setCopyright('Copyright 2013');
        testRSSChannel.setDocs('These are the RSSChannel docs.');
        testRSSChannel.setImage(testRSSImage);
        testRSSChannel.setItems(testRSSItems);
        //test the RSSChannel getters after using the setters above
        System.assertEquals('This is the RSSChannel Title.', testRSSChannel.getTitle());
        System.assertEquals('http://www.theRSSChannelLink.com', testRSSChannel.getLink());
        System.assertEquals('This is the RSSChannel description.', testRSSChannel.getDescription());
        System.assertEquals('R.S.S. Channel', testRSSChannel.getAuthor());
        System.assertEquals('This is the RSSChannel category.', testRSSChannel.getCategory());
        System.assertEquals('Copyright 2013', testRSSChannel.getCopyright());
        System.assertEquals('These are the RSSChannel docs.', testRSSChannel.getDocs());
        System.assertEquals('http://www.theRSSImageUrl.com', testRSSChannel.getImage().getUrl());
        System.assertEquals(testRssItems, testRSSChannel.getItems());
        System.assertEquals(1, testRSSChannel.getItems().size());
        
        //set the properties of the RSSNewsReader to some test values
        testRSSNewsReader.setRssURL('http://www.just-drinks.com/alerts/rssinsights.aspx');
        //test the RSSNewsReader getters after using the setter above
        System.assertEquals('http://www.just-drinks.com/alerts/rssinsights.aspx', testRSSNewsReader.getRssURL());
        
        //set the properties of the RSSInsightsExtension to some test value
        testRSSInsightsExt.setInsightsFeed(testRSSChannel);
        //test the RSSInsightsExtension getter after using the setter above
        System.assertEquals('This is the RSSChannel Title.', testRSSInsightsExt.getInsightsFeed().getTitle());
        
        //set the properties of the RSSCorbyStocksExtension to some test value
        testRSSCorbyStocksExt.setStocksFeed(testRSSChannel);
        //test the RSSCorbyStocksExtension getter after using the setter above
        System.assertEquals('This is the RSSChannel Title.', testRSSCorbyStocksExt.getStocksFeed().getTitle());
        
        /*test the web service call
          NOTE: - Since we can't execute the actual web service from within a test method,
          we need to write code to test for the null response from exceptions to get at least minimal code coverage*/
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req = RSS_CA.buildWebServiceRequest(testRSSNewsReader.getRssURL());
        System.assertEquals('http://www.just-drinks.com/alerts/rssinsights.aspx', req.getEndpoint());
        System.assert(null == RSS_CA.invokeWebService(h, req));
        System.assertEquals(RSS_CA.errorMsg, 'An error occurred. Unable to display feed at this time. Please reload the page or try again later');
        System.assert(null == RSS_CA.handleWebServiceResponse(res));
        System.assertEquals(RSS_CA.errorMsg, 'An error occurred. Unable to display feed at this time. Please reload the page or try again later');
        System.assert(null == RSS_CA.getRSSData(testRSSNewsReader.getRssURL()));
        System.assertEquals(RSS_CA.errorMsg, 'An error occurred. Unable to display feed at this time. Please reload the page or try again later');
    }
}