public class ESN_VFC15_BP_Home {

    /* Wrapper which contains Category and its subcategories */
    public class CategoryWrapper {
        public String catName {get;set;}
        public List<String> subCategory {get;set;}
        public Boolean hasSubcategory {get;set;}
        
        public CategoryWrapper(String cn, List<String> sc, Boolean hs){
            this.catName = cn.toLowerCase();
            this.subCategory = sc;
            this.hasSubcategory = hs;
        }
    }
    
    public List<ESN_Best_Practice__c> allBestPractices_list {get; set;}
    
    /* List of parameters (categories, subcategories, benefits) */
    public List<String> allBenefits_list {get; set;}
    public List<String> allCategories_list {get; set;}
    public Map<String,CategoryWrapper> categoryName2CategoryWrap_map {get; set;}
    
    public String benefitSelected {get;set;}
    public String freeSearch {get;set;}
    public String urlSFDC {get;set;}
    public String searchTooShortMsg {get;set;}
    public Boolean searchTooShort {get;set;}
    
    public ESN_VFC15_BP_Home(ApexPages.StandardController controller) {
        searchTooShort = false;
        categoryName2CategoryWrap_map = new Map<String,CategoryWrapper>();
        urlSFDC = URL.getSalesforceBaseUrl().toExternalForm();
        freeSearch = '';
                
        allBestPractices_list = [SELECT Id,ESN_BP_Category__c,ESN_BP_Subcategory__c,ESN_BP_Benefit1__c,ESN_BP_Benefit2__c,ESN_BP_Benefit3__c,ESN_BP_Benefit4__c,ESN_BP_Benefit5__c,ESN_BP_Benefit6__c,ESN_BP_Benefit7__c,ESN_BP_Benefit8__c,ESN_BP_Benefit9__c,ESN_BP_Benefit10__c FROM ESN_Best_Practice__c ORDER BY ESN_BP_Best_Practice_Number__c];

        buildCategoryAndSubcategoryList();
        //buildBenefitsList();
        allCategories_list = new List<String>(categoryName2CategoryWrap_map.keySet());
    }
    
    
    /*
     *    Build the list of category and subcategory based on values in all best practices.
     ***/
    public void buildCategoryAndSubcategoryList(){
        Set<String> allSubcategory_set;
        Set<String> allCategory_set = new Set<String>();
        
        for(ESN_Best_Practice__c bp : allBestPractices_list){
            // Save the subcategory if not already in set
            if(bp.ESN_BP_Subcategory__c == '' || bp.ESN_BP_Subcategory__c == null){
            /*   CategoryWrapper cWrp = new CategoryWrapper(bp.ESN_BP_Category__c,new List<String>(),false);
               categoryName2CategoryWrap_map.put(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace(), cWrp);
               */
               if(!allCategory_set.contains(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace()))
                    allCategory_set.add(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace());
            }else{
                if(!allCategory_set.contains(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace()))
                    allCategory_set.add(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace());
                    
                if(categoryName2CategoryWrap_map.containsKey(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace())){
                    // This category has been already added to the map //
                    CategoryWrapper currCatWrp = categoryName2CategoryWrap_map.get(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace());
                    
                    if(currCatWrp.subCategory != null)
                        allSubcategory_set = new Set<String>(currCatWrp.subCategory);    // Get the current list of its subcategory
                    else
                        allSubcategory_set = new Set<String>();
                         
                    // If this subcategory is not already in the list.
                    if(!allSubcategory_set.contains(bp.ESN_BP_Subcategory__c)){ 
                        allSubcategory_set.add(bp.ESN_BP_Subcategory__c);
                        // Create a temporary list to sort subcategories //
                        List<String> subcat_list = new List<String>(allSubcategory_set);
                        subcat_list.sort();
                        currCatWrp.subCategory = subcat_list;
                        // indicates this category has at less one subcategory.
                        currCatWrp.hasSubcategory = true; 
                        // add to the map
                        categoryName2CategoryWrap_map.put(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace(), currCatWrp);
                    }
                }else{
                    // It's the first time this category is treated.
                    List<String> subC = new List<String>();
                    subC.add(bp.ESN_BP_Subcategory__c);
                    CategoryWrapper cWrp = new CategoryWrapper(bp.ESN_BP_Category__c,subC,true);
                    categoryName2CategoryWrap_map.put(bp.ESN_BP_Category__c.toLowerCase().deleteWhitespace(), cWrp);
                }            
            }
        }
        
        for(String cat : allCategory_set){
            if(!categoryName2CategoryWrap_map.containsKey(cat))
                categoryName2CategoryWrap_map.put(cat, new CategoryWrapper(cat,null,false));
        }
    }
    
    /*
     *    Build the list of Benefit based on values in all best practices.
     ***/
    public void buildBenefitsList(){
        Set<String> allBenefits_set = new Set<String>();
        Set<String> allCategories_set = new Set<String>();
        Set<String> allSubcategory_set;
    
        for(ESN_Best_Practice__c bp : allBestPractices_list){
            // Save the benefit if not already in set
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit1__c))
                allBenefits_set.add(bp.ESN_BP_Benefit1__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit2__c))
                allBenefits_set.add(bp.ESN_BP_Benefit2__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit3__c))
                allBenefits_set.add(bp.ESN_BP_Benefit3__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit4__c))
                allBenefits_set.add(bp.ESN_BP_Benefit4__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit5__c))
                allBenefits_set.add(bp.ESN_BP_Benefit5__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit6__c))
                allBenefits_set.add(bp.ESN_BP_Benefit6__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit7__c))
                allBenefits_set.add(bp.ESN_BP_Benefit7__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit8__c))
                allBenefits_set.add(bp.ESN_BP_Benefit8__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit9__c))
                allBenefits_set.add(bp.ESN_BP_Benefit9__c);
            if(!allBenefits_set.contains(bp.ESN_BP_Benefit10__c))
                allBenefits_set.add(bp.ESN_BP_Benefit10__c);
        }
        allBenefits_list = new List<String>(allBenefits_set);
        allBenefits_list.sort();
    }
    /*
     *    Run the free search.
     ***/
    public pageReference submitSearch() {    
        pageReference results;
        if(freeSearch != '' && freeSearch.length() >= 2)
            results = new PageReference('/apex/ESN_VFP16_BP_Results?search='+EncodingUtil.urlEncode(freeSearch,'UTF-8'));
        else {
            if(freeSearch.length() < 2){
                searchTooShortMsg = 'Your search must contain at least 2 characters.';
                searchTooShort = true;
            }else{
                searchTooShortMsg = '';
                searchTooShort = false;
            }
            results = null;
        }
        return results;
    }

    /*
     *    Clear the free search.
     ***/
    public pageReference clearSearch() {
        freeSearch = '';
        return null;        
    }
}