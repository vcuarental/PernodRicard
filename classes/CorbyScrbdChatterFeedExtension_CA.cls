public with sharing class CorbyScrbdChatterFeedExtension_CA {
    //declare class variables
    public String feedItemId; 
    public String likeId;  
    public String commentToAdd; 
    public Integer pollChoicePosition; 
    
    // Constructor. Needed to use as an extension.
    public CorbyScrbdChatterFeedExtension_CA(CorbyScrbdChatterFeedController_CA custController) {}

    //call via javascript and actionFunction. Class variables feedItemId and commentToAdd are set by passing params via actionFunction
    public void addCommentToFeedItem(){
        try{
            FeedComment fcomment = new FeedComment();
            fcomment.FeedItemId = feedItemId; 
            fcomment.CommentBody = commentToAdd; 
            insert fcomment;
        }catch(Exception e){
            System.debug(e.getMessage());
            ApexPages.Message addCmtErrorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'An error occurred. Unable to add comment at this time. Please try again later');
            ApexPages.addMessage(addCmtErrorMsg);
        }
    }
    
    //call via javascript and actionFunction. Class variable feedItemId is set by passing params via actionFunction
    public void addLikeToFeedItem(){
        try{
            ConnectApi.ChatterFeeds.likeFeedItem(null, this.feedItemId);
        }catch(Exception e){
            System.debug(e.getMessage());
            ApexPages.Message addLikeErrorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'An error occurred. Unable to add like at this time. Please try again later');
            ApexPages.addMessage(addLikeErrorMsg);
        }
    }

    //call via javascript and actionFunction. Class variable likeId is set by passing params via actionFunction
    public void removeLikeFromFeedItem(){
        try{
            ConnectApi.ChatterFeeds.deleteLike(null, this.likeId);
        }catch(Exception e){
            System.debug(e.getMessage());
            ApexPages.Message rmvLikeErrorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'An error occurred. Unable to remove like at this time. Please try again later');
            ApexPages.addMessage(rmvLikeErrorMsg);
        }
    }
    
    //call via javascript and actionFunction. Class variables feedItemId and pollChoicePosition are set by passing params via actionFunction
    public void addVoteToFeedItemPoll(){
        try{
            ConnectApi.FeedPoll thePoll = ConnectApi.ChatterFeeds.getFeedPoll(null, this.feedItemId);
            String pollChoiceId = thePoll.choices[this.pollChoicePosition-1].id;
            ConnectApi.ChatterFeeds.voteOnFeedPoll(null, this.feedItemId, pollChoiceId);
        }catch(Exception e){
            System.debug(e.getMessage());
            ApexPages.Message addVoteErrorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'An error occurred. Unable to add vote at this time. Please try again later');
            ApexPages.addMessage(addVoteErrorMsg);
        }
    }
    
    //begin getters
    public String getFeedItemId(){
        return this.feedItemId;    
    }
    public String getLikeId(){
        return this.likeId;    
    }
    public String getCommentToAdd(){
        return this.commentToAdd;    
    }
    public Integer getPollChoicePosition(){
        return this.pollChoicePosition;    
    }
    //begin setters
    public void setFeedItemId(String theId){
        this.feedItemId = theId;
    }
    public void setLikeId(String theId){
        this.likeId = theId;
    }
    public void setCommentToAdd(String theComment){
        this.commentToAdd = theComment;
    }
    public void setPollChoicePosition(Integer thePosition){
        this.pollChoicePosition = thePosition;
    }
}