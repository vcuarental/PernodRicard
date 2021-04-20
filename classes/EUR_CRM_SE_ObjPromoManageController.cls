public with sharing class EUR_CRM_SE_ObjPromoManageController  extends EUR_CRM_AbstractSelectionItem{

    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    public Boolean isDraft {get; set;}
    public Boolean isDeactivated {get; set;}
    public Boolean isActive {get; set;}
    public Boolean isAccountSelectionDone {get; set;}
    public Boolean isProductSelectionDone {get; set;}
    public Boolean isTargetManagementDone {get; set;}
    public String selectedSelectionMethod {get; set;}
    public String selectedProductSelection {get; set;}
    public String selectedProductLevel {get;set;}
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> regionalTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srTargets {get;set;}
    public EUR_CRM_AbstractSelectionItem sCon {get; set;}
    public ApexPages.StandardController standardController {get; set;}
    public String PromoKitTargetUnitOpt {get;set;}

    public static Integer ROWS_PER_PAGE = 50;
    public Integer euAccountsPageNum {get; set;}
    public Boolean euAccountsPageHasMore {get; set;}
    public Integer euAccountsFirstIndex {get; set;}
    public Integer totalPages;

    public List<SelectOption> getPromoKitUnits(){
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Promokit','Promo Kit'));
            options.add(new SelectOption('Bottles','Bottles'));
            return options;
    }
    
    // Account Management
    private Set<Id> taxonomyIds = new Set<Id>();
    private Set<Id> accountIdsFromOPMapping = new Set<Id>();
    public List<EUR_CRM_Account__c> euAccounts {get; set;}
    public List<EUR_CRM_Account__c> pagedEUAccounts {get; set;}
    
    // Target Management
    // Maps Regional Manager's Id to a list of SR Ids under the manager
    private Map<Id, List<Id>> regionalSalesRepMap;
    private List<EUR_CRM_OPTargetHelperClass.TargetWrap> regionalTargetWrap;
    private List<User> regionalManagers;
    public Id regionManager {get;set;}
    

    //OP Target 
    //public final String OT_OBJ_VOLUME_TARGET   = 'EUR_SE_Objective_Volume_Target';
    //public final String OT_SR_VOLUME_TARGET    = 'EUR_SE_SR_Volume_Target';
    //public final String OT_OBJ_PRODUCT_TARGET  = 'EUR_SE_Objective_Product';
    //public final String OT_MG_VOLUME_TARGET    = 'EUR_SE_Manager_Volume_Target';

    //OP Record 
    public final String OP_LISTING_CAMPAIGN  	= 'EUR_SE_Listing_Campaign';
    public final String OP_STAFF_COM       		= 'EUR_SE_Staff_Communication';
    public final String OP_VOL_CAM     			= 'EUR_SE_Volume_Campaign';
    public final String OP_VOL_TRIP  			= 'EUR_SE_Volume_Trip_Campaign_Bundle';
    public final String OP_VOL_CAM_SM  			= 'EUR_SE_Volume_Campaign_Slow_moving';
    public final String OP_EVENT  				= 'EUR_SE_Events';
    public final String OP_STAFF_TRAIN  		= 'EUR_SE_Staff_Training_Education';

    //Flag
    public Boolean isSaleDrive 		{get;set;}{isSaleDrive=false;}
    public Boolean isProductSel 	{get;set;}{isProductSel=false;}

    //Define what kine of OP need Product selection and what product level is avalilable for selection
    private Map<String,String> poductSelectionLevel = new Map<String,String>
    		{	'EUR_SE_Listing_Campaign'			=>'EUR_CRM_Quality__c,EUR_CRM_Size__c',
    			'EUR_SE_Staff_Communication'		=>'EUR_CRM_Brand__c,EUR_CRM_Quality__c',
    			'EUR_SE_Volume_Campaign'			=>'EUR_CRM_Size__c',
    			'EUR_SE_Volume_Campaign_Slow_moving'=>'EUR_CRM_Size__c',
    			'EUR_SE_Events'						=>'EUR_CRM_Brand__c',
    			'EUR_SE_Staff_Training_Education' 	=>'EUR_CRM_Brand__c,EUR_CRM_Quality__c'
			};
    //Convert Field to Product Level : O/P Target.Field to Object / O/P Target.EUR_CRM_Product_Level__c
    private Map<String,String> fieldToProductLv = new Map<String,String>
            {   'EUR_CRM_SKU__c'    => 'EUR_CRM_SKU__c',
                'EUR_CRM_BQS__c'    => 'EUR_CRM_Size__c',
                'EUR_CRM_BQ__c'     => 'EUR_CRM_Quality__c',
                'EUR_CRM_Brand__c'  => 'EUR_CRM_Brand__c'
            };

    //Convert Product Level to Field : Object / O/P Target.EUR_CRM_Product_Level__c to O/P Target.Field      
    private Map<String,String> productLvToField = new Map<String,String>
            {   'EUR_CRM_SKU__c'    => 'EUR_CRM_SKU__c',
                'EUR_CRM_Size__c'   => 'EUR_CRM_BQS__c',
                'EUR_CRM_Quality__c'=> 'EUR_CRM_BQ__c',
                'EUR_CRM_Brand__c'  => 'EUR_CRM_Brand__c'
            };

    //Convert Product Level to Field : Object / O/P Target.EUR_CRM_Product_Level__c to O/P Target.Field      
    private Map<String,String> productSelMethodToField = new Map<String,String>
            {   'sku'    => 'EUR_CRM_SKU__c',
                'size'   => 'EUR_CRM_BQS__c',
                'quality'=> 'EUR_CRM_BQ__c',
                'brand'  => 'EUR_CRM_Brand__c'
            };


    private Set<String> OpTargetRtNameList = new Set<String>();

	//Record Type Mapping of O/P and O/P Target
	private Map<String,List<String>> opTargetMap = new Map<String,List<String>>
			{	'EUR_SE_Listing_Campaign'			=> New List<String>{'EUR_SE_Objective_Listing_Target'}, //,'EUR_SE_SR_Listing_Target'
    			'EUR_SE_Staff_Communication'		=> New List<String>{'EUR_SE_Objective_People_Target'}, //,'EUR_SE_SR_People_Target'
    			'EUR_SE_Volume_Campaign'			=> New List<String>{'EUR_SE_Objective_Volume_Target'}, //,'EUR_SE_SR_Volume_Target'
                'EUR_SE_Volume_Trip_Campaign_Bundle'=> New List<String>{'EUR_SE_Objective_Product'},
    			'EUR_SE_Volume_Campaign_Slow_moving'=> New List<String>{'EUR_SE_Objective_Volume_Target'}, //,'EUR_SE_SR_Volume_Target'
    			'EUR_SE_Events'						=> New List<String>{'EUR_SE_Objective_People_Target','EUR_SE_SR_People_Target'},
    			'EUR_SE_Staff_Training_Education' 	=> New List<String>{'EUR_SE_Objective_People_Target','EUR_SE_SR_People_Target'}
			};

    //Which Field to put the target
    private Map<String,String> opTargetFieldMap = new Map<String,String>
            {
                'EUR_SE_Listing_Campaign'           => 'EUR_CRM_Target_Quantity_Listing__c',
                'EUR_SE_Staff_Communication'        => 'EUR_CRM_Target_Quantity_People__c',
                'EUR_SE_Volume_Campaign'            => 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
                'EUR_SE_Volume_Trip_Campaign_Bundle'=> '',
                'EUR_SE_Volume_Campaign_Slow_moving'=> 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
                'EUR_SE_Events'                     => 'EUR_CRM_Target_Quantity_People__c',
                'EUR_SE_Staff_Training_Education'   => 'EUR_CRM_Target_Quantity_People__c'
            };

    public String getTargetQtyField(){return opTargetFieldMap.get(this.objpromo.RecordType.DeveloperName);}
    public String getTargetProductField(){

        if(selectedProductLevel == null){
            //If no targets is created, use the user selected product selection method
            return productSelMethodToField.get(this.selectedProductSelection);
        }else{
            //If targets is created, use the product selection method from targets
            return productLvToField.get(this.selectedProductLevel);
        }
    }

    private Set<String> opTargetReallocate = new Set<String>
            {   'EUR_SE_Events',
                'EUR_SE_Staff_Training_Education'
            };

	//Define what kind of OP need SR Level Target Management
	private Set<String> requireSRTarget = New Set<String>{'EUR_SE_Events','EUR_SE_Staff_Training_Education'};

	//Define what kind of OP need Manager Level Target Management
	private Set<String> requireMGTarget = New Set<String>{''};

        //Define what kind of OP need Objective Level Target Management
    private Set<String> requireOPTarget = New Set<String>{'EUR_SE_Listing_Campaign','EUR_SE_Staff_Communication','EUR_SE_Volume_Campaign','EUR_SE_Volume_Campaign_Slow_moving','EUR_SE_Events','EUR_SE_Staff_Training_Education'};

	//Define what kind of account selection method for each OP type
	private Set<String> accSelectOptListView = New Set<String>{'EUR_SE_Listing_Campaign','EUR_SE_Staff_Communication','EUR_SE_Volume_Campaign','EUR_SE_Volume_Trip_Campaign_Bundle','EUR_SE_Volume_Campaign_Slow_moving','EUR_SE_Events','EUR_SE_Staff_Training_Education'};
	private Set<String> accSelectOptCTax = New Set<String>{'EUR_SE_Listing_Campaign','EUR_SE_Staff_Communication','EUR_SE_Volume_Campaign','EUR_SE_Volume_Trip_Campaign_Bundle','EUR_SE_Volume_Campaign_Slow_moving','EUR_SE_Events','EUR_SE_Staff_Training_Education'};
	private Set<String> accSelectOptPRS = New Set<String>{'EUR_SE_Listing_Campaign','EUR_SE_Staff_Communication','EUR_SE_Volume_Campaign','EUR_SE_Volume_Trip_Campaign_Bundle','EUR_SE_Volume_Campaign_Slow_moving','EUR_SE_Events','EUR_SE_Staff_Training_Education'};

    public Boolean getIsEditable(){
        Boolean editable = False;
        
        If(this.objPromo.EUR_CRM_Status__c == 'Draft'){
            editable = True;
        }Else If(this.objPromo.EUR_CRM_Status__c == 'Published' && opTargetReallocate.contains(this.objPromo.RecordType.DeveloperName)){
            editable = True;
        }Else If(this.objPromo.EUR_CRM_Status__c == 'Activate' && opTargetReallocate.contains(this.objPromo.RecordType.DeveloperName)){
            editable = True;
        }
        return editable;
    }

    public Boolean getIsListViewOptionRendered() {
        return accSelectOptListView.contains(this.objPromo.RecordType.Developername);
    }
    public Boolean getIsCTaxOptionRendered() {
        return accSelectOptCTax.contains(this.objPromo.RecordType.Developername);
    }
    public Boolean getIsPRSOptionRendered() {
        return accSelectOptPRS.contains(this.objPromo.RecordType.Developername);
    }

	public Boolean getIsAccountListView() {
        return selectedSelectionMethod == 'listView';
    }
    public Boolean getIsCustomerTaxonomy() {
        return selectedSelectionMethod == 'cTax';
    }
    public Boolean getIsPRS() {
        return selectedSelectionMethod == 'pros';
    }

    //Control Product Level Option 
    public Boolean getIsBrandRendered() {
        if(!poductSelectionLevel.keyset().contains(this.objPromo.recordType.developername)){
            return false;
        }
        return poductSelectionLevel.get(this.objPromo.recordType.developername).contains('EUR_CRM_Brand__c');
    }
    public Boolean getIsBrandSizeRendered() {
        if(!poductSelectionLevel.keyset().contains(this.objPromo.recordType.developername)){
            return false;
        }
        return poductSelectionLevel.get(this.objPromo.recordType.developername).contains('EUR_CRM_Size__c');
    }
    public Boolean getIsBrandQualityRendered(){
        if(!poductSelectionLevel.keyset().contains(this.objPromo.recordType.developername)){
            return false;
        }
      	return poductSelectionLevel.get(this.objPromo.recordType.developername).contains('EUR_CRM_Quality__c');
    }
    public Boolean getIsSKURendered() {
        if(!poductSelectionLevel.keyset().contains(this.objPromo.recordType.developername)){
            return false;
        }
        return poductSelectionLevel.get(this.objPromo.recordType.developername).contains('EUR_CRM_SKU__c');
    }

    public Boolean getIsBrandSize() {
        return selectedProductSelection == 'size';
    }
    public Boolean getIsSKU() {
        return selectedProductSelection == 'sku';
    }
    public Boolean getIsBrandQuality(){
        return selectedProductSelection == 'quality';
    }
	public Boolean getIsBrand(){
        return selectedProductSelection == 'brand';
    }

/*
        'EUR_SE_Listing_Campaign'=>'SE_ON_Listing_Campaign',
        'EUR_SE_Staff_Communication'=>'SE_ON_Staff_Communication',
        'EUR_SE_Volume_Campaign'=>'SE_ON_Volume_Campaign',
        'EUR_SE_Volume_Trip_Campaign_Bundle'=>'SE_ON_Volume_Trip_Campaign_Bundle',
        'EUR_SE_Volume_Campaign_Slow_moving'=>'SE_ON_Volume_Campaign_Slow_moving',
        'EUR_SE_Events'=>'SE_ON_Events',
        'EUR_SE_Staff_Training_Education'=>'SE_ON_Staff_Training_Education'


*/


    Map<String, Id> rtMap;

    public EUR_CRM_SE_ObjPromoManageController(ApexPages.StandardController sc) {
        this.standardController = sc;
        this.objPromo = [SELECT Id, recordtypeId, recordtype.developername,
                         EUR_CRM_Is_Quota__c, EUR_CRM_Status__c, EUR_CRM_Is_Publish_ready__c
                         FROM EUR_CRM_ObjPromo__c
                         WHERE ID = :ApexPages.currentPage().getParameters().get('ObjPromoId')];
        this.rtMap = new Map<String, Id>();
        this.isDraft = this.objPromo != null && this.objPromo.EUR_CRM_Status__c == 'Draft';
        this.isDeactivated = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Deactivated';
        this.isActive = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Active';
        
        // Initialize record types
        for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo__c')) {
            rtMap.put(rt.developername, rt.Id);
        }
        
        // Add O/P Target record types to rtMap as well for later use
        for(String OPRtName : opTargetMap.KeySet()){
            for(String OPTRtName : (List<String>)opTargetMap.get(OPRtName)){
                rtMap.put(OPTRtName,Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OPTRtName));
                OpTargetRtNameList.add(OPTRtName);
            }
        }

        //rtMap.put(OT_OBJ_VOLUME_TARGET, 	Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OT_OBJ_VOLUME_TARGET));
        //rtMap.put(OT_SR_VOLUME_TARGET, 		Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OT_SR_VOLUME_TARGET));
        //rtMap.put(OT_OBJ_PRODUCT_TARGET, 	Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OT_OBJ_PRODUCT_TARGET));
        //rtMap.put(OT_MG_VOLUME_TARGET, 		Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OT_MG_VOLUME_TARGET));

        
        initializeAccountSelection();

        if(poductSelectionLevel.KeySet().contains(this.objPromo.RecordType.Developername)){
            initializeProductSelection();
        }
        if(requireSRTarget.contains(this.objPromo.RecordType.Developername) ){
            initializeSRTargets();
        }
        
        initializeTargetManagement();


        //Setup default Promot Kit Unit Type Selection, Depends on the first record
        /*If(objPromo.RecordType.DeveloperName == OP_ON_PROMO_KIT){
          If(targets.size() > 0){
            If(targets[0].EUR_CRM_Qty_Sell_in_Amount_Bottle__c != null && targets[0].EUR_CRM_Qty_Sell_in_Amount_Bottle__c > 0){
              PromoKitTargetUnitOpt = 'Bottles';
            }
          }
        }*/
        
    }
    
    public void initializeAccountSelection() {
        // Account Management
        euAccountsPageNum = 0;
        accountIdsFromOPMapping = EUR_CRM_OPTargetHelperClass.retrieveAccountsByOPAccountMapping(objPromo.Id);
        taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c, Name,
                      EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name,
                      EUR_CRM_Territory__r.EUR_CRM_Region__r.Name,
                      //EUR_CRM_Territory__r.EUR_CRM_Region__r.OwnerId
                      EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName ,
                      EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
                      from EUR_CRM_Account__c 
                      where EUR_JB_Customer_Taxonomy__c in : taxonomyIds
                      OR Id IN: accountIdsFromOPMapping];
                      
        System.debug(accountIdsFromOPMapping);
        System.debug(taxonomyIds);
        System.debug(euAccounts);
                
        if(euAccounts != null && euAccounts.size() > 0) {
            regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);
            this.isAccountSelectionDone = true;
            
            System.debug(regionalManagers);
            
            if(taxonomyIds != null && taxonomyIds.size() > 0) {
                this.selectedSelectionMethod = 'cTax';
            }
        }  else {
            this.isAccountSelectionDone = false;
        }

        getPagedEUAccounts();
    }

    public void getPagedEUAccounts() {
        pagedEUAccounts = new List<EUR_CRM_Account__c>();

        euAccountsFirstIndex = euAccountsPageNum * ROWS_PER_PAGE;
        euAccountsPageHasMore = (1 + euAccountsPageNum) < getTotalPages();

        for(Integer i = euAccountsFirstIndex; i < euAccountsFirstIndex + ROWS_PER_PAGE && euAccounts.size() > i; i++) {
            pagedEUAccounts.add(euAccounts.get(i));
        }
    }

    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the first one
    *****************************************************************/
    public void firstPage(){
        euAccountsPageNum = 0;
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the last one
    *****************************************************************/
    public void lastPage(){
        euAccountsPageNum = getTotalPages() - 1;
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the next one in order
    *****************************************************************/    
    public void nextPage(){
        Math.min(euAccountsPageNum++, getTotalPages());
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the previous one in order
    *****************************************************************/  
    public void previousPage(){
        Math.max(euAccountsPageNum--, 0);
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   calculates the total number of pages needed to display the full amount of data in the alleuAccounts list
    *   returns: and Integer number of maximum number of pages needed
    *****************************************************************/  
    public Integer getTotalPages(){
       if(System.Math.mod(euAccounts.size(), ROWS_PER_PAGE ) == 0)
          return euAccounts.size() / ROWS_PER_PAGE ;
       else
          return (euAccounts.size() / ROWS_PER_PAGE ) + 1;
    }
    
    public void initializeProductSelection() {
        this.sCon = this;
        this.initializeTargets();
        System.Debug('@@@initializeProductSelection:' + targets.size());
        if(targets != null && targets.size() > 0) {
            this.isProductSelectionDone = true;
            
            // Initialize selected product selectOption according to the product level of the target
            this.selectedProductSelection = targets[0].EUR_CRM_Product_Level__c.split('_')[2].toLowerCase();
            this.selectedProductLevel     = targets[0].EUR_CRM_Product_Level__c;
        }  else {
            this.isProductSelectionDone = false;
        }    
        System.debug(this.selectedProductSelection);      
    }
    
    public void initializeTargets() {
        System.Debug('@@@initializeTargets');
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();

        String TargetRtDevName = opTargetMap.get(this.objPromo.RecordType.DeveloperName)[0];
        targets = [select id,
                    EUR_CRM_BQS__c, EUR_CRM_BQS__r.Name,
                    EUR_CRM_BQ__c,EUR_CRM_BQ__r.Name,
                    EUR_CRM_Brand__c,EUR_CRM_Brand__r.name,
                    EUR_CRM_POS_Material__c, EUR_CRM_POS_Material__r.Name,
                    EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name,
                    EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,
                    EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c,
                    EUR_CRM_Product_Level__c,
                    EUR_CRM_Comments__c,
                    EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
                    EUR_CRM_Qty_Sell_in_Amount_Display__c,
                    EUR_CRM_Target_Quantity_Promo_Kits__c ,
                    EUR_CRM_Target_Quantity_Spyders__c,
                    EUR_CRM_Target_Owner__c,EUR_CRM_Target_Quantity_Listing__c,
                    EUR_CRM_Visit_Targets__c,EUR_CRM_Target_Quantity_People__c
                    from EUR_CRM_ObjPromo_Target__c 
                    where EUR_CRM_ObjPromo__c = :objPromo.Id
                    AND (RecordType.Developername =: TargetRtDevName)];
        itemMap = new Map<Id,SObject>();
        
        // Initialize existing Ids according to the Product Level
        for(EUR_CRM_ObjPromo_Target__c target: targets) {
            if(target.EUR_CRM_Product_Level__c == 'EUR_CRM_Size__c') {
                existingIds.add(target.EUR_CRM_BQS__c);
            } else if(target.EUR_CRM_Product_Level__c == 'EUR_CRM_Quality__c') {
                existingIds.add(target.EUR_CRM_BQ__c);
            } else if(target.EUR_CRM_Product_Level__c == 'EUR_CRM_Brand__c') {
                existingIds.add(target.EUR_CRM_Brand__c);
            } else if(target.EUR_CRM_Product_Level__c != null) {
                Id existingId = (Id)(target.get(target.EUR_CRM_Product_Level__c));
                existingIds.add(existingId);
            }
        }
        System.debug('###initializeTargets:Targets:' + targets.Size());
        System.debug('###initializeTargets:Targets:' + targets);
        System.debug(existingIds);
        
        if(getIsBrandSize()) {
            itemMap = new Map<Id, EUR_CRM_Size__c>([SELECT Id, Name FROM EUR_CRM_Size__c WHERE Id IN :existingIds]);
        } else if(getIsSKU()) {
            itemMap = new Map<Id, EUR_CRM_SKU__c>([SELECT Id, Name FROM EUR_CRM_SKU__c WHERE Id IN :existingIds]);
        } else if(getIsBrandQuality()) {
            itemMap = new Map<Id, EUR_CRM_Quality__c>([SELECT Id, Name FROM EUR_CRM_Quality__c WHERE Id IN :existingIds]);
        } else if(getIsBrand()) {
            itemMap = new Map<Id, EUR_CRM_Brand__c>([SELECT Id, Name FROM EUR_CRM_Brand__c WHERE Id IN :existingIds]);
        }
    }

    public void initializeSRTargets(){
        System.Debug('@@@initializeSRTargets');
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();

        String SRTargetRtDevName;

        If(opTargetMap.get(this.objPromo.RecordType.DeveloperName).size()==3){
            SRTargetRtDevName = opTargetMap.get(this.objPromo.RecordType.DeveloperName)[2];
        }Else If(opTargetMap.get(this.objPromo.RecordType.DeveloperName).size()==2){
            SRTargetRtDevName = opTargetMap.get(this.objPromo.RecordType.DeveloperName)[1];
        }Else If(opTargetMap.get(this.objPromo.RecordType.DeveloperName).size()==1){
            return; //No SR Target
        }
        System.Debug('@@@initializeSRTargets:DevName:' + SRTargetRtDevName);
        srTargets = [select id,
                    EUR_CRM_BQS__c, EUR_CRM_BQS__r.Name,
                    EUR_CRM_Brand__c,EUR_CRM_Brand__r.name,
                    EUR_CRM_POS_Material__c, EUR_CRM_POS_Material__r.Name,
                    EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name,
                    EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,
                    EUR_CRM_Product_Level__c,
                    EUR_CRM_Comments__c,
                    EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
                    EUR_CRM_Qty_Sell_in_Amount_Display__c,
                    EUR_CRM_Target_Quantity_Spyders__c,
                    EUR_CRM_Target_Quantity_Promo_Kits__c,
                    EUR_CRM_Target_Owner__c,EUR_CRM_Target_Quantity_Listing__c,
                    EUR_CRM_Visit_Targets__c,EUR_CRM_Target_Quantity_People__c
                    from EUR_CRM_ObjPromo_Target__c 
                    where EUR_CRM_ObjPromo__c = :objPromo.Id
                    AND (RecordType.Developername = :SRTargetRtDevName)];
    }
    
    public void initializeTargetManagement() {
        System.Debug('@@@initializeTargetManagement');
        System.debug(euAccounts);
        if(euAccounts != null && euAccounts.size() > 0) {
            System.debug(regionalManagers);
            
            regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;
            System.debug(regionmanager);
        }


    }
    
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalAndSalesAgencyTargetWraps(){ 
        system.debug('>>>getRegionalAndSalesAgencyTargetWraps');
        try{
            regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();

            Id parentRecordTypeId;
            Id subTargetRecordTypeId;


            parentRecordTypeId = rtMap.get(opTargetMap.get(this.objPromo.RecordType.DeveloperName)[0]);
            subTargetRecordTypeId = rtMap.get(opTargetMap.get(this.objPromo.RecordType.DeveloperName)[1]);

            String targetField =  productSelMethodToField.get(this.selectedProductSelection).replace('__c','');
            Id rManager = null;
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Carton__c',
            'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_BQS__c','EUR_CRM_BQS__r.name','EUR_CRM_SKU__c',
            'EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c ',
            'EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c','EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ',
            'EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c',
            'EUR_CRM_Target_Quantity_People__c','EUR_CRM_Visit_Targets__c','EUR_CRM_Target_Quantity_Listing__c'};
            
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> tempList  =  EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,regionalManagers
            ,rManager ,additionalFields);


            if(tempList != null && tempList.size() > 0) {

                // For each Regional Target, assign product level based on the Objective target's product level
                for(EUR_CRM_OPTargetHelperClass.TargetWrap targetWrap : tempList) {
                    if(targetWrap.srTargets != null) {
                        for(EUR_CRM_ObjPromo_Target__c target : targetWrap.srTargets) {
                            system.debug(target);
                            target.EUR_CRM_Product_Level__c = productSelMethodToField.get(this.selectedProductSelection);
                            if(target.Id == null) {
                                //isManagerLevelTargetDone = false;
                            }
                        }
                    }
                }

                System.debug(tempList);

                regionalTargetWrap = tempList;
            }


            return tempList;
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
        }
    }

    public List<SelectOption> getRegionalManagerOptions(){
        if(regionManager == null) {
            return null;
        }
        
        List<SelectOption> regionalManagerOptions = new List<SelectOption>();
        for(User regionManager : regionalManagers){
            regionalManagerOptions.add(new SelectOption(regionManager.id, regionManager.name));
        }
        return regionalManagerOptions;
    }
   
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> salesRepTargetWrap {
       get {
            try{
                System.debug(targets);
                if(targets == null || targets.size() <= 0 || euAccounts == null) {
                    return null;
                }
                
                if(salesRepTargetWrap != null) {
                    return salesRepTargetWrap;
                }
                System.debug(targets);
                System.debug(taxonomyIds);
                System.debug(euAccounts);
                System.debug(regionManager);
                List<User> targetOwners = new List<User>();
                List<Id> targetOwnerIds = new List<Id>();
                for(EUR_CRM_Account__c acc : euAccounts){
                    targetOwnerIds.add(acc.OwnerId);
                }
                targetOwners = [SELECT Id, Name FROM User WHERE Id IN : targetOwnerIds];
                //List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager); 
                srTargets = new List<EUR_CRM_ObjPromo_Target__c >();

                Id parentRecordTypeId;
                Id subTargetRecordTypeId;

                If(opTargetMap.get(this.objPromo.RecordType.DeveloperName).size()==3){
                    parentRecordTypeId = rtMap.get(opTargetMap.get(this.objPromo.RecordType.DeveloperName)[1]);
                    subTargetRecordTypeId = rtMap.get(opTargetMap.get(this.objPromo.RecordType.DeveloperName)[2]);
                }Else If(opTargetMap.get(this.objPromo.RecordType.DeveloperName).size()==2){
                    parentRecordTypeId = rtMap.get(opTargetMap.get(this.objPromo.RecordType.DeveloperName)[0]);
                    subTargetRecordTypeId = rtMap.get(opTargetMap.get(this.objPromo.RecordType.DeveloperName)[1]);
                }


                System.debug(targetOwners);
                
                String targetField = productSelMethodToField.get(this.selectedProductSelection).replace('__c','');

                //System.debug(targetField);
                
                List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c',
                    'EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c',
                    'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name',
                    'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
                    'EUR_CRM_BQ__c', 'EUR_CRM_BQ__r.Name',
                    'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
                    'EUR_CRM_Product_Level__c',
                    'EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c',
                    'EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Target_Quantity_Spyders__c','EUR_CRM_Target_Quantity_Promo_Kits__c ',
                    'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c',
                    'EUR_CRM_Target_Quantity_People__c','EUR_CRM_Visit_Targets__c','EUR_CRM_Target_Quantity_Listing__c'};

                /*If(this.objPromo.RecordType.DeveloperName == OP_OFF_SPYDER){
                    this.salesRepTargetWrap = EUR_CRM_OPTargetHelperClass.retrieveTargetSpyder(
                    objPromo.Id,srTargets,parentRecordTypeId,
                    subTargetRecordTypeId,targetOwners,
                    null,additionalFields);
                }Else If(this.objPromo.RecordType.DeveloperName == OP_ON_SECOND_PLACE){
                    return null;
                }Else{*/
                    this.salesRepTargetWrap = EUR_CRM_OPTargetHelperClass.retrieveTargets(
                    objPromo.Id,srTargets,parentRecordTypeId,
                    subTargetRecordTypeId,targetField,targetOwners,
                    null,additionalFields);
                //}
                
                    
                //System.debug(this.salesRepTargetWrap);
                System.debug(srTargets);
    
                Map<Id, List<EUR_CRM_ObjPromo_Target__c>> salesAgencyMap = new Map<Id,List<EUR_CRM_ObjPromo_Target__c>>();
                
                if(srTargets != null && srTargets.size() > 0) {
                    isTargetManagementDone = true;
                    
                    
                    // Assign correct target level to SR Targets
                    // Also specifies if the target selection has been completed by checking
                    // if SR targets has an Id
                    for(EUR_CRM_ObjPromo_Target__c srTarget: srTargets) {
                        srTarget.EUR_CRM_Product_Level__c = productSelMethodToField.get(this.selectedProductSelection);
                        if(srTarget.Id == null) {
                            isTargetManagementDone = false;
                        }
                    }
                }            
                
                return salesRepTargetWrap;
                
          }catch(Exception e){
              throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
          }           
       }
       set;
    }
    
    public void resetSalesRepTargetWrap() {
        salesRepTargetWrap = null;
    }

    public void setPublishStatus() {
        System.Debug('>>>setPublishStatus');
        System.debug(this.objPromo);

        System.debug('>>>isAccountSelectionDone:' + isAccountSelectionDone);
        System.debug('>>>isProductSelectionDone:' + isProductSelectionDone);
        SYstem.debug('>>>isTargetManagementDone:' + isTargetManagementDone);

        System.debug('>>>isDraft:' + isDraft);
        /*if(isAccountSelectionDone == null || isTargetManagementDone == null || isProductSelectionDone == null){
            return;
        }*/

        if(isAccountSelectionDone == true && isDraft == true) {
            //Only Need Account Selection
            If(this.objpromo.RecordType.Developername == OP_VOL_TRIP){
                List<EUR_CRM_ObjPromo_Target__c> existing = [SELECT Id FROM EUR_CRM_ObjPromo_Target__c Where EUR_CRM_ObjPromo__c =: this.objpromo.id];
                If(existing.size() > 0){
                    if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                        this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                        update this.objPromo;
                    }
                }
                
                return;
            //Only Product Selection
            }Else If(this.objPromo.RecordType.DeveloperName == OP_VOL_CAM){
                if(isProductSelectionDone == true ) {    
                  if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                    this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                    update this.objPromo;
                  }
                  return;
                }
            }Else{
                if(isProductSelectionDone == true  && isTargetManagementDone == true ) {    
                // if the O/P is not pubish ready, make it so
                  if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                    this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                    update this.objPromo;
                  }
                  return;
                }
            }
        }
        
        // if the O/P is publish ready, make it not publish ready
        if(this.objPromo.EUR_CRM_Is_Publish_ready__c == true) {
            this.objPromo.EUR_CRM_Is_Publish_ready__c = false;

            update this.objPromo;
        }
    }
    
    //Tab Visiablity Control


    public Boolean getIsProductionSelectionRendered() {
    	return poductSelectionLevel.keySet().contains(this.objPromo.RecordType.DeveloperName);
    }

    public Boolean getIsMGTargetManagementRendered() {
    	return requireMGTarget.contains(this.objPromo.RecordType.DeveloperName);
    }

    public Boolean getIsSRTargetManagementRendered() {
        return requireSRTarget.contains(this.objPromo.RecordType.DeveloperName);
    }

    public Boolean getIsOPTargetManagementRendered() {
        return requireOPTarget.contains(this.objPromo.RecordType.DeveloperName);
    }

    public Boolean getIsTargetManagementRendered() {
        return (getIsMGTargetManagementRendered() || getIsSRTargetManagementRendered() || getIsOPTargetManagementRendered());
    }

    public String getProductSelectionTabVisibility() {
        String style = '';
        if(!getIsProductionSelectionRendered()){
            style += 'display: none;';
        }
        return style;
    }
    public String getTargetManagementTabVisibility() {
        String style = '';
        
        if(!(getIsMGTargetManagementRendered()|| getIsSRTargetManagementRendered() || getIsOPTargetManagementRendered())){
            style += 'display: none;';
        }
        return style;
    }
    public String getTargetMGTabVisibility(){
        String style = '';
        if(!getIsMGTargetManagementRendered()){
            style += 'display: none;';
        }
        return style;
    }
    public String getTargetSRTabVisibility(){
        String style = '';
        if(!getIsSRTargetManagementRendered()){
            style += 'display: none;';
        }
        return style;
    }
    public String getTargetOPTabVisibility(){
        String style = '';
        if(!getIsOPTargetManagementRendered()){
            style += 'display: none;';
        }
        return style;
    }

    
    public Boolean getIsProductSelectionSelected() {
        return selectedProductSelection != null && selectedProductSelection != 'none';
    }

    //For Product Selection Tab
    public List<EUR_CRM_ObjPromo_Target__c> getTargetsInSelectedProductLevel() {
        System.Debug('@@@getTargetsInSelectedProductLevel:' + this.selectedProductSelection);
        System.Debug('@@@getTargetsInSelectedProductLevel:Targets:' + targets);
        System.Debug('@@@getTargetsInSelectedProductLevel:Targets.Size:' + targets.size());
        List<EUR_CRM_ObjPromo_Target__c> selectedTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        for(EUR_CRM_ObjPromo_Target__c target: targets) {
            System.Debug('@@@getTargetsInSelectedProductLevel:' + target.EUR_CRM_Product_Level__c);
            if(target.EUR_CRM_Product_Level__c.containsIgnoreCase(this.selectedProductSelection)) {
                selectedTargets.add(target);
            }
            System.Debug('@@@getTargetsInSelectedProductLevel:' + target);
        }
        
        return selectedTargets;
    }


    public override void add(){   
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedProductId = ApexPages.CurrentPage().getParameters().get('p1');
        
        if(getIsBrandSize()) {
            target.EUR_CRM_BQS__c = (Id) addedProductId;
            target.EUR_CRM_BQS__r = (EUR_CRM_Size__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
        } else if(getIsSKU()) {
            target.EUR_CRM_SKU__c = (Id) addedProductId;
            target.EUR_CRM_SKU__r = (EUR_CRM_SKU__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_SKU__c';
        } else if(getIsBrandQuality()) {
            target.EUR_CRM_BQ__c  = (Id) addedProductId;
            target.EUR_CRM_BQ__r  = (EUR_CRM_Quality__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
        } else if(getIsBrand()) {
            target.EUR_CRM_Brand__c  = (Id) addedProductId;
            target.EUR_CRM_Brand__r  = (EUR_CRM_Brand__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Brand__c';
        }

        target.recordTypeID = rtMap.get(opTargetMap.get(this.objpromo.RecordType.DeveloperName)[0]); //The First Level OP Target will create after product selection
        
        target.EUR_CRM_ObjPromo__c = objPromo.Id; 
        targets.add(target);
        existingIds.add((ID) addedProductId);
    }

    public void removeProduct(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i-1);
        if(target.id != null) {
            toDeleteTargets.add(target);             
        }
        
        if(getIsBrandSize()) {
            existingIDs.remove(target.EUR_CRM_BQS__c);
        } else if(getIsSKU()) {
            existingIDs.remove(target.EUR_CRM_SKU__c);
        } else if(getIsBrandQuality()) {
            existingIDs.remove(target.EUR_CRM_BQ__c);
        } else if(getIsBrand()) {
            existingIDs.remove(target.EUR_CRM_Brand__c);
        }            
    }
    
    /**
    * function: deleteOldTargets
    * deletes old targets as well as related manager level targets and sales rep targets
    * input: list of targets (objective level) to be deleted
    */
    public void deleteOldTargets(List<EUR_CRM_ObjPromo_Target__c> oldTargets) {
        List<String> targetIds = new List<String>();
        for(EUR_CRM_ObjPromo_Target__c target: oldTargets) {
            targetIds.add((String) target.Id);
        }
        
        Map<Id, EUR_CRM_ObjPromo_Target__c> oldManagerTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([
            SELECT Id FROM EUR_CRM_ObjPromo_Target__c
            WHERE EUR_CRM_O_P_Target__c IN :targetIds]);
        
        if(oldManagerTargets != null && oldManagerTargets.size() > 0) {
            oldTargets.addAll(oldManagerTargets.values());
            
            Map<Id, EUR_CRM_ObjPromo_Target__c> oldSRTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([
                SELECT Id FROM EUR_CRM_ObjPromo_Target__c
                WHERE EUR_CRM_O_P_Target__c IN :oldManagerTargets.keySet()
            ]);
            
            System.debug(oldManagerTargets);
            System.debug(oldSRTargets);
            
            if(oldSRTargets != null && oldSRTargets.size() > 0) {
                oldTargets.addAll(oldSRTargets.values());
            }          
        }
        
        System.debug(oldTargets);
        //toDeleteTargets.addAll((List<EUR_CRM_ObjPromo_Target__c>)Database.query(query));
        
        delete oldTargets;        
    }
    
    public pageReference quickSaveProducts() {
        System.Debug('Quick Product');
        try {
            
            if(toDeleteTargets.size() > 0) {
                deleteOldTargets(toDeleteTargets);
            }
            
            if(targets.size() > 0) {
                // Compare each target to the currently selected selection method, and remove
                // targets not belonging to that particular selection method.
                
                // Remove old O/P Targets
                List<EUR_CRM_ObjPromo_Target__c> oldTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                List<EUR_CRM_ObjPromo_Target__c> newTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                
                for(EUR_CRM_ObjPromo_Target__c target: targets) {
                    if(target.EUR_CRM_Product_Level__c.containsIgnoreCase(this.selectedProductSelection)) {
                        newTargets.add(target);
                    } else {
                        oldTargets.add(target);
                    }                 
                }
                
                deleteOldTargets(oldTargets);
                upsert newTargets;
            } else {
                isProductSelectionDone = false;
            }
            System.Debug('setPublishStatus:Save Product');
            setPublishStatus();
            
            return refresh('&pageReference=product');
        } catch(DMLException e) {
            throw e;
            System.debug(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }
    
    public PageReference saveProducts() {
        quickSaveProducts();
        setPublishStatus();
        return cancel();
    }
    
    public pageReference quickSaveObjectiveTargets() {
        System.Debug('Quick Objective Target');
        try{
            // Only delete targets when it is in draft mode
            if(isDraft) {
                EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets);  
            }
            
            System.debug(targets);
            System.debug(toDeleteTargets);
            
            if(targets != null && targets.size() >0){
              upsert targets;
              update this.objPromo;
              isTargetManagementDone = true;

            }
            
            // TODO: Update O/P Is Quota
            setPublishStatus();
            return refresh('&pageReference=objective');
        }catch(DMLException e){
            throw e;
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        } 
    }
    
    public PageReference saveObjectiveTargets() {
        //quickSaveObjectiveTargets();
        //return cancel();
        try{
            // Only delete targets when it is in draft mode
            if(isDraft) {
                EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets);  
            }
            
            System.debug(targets);
            System.debug(toDeleteTargets);
            
            if(targets != null && targets.size() >0){
              upsert targets;
              update this.objPromo;
              isTargetManagementDone = true;
            }
            
            // TODO: Update O/P Is Quota
            setPublishStatus();
            return cancel();
        }catch(DMLException e){
            throw e;
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        } 
    }
    
    public PageReference quickSaveRegionalTargets() {
        System.Debug('Quick Regional Target :' + regionalTargetWrap);
        System.debug(regionalTargetWrap);
        System.debug(regionalTargets);
        try{ 
            if(regionalTargets != null && regionalTargets.size() > 0){
                List<EUR_CRM_ObjPromo_Target__c> newMGTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                System.debug(regionalTargetWrap);
                for(EUR_CRM_OPTargetHelperClass.TargetWrap regTarget : regionalTargetWrap) {
                    //!!!False is match!!!
                    //getVolumeBottleMatched
                    //getTargetListingMatched
                    //getTargetVisitMatched
                    //getTargetPeopleMatched

                    if(regTarget.getEverythingMatched()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget)); //Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget
                        return null;
                    }else{
                        //isTargetManagementDone = true;
                    }

                    newMGTargets.addAll(regTarget.srTargets);
                }
                upsert newMGTargets;
            }
            System.Debug('setPublishStatus:Save Region Target');

            setPublishStatus();
            return refresh('&pageReference=manager');
        }catch(DMLException e){
            throw e;
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }        
    }

    public PageReference saveRegionalTargets() {
        quickSaveRegionalTargets();
        return cancel();
    }
    
    public PageReference quickSaveSRTargets() {
        System.Debug('Quick SR Target');

        try{
            if(salesRepTargetWrap != null && salesRepTargetWrap.size() > 0) {
                
                List<EUR_CRM_ObjPromo_Target__c> newSRTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                for(EUR_CRM_OPTargetHelperClass.TargetWrap srWrap : salesRepTargetWrap) {



                	//TODO Target Checking
                    If(this.objPromo.RecordType.DeveloperName == OP_VOL_CAM)
                    {
                        System.Debug('SP:' + srWrap.getEverythingMatched());
                        If(srWrap.getEverythingMatched()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget)); // Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget
                            return null;
                        } 
                        else{
                            isTargetManagementDone = true;
                        }
                    }
                                       
                    newSRTargets.addAll(srWrap.srTargets);
                }

                upsert newSRTargets;
            }
            System.Debug('setPublishStatus:Save SR Target');

            setPublishStatus();
            return refresh('&pageReference=salesRep');
        } catch(DMLException e) {
            System.debug(e);
            throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }
    
    public PageReference saveSRTargets() {
        try{
            if(salesRepTargetWrap != null && salesRepTargetWrap.size() > 0) {
                
                List<EUR_CRM_ObjPromo_Target__c> newSRTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                for(EUR_CRM_OPTargetHelperClass.TargetWrap srWrap : salesRepTargetWrap) {



                    //TODO Target Checking
                    If(this.objPromo.RecordType.DeveloperName == OP_VOL_CAM)
                    {
                        System.Debug('SP:' + srWrap.getEverythingMatched());
                        If(srWrap.getEverythingMatched()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget)); // Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget
                            return null;
                        } 
                        else{
                            isTargetManagementDone = true;
                        }
                    }
                                       
                    newSRTargets.addAll(srWrap.srTargets);
                }

                upsert newSRTargets;
            }
            System.Debug('setPublishStatus:Save SR Target');

            setPublishStatus();
            return cancel();
        } catch(DMLException e) {
            System.debug(e);
            throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference refresh(String referenceField) {
        PageReference pageRef = new PageReference('/apex/EUR_CRM_SE_ObjPromoManagePage?ObjPromoId=' + objPromo.Id + referenceField);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference createAccOP(){
        List<EUR_CRM_ObjPromo_Target__c> existing = [SELECT Id FROM EUR_CRM_ObjPromo_Target__c Where EUR_CRM_ObjPromo__c =: this.objpromo.id];

        List<EUR_CRM_ObjPromo_Target__c> newTarget = New List<EUR_CRM_ObjPromo_Target__c>();

        List<EUR_CRM_ObjPromo_Account_Mapping__c> OPAccMap = [SELECT Id,EUR_CRM_Account__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHere EUR_CRM_ObjPromo__c =: this.objpromo.id];

        String OPTargetName = opTargetMap.get('EUR_SE_Volume_Trip_Campaign_Bundle')[0];

        Id RrdTypeId = [SELECT Id FROM RecordType Where DeveloperName = : OPTargetName].id;

        for(EUR_CRM_ObjPromo_Account_Mapping__c OP : OPAccMap){
            newTarget.add(New EUR_CRM_ObjPromo_Target__c(recordtypeId = RrdTypeId, EUR_CRM_Account__c = OP.EUR_CRM_Account__c,EUR_CRM_ObjPromo__c = this.objpromo.id));
        }

        If(existing.size() > 0){
            delete existing;
        }



        If(newTarget.size() ==0 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account selection not finish')); //Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget
            return null;
        }else{

            insert newTarget;
            isAccountSelectionDone = true;
            setPublishStatus();
            return refresh('');
        }
    }
}