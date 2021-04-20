public class RSSChannel_CA{
    //properties
    public String title;
    public String link;
    public String description;
    public String author;
    public String category;
    public String copyright;
    public String docs;
    public RSSImage_CA image;
    public List<RSSItem_CA> items;
    
    //constructor
    public RSSChannel_CA() {
        items = new List<RSSItem_CA>();
    }
    
    //begin getters
    public String getTitle(){
        return this.title;
    }
    public String getLink(){
        return this.link;
    }
    public String getDescription(){
        return this.description;
    }
    public String getAuthor(){
        return this.author;
    }
    public String getCategory(){
        return this.category;
    }
    public String getCopyright(){
        return this.copyright;
    }
    public String getDocs(){
        return this.docs;
    }
    public RSSImage_CA getImage(){
        return this.image;
    }
    public List<RSSItem_CA> getItems(){
        return this.items;
    }
    //begin setters
    public void setTitle(String theTitle){
        this.title = theTitle;
    }
    public void setLink(String theLink){
        this.link = theLink;
    }
    public void setDescription(String theDesc){
        this.description = theDesc;
    }
    public void setAuthor(String theAuthor){
        this.author = theAuthor;
    }
    public void setCategory(String theCategory){
        this.category = theCategory;
    }
    public void setCopyright(String theCopyright){
        this.copyright = theCopyright;
    }
    public void setDocs(String theDocs){
        this.docs = theDocs;
    }
    public void setImage(RSSImage_CA theImage){
        this.image = theImage;
    }
    public void setItems(List<RSSItem_CA> theItems){
        this.items = theItems;
    }

}