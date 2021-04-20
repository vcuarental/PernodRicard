public class FeedItemInfo_CA{
	//-------- properties ----------//
    public ConnectApi.FeedItem feedItem;
    public ConnectApi.CommentPage commentPage;
    public ConnectApi.FeedPoll poll;
    public Integer numChoices;
    public String feedItemId;
    public String feedItemParentId;
    public String feedItemParentName;
    public String feedItemParentSmallIconUrl;
    public String userName;
    public String userId;
    public String imageUrl;
    public String linkUrl;
    public String linkTitle;
    public String contentDescription;
    public String contentDownloadUrl;
    public String contentTitle;
    public Boolean hasImagePreview;
    public String formattedText;
    public String contentId;
    public List<CommentInfo_CA> comments;
    public String relativeCreatedDate;
    public String likesMessage;
    public Boolean isLikedByUser;
    public String myLikeId;
    //gets the commentCount for the number of comments on the first page of comments (pageSize=100)
    public Integer commentCount;
    
    //Constructor
    public FeedItemInfo_CA(ConnectApi.FeedItem inFeedItem) {
        setFeedItem(inFeedItem);
        setFeedItemId(inFeedItem.id);
        setUserName('');
        setRelativeCreatedDate(feedItem.relativeCreatedDate);
        setLikesMessage('');
        setIsLikedByUser(feedItem.isLikedByCurrentUser);
        setMyLikeId('');
        
        if(feedItem.parent != null){
            setFeedItemParentId(feedItem.parent.id);   
            if(feedItem.parent.name != null){
                setFeedItemParentName(feedItem.parent.name);
            }
            if(feedItem.parent.motif.smallIconUrl != null){
                setFeedItemParentSmallIconUrl(feedItem.parent.motif.smallIconUrl);
            }
        }
        if(feedItem.myLike != null){
            if(getIsLikedByUser()){
                setMyLikeId(feedItem.myLike.id);
            }        
        }        
        
        if(feedItem.likesMessage != null){
            setLikesMessage(feedItem.likesMessage.text);
        }
        
        if (feedItem.actor != null && feedItem.actor instanceof ConnectApi.User) {
            setUserName( ((ConnectApi.User)feedItem.actor).name );
            setUserId( ((ConnectApi.User)feedItem.actor).id );
        }

        setImageUrl('');
        if (feedItem.attachment != null) {
            if (feedItem.attachment instanceof ConnectApi.ContentAttachment) {
                ConnectApi.ContentAttachment content = (ConnectApi.ContentAttachment)feedItem.attachment;
                setImageUrl(content.renditionUrl);
                setContentDescription(content.description);
                setContentTitle(content.title);
                setHasImagePreview(content.hasImagePreview);
                setContentId(content.versionId);
                setContentDownloadUrl('/sfc/servlet.shepherd/version/download/' + content.versionId + '?asPdf=false&operationContext=CHATTER');
            } else if (feedItem.attachment instanceof ConnectApi.LinkAttachment) {
                ConnectApi.LinkAttachment link = (ConnectApi.LinkAttachment)feedItem.attachment;
                setLinkUrl(link.url);
                setLinkTitle(link.title);
            } else if (feedItem.attachment instanceof ConnectApi.FeedPoll){
                setPoll( (ConnectApi.FeedPoll)feedItem.attachment );  
                setNumChoices(poll.choices.size());
            }
        }

        setFormattedText(FeedFormatter_CA.formatBodyText(feedItem.body));

        setComments(new List<CommentInfo_CA>());
        try{
            setCommentPage(ConnectApi.ChatterFeeds.getCommentsForFeedItem(null, feedItemId, null, 100));
            for (ConnectApi.Comment comment : commentPage.comments) {
                comments.add(new CommentInfo_CA(comment));
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            ApexPages.Message addCmtErrorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'An error occurred. Unable to retrieve comments at this time. Please try again later');
            ApexPages.addMessage(addCmtErrorMsg);
        }
    }
    
    //beging getters
    public ConnectApi.FeedItem getFeedItem(){
        return this.feedItem;
    }
    public ConnectApi.CommentPage getCommentPage(){ 
        return this.commentPage;
    }
    public ConnectApi.FeedPoll getPoll(){ 
        return this.poll;
    }
    public Integer getNumChoices(){ 
        return this.numChoices;
    }
    public String getFeedItemId(){ 
        return this.feedItemId;
    }
    public String getFeedItemParentId(){ 
        return this.feedItemParentId;
    }
    public String getFeedItemParentName(){ 
        return this.feedItemParentName;
    }
    public String getFeedItemParentSmallIconUrl(){ 
        return this.feedItemParentSmallIconUrl;
    }
    public String getUserName(){ 
        return this.userName;
    }
    public String getUserId(){ 
        return this.userId;
    }
    public String getImageUrl(){ 
        return this.imageUrl;
    }
    public String getLinkUrl(){ 
        return this.linkUrl;
    }
    public String getLinkTitle(){ 
        return this.linkTitle;
    }
    public String getContentDescription(){ 
        return this.contentDescription;
    }
    public String getContentDownloadUrl(){ 
        return this.contentDownloadUrl;
    }
    public String getContentTitle(){ 
        return this.contentTitle; 
    }
    public Boolean getHasImagePreview(){ 
        return this.hasImagePreview;
    }
    public String getFormattedText(){ 
        return this.formattedText;
    }
    public String getContentId(){ 
        return this.contentId; 
    }
    public List<CommentInfo_CA> getComments(){ 
        return this.comments; 
    }
    public String getRelativeCreatedDate(){ 
        return this.relativeCreatedDate; 
    }
    public String getLikesMessage(){ 
        return this.likesMessage; 
    }
    public Boolean getIsLikedByUser(){ 
        return this.isLikedByUser; 
    }
    public String getMyLikeId(){ 
        return this.myLikeId; 
    }
    //gets the commentCount for the number of comments on the first page of comments (pageSize=100)
    public Integer getCommentCount(){
        return this.comments.size();
    }
    //begin setters
    private void setFeedItem(ConnectApi.FeedItem theItem){
        this.feedItem = theItem;
    }
    private void setCommentPage(ConnectApi.CommentPage thePage){ 
        this.commentPage = thePage;
    }
    private void setPoll(ConnectApi.FeedPoll thePoll){ 
        this.poll = thePoll;
    }
    private void setNumChoices(Integer theNumber){ 
        this.numChoices = theNumber;
    }
    private void setFeedItemId(String theItemId){ 
        this.feedItemId = theItemId;
    }
    private void setFeedItemParentId(String theItemId){ 
        this.feedItemParentId = theItemId;
    }
    private void setFeedItemParentName(String theName){ 
        this.feedItemParentName = theName;
    }
    private void setFeedItemParentSmallIconUrl(String theUrl){ 
        this.feedItemParentSmallIconUrl = theUrl;
    }
    private void setUserName(String theName){ 
        this.userName = theName;
    }
    private void setUserId(String theId){ 
        this.userId = theId;
    }
    private void setImageUrl(String theUrl){ 
        this.imageUrl = theUrl;
    }
    private void setLinkUrl(String theUrl){ 
        this.linkUrl = theUrl;
    }
    private void setLinkTitle(String theTitle){ 
        this.linkTitle = theTitle;
    }
    private void setContentDescription(String theDesc){ 
        this.contentDescription = theDesc;
    }
    private void setContentDownloadUrl(String theUrl){ 
        this.contentDownloadUrl = theUrl;
    }
    private void setContentTitle(String theTitle){ 
        this.contentTitle = theTitle; 
    }
    private void setHasImagePreview(Boolean theAnswer){ 
        this.hasImagePreview = theAnswer;
    }
    private void setFormattedText(String theText){ 
        this.formattedText = theText;
    }
    private void setContentId(String theId){ 
        this.contentId =  theId; 
    }
    private void setComments(List<CommentInfo_CA> theComments){ 
        this.comments = theComments; 
    }
    private void setRelativeCreatedDate(String theDate){ 
        this.relativeCreatedDate = theDate; 
    }
    private void setLikesMessage(String theMessage){ 
        this.likesMessage = theMessage; 
    }
    private void setIsLikedByUser(Boolean theAnswer){ 
        this.isLikedByUser = theAnswer; 
    }
    private void setMyLikeId(String theId){ 
        this.myLikeId = theId; 
    }
}