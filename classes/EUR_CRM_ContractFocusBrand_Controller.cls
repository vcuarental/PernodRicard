/**
** Purpose: Build list of Contract Focus Brands
**/

public with sharing class EUR_CRM_ContractFocusBrand_Controller extends EUR_CRM_ComponentControllerBase{
    //Component Parameters
    //Contract(EU) Object - Master object of EUR_CRM_Contract_Focus_Brand__c
    public EUR_CRM_Contract__c contractObj {get;set;}
    //List of all Brands
    public List<EUR_CRM_Brand__c> brandReferenceList {get;set;}{brandReferenceList = new List<EUR_CRM_Brand__c>();}
    //Map of existing Focus Brands. Key - Id of EUR_CRM_Brand__c
    public List<EUR_CRM_Contract_Focus_Brand__c> existingFocusBrandsList {get;set;}{existingFocusBrandsList = new List<EUR_CRM_Contract_Focus_Brand__c>();}
    //Determines if existing focus brands should be populated, default to false
    //public Boolean populateExistingFocusBrands{get;set;}{populateExistingFocusBrands = false;}
    
    //Local Variables
    //Map of all Brands
    public Map<Id, EUR_CRM_Brand__c> brandReference {get;set;} {brandReference = new Map<Id, EUR_CRM_Brand__c>();}
    //Map of existing Focus Brands. Key - Id of EUR_CRM_Brand__c
    public Map<Id, EUR_CRM_Contract_Focus_Brand__c> existingFocusBrands {get;set;} {existingFocusBrands = new Map<Id, EUR_CRM_Contract_Focus_Brand__c>();}
    public Map<Id, EUR_CRM_Brand__c> brandSelection {get;set;}{brandSelection =  new Map<Id, EUR_CRM_Brand__c> ();}
    public Map<Id, EUR_CRM_Contract_Focus_Brand__c> createdFocusBrands {get;set;} //Key: Id - EUR_CRM_Brand__c
    public Set<Id> deletedFocusBrands {get;set;}
    
    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    
    public boolean init (){
        brandReference = new Map<Id, EUR_CRM_Brand__c>();
        //existingFocusBrandsList = new List<EUR_CRM_Contract_Focus_Brand__c>();
        existingFocusBrands = new Map<Id, EUR_CRM_Contract_Focus_Brand__c>();
        brandSelection =  new Map<Id, EUR_CRM_Brand__c> ();
        createdFocusBrands = new Map<Id, EUR_CRM_Contract_Focus_Brand__c>();
        deletedFocusBrands = new  Set<Id>();
        
        //init brand reference
        for(EUR_CRM_Brand__c brand: brandReferenceList){
            brandReference.put(brand.Id, brand);
        }
        //System.debug('Flag - Focus Brand - Brand Ref:' + brandReference);
        //Init existing focus brands
        if (existingFocusBrandsList==null || existingFocusBrandsList.size()<=0){
            if (contractObj!=null){
                existingFocusBrands = initExistingFocusBrands(contractObj.Id);
            }
        }else{
            for(EUR_CRM_Contract_Focus_Brand__c focusBrand: existingFocusBrandsList){
                existingFocusBrands.put(focusBrand.EUR_CRM_Brand__c, focusBrand);
            }
        }
        
        if(existingFocusBrands.size()>0){
            //init createdFocusBrands
            createdFocusBrands.putAll(existingFocusBrands);
        }
        //init brand selection
        brandSelection = trimMap(brandReference, existingFocusBrands.keySet());
        return true;
    }
    
    public PageReference addContractFocusBrand(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_BrandId = params.get('PARAM_BRAND_ID');
        
        if (contractObj!=null && brandReference.containsKey(param_BrandId)){
            EUR_CRM_Brand__c brand = brandReference.get(param_BrandId);
            //Create and Add Focus Brand
            EUR_CRM_Contract_Focus_Brand__c focusBrand = new EUR_CRM_Contract_Focus_Brand__c(EUR_CRM_Contract__c=contractObj.Id,
                                                        EUR_CRM_Brand__c=brand.Id);
            focusBrand.EUR_CRM_Name_Reference__c = brand.Name;
            createdFocusBrands.put(brand.Id, focusBrand);
            
            //Remove at Brand Selection
            if (brandSelection.containsKey(param_BrandId)){
                brandSelection.remove(param_BrandId);
            }
        }
        return pageRef;
    }
    
    public PageReference removeContractFocusBrand(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_BrandId = params.get('PARAM_BRAND_ID');
        //Add at Brand Selection
        if(brandReference.containsKey(param_BrandId)){
            brandSelection.put(param_BrandId, brandReference.get(param_BrandId));
        }
        //Remove at Created Focus Brands
        if(createdFocusBrands.containsKey(param_BrandId)){
            EUR_CRM_Contract_Focus_Brand__c focusBrand = createdFocusBrands.get(param_BrandId);
            //Add deleted focus brand item on Set
            if (focusBrand.Id != null){
                deletedFocusBrands.add(focusBrand.Id);
            }
            createdFocusBrands.remove(param_BrandId);
        }
        
        return pageRef;
    }
    
    private Map<Id, EUR_CRM_Contract_Focus_Brand__c> initExistingFocusBrands(Id contractObjId){
        Map<Id, EUR_CRM_Contract_Focus_Brand__c> focusBrands = new Map<Id, EUR_CRM_Contract_Focus_Brand__c>();
        
        for (EUR_CRM_Contract_Focus_Brand__c focusBrand : [SELECT Id, Name, 
                                                        EUR_CRM_Contract__c, EUR_CRM_Brand__c,
                                                        EUR_CRM_Brand__r.Name,
                                                        EUR_CRM_Name_Reference__c 
                                                        FROM EUR_CRM_Contract_Focus_Brand__c
                                                        WHERE EUR_CRM_Contract__c =: contractObjId])
        {
            focusBrand.EUR_CRM_Name_Reference__c = (focusBrand.EUR_CRM_Name_Reference__c == null) ? focusBrand.EUR_CRM_Brand__r.Name : focusBrand.EUR_CRM_Name_Reference__c;
            focusBrands.put(focusBrand.EUR_CRM_Brand__c, focusBrand);
        }
        System.debug('Flag - Focus Brand Component - Existing Focus Brands:' + focusBrands);
        return focusBrands;
    }
    
    private Map<Id, EUR_CRM_Brand__c> trimMap(Map<Id, EUR_CRM_Brand__c> referenceMap, Set<Id> referenceSet){
        Map<Id, EUR_CRM_Brand__c> trimmedMap = new Map<Id, EUR_CRM_Brand__c>();
        trimmedMap.putAll(referenceMap);
        //System.debug('Flag - Focus Brand - Trim Map:' + trimmedMap + '---'+ referenceSet);
        for(Id key: referenceSet){
            if (trimmedMap.containsKey(key)){
                trimmedMap.remove(key);
            }
        }
        System.debug('Flag - Focus Brand - Trim Map Result:' + trimmedMap);
        return trimmedMap;
    }
    
}