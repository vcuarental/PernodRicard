public class RSSItem_CA{
	//properties
    public String title;
    public String guid;
    public String link;
    public String description;
    public String pubDate;
    public String source;
    
    //empty constructor
    public RSSItem_CA(){}
    
    //begin getters
    public String getTitle(){
        return this.title;
    }
    public String getGuid(){
        return this.guid;
    }
    public String getLink(){
        return this.link;
    }
    public String getDescription(){
        return this.description;
    }
    public String getPubDate(){
        return this.pubDate;
    }
    public String getSource(){
        return this.source;
    }
    //begin setters
    public void setTitle(String theTitle){
        this.title = theTitle;
    }
    public void setGuid(String theGuid){
        this.guid = theGuid;
    }
    public void setLink(String theLink){
        this.link = theLink;
    }
    public void setDescription(String theDesc){
        this.description = theDesc;
    }
    public void setPubDate(String thePubDate){
        this.pubDate = thePubDate;
    }
    public void setSource(String theSource){
        this.source = theSource;
    }
}