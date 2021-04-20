public class RSSNewsReader_CA{
    private String rssURL;
    
    public RSSNewsReader_CA() { 
    }   
    
    public String getRssURL(){
        return rssURL;
    }    
    
    public void setRssURL(String feedURL){
        rssURL = feedURL;
    }
    
    public RSSChannel_CA getRSSFeed() {
        return RSS_CA.getRSSData(rssURL);
    }
}