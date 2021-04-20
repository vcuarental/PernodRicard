public class ESN_VFC16_BP_Results {

    public class BpWrapper {
        public String firstMediaId {get;set;}
        public ESN_Best_Practice__c bestPractice {get;set;}
        public BpWrapper(ESN_Best_Practice__c bp){
            if(bp.ESN_BP_Media_URLs__c != null)
                this.firstMediaId = bp.ESN_BP_Media_URLs__c.split(';').get(0);
            this.bestPractice = bp;
        }
    }
    
    public List<BpWrapper> currBbWrapper_list {get;set;}
    public List<ESN_Best_Practice__c> currBestPractices_list {get;set;}
    public String searchFree {get;set;}
    public String urlDisplayDocument {get;set;}
    public String urlSFDC {get;set;}
    public Boolean noResult {get;set;}
    public String noResultMsg {get;set;}
    public String currentSearch {get;set;}
    public String searchTooShortMsg {get;set;}
    public Boolean searchTooShort {get;set;}

    public ESN_VFC16_BP_Results() {
        // Variables : Initialisation //
        currBbWrapper_list = new List<BpWrapper>();
        currBestPractices_list = new List<ESN_Best_Practice__c>();
        noResult = false;
        noResultMsg = 'No Result';
        searchTooShortMsg = 'Your search must contain at least 2 characters.';
        searchFree = '';
        
        // Variables : Define default values //
        urlSFDC = URL.getSalesforceBaseUrl().toExternalForm();
        urlDisplayDocument = urlSFDC + '/servlet/servlet.FileDownload?file=';
        
        buildCurrentCollectionBP();
    }
    
    private void buildCurrentCollectionBP(){
        String paramSubcategory = ApexPages.currentPage().getParameters().get('subcategory');
        String paramCategory = ApexPages.currentPage().getParameters().get('category');
        String paramBenefit = ApexPages.currentPage().getParameters().get('benefit');
        String paramSearch = ApexPages.currentPage().getParameters().get('search');
        
        if(paramCategory != null && paramCategory != ''){
            currBestPractices_list = [SELECT Id, Name,ESN_BP_Affiliate_Name__c,ESN_BP_Category__c,ESN_BP_Media_URLs__c,ESN_BP_Subcategory__c,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c WHERE ESN_BP_Category__c = :paramCategory ORDER BY ESN_BP_Best_Practice_Number__c];
            currentSearch = '&category='+EncodingUtil.urlEncode(paramCategory,'UTF-8');
        }
        if(paramSubcategory != null && paramSubcategory != ''){
            currBestPractices_list = [SELECT Id, Name,ESN_BP_Affiliate_Name__c,ESN_BP_Category__c,ESN_BP_Media_URLs__c,ESN_BP_Subcategory__c,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c WHERE ESN_BP_Subcategory__c = :paramSubcategory ORDER BY ESN_BP_Best_Practice_Number__c];
            currentSearch = '&subcategory='+EncodingUtil.urlEncode(paramSubcategory,'UTF-8');
        }
        if(paramBenefit != null && paramBenefit != ''){
            currBestPractices_list = [SELECT Id, Name,ESN_BP_Affiliate_Name__c,ESN_BP_Category__c,ESN_BP_Media_URLs__c,ESN_BP_Subcategory__c,ESN_BP_Best_Practice_Number__c FROM ESN_Best_Practice__c WHERE ESN_BP_Benefit1__c = :paramBenefit OR ESN_BP_Benefit2__c = :paramBenefit OR ESN_BP_Benefit3__c = :paramBenefit OR ESN_BP_Benefit4__c = :paramBenefit OR ESN_BP_Benefit5__c = :paramBenefit OR ESN_BP_Benefit6__c = :paramBenefit OR ESN_BP_Benefit7__c = :paramBenefit OR ESN_BP_Benefit8__c = :paramBenefit OR ESN_BP_Benefit9__c = :paramBenefit OR ESN_BP_Benefit10__c = :paramBenefit ORDER BY ESN_BP_Best_Practice_Number__c];
            currentSearch = '&benefit='+EncodingUtil.urlEncode(paramBenefit,'UTF-8');
        }
        if(paramSearch != null && paramSearch != ''){
            currBestPractices_list = (List<ESN_Best_Practice__c>)[FIND :paramSearch RETURNING ESN_Best_Practice__c(Id, Name,ESN_BP_Affiliate_Name__c,ESN_BP_Media_URLs__c,ESN_BP_Category__c,ESN_BP_Subcategory__c,ESN_BP_Best_Practice_Number__c ORDER BY ESN_BP_Best_Practice_Number__c ASC)].get(0);
            searchFree = paramSearch;
            currentSearch = '&search='+EncodingUtil.urlEncode(paramSearch,'UTF-8');
        }
        if(currBestPractices_list != null && currBestPractices_list.size() != 0){
            for(ESN_Best_Practice__c bp : currBestPractices_list ){
                currBbWrapper_list.add(new BpWrapper(bp));
            }
        }else{
            noResult = true;
        }
    }
    
    /*
     *    Run the free search.
     ***/
    public pageReference submitSearch() {    
        pageReference results;
        if(searchFree != '' && searchFree.length() >= 2){
            results = new PageReference('/apex/ESN_VFP16_BP_Results?search='+EncodingUtil.urlEncode(searchFree,'UTF-8'));
            results.setRedirect(true);
        } else {
            if(searchFree.length() < 2){
                searchTooShort = true;
                noResult = false;
            }else{
                searchTooShort = false;
                noResult = true;
            }
            currBestPractices_list.clear();
            results = null;
        }                
        return results;
    }

    /*
     *    Clear the free search.
     ***/
    public pageReference clearSearch() {
        searchFree = '';
        return null;        
    }
}