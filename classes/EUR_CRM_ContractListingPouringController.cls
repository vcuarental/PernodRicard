public with sharing class EUR_CRM_ContractListingPouringController extends EUR_CRM_ComponentControllerBase{
    //Component Parameters
    public EUR_CRM_Contract__c contractObj {get;set;}
    public List<EUR_CRM_Quality__c> brandQualityReferenceList {get;set;}{brandQualityReferenceList = new List<EUR_CRM_Quality__c>();}
    //Deafult all Listing Pouring records under Contract
    public List<EUR_CRM_Contract_Listing_Pouring__c> listingPouringReferenceList {get;set;}{listingPouringReferenceList = new List<EUR_CRM_Contract_Listing_Pouring__c> ();}
    
    //Local Variables
    public Map<Id, ListingPouringCategoryWrapper> listingPouringMap {get;set;}//{listingPouringMap = new Map<Id, ListingPouringCategoryWrapper>();}
    public Integer listingPouringMapSize {get{return listingPouringMap.size();}}
    public List<SelectOption> categoryOptions {get;set;} //{categoryOptions = new List<SelectOption>();}
    public Id selectedCategory{get;set;}
    public Boolean showAllFlag {get;set;}
    
    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    
    public Boolean init(){
        System.debug('Flag - Contract:'+contractObj);
        listingPouringReferenceList = new List<EUR_CRM_Contract_Listing_Pouring__c> ();
        listingPouringMap = new Map<Id, ListingPouringCategoryWrapper>();
        categoryOptions = new List<SelectOption>();
        
        if (contractObj!=null){
            //init existingListingPouring - Key:EUR_CRM_Quality__c Id
            Map<Id, EUR_CRM_Contract_Listing_Pouring__c> exsitingListingPouringMap = new Map<Id, EUR_CRM_Contract_Listing_Pouring__c> ();
            System.debug(listingPouringReferenceList);
            if (listingPouringReferenceList.size()>0){
                for (EUR_CRM_Contract_Listing_Pouring__c listingPouring: listingPouringReferenceList){
                    exsitingListingPouringMap.put(listingPouring.EUR_CRM_Brand_Quality__c, listingPouring);
                }
            }else{
                exsitingListingPouringMap = initExistingListingPouring(contractObj.Id);
                exsitingListingPouringMap = (exsitingListingPouringMap==null)?new Map<Id, EUR_CRM_Contract_Listing_Pouring__c>():exsitingListingPouringMap;
            }
            
            //init Create Listing Pourrig Wrapper Map and Category select option
            System.debug('Flag - Listing Pouring Component - BQ Ref:' + brandQualityReferenceList);
            Map<String, Map<Id,String>> categoryMap = new Map<String, Map<Id,String>>();
            for (EUR_CRM_Quality__c brandQuality: brandQualityReferenceList){
                Id listingPouringCategoryKey = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c;
                Id lpItemKey = brandQuality.Id;
                ListingPouringCategoryWrapper listingPouringWrapper = (listingPouringMap.containsKey(listingPouringCategoryKey))?listingPouringMap.get(listingPouringCategoryKey):new ListingPouringCategoryWrapper();
                //Add on listing pouring map
                if (exsitingListingPouringMap.containsKey(lpItemKey)){
                    listingPouringWrapper.addListingPouring(exsitingListingPouringMap.get(lpItemKey));
                }
                else{
                    listingPouringWrapper.addListingPouring(contractObj.Id, brandQuality);
                }
                listingPouringMap.put(brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c, listingPouringWrapper);
                //Add on Category Map
                String categoryKey = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name+'_'+brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c;
                categoryMap.put(categoryKey, new Map<Id,String>{brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c => brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name});
                //categoryMap.put(brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c, brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name);
            }
            System.debug(listingPouringMap);
            
            //init Category Select Option
            List<String> catKeys = new List<String>(categoryMap.keySet());
            catKeys.sort();
            Integer count = 0;
            for (String key: catKeys){
                Map<Id,String> catMap = categoryMap.get(key);
                Id categoryId = new List<Id>(catMap.keySet())[0];
                if (categoryId!= null && catMap.values()[0]!=null){
                    categoryOptions.add(new SelectOption(categoryId, catMap.values()[0]));
                    //categoryOptions.add(new SelectOption(key, categoryMap.get(key)));
                    if (count == 0){
                        selectedCategory = categoryId;
                    }
                    count ++;
                }
            }
            
            return true;
        }
        return false;
    }
    
    public PageReference validateListingPouringCategory(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_CategoryId = params.get('PARAM_CATEGORY_ID');
        
        return pageRef;
    }
    
    public void save(){
        //Save all items with either listing or pouring
        //Delete items that was previously created but has no listing or pouring 
        Database.deleteResult[] deleteResultListingPouring;
        Database.upsertResult[] upsertResultListingPouring;
            
        Set<Id> deletedListingPouring = new Set<Id>();
        Set<EUR_CRM_Contract_Listing_Pouring__c> createdListingPouring = new Set<EUR_CRM_Contract_Listing_Pouring__c>();
        
        for (ListingPouringCategoryWrapper lpCatWrap: listingPouringMap.values())
        {
            for (ListingPouringWrapper lpWrap: lpCatWrap.createdListingPouring.values()){
                if (lpWrap.listingPouringObj.Id!=null && (!lpWrap.listingPouringObj.EUR_CRM_Listing__c) 
                    && (!lpWrap.listingPouringObj.EUR_CRM_Pouring__c)){
                    deletedListingPouring.add(lpWrap.listingPouringObj.Id);
                }
                if (lpWrap.listingPouringObj.EUR_CRM_Listing__c || lpWrap.listingPouringObj.EUR_CRM_Pouring__c){
                    createdListingPouring.add(lpWrap.listingPouringObj);
                }
            }
        }

        System.debug(createdListingPouring);
        System.debug(createdListingPouring.size());
        
        if(deletedListingPouring.size()>0){
            deleteResultListingPouring = Database.delete(new List<Id>(deletedListingPouring));
        }
        if(createdListingPouring.size()>0){
            upsertResultListingPouring = Database.upsert(new List<EUR_CRM_Contract_Listing_Pouring__c>(createdListingPouring));
        }
    }

    private Map<Id, EUR_CRM_Contract_Listing_Pouring__c> initExistingListingPouring(Id contractObjId){
        System.debug('Initializing Existing Listing Pouring for ' + contractObjId);
        
        Map<Id, EUR_CRM_Contract_Listing_Pouring__c> listingPouringMap = new Map<Id, EUR_CRM_Contract_Listing_Pouring__c>();
        for (EUR_CRM_Contract_Listing_Pouring__c listingPouring: [SELECT Id, Name,
                                                                EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c, 
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                                                                EUR_CRM_Contract__c, 
                                                                EUR_CRM_Listing__c, EUR_CRM_Pouring__c,
                                                                EUR_CRM_Name_Reference__c
                                                                FROM EUR_CRM_Contract_Listing_Pouring__c
                                                                WHERE EUR_CRM_Contract__c=:contractObjId])
        {
            listingPouring.EUR_CRM_Name_Reference__c = listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            listingPouringMap.put(listingPouring.EUR_CRM_Brand_Quality__c, listingPouring);
        }
        
        System.debug(listingPouringMap);
        return listingPouringMap;
    }
    
    public class ListingPouringCategoryWrapper{
        //Key - EUR_CRM_Quality__c Id
        public Map<Id, ListingPouringWrapper> createdListingPouring{get;set;}{createdListingPouring = new Map<Id, ListingPouringWrapper>();} 
        public ListingPouringCategoryWrapper(){}
        
        public void addListingPouring (EUR_CRM_Contract_Listing_Pouring__c listingPouring){
            ListingPouringWrapper lpWrap = new ListingPouringWrapper(listingPouring, 
                                            listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name, 
                                            listingPouring.EUR_CRM_Brand_Quality__r.Name);
            createdListingPouring.put(listingPouring.EUR_CRM_Brand_Quality__c, lpWrap);
        }
        public void addListingPouring (Id contractId, EUR_CRM_Quality__c brandQuality){
            EUR_CRM_Contract_Listing_Pouring__c listingPouring = new EUR_CRM_Contract_Listing_Pouring__c(
                                            EUR_CRM_Brand_Quality__c = brandQuality.Id,
                                            EUR_CRM_Contract__c = contractId);
            //listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            listingPouring.EUR_CRM_Name_Reference__c = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            ListingPouringWrapper lpWrap = new ListingPouringWrapper(listingPouring, 
                                            brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name, 
                                            brandQuality.Name);
            createdListingPouring.put(brandQuality.Id, lpWrap);
        }
    }
    
    public class ListingPouringWrapper{
        public EUR_CRM_Contract_Listing_Pouring__c listingPouringObj {get;set;}
        public String categoryName {get;set;}
        public String brandQualityName {get;set;}
        
        public ListingPouringWrapper(EUR_CRM_Contract_Listing_Pouring__c listingPouringObj, String categoryName, String brandQualityName){
            this.listingPouringObj = listingPouringObj;
            this.categoryName = categoryName;
            this.brandQualityName = brandQualityName;
        }
    }
}