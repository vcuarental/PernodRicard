public with sharing class EUR_CRM_ContractListingController extends EUR_CRM_ComponentControllerBase{
    //Component Parameters
    public EUR_CRM_Contract__c contractObj {get;set;}
    public List<EUR_CRM_Quality__c> brandQualityReferenceList {get;set;}{brandQualityReferenceList = new List<EUR_CRM_Quality__c>();}
    //Deafult all Listing Pouring records under Contract
//    public List<EUR_CRM_Contract_Product_Item__c> listingPouringReferenceList {get;set;}{listingPouringReferenceList = new List<EUR_CRM_Contract_Product_Item__c> ();}

    //Local Variables
    public Map<Id, ListingPouringCategoryWrapper> listingMap {get;set;}//{listingMap = new Map<Id, ListingPouringCategoryWrapper>();}
    public Integer listingMapSize {get{return listingMap.size();}}
    public List<SelectOption> categoryOptions {get;set;} //{categoryOptions = new List<SelectOption>();}
    public Id selectedCategory{get;set;}
    public Boolean showAllFlag {get;set;}

    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }

    public Boolean init(){
        System.debug('\n\n Boolean EUR_CRM_ContractListingController.init([]) \n');
        System.debug('Flag - Contract:'+contractObj);
//        listingPouringReferenceList = new List<EUR_CRM_Contract_Product_Item__c> ();
        listingMap = new Map<Id, ListingPouringCategoryWrapper>();
        categoryOptions = new List<SelectOption>();

        System.debug('\n\n contractObj => ' + JSON.serializePretty(contractObj) + '\n');

        if (contractObj!=null){
            //init existingListingPouring - Key:EUR_CRM_Quality__c Id
            Map<Id, EUR_CRM_Contract_Product_Item__c> exsitingListingPouringMap = new Map<Id, EUR_CRM_Contract_Product_Item__c> ();
//            System.debug('\n\n listingPouringReferenceList.size() => ' + JSON.serializePretty(listingPouringReferenceList.size()) + '\n');
//            System.debug('\n\n listingPouringReferenceList => ' + JSON.serializePretty(listingPouringReferenceList) + '\n');
//            if (listingPouringReferenceList.size()>0){
//                for (EUR_CRM_Contract_Product_Item__c listingPouring: listingPouringReferenceList){
//                    exsitingListingPouringMap.put(listingPouring.EUR_CRM_Brand_Quality__c, listingPouring);
//                }
//            }else{
            exsitingListingPouringMap = initExistingListing(contractObj.Id);
            exsitingListingPouringMap = (exsitingListingPouringMap==null)?new Map<Id, EUR_CRM_Contract_Product_Item__c>():exsitingListingPouringMap;
//            }

            System.debug('\n\n exsitingListingPouringMap.size() => ' + JSON.serializePretty(exsitingListingPouringMap.size()) + '\n');
            System.debug('\n\n exsitingListingPouringMap => ' + JSON.serializePretty(exsitingListingPouringMap) + '\n');

            //init Create Listing Pourrig Wrapper Map and Category select option
            System.debug('Flag - Listing Pouring Component - BQ Ref:' + brandQualityReferenceList);

            System.debug('\n\n brandQualityReferenceList.size() => ' + JSON.serializePretty(brandQualityReferenceList.size()) + '\n');
            System.debug('\n\n brandQualityReferenceList => ' + JSON.serializePretty(brandQualityReferenceList) + '\n');

            Map<String, Map<Id,String>> categoryMap = new Map<String, Map<Id,String>>();
            for (EUR_CRM_Quality__c brandQuality: brandQualityReferenceList){
                Id listingPouringCategoryKey = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c;
                if (listingPouringCategoryKey == null) { continue; }

                Id lpItemKey = brandQuality.Id;
                ListingPouringCategoryWrapper listingPouringWrapper = (listingMap.containsKey(listingPouringCategoryKey))? listingMap.get(listingPouringCategoryKey):new ListingPouringCategoryWrapper();
                //Add on listing pouring map
                if (exsitingListingPouringMap.containsKey(lpItemKey)){
                    listingPouringWrapper.addListingPouring(exsitingListingPouringMap.get(lpItemKey));
                }
                else{
                    listingPouringWrapper.addListingPouring(contractObj.Id, brandQuality);
                }
                listingMap.put(brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c, listingPouringWrapper);
                //Add on Category Map
                String categoryKey = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name+'_'+brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c;
                categoryMap.put(categoryKey, new Map<Id,String>{brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c => brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name});
                //categoryMap.put(brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c, brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name);
            }
            System.debug('\n\n listingMap.size() => ' + JSON.serializePretty(listingMap.size()) + '\n');
            System.debug('\n\n listingMap => ' + JSON.serializePretty(listingMap) + '\n');

            System.debug('\n\n categoryMap.size() => ' + JSON.serializePretty(categoryMap.size()) + '\n');
            System.debug('\n\n categoryMap => ' + JSON.serializePretty(categoryMap) + '\n');

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

            System.debug('\n\n categoryOptions.size() => ' + JSON.serializePretty(categoryOptions.size()) + '\n');
            System.debug('\n\n categoryOptions => ' + categoryOptions + '\n');

            System.debug('\n\n selectedCategory => ' + JSON.serializePretty(selectedCategory) + '\n');

            return true;
        }
        return false;
    }

    private void reInitListingMap() {
        listingMap = new Map<Id, ListingPouringCategoryWrapper>();

        Map<Id, EUR_CRM_Contract_Product_Item__c> exsitingListingPouringMap = new Map<Id, EUR_CRM_Contract_Product_Item__c> ();
        exsitingListingPouringMap = initExistingListing(contractObj.Id);
        exsitingListingPouringMap = (exsitingListingPouringMap==null)?new Map<Id, EUR_CRM_Contract_Product_Item__c>():exsitingListingPouringMap;

        System.debug('\n\n exsitingListingPouringMap.size() => ' + JSON.serializePretty(exsitingListingPouringMap.size()) + '\n');
        System.debug('\n\n exsitingListingPouringMap => ' + JSON.serializePretty(exsitingListingPouringMap) + '\n');

        for (EUR_CRM_Quality__c brandQuality: brandQualityReferenceList){
            Id listingPouringCategoryKey = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c;
            Id lpItemKey = brandQuality.Id;
            ListingPouringCategoryWrapper listingPouringWrapper = (listingMap.containsKey(listingPouringCategoryKey))? listingMap.get(listingPouringCategoryKey):new ListingPouringCategoryWrapper();
            //Add on listing pouring map
            if (exsitingListingPouringMap.containsKey(lpItemKey)){
                listingPouringWrapper.addListingPouring(exsitingListingPouringMap.get(lpItemKey));
            }
            else{
                listingPouringWrapper.addListingPouring(contractObj.Id, brandQuality);
            }
            listingMap.put(brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__c, listingPouringWrapper);
        }
        System.debug('\n\n listingMap.size() => ' + JSON.serializePretty(listingMap.size()) + '\n');
        System.debug('\n\n listingMap => ' + JSON.serializePretty(listingMap) + '\n');
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

        Map<Id, EUR_CRM_Contract_Product_Item__c> cpiListingToDeleteIds = new Map<Id, EUR_CRM_Contract_Product_Item__c>();
        Set<Id> caiWithDeletedChildrenIds = new Set<Id>();
        Set<EUR_CRM_Contract_Product_Item__c> cpiListingToInsert = new Set<EUR_CRM_Contract_Product_Item__c>();

        System.debug('\n\n listingMap => ' + JSON.serializePretty(listingMap) + '\n');

        for (ListingPouringCategoryWrapper lpCatWrap: listingMap.values()) {
            for (ListingPouringWrapper lpWrap: lpCatWrap.createdListingPouring.values()) {
                if (lpWrap.isChecked == false && lpWrap.wasChecked == true){
                    cpiListingToDeleteIds.put(lpWrap.listingPouringObj.Id, lpWrap.listingPouringObj);
                    lpWrap.wasChecked = lpWrap.isChecked;
                    caiWithDeletedChildrenIds.add(lpWrap.listingPouringObj.EUR_CRM_Contract_Activity_Item__c);
                }
                if (lpWrap.isChecked == true && lpWrap.wasChecked == false){
                    lpWrap.wasChecked = lpWrap.isChecked;
                    cpiListingToInsert.add(lpWrap.listingPouringObj);
                }
            }
        }

        System.debug('\n\n cpiListingToDeleteIds.size() => ' + JSON.serializePretty(cpiListingToDeleteIds.size()) + '\n');
        System.debug('\n\n cpiListingToDeleteIds => ' + JSON.serializePretty(cpiListingToDeleteIds) + '\n');
        this.deletePouringContractProductItems(cpiListingToDeleteIds.values());
        this.deleteContractProductItems(cpiListingToDeleteIds.keySet());

        System.debug('\n\n cpiListingToInsert.size() => ' + JSON.serializePretty(cpiListingToInsert.size()) + '\n');
        System.debug('\n\n cpiListingToInsert => ' + JSON.serializePretty(cpiListingToInsert) + '\n');
        this.createContractProductItems(cpiListingToInsert);

        System.debug('\n\n caiWithDeletedChildrenIds.size() => ' + JSON.serializePretty(caiWithDeletedChildrenIds.size()) + '\n');
        System.debug('\n\n caiWithDeletedChildrenIds => ' + JSON.serializePretty(caiWithDeletedChildrenIds) + '\n');
        if(caiWithDeletedChildrenIds.isEmpty() || ! cpiListingToInsert.isEmpty()) { return; }

        this.deleteContractActivityItemsWithoutChildren(caiWithDeletedChildrenIds);

        this.reInitListingMap();
    }

    private void deletePouringContractProductItems(List<EUR_CRM_Contract_Product_Item__c> cpiListingToDelete) {
        Set<Id> listingBrandQuqlities = new Set<Id>();
        for(EUR_CRM_Contract_Product_Item__c cpi : cpiListingToDelete) {
            listingBrandQuqlities.add(cpi.EUR_CRM_Brand_Quality__c);
        }

        List<EUR_CRM_Contract_Product_Item__c> existingPouringCPI = [
            SELECT Id, EUR_CRM_Contract_Activity_Item__c
            FROM EUR_CRM_Contract_Product_Item__c
            WHERE EUR_CRM_Brand_Quality__c IN :listingBrandQuqlities AND
            EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c = :contractObj.Id AND
            EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c = 'EUR_DE_House_Pouring'
        ];
        if(existingPouringCPI.isEmpty()) return;
        Id pouringContractActivityItemId = existingPouringCPI[0].EUR_CRM_Contract_Activity_Item__c;

        Database.delete(existingPouringCPI);

        List<EUR_CRM_Contract_Product_Item__c> allExistingPouringCPI = [
            SELECT Id
            FROM EUR_CRM_Contract_Product_Item__c
            WHERE EUR_CRM_Contract_Activity_Item__c = :pouringContractActivityItemId
            LIMIT 1
        ];
        if(allExistingPouringCPI.isEmpty()) {
            Database.delete(pouringContractActivityItemId);
        }
    }

    private Map<Id, EUR_CRM_Contract_Product_Item__c> initExistingListing(Id contractObjId){
        System.debug('Initializing Existing Listing Pouring for ' + contractObjId);

        Map<Id, EUR_CRM_Contract_Product_Item__c> listingMap = new Map<Id, EUR_CRM_Contract_Product_Item__c>();
        for (EUR_CRM_Contract_Product_Item__c listingPouring: [SELECT Id, Name,
            EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.Name,
            EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c,
            EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__c,
            EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
            EUR_CRM_Contract__c,
//            EUR_CRM_Listing__c, EUR_CRM_Pouring__c,
            EUR_CRM_Mechanic_Type_Name__c,
            EUR_CRM_Name_Reference__c, EUR_CRM_Contract_Activity_Item__c
        FROM EUR_CRM_Contract_Product_Item__c
        WHERE EUR_CRM_Contract__c=:contractObjId
            AND EUR_CRM_Mechanic_Type_Name__c = 'Listing'])
        {
            listingPouring.EUR_CRM_Name_Reference__c = listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            listingMap.put(listingPouring.EUR_CRM_Brand_Quality__c, listingPouring);
        }

        System.debug('\n\n listingMap.size() => ' + JSON.serializePretty(listingMap.size()) + '\n');
        System.debug('\n\n listingMap => ' + JSON.serializePretty(listingMap) + '\n');
        return listingMap;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void deleteContractProductItems(Set<Id> cpiListingToDeleteIds) {
        if (cpiListingToDeleteIds.isEmpty()) { return ; }

         Database.delete(new List<Id>(cpiListingToDeleteIds));
    }

    private void createContractProductItems(Set<EUR_CRM_Contract_Product_Item__c> cpiListingToInsert) {
        if (cpiListingToInsert.isEmpty()) { return ; }

        List<EUR_CRM_Contract_Activity_Item__c> cais = this.selectContractActivityItems();
        System.debug('\n\n cais => ' + JSON.serializePretty(cais) + '\n');
        if (cais.isEmpty()) {
            cais.add(this.createContractActivityItem());
        }

        this.setParentLinkOnContractProductItems(cpiListingToInsert, cais[0].Id);
        System.debug('\n\n createdListingPouring.size() => ' + JSON.serializePretty(cpiListingToInsert.size()) + '\n');
        System.debug('\n\n createdListingPouring => ' + JSON.serializePretty(cpiListingToInsert) + '\n');
        Database.upsert(new List<EUR_CRM_Contract_Product_Item__c>(cpiListingToInsert));
    }

    private void deleteContractActivityItemsWithoutChildren(Set<Id> caiWithDeletedChildrenIds) {
        List<EUR_CRM_Contract_Activity_Item__c> caiWithChildren = this.selectContractActivityItemsWithChildren(caiWithDeletedChildrenIds);
        System.debug('\n\n caiWithDeletedChildren.size() => ' + JSON.serializePretty(caiWithChildren.size()) + '\n');
        System.debug('\n\n caiWithDeletedChildren => ' + JSON.serializePretty(caiWithChildren) + '\n');

        List<EUR_CRM_Contract_Activity_Item__c> caisWithoutChildren = this.extraContractActivityItemsWithoutChildren(caiWithChildren);
        System.debug('\n\n caisToDelete.size() => ' + JSON.serializePretty(caisWithoutChildren.size()) + '\n');
        System.debug('\n\n caisToDelete => ' + JSON.serializePretty(caisWithoutChildren) + '\n');
        if (caisWithoutChildren.isEmpty()) { return ; }

        Database.delete(caisWithoutChildren);
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void setParentLinkOnContractProductItems(Set<EUR_CRM_Contract_Product_Item__c> createdListingPouring, Id caiId) {
        Id cpiRTID = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
        for (EUR_CRM_Contract_Product_Item__c cpi : createdListingPouring) {
            this.updateContractProductItem(cpi, caiId, cpiRTID);
        }
    }

    private EUR_CRM_Contract_Activity_Item__c createContractActivityItem() {
        List<EUR_CRM_Mechanic_Type__c> mechanicTypes = this.selectMechanicTypes();
        if (mechanicTypes.isEmpty()) {
            throw new EUR_CRM_ContractListingControllerException('There is no Mechanic Type with an External Id "EUR_DE_Listing"!');
        }

        EUR_CRM_Contract_Activity_Item__c cai = this.makeContractActivityItem(mechanicTypes[0].Id);
        insert cai;
        return cai;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Contract_Activity_Item__c> extraContractActivityItemsWithoutChildren(List<EUR_CRM_Contract_Activity_Item__c> caiWithChildren) {
        List<EUR_CRM_Contract_Activity_Item__c> caisWithoutChildren = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c cai : caiWithChildren) {
            if (cai.Contract_Product_Items__r.isEmpty()) {
                caisWithoutChildren.add(cai);
            }
        }
        return caisWithoutChildren;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private EUR_CRM_Contract_Activity_Item__c makeContractActivityItem(Id mechanicTypeId) {
        return new EUR_CRM_Contract_Activity_Item__c(
            EUR_CRM_Contract__c = this.contractObj.Id
        ,   RecordTypeId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Activity_Item').getRecordTypeId()
        ,   EUR_CRM_Mechanic_Type__c = mechanicTypeId
        );
    }

    private void updateContractProductItem(EUR_CRM_Contract_Product_Item__c cpi, Id caiId, Id cpiRTID) {
        cpi.EUR_CRM_Contract_Activity_Item__c = caiId;
        cpi.RecordTypeId = cpiRTID;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Contract_Activity_Item__c> selectContractActivityItems() {
        return [
            SELECT Id
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c = :contractObj.Id
                AND EUR_CRM_Mechanic_Type_Name__c = 'Listing'
            LIMIT 1
        ];
    }

    private List<EUR_CRM_Mechanic_Type__c> selectMechanicTypes() {
        return [
            SELECT Id
            FROM EUR_CRM_Mechanic_Type__c
            WHERE EUR_CRM_External_ID__c = 'EUR_DE_Listing'
            LIMIT 1
        ];
    }

    private List<EUR_CRM_Contract_Activity_Item__c> selectContractActivityItemsWithChildren(Set<Id> caiIds) {
        return [
            SELECT Id
            ,   (
                SELECT Id
                FROM Contract_Product_Items__r
                LIMIT 1
            )
            FROM EUR_CRM_Contract_Activity_Item__c
            WHERE EUR_CRM_Contract__c = :this.contractObj.Id
                AND Id IN :caiIds
        ];
    }

    public class ListingPouringCategoryWrapper{
        //Key - EUR_CRM_Quality__c Id
        public Map<Id, ListingPouringWrapper> createdListingPouring{get;set;}{createdListingPouring = new Map<Id, ListingPouringWrapper>();}
        public ListingPouringCategoryWrapper(){}

        public void addListingPouring (EUR_CRM_Contract_Product_Item__c listingPouring){
            ListingPouringWrapper lpWrap = new ListingPouringWrapper(listingPouring,
                listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                listingPouring.EUR_CRM_Brand_Quality__r.Name);
            lpWrap.wasChecked = true;
            lpWrap.isChecked = true;
            createdListingPouring.put(listingPouring.EUR_CRM_Brand_Quality__c, lpWrap);
        }
        public void addListingPouring (Id contractId, EUR_CRM_Quality__c brandQuality){
            EUR_CRM_Contract_Product_Item__c listingPouring = new EUR_CRM_Contract_Product_Item__c(
                EUR_CRM_Brand_Quality__c = brandQuality.Id
//                , EUR_CRM_Contract__c = contractId
            );
            //listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            listingPouring.EUR_CRM_Name_Reference__c = brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            ListingPouringWrapper lpWrap = new ListingPouringWrapper(listingPouring,
                brandQuality.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                brandQuality.Name);
            createdListingPouring.put(brandQuality.Id, lpWrap);
        }
    }

    public class ListingPouringWrapper{
        public EUR_CRM_Contract_Product_Item__c listingPouringObj {get;set;}
        public String categoryName {get;set;}
        public String brandQualityName {get;set;}
        public Boolean wasChecked {get;set;}
        public Boolean isChecked {get;set;}

        public ListingPouringWrapper(EUR_CRM_Contract_Product_Item__c listingPouringObj, String categoryName, String brandQualityName){
            this.listingPouringObj = listingPouringObj;
            this.categoryName = categoryName;
            this.brandQualityName = brandQualityName;
            this.wasChecked = false;
            this.isChecked = false;
        }
    }

    public class EUR_CRM_ContractListingControllerException extends Exception {}

}