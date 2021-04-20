public class RSSImage_CA{
	//properties
    public String url;
    public String title;
    public String link;
    
    //empty constructor
    public RSSImage_CA(){}
    
    //begin getters
    public String getUrl(){
        return this.url;
    }
    public String getTitle(){
        return this.title;
    }
    public String getLink(){
        return this.link;
    }
    //begin setters
    public void setUrl(String theUrl){
        this.url = theUrl;
    }
    public void setTitle(String theTitle){
        this.title = theTitle;
    }
    public void setLink(String theLink){
        this.link = theLink;
    }
}