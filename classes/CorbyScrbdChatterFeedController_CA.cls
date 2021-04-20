public class CorbyScrbdChatterFeedController_CA {
    static ConnectApi.FeedItemPage feedPage;
    static ConnectApi.ChatterGroupPage chatterGrpPg;
    static String theGroupId;
    
    //empty constructor
    public CorbyScrbdChatterFeedController_CA(){}
    
    // get first page of news feed
    public static ConnectApi.FeedItemPage getNewsFeed() {
        try{
            //get the proper Chatter Group Page 
            chatterGrpPg = ConnectApi.ChatterGroups.searchGroups(null, 'Canada - Corby Scoreboard', null, 1);
            ////get the groupId     
            theGroupId = chatterGrpPg.groups[0].id;
            //use the groupId to get the feedItems
            feedPage = ConnectApi.ChatterFeeds.getFeedItemsFromFeed(null, ConnectApi.FeedType.Record, theGroupId);
            return feedPage;
        }
        catch(Exception e){
            //if an exception is thrown above, it is most likely due to the group becoming archived for inactivity,
            //so just return null. In this case the VF page will display an error message in this section, 
            //but continue to render the rest of the page.
            return null;
        }
    }

    //The Id of the ChatterGroup we want to display will be different in the sandbox from what it is in production
    //(production id: 0F9D0000000UGqS in sandbox id:0F9M0000000FGsK), in order to get the feed items we want, 
    //we have to search for the ChatterGroup by name. Since Group Name must be unique,
    //the searchGroups method should only return one ChatterGroupPage with one ChatterGroup
    public static ConnectApi.ChatterGroupPage getCorbyScrbdChatterGrpPg(){
        //return ConnectApi.ChatterGroups.searchGroups(null, 'Canada - Corby Scoreboard', null, 1);
        return ConnectApi.ChatterGroups.searchGroups(null, 'CorbyTestGroup', null, 1);
    }

    // build list of wrapped feed items for display in VisualForce
    public static List<FeedItemInfo_CA> getNewsFeedForDisplay() {
        ConnectApi.FeedItemPage feed = getNewsFeed();      
        List<FeedItemInfo_CA> result = new List<FeedItemInfo_CA>();
        if(feed != null){
        	for (ConnectApi.FeedItem item : feed.items) {
                result.add(new FeedItemInfo_CA(item));
            }
            return result;
        }
        return null;
    }
    
    
    public PageReference refreshFeed(){
        return null;
    }
}