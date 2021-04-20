public class CommentInfo_CA{
	//-------- properties ----------//
    public ConnectApi.Comment comment;
    public String userName;
    public String userId;
    public String imageUrl;
    public String formattedText;
    public String contentDescription;
    public String contentDownloadUrl;
    public String contentTitle;
    public Boolean hasImagePreview;
    public String contentId;
    public String relativeCreatedDate;
    
    public CommentInfo_CA(ConnectApi.Comment inComment) {
        setComment(inComment);
        setUserName(inComment.user.name);
        setUserId(inComment.user.id);
        setRelativeCreatedDate(inComment.relativeCreatedDate);
            
        setImageUrl('');
        if (inComment.attachment != null && inComment.attachment instanceof ConnectApi.ContentAttachment) {
            ConnectApi.ContentAttachment content = (ConnectApi.ContentAttachment)inComment.attachment;
            setImageUrl(content.renditionUrl);
            setContentDescription(content.description);
            setContentTitle(content.title);
            setHasImagePreview(content.hasImagePreview);
            setContentId(content.versionId);
            setContentDownloadUrl('/sfc/servlet.shepherd/version/download/' + content.versionId + '?asPdf=false&operationContext=CHATTER');
        }
            
        setFormattedText(FeedFormatter_CA.formatBodyText(inComment.body));
    }
    
    //begin getters
    public ConnectApi.Comment getComment(){
        return this.comment;
    }
    public String getUserName(){
        return this.username;   
    }
    public String getUserId(){
        return this.userId;   
    }
    public String getImageUrl(){
        return this.imageUrl;
    }
    public String getFormattedtext(){
        return this.formattedText;
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
    public String getContentId(){
        return this.contentId;
    }
    public String getRelativeCreatedDate(){
        return this.relativeCreatedDate;
    }        
    //begin setters
    private void setComment(ConnectApi.Comment theComment){
        this.comment = theComment;
    }
    private void setUserName(String theUserName){
        this.userName = theUserName;
    }
    private void setUserId(String theUserId){
        this.userId = theUserId;
    }
    private void setImageUrl(String theImageUrl){
        this.imageUrl = theImageUrl;
    }
    private void setFormattedText(String theFormattedText){
        this.formattedText = theFormattedText;
    }
    private void setContentDescription(String theContentDescription){
        this.contentDescription = theContentDescription;
    }
    private void setContentDownloadUrl(String theContentDownloadUrl){
        this.contentDownloadUrl = theContentDownloadUrl;
    }
    private void setContentTitle(String theContentTitle){
        this.contentTitle = theContentTitle;
    }
    private void setHasImagePreview(Boolean theAnswer){
        this.hasImagePreview = theAnswer;
    }
    private void setContentId(String theContentId){
        this.contentId = theContentId;
    }
    private void setRelativeCreatedDate(String theDate){
        this.relativeCreatedDate = theDate;
    }
}