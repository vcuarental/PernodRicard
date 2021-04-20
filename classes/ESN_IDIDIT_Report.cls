public with sharing class ESN_IDIDIT_Report {
    
    private static List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name=:Label.ESN_IDIDIT_ChatterGroupName LIMIT 1];
    
    private static final String communityId = null;
    private static final ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
    private static String subjectId = chatterGroup[0].Id;
    private static final Integer pageSize = 100;
    private static final ConnectApi.FeedSortOrder sortParam = ConnectApi.FeedSortOrder.CreatedDateDesc;
    
    private List<IDidIt> listResult {get; set;}
    private IDidIt result {get; set;}

    public String previousPageToken {get; set;}
    public String currentPageToken {get; set;}
    public String nextPageToken {get; set;}
    public Boolean nextPage {get; set;}


    public ESN_IDIDIT_Report() {
        listResult = new List<IDidIt>();
        nextPage = false;
    } 
    
    public void displayRecords() {
        String excel = System.currentPageReference().getParameters().get('excel');
        if (excel == 'true') {
            getRecords(currentPageToken);        
        } else {
            getRecords(nextPageToken);
        }
    }
    
    // Next page    
    public void next() {
        displayRecords(); 
    }
    
    public void getRecords(String token) {
        listResult.clear();
        
        transient ConnectApi.FeedItemPage fep = ConnectApi.ChatterFeeds.getFeedItemsFromFeed(communityId, feedType, subjectId, token, pageSize, sortParam);
        transient List<ConnectApi.FeedItem> listFeedItem = fep.items;
        
        transient String feedItemLimit = System.currentPageReference().getParameters().get('feedItemLimit');
        transient Integer dataLimit;
        if(feedItemLimit == null || feedItemLimit == '' || feedItemLimit.trim().length() == 0) {
            dataLimit = Integer.valueOf(Label.ESN_IDIDIT_FeedItemLimit);
        } else {
            dataLimit = Integer.valueOf(System.currentPageReference().getParameters().get('feedItemLimit'));                
        }
        
        
        while (fep.nextPageToken != null && listFeedItem.size() < dataLimit) {
            fep = ConnectApi.ChatterFeeds.getFeedItemsFromFeed(communityId, feedType, subjectId, fep.nextPageToken, pageSize, sortParam);
            listFeedItem.addall(fep.items); 
            
        }
        previousPageToken = currentPageToken;
        currentPageToken = nextPageToken;
        nextPageToken = fep.nextPageToken; 
        
        if (nextPageToken == null) {
            nextpage = false;
        } else {
            nextPage = true;
        }
        
        setListResult(listFeedItem);
        listFeedItem.clear();
        system.debug('listResult: ' + listResult.size());
    }
    
    
    private void setListResult(List<ConnectApi.FeedItem> listFeedItem) {
        
        // Get users who have posted message
        transient List<Id> userIdList = new List<Id>();
        for (ConnectApi.FeedItem fi : listFeedItem) {
          userIdList.add(((ConnectApi.ActorWithId)fi.actor).Id);
        }
        transient List<User> listUser = [SELECT Id, Email, CompanyName FROM User WHERE Id IN :userIdList];
        system.debug('listUser size: ' + listUser.size());
          
        for (ConnectApi.FeedItem fi : listFeedItem) {
            if(fi.body.text != null) {
               //transient Pattern p = Pattern.compile(Label.ESN_IDIDIT_PostMsg1 + ' ' + '(.*?)' + ' ' + Label.ESN_IDIDIT_PostMsg2);
               //transient Matcher m = p.matcher(fi.body.text);
               // if (m.find()) {
                    result = new IDidIt();
                    result.createdDate = fi.createdDate.format('dd/MM/yyyy HH:mm:ss', 'Europe/Paris');
                    result.userName = fi.actor.name;
                    
                    /*init values */
                    String idimage = '';
                    String titre = 'No picture added';

                try{
                    if(((ConnectApi.ContentAttachment)fi.attachment)!=null){
                        idimage = ((ConnectApi.ContentAttachment)fi.attachment).id;
                        titre = ((ConnectApi.ContentAttachment)fi.attachment).title;
                        result.chatterPhoto = Label.ESN_IDIDIT_Url_org_for_picture+idimage;
                    }
                }catch(Exception e){
                    
                }
                    
                                        
                    result.chatterPhotoTitle = titre;
                    
                    for (User user : listUser) {
                        if (((ConnectApi.ActorWithId)fi.actor).Id == user.Id) {
                            result.userEmail = user.Email;
                            result.userFiliale = user.CompanyName;
                        }
                    }
                
                
                
                   /* 
                    * //p = Pattern.compile(Label.ESN_IDIDIT_PostMsg2 +'\n\n' + '(.*?)' + '\n\n' + '@' + Label.ESN_IDIDIT_ChatterGroupName);
                    * 
                    * Comment 03/06/2016 - Problème regex too complicated 
                    * transient Pattern p = Pattern.compile('(.*?)' + '\n\n' + '@' + Label.ESN_IDIDIT_ChatterGroupName);
                    * transient Matcher m = p.matcher(fi.body.text);
                   
                
                    //if (m.find()) {
                        on coupe au @ pour avoir seulement le message
                        String[] messageCompose = fi.body.text.split('@');
                        result.chatterMessage = messageCompose[0];
                       */ 
                        result.chatterMessage = fi.body.text;
                
                    //
                    // } else {
                    // p = Pattern.compile(Label.ESN_IDIDIT_PostMsg2 +'\n\n' + '(.*?)' + '$');
                    /*   
                     * Comment 03/06 -  Problème regex too complicated 
                     * p = Pattern.compile('(.*?)' + '$');
                     * m = p.matcher(fi.body.text);
                     * if (m.find()) {
                     *    if (m.group(1) != ('@' + Label.ESN_IDIDIT_ChatterGroupName)) {
                     *       result.chatterMessage = m.group(1);
                     * 			}
                     * 	 	}
                     *  }
                     * */

                    result.chatterGroupName = Label.ESN_IDIDIT_ChatterGroupName;
                    listResult.add(result);
                }
           // }
        }
        listUser.clear();
    }
    
    
    public List<IDidIt> getResult() {
        return this.listResult;
    }
    
    public PageReference exportToExcel() {
        PageReference pr = new PageReference('/apex/ESN_IDidIt_ReportExcel');
        pr.getParameters().put('excel','true');
        return pr;
    }
    
    
    public class IDidIt {
        public String createdDate {get;set;}
        public String userName {get;set;}
        public String userEmail {get;set;}
        public String userFiliale {get;set;}
        //public String chatterCounter {get;set;}
        public String chatterMessage {get;set;}
        public String chatterGroupName {get;set;}
        public String chatterPhoto{get;set;}
        public String chatterPhotoTitle{get;set;}
        public IDidIt() {
            
        }
    }
}