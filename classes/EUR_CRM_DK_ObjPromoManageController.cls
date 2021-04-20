public with sharing class EUR_CRM_DK_ObjPromoManageController  extends EUR_CRM_AbstractSelectionItem{

    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    public Boolean isDraft {get; set;}
    public Boolean isDeactivated {get; set;}
    public Boolean isActive {get; set;}
    public Boolean isAccountSelectionDone {get; set;}
    public Boolean isProductSelectionDone {get; set;}
    public Boolean isTargetManagementDone {get; set;}
    public String selectedSelectionMethod {get; set;}
    public String selectedProductSelection {get; set;}
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> regionalTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srTargets {get;set;}
    public EUR_CRM_AbstractSelectionItem sCon {get; set;}
    public ApexPages.StandardController standardController {get; set;}

    public static Integer ROWS_PER_PAGE = 50;
    public Integer euAccountsPageNum {get; set;}
    public Boolean euAccountsPageHasMore {get; set;}
    public Integer euAccountsFirstIndex {get; set;}
    public Integer totalPages;


    private Map<String, String> productLevelToFieldName = new Map<String, String>{
      'EUR_CRM_Size__c' => 'EUR_CRM_BQS',
      'EUR_CRM_SKU__c' => 'EUR_CRM_SKU' 
    };
    
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
    
    public final String OBJ_PRODUCT         = 'EUR_DK_Objective_Product';
    public final String OBJ_VOLUME_TARGET   = 'EUR_DK_Objective_Volume_Target';
    public final String MGR_VOLUME_TARGET   = 'EUR_DK_Manager_Volume_Target';
    public final String SR_VOLUME_TARGET    = 'EUR_DK_SR_Volume_Target';
    public final String OP_OFF_SKU_BOTTLES  = 'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles';
    public final String OP_OFF_SKU_DISPLAYS = 'EUR_DK_Off_Trade_Sales_Drive_SKU_Displays';
    public final String OP_OFF_SKU_CARTONS  = 'EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons';
    public final String OP_OFF_LEAFLET      = 'EUR_DK_Off_Trade_Leaflet_Campaign';
    public final String OP_OFF_TASTING      = 'EUR_DK_Off_Trade_Tasting_Campaign';
    public final String OP_OFF_DISTRIBUTION = 'EUR_DK_Off_Trade_Distribution_Drive';
    Map<String, Id> rtMap;

    public EUR_CRM_DK_ObjPromoManageController(ApexPages.StandardController sc) {
        this.standardController = sc;
        this.objPromo = [SELECT Id, recordtypeId, recordtype.developername,
                         EUR_CRM_Is_Quota__c, EUR_CRM_Status__c, EUR_CRM_Is_Publish_ready__c
                         FROM EUR_CRM_ObjPromo__c
                         WHERE ID = :ApexPages.currentPage().getParameters().get('objPromoId')];
        this.rtMap = new Map<String, Id>();
        this.isDraft = this.objPromo != null && this.objPromo.EUR_CRM_Status__c == 'Draft';
        this.isDeactivated = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Deactivated';
        this.isActive = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Active';
        
        // Initialize record types
        for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo__c')) {
            rtMap.put(rt.developername, rt.Id);
        }
        
        // Add O/P Target record types to rtMap as well for later use
        rtMap.put(OBJ_PRODUCT, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_PRODUCT));
        rtMap.put(OBJ_VOLUME_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_VOLUME_TARGET));
        rtMap.put(MGR_VOLUME_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + MGR_VOLUME_TARGET));
        rtMap.put(SR_VOLUME_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + SR_VOLUME_TARGET));
        
        initializeAccountSelection();
        
        initializeProductSelection();
        
        initializeTargetManagement();
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
        
        if(targets != null && targets.size() > 0) {
            this.isProductSelectionDone = true;
            
            // Initialize selected product selectOption according to the product level of the target
            this.selectedProductSelection = targets[0].EUR_CRM_Product_Level__c.split('_')[2].toLowerCase();
            
        }  else {
            this.isProductSelectionDone = false;
        }          
    }
    
    public void initializeTargets() {
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [select id,
                    EUR_CRM_BQS__c, EUR_CRM_BQS__r.Name,
                    EUR_CRM_Brand__c,EUR_CRM_Brand__r.name,
                    EUR_CRM_POS_Material__c, EUR_CRM_POS_Material__r.Name,
                    EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name,
                    EUR_CRM_Product_Level__c,
                    EUR_CRM_Comments__c,
                    EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
                    EUR_CRM_Target_Owner__c
                    from EUR_CRM_ObjPromo_Target__c 
                    where EUR_CRM_ObjPromo__c = :objPromo.Id
                    AND (RecordType.Developername = :OBJ_VOLUME_TARGET OR
                        RecordType.Developername = :OBJ_PRODUCT)];
        itemMap = new Map<Id,SObject>();
        
        // Initialize existing Ids according to the Product Level
        for(EUR_CRM_ObjPromo_Target__c target: targets) {
            if(target.EUR_CRM_Product_Level__c == 'EUR_CRM_Size__c') {
                existingIds.add(target.EUR_CRM_BQS__c);
            } else if(target.EUR_CRM_Product_Level__c != null) {
                Id existingId = (Id)(target.get(target.EUR_CRM_Product_Level__c));
                existingIds.add(existingId);
            }
        }
        
        System.debug(targets);
        System.debug(existingIds);
        
        if(getIsBrandSize()) {
            itemMap = new Map<Id, EUR_CRM_Size__c>([SELECT Id, Name FROM EUR_CRM_Size__c WHERE Id IN :existingIds]);
        } else if(getIsSKU()) {
            itemMap = new Map<Id, EUR_CRM_SKU__c>([SELECT Id, Name FROM EUR_CRM_SKU__c WHERE Id IN :existingIds]);
        }
    }
    
    public void initializeTargetManagement() {
        System.debug(euAccounts);
        if(euAccounts != null && euAccounts.size() > 0) {
            System.debug(regionalManagers);
            
            regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;

            if(regionManager != null && targets != null ) {
              this.isTargetManagementDone = true;
            }

            System.debug(regionmanager);
        }
    }
    
   public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalAndSalesAgencyTargetWraps(){ 
      try{
          if(targets.size() <= 0 || regionalManagers == null || regionalManagers.size() <= 0) {
              System.debug('Targets are not created ' + targets);
              System.debug('regionalmanagers ' + regionalManagers);
              return null;
          }
          
          regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
          
          Id parentRecordTypeId;
          if(this.getIsLeaflet() || this.getIsDistribution() || this.getIsTasting()) {
              parentRecordTypeId = rtMap.get(OBJ_PRODUCT);
          } else {
              parentRecordTypeId = rtMap.get(OBJ_VOLUME_TARGET);
          }
          Id subTargetRecordTypeId = rtMap.get(MGR_VOLUME_TARGET);
          
          System.debug(regionalManagers);
          
          String targetField =  productLevelToFieldName.get(targets[0].EUR_CRM_Product_Level__c);
          System.debug(targetField);
          
          Id rManager = null;
          List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c',
              'EUR_CRM_SKU__r.name', 'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
              'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
              'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name', 'EUR_CRM_Product_Level__c',
              'EUR_CRM_Promotion_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c',
              'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
          
          List<EUR_CRM_OPTargetHelperClass.TargetWrap> tempList  =  EUR_CRM_OPTargetHelperClass.retrieveTargets(
               objPromo.Id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,
               targetField,regionalManagers, rManager ,additionalFields);
          
          // Assign correct product level name for Brand Size
          // EUR_CRM_Size__c instead of EUR_CRM_BQS__c
          if(targetField == 'EUR_CRM_BQS') {
              targetField = 'EUR_CRM_Size';
          }
          
          // For each Regional Target, assign product level based on the Objective target's product level
          for(EUR_CRM_OPTargetHelperClass.TargetWrap targetWrap: tempList) {
              if(targetWrap.srTargets != null) {
                  for(EUR_CRM_ObjPromo_Target__c target: targetWrap.srTargets) {
                      target.EUR_CRM_Product_Level__c = targetField + '__c';
                  }
              }
          }
          
          System.debug(tempList);
          
          regionalTargetWrap = tempList;
          
          return tempList;
      }catch(Exception e){
          throw e;
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
                if(regionManager == null || targets == null || targets.size() <= 0 || euAccounts == null) {
                    return null;
                }
                
                if(salesRepTargetWrap != null) {
                    return salesRepTargetWrap;
                }
                
                System.debug(taxonomyIds);
                System.debug(euAccounts);
                System.debug(regionManager);
                
                List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager); 
                srTargets = new List<EUR_CRM_ObjPromo_Target__c >();
                Id parentRecordTypeId = rtMap.get(MGR_VOLUME_TARGET);
                Id subTargetRecordTypeId = rtMap.get(SR_VOLUME_TARGET);
                
                System.debug(targetOwners);
                
                String targetField =  productLevelToFieldName.get(targets[0].EUR_CRM_Product_Level__c);
                System.debug(targetField);
                
                List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c',
                    'EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name',
                    'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name',
                    'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
                    'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
                    'EUR_CRM_Product_Level__c',
                    'EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c',
                    'EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c',
                    'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
                
                this.salesRepTargetWrap = EUR_CRM_OPTargetHelperClass.retrieveTargets(
                    objPromo.Id,srTargets,parentRecordTypeId,
                    subTargetRecordTypeId,targetField,targetOwners,
                    regionManager,additionalFields);
                    
                //System.debug(this.salesRepTargetWrap);
                System.debug(srTargets);
    
                Map<Id, List<EUR_CRM_ObjPromo_Target__c>> salesAgencyMap = new Map<Id,List<EUR_CRM_ObjPromo_Target__c>>();
                
                if(srTargets != null && srTargets.size() > 0) {
                    isTargetManagementDone = true;
                    
                    // Assign target Field for Brand Size to the correct API name
                    if(targetField == 'EUR_CRM_BQS') {
                        targetField = 'EUR_CRM_Size';
                    }
                    
                    // Assign correct target level to SR Targets
                    // Also specifies if the target selection has been completed by checking
                    // if SR targets has an Id
                    for(EUR_CRM_ObjPromo_Target__c srTarget: srTargets) {
                        srTarget.EUR_CRM_Product_Level__c = targetField + '__c';
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
        System.debug(this.objPromo);

        System.debug(isAccountSelectionDone);
        System.debug(isProductSelectionDone);
        System.debug(isDraft);
        System.debug(getIsLeaflet());
        System.debug(getIsTasting());
        System.debug(getIsDistribution());
        SYstem.debug(isTargetManagementDone);

        if(isAccountSelectionDone == true && isProductSelectionDone == true && isDraft == true) {
            if(this.getIsLeaflet() ||  getIsTasting() || getIsDistribution() ||
                isTargetManagementDone == true ) {
                
                // if the O/P is not pubish ready, make it so
                if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                  this.objPromo.EUR_CRM_Is_Publish_ready__c = true;

                  update this.objPromo;
                }

                return;
            }
        }
        
        // if the O/P is publish ready, make it not publish ready
        if(this.objPromo.EUR_CRM_Is_Publish_ready__c == true) {
            this.objPromo.EUR_CRM_Is_Publish_ready__c = false;

            update this.objPromo;
        }
    }
    
    public String getProductSelectionTabVisibility() {
        if(this.isAccountSelectionDone != true) {
            return 'pointer-events: none;cursor: default;';
        }
        
        return '';
    }
    
    public String getTargetManagementTabVisibility() {
        String style = '';
        
        if(!this.getIsTargetManagementRendered()) {
            style += 'display: none;';
        }
        if(this.isProductSelectionDone != true || this.isAccountSelectionDone != true ) {
            style += 'pointer-events: none;cursor: default;';
        }
        
        return style;
    }
    
    public Boolean getIsTargetManagementRendered() {
        if(getIsLeaflet() || getIsTasting() || getIsDistribution()) {
            return false;
        } else {
            return true;
        }
    }
    
    public Boolean getIsLeaflet() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_LEAFLET;
    }
    
    public Boolean getIsTasting() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_TASTING;
    }
    
    public Boolean getIsDistribution() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_DISTRIBUTION;
    }
    
    public Boolean getIsListViewOptionRendered() {
        return true;
    }
    
    public Boolean getIsCTaxOptionRendered() {
        return true;
    }

    public Boolean getIsAccountListView() {
        return selectedSelectionMethod == 'listView';
    }
    
    public Boolean getIsCustomerTaxonomy() {
        return selectedSelectionMethod == 'cTax';
    }
    
    public Boolean getIsProductSelectionSelected() {
        return selectedProductSelection != null && selectedProductSelection != 'none';
    }
    
    public Boolean getIsBrandSizeRendered() {
        if(this.objPromo.recordType.developername == OP_OFF_SKU_BOTTLES ||
            this.objPromo.recordType.developername == OP_OFF_SKU_DISPLAYS ||
            this.objPromo.recordType.developername == OP_OFF_SKU_CARTONS) {
                
            return false;
        } else {
            return true;
        }
    }
    
    public Boolean getIsSKURendered() {
        return !getIsBrandSizeRendered();
    }
    
    public Boolean getIsBrandSize() {
        return selectedProductSelection == 'size';
    }
    
    public Boolean getIsSKU() {
        return selectedProductSelection == 'sku';
    }
    
    public List<EUR_CRM_ObjPromo_Target__c> getTargetsInSelectedProductLevel() {
        if(this.selectedProductSelection == null) {
            return null;
        }
        
        List<EUR_CRM_ObjPromo_Target__c> selectedTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        
        for(EUR_CRM_ObjPromo_Target__c target: targets) {
            if(target.EUR_CRM_Product_Level__c.containsIgnoreCase(this.selectedProductSelection)) {
                selectedTargets.add(target);
            }
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
        }

        if(this.getIsLeaflet() || this.getIsDistribution() || this.getIsTasting()) {
            target.recordTypeId = rtMap.get(OBJ_PRODUCT);
        } else {
            target.recordTypeId = rtMap.get(OBJ_VOLUME_TARGET);
        }
        
        System.debug(target);
        
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
        return cancel();
    }
    
    public pageReference quickSaveObjectiveTargets() {
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
            }
            
            // TODO: Update O/P Is Quota

            return refresh('&pageReference=objective');
        }catch(DMLException e){
            throw e;
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        } 
    }
    
    public PageReference saveObjectiveTargets() {
        quickSaveObjectiveTargets();
        return cancel();
    }
    
    public PageReference quickSaveRegionalTargets() {
        try{ 
            if(regionalTargets != null && regionalTargets.size() > 0 && regionalTargetWrap != null){

                System.debug(regionalTargetWrap);
                for(EUR_CRM_OPTargetHelperClass.TargetWrap regTarget : regionalTargetWrap) {
                    if(regTarget.getVolumeBottleMatched()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                        return null;
                    }
                }
                upsert regionalTargets;
            }
            
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
        try{
            if(salesRepTargetWrap != null && salesRepTargetWrap.size() > 0) {
                
                List<EUR_CRM_ObjPromo_Target__c> newSRTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                for(EUR_CRM_OPTargetHelperClass.TargetWrap srWrap : salesRepTargetWrap) {
                    if(srWrap.getVolumeBottleMatched()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                        return null;
                    }                    
                    newSRTargets.addAll(srWrap.srTargets);
                }
                //upsert salesRepTargetWrap.srTargets;
                
                upsert newSRTargets;
            }
            
            return refresh('&pageReference=salesRep');
        } catch(DMLException e) {
            System.debug(e);
            throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }
    
    public PageReference saveSRTargets() {
        quickSaveSRTargets();
        return cancel();
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference refresh(String referenceField) {
        PageReference pageRef = new PageReference('/apex/EUR_CRM_DK_ObjPromoManagePage?ObjPromoId=' + objPromo.Id + referenceField);
        pageRef.setRedirect(true);
        return pageRef;
    }
}