public class ESN_VFC14_BP_Display {
    
    public class ContentWrapper {
        public String contentType {get;set;}
        public String contentUrl {get;set;}
        public Integer contentNb {get;set;}
        public ContentWrapper(Integer nb, String ct, String cu){
            this.contentType = ct;
            this.contentUrl = cu;
            this.contentNb = nb;
        }
    }
    
    public List<ESN_Best_Practice__c> currBestPractices_list {get;set;}
    public List<ContentWrapper> contentsUrl_list {get;set;}
    public ContentWrapper firstContentWr {get;set;}
    public ContentWrapper secondContentWr {get;set;}
    public ESN_Best_Practice__c currBP {get;set;}
    public ESN_Best_Practice__c prevBP {get;set;}
    public ESN_Best_Practice__c nextBP {get;set;}
    public String prevURL {get;set;}
    public String nextURL {get;set;}
    public String urlDisplayDocument {get;set;}
    public String urlDisplayDocument_short {get;set;}
    public String urlSFDC {get;set;}
    public String msg {get;set;}
    
    public ESN_VFC14_BP_Display(ApexPages.StandardController controller) {
        // Variables : Initialisation //
        currBestPractices_list = new List<ESN_Best_Practice__c>();
        contentsUrl_list = new List<ContentWrapper>();
        currBP = new ESN_Best_Practice__c();
        
        // Variables : Define default values //
        urlSFDC = URL.getSalesforceBaseUrl().toExternalForm();
        urlDisplayDocument = urlSFDC + '/servlet/servlet.FileDownload?file=';
        urlDisplayDocument_short = '/servlet/servlet.FileDownload?file=';
    
        // Get the ID of current BP in parameters
        if(ApexPages.currentPage().getParameters().get('id') != null)
            currBP = (ESN_Best_Practice__c)controller.getRecord();
            
        // Get the collection of BPs
        buildCurrentCollectionBP();
        
        // Build the list of Contents URL
        contentsUrl_list = buildListOfContentsURL(currBP.ESN_BP_Media_URLs__c);
        if(contentsUrl_list != null && contentsUrl_list.size() > 1){
            firstContentWr = contentsUrl_list.get(0);
            secondContentWr = contentsUrl_list.get(1);
        }

    }
    
    private void buildCurrentCollectionBP(){
        prevURL = '/apex/ESN_VFP14_BP_Display?';
        nextURL = '/apex/ESN_VFP14_BP_Display?';
        
        String paramSubcategory = ApexPages.currentPage().getParameters().get('subcategory');
        String paramCategory = ApexPages.currentPage().getParameters().get('category');
        String paramBenefit = ApexPages.currentPage().getParameters().get('benefit');
        String paramSearch = ApexPages.currentPage().getParameters().get('search');
        Boolean noResultSearch = false;
        if(paramCategory != null){
            currBestPractices_list = [SELECT Id,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c WHERE ESN_BP_Category__c = :paramCategory ORDER BY ESN_BP_Best_Practice_Number__c];
            prevURL += 'category='+paramCategory;
            nextURL += 'category='+paramCategory;
        } else if(paramSubcategory != null){
            currBestPractices_list = [SELECT Id,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c WHERE ESN_BP_Subcategory__c = :paramSubcategory ORDER BY ESN_BP_Best_Practice_Number__c];
            prevURL += 'subcategory='+paramSubcategory;
            nextURL += 'subcategory='+paramSubcategory;
        } else if(paramBenefit != null){
            currBestPractices_list = [SELECT Id,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c WHERE ESN_BP_Benefit__c = :paramBenefit ORDER BY ESN_BP_Best_Practice_Number__c];
            prevURL += 'benefit='+paramBenefit;
            nextURL += 'benefit='+paramBenefit;
        } else if(paramSearch != null){
            currBestPractices_list = (List<ESN_Best_Practice__c>)[FIND :paramSearch RETURNING ESN_Best_Practice__c(Id,ESN_BP_Best_Practice_Number__c ORDER BY ESN_BP_Best_Practice_Number__c ASC)].get(0);
            prevURL += 'search='+paramSearch;
            nextURL += 'search='+paramSearch;
        } else {
                noResultSearch = true;
        }

        if(currBestPractices_list == null || currBestPractices_list.size() == 0)
                noResultSearch = true;
                
        if(noResultSearch)
                currBestPractices_list = [SELECT Id,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c ORDER BY ESN_BP_Best_Practice_Number__c];
        
        Boolean isFirst = false;
        Boolean isLast = false;
        
        for(Integer i=0 ; i<currBestPractices_list.size() ; i++){
            if(currBestPractices_list.get(i).Id == currBP.Id){
                // Define the previous BP
                if(i == 0)
                    prevBP = currBestPractices_list.get(currBestPractices_list.size()-1);
                else 
                    prevBP = currBestPractices_list.get(i-1);
                
                // Define the next BP
                if(i == currBestPractices_list.size()-1)
                    nextBP = currBestPractices_list.get(0);
                else 
                    nextBP = currBestPractices_list.get(i+1);
            }
        }
        prevURL += '&id=' + prevBP.Id;
        nextURL += '&id=' + nextBP.Id;
    }
    
    private List<ContentWrapper> buildListOfContentsURL(String contentURL){
        List<ContentWrapper> contentWrapper_list = new List<ContentWrapper>();
        List<String> contents_List = new List<String>();
        
        if(contentURL != null && contentURL != ''){
          /*  if(contentURL.countMatches(';') <= 1)  
                contents_List.add(contentURL).removeEnd(';');
            else */
                contents_List = contentURL.split(';');
        }else{
            return null;
        }
        
        Map<Id,Document> docId2Doc_map = new Map<Id,Document>([SELECT Id,ContentType FROM Document WHERE FolderId IN (SELECT Id FROM Folder WHERE DeveloperName = 'Embiez_13_Best_Practices')]);
        
        for(Integer i=0 ; i<contents_List.size() ; i++){
            if(contents_list.get(i).contains('http'))
                contentWrapper_list.add(new ContentWrapper(i,'video', contents_list.get(i)));
            else if(contents_list.get(i) != '' && contents_list.get(i) != null && docId2Doc_map.containsKey((Id)contents_list.get(i))){
                if(docId2Doc_map.get((Id)contents_list.get(i)).ContentType.contains('image'))
                    contentWrapper_list.add(new ContentWrapper(i,'image', urlDisplayDocument + contents_list.get(i)));
                else if(docId2Doc_map.get((Id)contents_list.get(i)).ContentType.contains('pdf'))
                    contentWrapper_list.add(new ContentWrapper(i,'pdf', urlDisplayDocument_short + contents_list.get(i)));
            }
        }
        return contentWrapper_list ;
    }
}