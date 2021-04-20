//Custom Controller extension for RSSNewsReader_CA controller
public class RSSInsightsExtension_CA {

    private RSSChannel_CA insightsFeed;
    public String insightsError {get; private set;}
    
    public RSSInsightsExtension_CA (RSSNewsReader_CA custController) {
        custController.setRssURL('http://www.just-drinks.com/alerts/rssinsights.aspx');
        setInsightsFeed((RSSChannel_CA)custController.getRSSFeed());
        try{
            for(RSSItem_CA theItem : getInsightsFeed().items){
                String itemCheck = 'Checked' + theItem.description.stripHtmlTags();
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            this.insightsError = '<span style="color:#D50005;">AN ERROR OCCURRED!</span><br /><br />Unable to display JustDrinks.com<br />Insights at this time.<br />Please reload the page or try again later';
        }
    }

    public RSSChannel_CA getInsightsFeed() {
        return this.insightsFeed;
    }
    public void setInsightsFeed(RSSChannel_CA theRSSChannel){
        this.insightsFeed = theRSSChannel;
    }
}