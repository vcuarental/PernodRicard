public class EUR_CRM_RU_ObjPromoManageController extends EUR_CRM_AbstractSelectionItem{

    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    //private String objPromoRecordTypeDeveloperName;
    public Boolean isDraft {get; set;}
    public Boolean isDeactivated {get; set;}
    public Boolean isActive {get; set;}
    public Boolean isOff {get; set;}
    public Boolean isAccountSelectionDone {get; set;}
    public Boolean isProductSelectionDone {get; set;}
    public Boolean isManagerLevelTargetDone {get; set;}
    public Boolean isTargetManagementDone {get; set;}
    public String selectedSelectionMethod {get; set;}
    public String selectedProductSelection {get; set;}
    //public String confirmedProductLevel {get; set;}
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;
    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> regionalTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srTargets {get;set;}
    public EUR_CRM_AbstractSelectionItem sCon {get; set;}
    public ApexPages.StandardController standardController {get; set;}
    public ApexPages.StandardSetController accCon {get; set;}

    public static Integer ROWS_PER_PAGE = 50;
    public Integer euAccountsPageNum {get; set;}
    public Boolean euAccountsPageHasMore {get; set;}
    public Integer euAccountsFirstIndex {get; set;}
    public Integer totalPages;

    private Set<Id> offTradeRecordTypes {get; set;}
    private Set<Id> onTradeRecordTypes {get; set;}
    private Map<String, String> productLevelToFieldName = new Map<String, String>{
      'EUR_CRM_Quality__c' => 'EUR_CRM_BQ',
      'EUR_CRM_SKU__c' => 'EUR_CRM_SKU',
      'EUR_CRM_POS_Material__c' => 'EUR_CRM_POS_Material',
      'EUR_CRM_Brand__c' => 'EUR_CRM_Brand',
      'EUR_CRM_Size__c' => 'EUR_CRM_BQS' 
    };
    
    // Account Management
    private Set<Id> taxonomyIds = new Set<Id>();
    private Set<Id> accountIdsFromOPMapping = new Set<Id>();
    public List<EUR_CRM_Account__c> euAccounts {get; set;}
    public List<EUR_CRM_Account__c> pagedEUAccounts {get; set;}
    
    // Target Management
    // Maps Regional Manager's Id to a list of SR Ids under the manager
    @TestVisible private Map<Id, List<Id>> regionalSalesRepMap;
    @TestVisible private List<EUR_CRM_OPTargetHelperClass.TargetWrap> regionalTargetWrap;
    @TestVisible private List<User> regionalManagers;
    public Id regionManager {get;set;}
    
    public final String OBJ_PRODUCT                 = 'EUR_RU_Objective_Product';
    public final String OBJ_POSM_TARGET             = 'EUR_RU_Objective_POSM_Target';
    public final String MGR_POSM_TARGET             = 'EUR_RU_Manager_POSM_Target';
    public final String SR_POSM_TARGET              = 'EUR_RU_Sales_Rep_POSM_Target';

    public final String OP_OFF_TRADE_LOYALTY_POSM   = 'EUR_RU_Off_Trade_Loyalty_POSM_Placement';
    public final String OP_OFF_TRADE_POSM_PLACEMENT = 'EUR_RU_Off_Trade_POSM_Placement';
    public final String OP_OFF_TRADE_LEAFLET        = 'EUR_RU_Off_Trade_Leaflet_Campaign';
    public final String OP_OFF_TRADE_DISCOUNT       = 'EUR_RU_Off_Trade_Discount_Campaign';
    public final String OP_OFF_TRADE_MODEL_STORE    = 'EUR_RU_Off_Trade_Model_Store';
    public final String OP_OFF_TRADE_ON_SITE_PROMO  = 'EUR_RU_Off_Trade_On_Site_Promo_Activities';
    public final String OP_OFF_TRADE_IN_STORE_MEDIA = 'EUR_RU_Off_Trade_InStore_Media_POSM_Control';
    public final String OP_ON_TRADE_PHASE_1         = 'EUR_RU_ON_Trade_Phase_1';
    public final String OP_ON_TRADE_PHASE_2         = 'EUR_RU_ON_Trade_Phase_2';

    Map<String, Id> rtMap;

    public EUR_CRM_RU_ObjPromoManageController(ApexPages.StandardController sc) {
        this.standardController = sc;
        this.objPromo = [SELECT Id, recordtypeId, recordtype.developername, EUR_CRM_Status__c,
                         EUR_CRM_Is_Quota__c, EUR_CRM_Is_Publish_ready__c
                         FROM EUR_CRM_ObjPromo__c
                         WHERE ID = :ApexPages.currentPage().getParameters().get('objPromoId')];
        this.offTradeRecordTypes = new Set<Id>();
        this.onTradeRecordTypes = new Set<Id>();
        this.rtMap = new Map<String, Id>();
        this.isDraft = this.objPromo != null && this.objPromo.EUR_CRM_Status__c == 'Draft';
        this.isDeactivated = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Deactivated';
        this.isActive = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Active';
        
        // Initialize record types
        for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo__c')) {
            if(rt.developername.contains('_RU_') && rt.developername.containsIgnoreCase('off')) {
                this.offTradeRecordTypes.add(rt.Id);
            } else if(rt.developername.contains('_RU_') && rt.developername.containsIgnoreCase('on')) {
                this.onTradeRecordTypes.add(rt.Id);
            }
            rtMap.put(rt.developername, rt.Id);
        }
        
        // Add O/P Target record types to rtMap as well for later use
        rtMap.put(OBJ_PRODUCT, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_PRODUCT));
        rtMap.put(OBJ_POSM_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_POSM_TARGET));
        rtMap.put(MGR_POSM_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + MGR_POSM_TARGET));
        rtMap.put(SR_POSM_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + SR_POSM_TARGET));
        
        this.isOff = this.offTradeRecordTypes.contains(this.objPromo.recordtypeId);
        
        initializeAccountSelection();
        initializeProductSelection();
        
        // Initialize Target Management, for POSM loyalty
        if(this.getIsLoyaltyPOSM()) {
            initializeTargetManagement();
        }
    }
    
    public void initializeAccountSelection() {
        // Account Management
        euAccountsPageNum = 0;
        accountIdsFromOPMapping = EUR_CRM_OPTargetHelperClass.retrieveAccountsByOPAccountMapping(objPromo.Id);
        taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        /*euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c, Name,
                      EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name,
                      EUR_CRM_Territory__r.EUR_CRM_Region__r.Name,EUR_CRM_Manager_of_Account_Owner__c,
                      //EUR_CRM_Territory__r.EUR_CRM_Region__r.OwnerId
                      EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName ,
                      EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
                      from EUR_CRM_Account__c 
                      where EUR_JB_Customer_Taxonomy__c in : taxonomyIds
                      OR Id IN: accountIdsFromOPMapping];*/

        accCon = New  ApexPages.StandardSetController( Database.getQueryLocator([select id, EUR_CRM_Territory__r.EUR_CRM_Region__c, Name,
                                           EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name,
                                           EUR_CRM_Territory__r.EUR_CRM_Region__r.Name,EUR_CRM_Manager_of_Account_Owner__c,
                                           //EUR_CRM_Territory__r.EUR_CRM_Region__r.OwnerId
                                           EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName ,
                                           EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
                                           from EUR_CRM_Account__c 
                                           where EUR_JB_Customer_Taxonomy__c in : taxonomyIds
                                           OR Id IN: accountIdsFromOPMapping]));

                      
        System.debug('##accountIdsFromOPMapping:' + accountIdsFromOPMapping);
        System.debug('##taxonomyIds' + taxonomyIds);
        System.debug('##euAccounts' + accCon.getResultSize());
                
        if(accCon != null && accCon.getResultSize() > 0) {
            //regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);

            accCon.setPageSize(50);

            /*If(this.objpromo.recordtype.developerName == OP_ON_TRADE_PHASE_2){
                //Update For Phase 2 Promo
                //regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerRegionalHeadLevel(accCon.getRecords());
                List<User> AccOwner = [SELECT  Id,Name,UserRoleId FROM USER Where Id IN (SELECT OwnerId From EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds OR Id IN:accountIdsFromOPMapping )];
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerRegionalHeadLevel(AccOwner);
            }Else{
                List<User> AccOwner = [SELECT  Id,Name,UserRoleId FROM USER Where Id IN (SELECT OwnerId From EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds OR Id IN:accountIdsFromOPMapping )];
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerManagerLevelByAccountOwner(AccOwner);
            }*/
            
            If(this.objpromo.recordtype.developerName == OP_ON_TRADE_PHASE_2){
                //Update For Phase 2 Promo
                List<User> AccOwner = [SELECT Id,Name FROM USER Where Id IN (SELECT OwnerId From EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c in : taxonomyIds OR Id IN:accountIdsFromOPMapping )];
                List<Id> UserIds = New List<Id>();
                for(User u : AccOwner){
                    UserIds.add(u.Id);
                }
                
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerRegionalHeadLevel(UserIds);
            }Else{
                regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerManagerLevel(accCon.getRecords());
            }


            this.isAccountSelectionDone = true;
            
            //System.debug(regionalManagers);
            System.debug('##retrieveTargetOwnersAccountOwnersManagerLevel:' + regionalManagers);
            
            
            if(taxonomyIds != null && taxonomyIds.size() > 0) {
                this.selectedSelectionMethod = 'cTax';
            }
        }  else {
            this.isAccountSelectionDone = false;
        }

        accCon.setPageSize(ROWS_PER_PAGE);

        getPagedEUAccounts();
    }

    public Integer getPageSize(){
        return ROWS_PER_PAGE;
    }

    public Integer getRecordSize(){
        return accCon.getResultSize();
    }

    public void getPagedEUAccounts() {
        pagedEUAccounts = new List<EUR_CRM_Account__c>();
        /*pagedEUAccounts = new List<EUR_CRM_Account__c>();

        euAccountsFirstIndex = euAccountsPageNum * ROWS_PER_PAGE;
        euAccountsPageHasMore = (1 + euAccountsPageNum) < getTotalPages();
        
        for(Integer i = euAccountsFirstIndex; i < euAccountsFirstIndex + ROWS_PER_PAGE && euAccounts.size() > i; i++) {
            pagedEUAccounts.add(euAccounts.get(i));
        }*/
        
        pagedEUAccounts.addAll((List<EUR_CRM_Account__c>)accCon.getRecords());


    }

    public Integer getPageNumber(){
        return euAccountsPageNum;
    }

    public Boolean getHasNextPage(){
        return !(euAccountsPageNum == getTotalPages() - 1);
    }

    public Boolean getHasPreviousPage(){
        return !(euAccountsPageNum == 0);
    }

    public Boolean getHasMoreThanOnePage(){
        return getTotalPages() > 1;
    }

    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the first one
    *****************************************************************/
    public void firstPage(){
        euAccountsPageNum = 0;
        //getPagedEUAccounts();
        accCon.first();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the last one
    *****************************************************************/
    public void lastPage(){
        euAccountsPageNum = getTotalPages() - 1;
        accCon.last();
        //getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the next one in order
    *****************************************************************/    
    public void nextPage(){
        Math.min(euAccountsPageNum++, getTotalPages());
        accCon.next();
        //getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the previous one in order
    *****************************************************************/  
    public void previousPage(){
        Math.max(euAccountsPageNum--, 0);
        accCon.previous();
        //getPagedEUAccounts();
    }
    /*****************************************************************
    *   calculates the total number of pages needed to display the full amount of data in the alleuAccounts list
    *   returns: and Integer number of maximum number of pages needed
    *****************************************************************/  
    public Integer getTotalPages(){
        return accCon.getResultSize() / accCon.getPageSize();
       /*if(System.Math.mod(euAccounts.size(), ROWS_PER_PAGE ) == 0)
          return euAccounts.size() / ROWS_PER_PAGE ;
       else
          return (euAccounts.size() / ROWS_PER_PAGE ) + 1;*/
    }
    
    public void initializeProductSelection() {
        this.sCon = this;
        this.initializeTargets();
               
        if(targets != null && targets.size() > 0) {
            this.isProductSelectionDone = true;
            
            if(!this.getIsOnTradePhase2() && !this.getIsLoyaltyPOSM()){
                // Initialize selected product selectOption according to the product level of the target
                this.selectedProductSelection = targets[0].EUR_CRM_Product_Level__c.split('_')[2].toLowerCase();
            }            
        }  else {
            this.isProductSelectionDone = false;
        }          
    }
    
    public void initializeTargets() {
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [select id,
                    EUR_CRM_BQS__c, EUR_CRM_BQS__r.Name,
                    EUR_CRM_BQ__c, EUR_CRM_BQ__r.Name,
                    EUR_CRM_Brand__c,EUR_CRM_Brand__r.name,
                    EUR_CRM_POS_Material__c, EUR_CRM_POS_Material__r.Name,
                    EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name,
                    EUR_CRM_Product_Level__c,
                    EUR_CRM_Comments__c,
                    EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
                    EUR_CRM_Target_Quantity_Promo_Kits__c,
                    EUR_CRM_Target_Owner__c
                    from EUR_CRM_ObjPromo_Target__c 
                    where EUR_CRM_ObjPromo__c = :objPromo.Id
                    AND (RecordType.Developername = :OBJ_POSM_TARGET OR
                        RecordType.Developername = :OBJ_PRODUCT)];
        itemMap = new Map<Id,SObject>();
        
        // Initialize existing Ids according to the Product Level
        for(EUR_CRM_ObjPromo_Target__c target: targets) {
            if(target.EUR_CRM_Product_Level__c == 'EUR_CRM_Quality__c') {
                existingIds.add(target.EUR_CRM_BQ__c);
            } else if(target.EUR_CRM_Product_Level__c == 'EUR_CRM_Size__c') {
                existingIds.add(target.EUR_CRM_BQS__c);
            } else if(target.EUR_CRM_Product_Level__c != null) {
                Id existingId = (Id)(target.get(target.EUR_CRM_Product_Level__c));
                existingIds.add(existingId);
            }
        }
        
        System.debug(targets);
        System.debug(existingIds);
        
        if(getIsBrandQuality()) {
            itemMap = new Map<Id, EUR_CRM_Quality__c>([SELECT Id, Name FROM EUR_CRM_Quality__c WHERE Id IN :existingIds]);
        } else if(getIsBrand()) {
            itemMap = new Map<Id, EUR_CRM_Brand__c>([SELECT Id, Name FROM EUR_CRM_Brand__c WHERE Id IN :existingIds]);
        } else if(getIsPOSM()) {
            itemMap = new Map<Id, EUR_CRM_POS_Material__c>([SELECT Id, Name FROM EUR_CRM_POS_Material__c WHERE Id IN :existingIds]);
        } else if(getIsSKU()) {
            itemMap = new Map<Id, EUR_CRM_SKU__c>([SELECT Id, Name FROM EUR_CRM_SKU__c WHERE Id IN :existingIds]);
        } else if(getIsBrandSize()) {
            itemMap = new Map<Id, EUR_CRM_Size__c>([SELECT Id, Name FROM EUR_CRM_Size__c WHERE Id IN :existingIds]);
        }
    }
      
    public void initializeTargetManagement() {
        System.debug('##initializeTargetManagement:'+euAccounts);
        if(euAccounts != null && euAccounts.size() > 0) {
            System.debug('##initializeTargetManagement:'+regionalManagers);
            
            regionManager = (regionalManagers != null && regionalManagers.size() >0) ? regionalManagers.get(0).id : null;

            System.debug('##initializeTargetManagement:'+regionmanager);
        }
    }
    
    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalAndSalesAgencyTargetWraps(){ 
        try{
            if(targets.size() <= 0 || regionalManagers == null || regionalManagers.size() <= 0) {
                System.debug('Targets are not created ' + targets);
                System.debug('regionalManagers ' + regionalManagers);
                return null;
            }
            
            regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
            
            Id parentRecordTypeId;
            if(getIsLoyaltyPOSM()) {
                parentRecordTypeId = rtMap.get(OBJ_POSM_TARGET);
            } else {
                parentRecordTypeId = rtMap.get(OBJ_PRODUCT);
            }
            Id subTargetRecordTypeId = rtMap.get(MGR_POSM_TARGET);
            
            System.debug(regionalManagers);
            
            String targetField =  productLevelToFieldName.get(targets[0].EUR_CRM_Product_Level__c);
            System.debug(targetField);
            
            Id rManager = null;
            List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c', 'EUR_CRM_Target_Quantity_Promo_Kits__c',
                                                             'EUR_CRM_SKU__r.name', 'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
                                                             'EUR_CRM_BQ__c', 'EUR_CRM_BQ__r.Name',
                                                             'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
                                                             'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name', 'EUR_CRM_Product_Level__c',
                                                             'EUR_CRM_Promotion_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c',
                                                             'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'
                                                            };
           
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> tempList  =  EUR_CRM_OPTargetHelperClass.retrieveTargets(
                objPromo.Id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,
                targetField,regionalManagers, rManager ,additionalFields);
          
            System.debug(tempList);
            System.debug(tempList[0]);
            System.debug(parentRecordTypeId);

            if(tempList != null && tempList.size() > 0) {
                isManagerLevelTargetDone = true;

                // Assign correct product level name for Brand Quality
                // EUR_CRM_Quality__c instead of EUR_CRM_BQ__c
                if(targetField == 'EUR_CRM_BQ') {
                    targetField = 'EUR_CRM_Quality';
                } else if(targetField == 'EUR_CRM_BQS') {
                    targetField = 'EUR_CRM_Size';
                }

                // For each Regional Target, assign product level based on the Objective target's product level
                for(EUR_CRM_OPTargetHelperClass.TargetWrap targetWrap : tempList) {
                    System.debug(targetWrap.getVolumeBottleMatched());

                    if(!getIsOnTradePhase2()){
                        if(targetWrap.getVolumeBottleMatched()) {
                            isManagerLevelTargetDone = false;
                        }                        
                    } else {
                        if(targetWrap.getQuantityMatched()) {
                            isManagerLevelTargetDone = false;
                        }                        
                    }

                    if(targetWrap.srTargets != null) {
                        for(EUR_CRM_ObjPromo_Target__c target : targetWrap.srTargets) {
                            system.debug(target);
                            target.EUR_CRM_Product_Level__c = targetField + '__c';
                            if(target.Id == null) {
                                isManagerLevelTargetDone = false;
                            }
                        }
                    }
                }

                System.debug(tempList);

                regionalTargetWrap = tempList;
            }

            System.debug(isManagerLevelTargetDone);
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
                if(regionManager == null || targets == null || targets.size() <= 0 || euAccounts == null) {
                    System.Debug('##salesRepTargetWrap:regionManager' + regionManager);
                    System.Debug('##salesRepTargetWrap:targets' + targets);
                    System.Debug('##salesRepTargetWrap:targets.size()' + targets.size());
                    System.Debug('##salesRepTargetWrap:euAccounts' + euAccounts);
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
                Id parentRecordTypeId = rtMap.get(MGR_POSM_TARGET);
                Id subTargetRecordTypeId = rtMap.get(SR_POSM_TARGET);
                
                System.debug(targetOwners);
                
                String targetField =  productLevelToFieldName.get(targets[0].EUR_CRM_Product_Level__c);
                System.debug(targetField);
                
                List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c', 'EUR_CRM_Target_Quantity_Promo_Kits__c',
                    'EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name',
                    'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name',
                    'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
                    'EUR_CRM_BQ__c', 'EUR_CRM_BQ__r.Name',
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
                    
                    // Assign target Field for Brand Quality to the correct API name
                    if(targetField == 'EUR_CRM_BQ__c') {
                        targetField = 'EUR_CRM_Quality__c';
                    } else if(targetField == 'EUR_CRM_BQS') {
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
    
    public Boolean getIsLoyaltyPOSM() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_TRADE_LOYALTY_POSM;
    }

    public Boolean getIsOffPOSMPlacement() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_TRADE_POSM_PLACEMENT;
    }
  
    public Boolean getIsOffTradeLeaflet() {
        return this.objPromo.recordType.DeveloperName == OP_OFF_TRADE_LEAFLET;
    }

    public Boolean getIsOffTradeDiscount() {
        return this.objPromo.recordType.DeveloperName == OP_OFF_TRADE_DISCOUNT;
    }

    public Boolean getIsOffTradeModelStore() {
        return this.objPromo.recordType.DeveloperName.contains(OP_OFF_TRADE_MODEL_STORE);
    }

    public Boolean getIsOffTradeOnSitePromo() {
        return this.objPromo.recordType.DeveloperName == OP_OFF_TRADE_ON_SITE_PROMO;
    }

    public Boolean getIsOffTradeInStoreMedia() {
        return this.objPromo.recordType.DeveloperName == OP_OFF_TRADE_IN_STORE_MEDIA;
    }
    public Boolean getIsOnTradePhase1() {
        return this.objPromo.recordType.DeveloperName == OP_ON_TRADE_PHASE_1;
    }
    
    public Boolean getIsOnTradePhase2() {
        return this.objPromo.recordType.DeveloperName == OP_ON_TRADE_PHASE_2;
    }

    public void setPublishStatus() {
        if(isAccountSelectionDone == true && isDraft == true) {

            // Check if the targets are matched
            getRegionalAndSalesAgencyTargetWraps();
            System.debug(isManagerLevelTargetDone);

            if(isProductSelectionDone == true) {
                if(this.getIsLoyaltyPOSM() && isManagerLevelTargetDone == true) {
                    System.debug(isManagerLevelTargetDone);
                    // For loyalty POSM, all 3 tabs need to be completed
                    if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                        this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                        update this.objPromo;
                    }
                } else {
                    // for the rest, only the first 2 tabs
                    if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                        this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                        update this.objPromo;
                    }
                }

                return;
            } else if(this.getIsOnTradePhase2() && isManagerLevelTargetDone == true) {
                if(this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                    this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                    update this.objPromo;
                }

                return;
            }            
        } else {
            // if the O/P is publish ready, make it not publish ready
            if(this.objPromo.EUR_CRM_Is_Publish_ready__c == true) {
                this.objPromo.EUR_CRM_Is_Publish_ready__c = false;
                update this.objPromo;
            }

            return;
        }
        
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
        
        if(!this.getIsLoyaltyPOSM() && !this.getIsOnTradePhase2()) {
            style += 'display: none;';
        }
        if((this.isProductSelectionDone != true && this.getIsLoyaltyPOSM()) ||
            (this.isProductSelectionDone != true && this.getIsOnTradePhase2())) {
            style += 'pointer-events: none;cursor: default;';
        }
        
        return style;
    }
    
    public Boolean getIsListViewOptionRendered() {
        return true;
    }
    
    public Boolean getIsCTaxOptionRendered() {
        return this.offTradeRecordTypes.contains(this.objPromo.recordtypeId) && !this.getIsOffTradeModelStore();
    }
    
    public Boolean getIsPROSOptionRendered() {
        return this.getIsOnTradePhase1();
    }
    
    public Boolean getIsCSVOptionRendered() {
        return this.offTradeRecordTypes.contains(this.objPromo.recordTypeId) ||
                this.getIsOnTradePhase2();
    }

    public Boolean getIsBrandSizeRendered() {
        return this.getIsLoyaltyPOSM() || this.getIsOffTradeLeaflet() || this.getIsOffTradeDiscount() || this.getIsOffPOSMPlacement();
    }

    public Boolean getIsSKURendered() {
        return  !this.getIsOnTradePhase1() && !this.getIsOnTradePhase2() && !this.getIsLoyaltyPOSM() && !this.getIsOffTradeLeaflet() &&
                !this.getIsOffTradeDiscount() && !this.getIsOffTradeModelStore() && !this.getIsOffTradeOnSitePromo() &&
                !this.getIsOffTradeInStoreMedia() && !this.getIsOffPOSMPlacement();
    }

    public Boolean getIsAccountListView() {
        return selectedSelectionMethod == 'listView';
    }
    
    public Boolean getIsCustomerTaxonomy() {
        return selectedSelectionMethod == 'cTax';
    }
    
    public Boolean getIsPROS() {
        return selectedSelectionMethod == 'pros';
    }
    
    public Boolean getIsCSV() {
        return selectedSelectionMethod == 'csv';
    }
    
    public Boolean getIsProductSelectionSelected() {
        return selectedProductSelection != null && selectedProductSelection != 'none';
    }
    
    // TODO: Extend Product Selection Picklist. When a target is already created, the value of product selection should be inferred
    // instead of taken from the product selection picklist
    public Boolean getIsBrandQuality() {
        return selectedProductSelection == 'quality';
    }
    
    public Boolean getIsPOSM() {
        return selectedProductSelection == 'pos';
    }
    
    public Boolean getIsSKU() {
        return selectedProductSelection == 'sku';
    }

    public Boolean getIsBrand() {
        return selectedProductSelection == 'brand';
    }

    public Boolean getIsBrandSize() {
        return selectedProductSelection == 'size';
    }

    public Boolean getIsMultiSelectEnabled() {
        if(this.getIsOnTradePhase1() && this.getTargetsInSelectedProductLevel() != null && this.getTargetsInSelectedProductLevel().size() > 0) {
            return false;
        }

        return true;
    }
    
    public List<EUR_CRM_ObjPromo_Target__c> getTargetsInSelectedProductLevel() {

        if(this.selectedProductSelection == null) {
            return null;
        }
        List<EUR_CRM_ObjPromo_Target__c> selectedTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        for(EUR_CRM_ObjPromo_Target__c target : targets) {
            if(target.EUR_CRM_Product_Level__c.containsIgnoreCase(this.selectedProductSelection)) {
                selectedTargets.add(target);
            }
        }        
        
        return selectedTargets;
    }

    public List<EUR_CRM_ObjPromo_Target__c> getTargetsInSelectedProductLevelForTargetManagement(){
        List<EUR_CRM_ObjPromo_Target__c> selectedTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        for(EUR_CRM_ObjPromo_Target__c target : targets) {
            selectedTargets.add(target);
        }        
        
        return selectedTargets;
    }

    public Boolean getHideAddButtons(){
        if(getIsOnTradePhase2() && targets != null && targets.size()>=1){
            return true;
        }
        return false;
    }

    public override void add(){
        if(getIsOnTradePhase2() && targets.size()>=1){
            return;
        }

        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedProductId = ApexPages.CurrentPage().getParameters().get('p1');
        
        if(getIsBrandQuality()) {
            target.EUR_CRM_BQ__c = (Id) addedProductId;
            target.EUR_CRM_BQ__r = (EUR_CRM_Quality__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
        } else if(getIsBrand()) {
            target.EUR_CRM_Brand__c = (Id) addedProductId;
            target.EUR_CRM_Brand__r = (EUR_CRM_Brand__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Brand__c';
        } else if(getIsPOSM()) {
            target.EUR_CRM_POS_Material__c = (Id) addedProductId;
            target.EUR_CRM_POS_Material__r = (EUR_CRM_POS_Material__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_POS_Material__c';
        } else if(getIsSKU()) {
            target.EUR_CRM_SKU__c = (Id) addedProductId;
            target.EUR_CRM_SKU__r = (EUR_CRM_SKU__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_SKU__c';
        } else if(getIsBrandSize()) {
            target.EUR_CRM_BQS__c = (Id) addedProductId;
            target.EUR_CRM_BQS__r = (EUR_CRM_Size__c)itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
        }

        // Assign POSM target record type to POSM placement O/P
        if(this.getIsLoyaltyPOSM()) {
            target.recordtypeId = rtMap.get(OBJ_POSM_TARGET);
        } else {
            target.recordtypeId = rtMap.get(OBJ_PRODUCT);
        }
        
        System.debug(target.recordTypeId);
        
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
        
        if(getIsBrandQuality()) {
            existingIDs.remove(target.EUR_CRM_BQ__c);
        } else if(getIsBrand()) {
            existingIDs.remove(target.EUR_CRM_Brand__c);
        } else if(getIsPOSM()) {
            existingIDs.remove(target.EUR_CRM_POS_Material__c);
        } else if(getIsSKU()) {
            existingIDs.remove(target.EUR_CRM_SKU__c);
        } else if(getIsBrandSize()) {
            existingIDs.remove(target.EUR_CRM_BQS__c);
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
            } 
            else {
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
            // Only Delete Targets when it is in draft mode
            if(isDraft) {
                EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets);                 
            }
            
            System.debug(targets);
            System.debug(toDeleteTargets);
            
            if(targets != null && targets.size() >0){
                upsert targets;
            }

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
        quickSaveObjectiveTargets();
        return cancel();
    }
    
    public PageReference quickSaveRegionalTargets() {
        try{
            System.debug(regionalTargets);
            System.debug(regionalTargetWrap);

            // TODO: Necessary to delete targets?
            if(regionalTargets != null && regionalTargets.size() > 0 && regionalTargetWrap != null){
                
                System.debug(regionalTargetWrap);
                for(EUR_CRM_OPTargetHelperClass.TargetWrap regTarget : regionalTargetWrap) {
                    if(!getIsOnTradePhase2()){
                        if(regTarget.getVolumeBottleMatched()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }                       
                    } else {
                        if(regTarget.getQuantityMatched()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }                        
                    }
                }
                
                upsert regionalTargets;   
            } else {
                isManagerLevelTargetDone = false;
            }
            
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
        if(quickSaveRegionalTargets() == null) {
            return null;
        }
        return cancel();
    }
    
    public PageReference quickSaveSRTargets() {
        try{
            if(salesRepTargetWrap != null && salesRepTargetWrap.size() > 0) {
                
                List<EUR_CRM_ObjPromo_Target__c> newSRTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                for(EUR_CRM_OPTargetHelperClass.TargetWrap srWrap : salesRepTargetWrap) {
                    if(!getIsOnTradePhase2()){
                        if(srWrap.getVolumeBottleMatched()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }                        
                    } else {
                        if(srWrap.getQuantityMatched()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }                        
                    }
                    newSRTargets.addAll(srWrap.srTargets);
                }
                //upsert salesRepTargetWrap.srTargets;
                
                upsert newSRTargets;
            }
            
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
        if(quickSaveSRTargets() == null) {
            return null;
        }
        return cancel();
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference refresh(String referenceField) {
        PageReference pageRef = new PageReference('/apex/EUR_CRM_RU_ObjPromoManagePage?ObjPromoId=' + objPromo.Id + referenceField);
        pageRef.setRedirect(true);
        return pageRef;
    }

}