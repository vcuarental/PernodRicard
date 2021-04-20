public class VFC06_HomePageCustom {

    // Variables used for translation
    public boolean isFrench {get;set;}        
    public void setFrench() {
        isFrench = true;
        isEnglish = false;
        isSpanish = false;
    }
    
    public boolean isEnglish {get;set;}  
    public void setEnglish() {
        isFrench = false;
        isEnglish = true;
        isSpanish = false;
    } 

    public boolean isSpanish {get;set;}  
    public void setSpanish() {
        isFrench = false;
        isEnglish = false;
        isSpanish = true;
    } 
    
/*    public String contentID { get; set; }
    public String FirstTopicTitle { get; set; }
    public String SecondTopicTitle { get; set; }
    public String ThirdTopicTitle { get; set; }
    public String FirstTopicContent { get; set; }
    public String SecondTopicContent { get; set; }
    public String ThirdTopicContent { get; set; } */
    public String errorMsg { get; set; }
    
  //  public HomePageConfig_Local__c currConfig { get; set; }
    public HomePageConfig_Global__c orgConfig { get; set; }
    
    public String currLang {get; set;}
        
    public boolean firstHomeDisplay { get; set; }
    public boolean isChivas { get; set; }
    public boolean isAbsolute { get; set; }
    public boolean refreshPage { get; set; }
    public Integer timeElapsedAfterFirstLogin { get; set; }
    
    private Id uid;
    private User currentUser;

    public VFC06_HomePageCustom() {                        
      // Get the good profile related to the country of the user.
/*        currConfig = HomePageConfig_Local__c.getValues(currentUser.Country);     
        if(currConfig != null){
                FirstTopicTitle = currConfig.First_Topic_Title__c;
                SecondTopicTitle = currConfig.Second_Topic_Title__c;
                ThirdTopicTitle = currConfig.Third_Topic_Title__c;
                FirstTopicContent = currConfig.First_Topic_Content__c;
                SecondTopicContent = currConfig.Second_Topic_Content__c;
                ThirdTopicContent = currConfig.Third_Topic_Content__c;
                contentID = getContent(currConfig.Content_Video_URL__c, currConfig.Content_Image_URL__c);
        } else {   */             
      //  }                
    }
    
/*    public void setContentPage(){
        orgConfig = HomePageConfig_Global__c.getOrgDefaults();
        FirstTopicTitle = orgConfig.FirstTopicTitle__c;
        SecondTopicTitle = orgConfig.SecondTopicTitle__c;
        ThirdTopicTitle = orgConfig.ThirdTopicTitle__c;
        FirstTopicContent = orgConfig.FirstTopicContent__c;
        SecondTopicContent = orgConfig.SecondTopicContent__c;
        ThirdTopicContent = orgConfig.ThirdTopicContent__c;
        contentID = orgConfig.videoYoutubeID__c;
    }*/
    
    public void checkTimeElapsed() {   
        uid = UserInfo.getUserId();
        currLang = UserInfo.getLanguage();
        timeElapsedAfterFirstLogin = 0;
        firstHomeDisplay = true;
        refreshPage = false;
        
        isFrench = false;
        isEnglish = true;
        isSpanish = false;   
        
        if(UserInfo.getLanguage() == 'es')
            setSpanish();
        else if(UserInfo.getLanguage() == 'fr')
            setFrench();
        else
            setEnglish();   
            
        // Get info about the current user
        User currentUser = [SELECT ESNPolicyAcceptanceDate__c, Country, LastLoginDate, TECH_Connection_Today__c, LanguageLocaleKey FROM User WHERE ID = :uid LIMIT 1].get(0);
        
        // Calculate time elapsed after the first successfully login of the user
        if(currentUser.ESNPolicyAcceptanceDate__c != null)
            timeElapsedAfterFirstLogin = currentUser.ESNPolicyAcceptanceDate__c.date().daysBetween(date.today());
        if(timeElapsedAfterFirstLogin >= 15){
            firstHomeDisplay = false;
        } 
    
        system.debug('##### time elapsed '+timeElapsedAfterFirstLogin);
        // if timeElapsedAfterFirstLogin <= 15, display the first home page version
          if(timeElapsedAfterFirstLogin >= 15){
                if(currentUser.LastLoginDate > currentUser.TECH_Connection_Today__c || currentUser.TECH_Connection_Today__c == null){ // User just connected
                    system.debug('##### refresh');
                    refreshPage = true;
                    currentUser.TECH_Connection_Today__c = Datetime.now();             
                    update currentUser;
                } else { // User clicked on the Home tab
                    system.debug('##### not refresh');
                    refreshPage = false;
            		firstHomeDisplay = true;
                }
        } else {
            refreshPage = false;
        }
        
        // Set all contents of the page
     //   setContentPage();         
    } 

/*      public String getContent(String contentVideoURL, String contentImgURL) {
                String result;
                if(contentVideoURL != null){
                        List<String> splits = contentVideoURL.split('v=');
                        result = splits[splits.size()-1];
                } else if(contentImgURL != null){
                        
                }
                return result;
        } */
}