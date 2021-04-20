//Custom Controller extension for RSSNewsReader_CA controller
public class RSSCorbyStocksExtension_CA {

    private RSSChannel_CA stocksFeed;
    public String yahooError {get; private set;}
    
    public RSSCorbyStocksExtension_CA (RSSNewsReader_CA custController) {
        /* In order to add Stock Quotes for Corby Stocks, I created a Yahoo Pipe in order to get a customized RSS feed for the desired stocks. 
           I created a Yahoo account for this. The credentials are as follows:
            Visit: http://pipes.yahoo.com/pipes/ 
            Yahoo! ID: ituser.pernodricard@yahoo.com 
            Password: P3rn0dIT
            Alternate email: steven.westfall@pernod-ricard.com
            Secret Q1 Answer: Windsor  Secret Q2 Answer: Mock
            Instructions to get Stocks RSS: Login and go to “My Pipes”. Click on the link “Stock Quote Watch List Feed w/Chart”. 
            In the input field labeled “Enter Stock Ticker”, change the entry to “CSW-A.TO,CSW-B.TO,RI.PA” and click “Run Pipe”. 
            The customized pipe should now be displayed below. You can view it as either a Chart (“Image”) or as a List. 
            To get the RSS feed needed for the Salesforce RSS controller extension, click on “Get as RSS”. 
            This will open the RSS feed in the current window. Copy the URL and paste it into the controller extension at the appropriate spot below.
            In order for this to work within SFDC, you will also need to ensure that http://pipes.yahoo.com has been added to Security Controls -> Remote Site Settings. 
        */
        //When a new stock set needs to be defined, follow the instructions above and paste the resulting URL below
        custController.setRssURL('http://pipes.yahoo.com/pipes/pipe.run?_id=ef75f04b58cd362fc814a80200dbecad&_render=rss&ticker=CSW-A.TO%2CCSW-B.TO+%2CRI.PA');
        setStocksFeed((RSSChannel_CA)custController.getRSSFeed());
        // manipulate description of each item to suit our needs
        try{
            for(RSSItem_CA theItem : getStocksFeed().items){
                theItem.description = 'change' + theItem.description.stripHtmlTags().substringAfterLast('change').replace('day ', '');
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            this.yahooError = '<span style="color:#D50005;">AN ERROR OCCURRED!</span><br /><br />Unable to display Corby Stock prices at this time. <br /> Please reload the page or try again later';
        }
    }

    public RSSChannel_CA getStocksFeed() {
        return this.stocksFeed;
    }
    
    public void setStocksFeed(RSSChannel_CA theRSSChannel){
        this.stocksFeed = theRSSChannel;
    }
}