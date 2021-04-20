public with sharing class EUR_CRM_BE_ObjPromoManageController extends EUR_CRM_AbstractSelectionItem {

    public EUR_CRM_ObjPromo__c objPromo { get; set; }
    public Boolean isDraft { get; set; }
    public Boolean isDeactivated { get; set; }
    public Boolean isActive { get; set; }
    public Boolean isAccountSelectionDone { get; set; }
    public Boolean isProductSelectionDone { get; set; }
    public Boolean isTargetManagementDone { get; set; }
    public String selectedSelectionMethod { get; set; }
    public String selectedProductSelection { get; set; }
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;
    public List<EUR_CRM_ObjPromo_Target__c> targets { get; set; }
    public List<EUR_CRM_ObjPromo_Target__c> regionalTargets { get; set; }
    public List<EUR_CRM_ObjPromo_Target__c> srTargets { get; set; }
    public EUR_CRM_AbstractSelectionItem sCon { get; set; }
    public ApexPages.StandardController standardController { get; set; }
    public String PromoKitTargetUnitOpt { get; set; }

    public static Integer ROWS_PER_PAGE = 50;
    public Integer euAccountsPageNum { get; set; }
    public Boolean euAccountsPageHasMore { get; set; }
    public Integer euAccountsFirstIndex { get; set; }


    private Map<String, String> productLevelToFieldName = new Map<String, String>{
            'EUR_CRM_Size__c' => 'EUR_CRM_BQS',
            'EUR_CRM_SKU__c' => 'EUR_CRM_SKU',
            'EUR_CRM_Quality__c' => 'EUR_CRM_BQ'
    };

    public List<SelectOption> getPromoKitUnits() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Promokit', 'Promo Kit'));
        options.add(new SelectOption('Bottles', 'Bottles'));
        return options;
    }

    // Account Management
    private transient List<EUR_CRM_Account__c> euAccounts;
    public List<EUR_CRM_Account__c> pagedEUAccounts { get; set; }

    // Target Management
    // Maps Regional Manager's Id to a list of SR Ids under the manager
    private Map<Id, List<Id>> regionalSalesRepMap;
    private List<EUR_CRM_OPTargetHelperClass.TargetWrap> regionalTargetWrap;
    private List<User> regionalManagers;
    public Id regionManager { get; set; }

    private Boolean hasWriteAccess;


    //OP Target 
    public final String OBJ_VOLUME_TARGET = 'EUR_BE_Objective_Volume_Target';
    public final String SR_VOLUME_TARGET = 'EUR_BE_SR_Volume_Target';
    public final String OBJ_PRODUCT_TARGET = 'EUR_BE_Objective_Product';

    //OP Record 
    public final String OP_OFF_SALES_DRIVE = 'EUR_BE_Off_Trade_Sales_Drive';
    public final String OP_OFF_SPYDER = 'EUR_BE_Off_Trade_Secondary_placement_Spyder_display';
    public final String OP_ON_PROMO_KIT = 'EUR_BE_On_Trade_Promo_Kit_Activation';
    public final String OP_ON_SECOND_PLACE = 'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist';

    public final List<String> AccountSelectionByCTax = New List<String>{
    };
    public final List<String> AccountSelectionByPROS = New List<String>{
    };
    public final List<String> EnableProductSelection = New List<String>{
    };
    public final List<String> EnableTargetManagement = New List<String>{
    };

    //public final String OP_OFF_SKU_BOTTLES  = 'EUR_BE_Off_Trade_Sales_Drive_SKU_Bottles';
    //public final String OP_OFF_SKU_DISPLAYS = 'EUR_BE_Off_Trade_Sales_Drive_SKU_Displays';
    //public final String OP_OFF_SKU_CARTONS  = 'EUR_BE_OFF_Trade_Sales_Drive_SKU_Cartons';
    //public final String OP_OFF_LEAFLET      = 'EUR_BE_Off_Trade_Leaflet_Campaign';
    //public final String OP_OFF_TASTING      = 'EUR_BE_Off_Trade_Tasting_Campaign';
    //public final String OP_OFF_DISTRIBUTION = 'EUR_BE_Off_Trade_Distribution_Drive';
    Map<String, Id> rtMap;

    public EUR_CRM_BE_ObjPromoManageController(ApexPages.StandardController sc) {
        this.standardController = sc;
        this.objPromo = [
                SELECT Id, recordtypeId, recordtype.developername,
                        EUR_CRM_Is_Quota__c, EUR_CRM_Status__c, EUR_CRM_Is_Publish_ready__c, Name
                FROM EUR_CRM_ObjPromo__c
                WHERE ID = :ApexPages.currentPage().getParameters().get('objPromoId')
        ];
        this.rtMap = new Map<String, Id>();
        this.isDraft = this.objPromo != null && this.objPromo.EUR_CRM_Status__c == 'Draft';
        this.isDeactivated = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Deactivated';
        this.isActive = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Active';

        List<UserRecordAccess> userRecordAccessList = [
                SELECT RecordId, HasEditAccess
                FROM UserRecordAccess
                WHERE UserId = :UserInfo.getUserId()
                AND RecordId = :objPromo.Id
        ];

        this.hasWriteAccess = userRecordAccessList.size() > 0 ? userRecordAccessList[0].HasEditAccess : false;

        // Initialize record types
        for (RecordType rt : Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo__c')) {
            rtMap.put(rt.developername, rt.Id);
        }

        // Add O/P Target record types to rtMap as well for later use
        //rtMap.put(OBJ_PRODUCT, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_PRODUCT));
        //rtMap.put(MGR_VOLUME_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + MGR_VOLUME_TARGET));

        rtMap.put(OBJ_VOLUME_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_VOLUME_TARGET));
        rtMap.put(SR_VOLUME_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + SR_VOLUME_TARGET));
        rtMap.put(OBJ_PRODUCT_TARGET, Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c' + OBJ_PRODUCT_TARGET));

        initializeAccountSelection();
        if (this.objPromo.RecordType.Developername != OP_OFF_SPYDER) {
            initializeProductSelection();
        }
        if (this.objPromo.RecordType.Developername == OP_OFF_SPYDER) {
            initializeSRTargets();
        }

        initializeTargetManagement();

        //Setup default Promot Kit Unit Type Selection, Depends on the first record
        If (objPromo.RecordType.DeveloperName == OP_ON_PROMO_KIT) {
            If (targets.size() > 0) {
                If (targets[0].EUR_CRM_Qty_Sell_in_Amount_Bottle__c != null && targets[0].EUR_CRM_Qty_Sell_in_Amount_Bottle__c > 0) {
                    PromoKitTargetUnitOpt = 'Bottles';
                }
            }
        }

    }

    public void initializeAccountSelection() {
        // Account Management
        euAccountsPageNum = 0;
        Set<Id> taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        initEuAccounts(taxonomyIds);

        if (euAccounts != null && euAccounts.size() > 0) {
            regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);
            this.isAccountSelectionDone = true;

            //System.Debug(regionalManagers);

            if (taxonomyIds != null && taxonomyIds.size() > 0) {
                this.selectedSelectionMethod = 'cTax';
            }
        } else {
            this.isAccountSelectionDone = false;
        }

        getPagedEUAccounts();
    }

    public void getPagedEUAccounts() {
        initEuAccounts();
        pagedEUAccounts = new List<EUR_CRM_Account__c>();

        euAccountsFirstIndex = euAccountsPageNum * ROWS_PER_PAGE;
        euAccountsPageHasMore = (1 + euAccountsPageNum) < getTotalPages();

        for (Integer i = euAccountsFirstIndex; i < euAccountsFirstIndex + ROWS_PER_PAGE && euAccounts.size() > i; i++) {
            pagedEUAccounts.add(euAccounts.get(i));
        }
    }

    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the first one
    *****************************************************************/
    public void firstPage() {
        euAccountsPageNum = 0;
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the last one
    *****************************************************************/
    public void lastPage() {
        euAccountsPageNum = getTotalPages() - 1;
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the next one in order
    *****************************************************************/
    public void nextPage() {
        Math.min(euAccountsPageNum++, getTotalPages());
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the previous one in order
    *****************************************************************/
    public void previousPage() {
        Math.max(euAccountsPageNum--, 0);
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   calculates the total number of pages needed to display the full amount of data in the alleuAccounts list
    *   returns: and Integer number of maximum number of pages needed
    *****************************************************************/
    private Integer getTotalPages() {
        initEuAccounts();
        if (System.Math.mod(euAccounts.size(), ROWS_PER_PAGE) == 0)
            return euAccounts.size() / ROWS_PER_PAGE ; else
                return (euAccounts.size() / ROWS_PER_PAGE) + 1;
    }

    public void initializeProductSelection() {
        this.sCon = this;
        this.initializeTargets();

        if (targets != null && targets.size() > 0) {
            this.isProductSelectionDone = true;

            // Initialize selected product selectOption according to the product level of the target
            this.selectedProductSelection = targets[0].EUR_CRM_Product_Level__c.split('_')[2].toLowerCase();

        } else {
            this.isProductSelectionDone = false;
        }
    }

    public void initializeTargets() {
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [
                select id,
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
                        EUR_CRM_Target_Quantity_Promo_Kits__c,
                        EUR_CRM_Target_Quantity_Spyders__c,
                        EUR_CRM_Target_Owner__c,
                        EUR_CRM_Actual_Volume_Displays__c,
                        EUR_CRM_Actual_Volume_Bottles__c
                from EUR_CRM_ObjPromo_Target__c
                where EUR_CRM_ObjPromo__c = :objPromo.Id
                AND ((RecordType.Developername = :OBJ_VOLUME_TARGET) OR (RecordType.Developername = :OBJ_PRODUCT_TARGET))
        ];
        itemMap = new Map<Id, SObject>();

        // Initialize existing Ids according to the Product Level
        for (EUR_CRM_ObjPromo_Target__c target : targets) {
            if (target.EUR_CRM_Product_Level__c == 'EUR_CRM_Size__c') {
                existingIds.add(target.EUR_CRM_BQS__c);
            } else if (target.EUR_CRM_Product_Level__c == 'EUR_CRM_Quality__c') {
                existingIds.add(target.EUR_CRM_BQ__c);
            } else if (target.EUR_CRM_Product_Level__c != null) {
                Id existingId = (Id) (target.get(target.EUR_CRM_Product_Level__c));
                existingIds.add(existingId);
            }
        }

        //System.Debug('inside initializeTargets() targets:' + targets);
        //System.Debug('inside initializeTargets() existingIds:' + existingIds);

        if (getIsBrandSize()) {
            itemMap = new Map<Id, EUR_CRM_Size__c>([SELECT Id, Name FROM EUR_CRM_Size__c WHERE Id IN :existingIds]);
        } else if (getIsSKU()) {
            itemMap = new Map<Id, EUR_CRM_SKU__c>([SELECT Id, Name FROM EUR_CRM_SKU__c WHERE Id IN :existingIds]);
        } else if (getIsBrandQuality()) {
            itemMap = new Map<Id, EUR_CRM_Quality__c>([SELECT Id, Name FROM EUR_CRM_Quality__c WHERE Id IN :existingIds]);
        }
        setDefaults(targets);
    }

    public void initializeSRTargets() {
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [
                select id,
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
                        EUR_CRM_Target_Owner__c,
                        EUR_CRM_Actual_Volume_Displays__c,
                        EUR_CRM_Actual_Volume_Bottles__c
                from EUR_CRM_ObjPromo_Target__c
                where EUR_CRM_ObjPromo__c = :objPromo.Id
                AND (RecordType.Developername = :OBJ_VOLUME_TARGET)
        ];
        setDefaults(targets);
    }

    public void initializeTargetManagement() {
        initEuAccounts();
        //System.Debug(euAccounts);
        if (euAccounts != null && euAccounts.size() > 0) {
            //System.Debug(regionalManagers);

            regionManager = (regionalManagers != null && regionalManagers.size() > 0) ? regionalManagers.get(0).id : null;

            if (regionManager != null && targets != null) {
                this.isTargetManagementDone = true;
            }

            //System.Debug(regionmanager);
        }
    }

    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getRegionalAndSalesAgencyTargetWraps() {
        /*try{
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
                'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c','EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c'};

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
        }*/

        return null;
    }

    public List<SelectOption> getRegionalManagerOptions() {
        if (regionManager == null) {
            return null;
        }

        List<SelectOption> regionalManagerOptions = new List<SelectOption>();
        for (User regionManager : regionalManagers) {
            regionalManagerOptions.add(new SelectOption(regionManager.id, regionManager.name));
        }
        return regionalManagerOptions;
    }

    public List<EUR_CRM_OPTargetHelperClass.TargetWrap> salesRepTargetWrap {
        get {
            try {
                initEuAccounts();
                //System.Debug(targets);
                if (targets == null || targets.size() <= 0 || euAccounts == null) {
                    return null;
                }

                if (salesRepTargetWrap != null) {
                    return salesRepTargetWrap;
                }
                //System.Debug(targets);
                //System.Debug(euAccounts);
                //System.Debug(regionManager);
                List<User> targetOwners = new List<User>();
                List<Id> targetOwnerIds = new List<Id>();
                for (EUR_CRM_Account__c acc : euAccounts) {
                    targetOwnerIds.add(acc.OwnerId);
                }
                targetOwners = [SELECT Id, Name FROM User WHERE Id IN :targetOwnerIds];
                //List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager); 
                srTargets = new List<EUR_CRM_ObjPromo_Target__c >();


                Id parentRecordTypeId;
                if (this.getIsOnSecondPlace()) {
                    parentRecordTypeId = rtMap.get(OBJ_PRODUCT_TARGET);
                } else {
                    parentRecordTypeId = rtMap.get(OBJ_VOLUME_TARGET);
                }

                Id subTargetRecordTypeId = rtMap.get(SR_VOLUME_TARGET);

                //System.Debug(targetOwners);

                String targetField = productLevelToFieldName.get(targets[0].EUR_CRM_Product_Level__c);
                //System.Debug(targetField);

                List<String> additionalFields = new List<String>{
                        'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ', 'EUR_CRM_SKU__c',
                        'EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name', 'EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c',
                        'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name',
                        'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
                        'EUR_CRM_BQ__c', 'EUR_CRM_BQ__r.Name',
                        'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
                        'EUR_CRM_Product_Level__c',
                        'EUR_CRM_Promotion_Type__c ', 'EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c',
                        'EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ', 'EUR_CRM_Qty_Sell_in_Amount_Display__c', 'EUR_CRM_Target_Quantity_Spyders__c', 'EUR_CRM_Target_Quantity_Promo_Kits__c ',
                        'EUR_CRM_Unit_of_Measure__c', 'EUR_CRM_Grouping_Type__c', 'EUR_CRM_Actual_Volume_Displays__c', 'EUR_CRM_Actual_Volume_Bottles__c'
                };

                If (this.objPromo.RecordType.DeveloperName == OP_OFF_SPYDER) {
                    this.salesRepTargetWrap = EUR_CRM_OPTargetHelperClass.retrieveTargetSpyder(
                            objPromo.Id, srTargets, parentRecordTypeId,
                            subTargetRecordTypeId, targetOwners,
                            null, additionalFields);
                } Else If (this.objPromo.RecordType.DeveloperName == OP_ON_SECOND_PLACE) {
                    return null;
                } Else {
                    this.salesRepTargetWrap = EUR_CRM_OPTargetHelperClass.retrieveTargets(
                            objPromo.Id, srTargets, parentRecordTypeId,
                            subTargetRecordTypeId, targetField, targetOwners,
                            null, additionalFields);
                }


                //System.debug(this.salesRepTargetWrap);
                //System.Debug(srTargets);

                Map<Id, List<EUR_CRM_ObjPromo_Target__c>> salesAgencyMap = new Map<Id, List<EUR_CRM_ObjPromo_Target__c>>();

                if (srTargets != null && srTargets.size() > 0) {
                    isTargetManagementDone = true;

                    // Assign target Field for Brand Size to the correct API name
                    if (targetField == 'EUR_CRM_BQS') {
                        targetField = 'EUR_CRM_Size';
                    }

                    // Assign correct target level to SR Targets
                    // Also specifies if the target selection has been completed by checking
                    // if SR targets has an Id
                    for (EUR_CRM_ObjPromo_Target__c srTarget : srTargets) {
                        srTarget.EUR_CRM_Product_Level__c = targetField + '__c';
                        if (srTarget.Id == null) {
                            isTargetManagementDone = false;
                        }
                    }
                }
                setDefaults(salesRepTargetWrap);
                return salesRepTargetWrap;

            } catch (Exception e) {
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
        //System.Debug('>>>setPublishStatus');
        //System.Debug(this.objPromo);

        //System.Debug('>>>isAccountSelectionDone:' + isAccountSelectionDone);
        //System.Debug('>>>isProductSelectionDone' + isProductSelectionDone);
        //System.Debug('>>>isDraft' + isDraft);
        //System.debug(getIsLeaflet());
        //System.debug(getIsTasting());
        //System.debug(getIsDistribution());
        //System.Debug('>>>isTargetManagementDone' + isTargetManagementDone);

        if (isAccountSelectionDone == true && isDraft == true) {

            If (this.objPromo.RecordType.DeveloperName == OP_OFF_SPYDER && isTargetManagementDone == true) {
                if (this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                    this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                    update this.objPromo;
                }
                return;
            } else if (this.objPromo.RecordType.DeveloperName == OP_ON_SECOND_PLACE && isProductSelectionDone == true) {
                if (this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                    this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                    update this.objPromo;
                }
                return;
            } else {
                if (isProductSelectionDone == true && isTargetManagementDone == true) {
                    // if the O/P is not pubish ready, make it so
                    if (this.objPromo.EUR_CRM_Is_Publish_ready__c == false) {
                        this.objPromo.EUR_CRM_Is_Publish_ready__c = true;
                        update this.objPromo;
                    }
                    return;
                }
            }
            /*if(this.getIsLeaflet() ||  getIsTasting() || getIsDistribution() ||
                isTargetManagementDone == true ) {*/

        }

        // if the O/P is publish ready, make it not publish ready
        if (this.objPromo.EUR_CRM_Is_Publish_ready__c == true) {
            this.objPromo.EUR_CRM_Is_Publish_ready__c = false;

            update this.objPromo;
        }
    }

    public String getProductSelectionTabVisibility() {
        If (this.objPromo.RecordType.DeveloperName == OP_OFF_SPYDER) {
            return 'pointer-events: none;cursor: default; display:none;';
        }

        if (this.isAccountSelectionDone != true) {
            return 'pointer-events: none;cursor: default; display:none;';
        }

        return '';
    }

    public Boolean getIsProductionSelectionRendered() {
        If (this.objPromo.RecordType.DeveloperName == OP_OFF_SALES_DRIVE) {
            return true;
        }
        return false;
    }

    public Boolean getIsTargetManagementRendered() {
        If (this.objPromo.RecordType.DeveloperName == OP_OFF_SALES_DRIVE) {
            return true;
        }
        return false;
    }

    public String getTargetManagementTabVisibility() {
        String style = '';

        //if(!this.getIsTargetManagementRendered()) {
        //    style += 'display: none;';
        //}
        if (this.isProductSelectionDone != true || this.isAccountSelectionDone != true) {
            style += 'pointer-events: none;cursor: default;';
        }

        if (!getIsTargetManagementRendered()) {
            style += 'display: none;';
        }

        return style;
    }

    public String getTargetManagementSpyderTabVisibility() {
        String style = '';
        if (this.objPromo.RecordType.DeveloperName != OP_OFF_SPYDER) {
            style += 'display: none;';
        }
        return style;
    }

    public String getTargetManagementPromoKitTabVisibility() {
        String style = '';
        if (this.objPromo.RecordType.DeveloperName != OP_ON_PROMO_KIT) {
            style += 'display: none;';
        }
        return style;
    }

    public String getTargetManagerTabVisibility() {
        String style = '';
        if (this.objPromo.RecordType.DeveloperName == 'EUR_BE_Off_Trade_Sales_Drive' || this.objPromo.RecordType.DeveloperName == OP_ON_PROMO_KIT) {
            style += 'display: none;';
        }
        return style;
    }


    /*public Boolean getIsLeaflet() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_LEAFLET;
    }
    
    public Boolean getIsTasting() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_TASTING;
    }
    
    public Boolean getIsDistribution() {
        return this.objPromo.RecordType.DeveloperName == OP_OFF_DISTRIBUTION;
    }*/

    public Boolean getIsSpyder() {
        return this.objPromo.RecordType.Developername == OP_OFF_SPYDER;
    }

    public Boolean getIsSalesDrive() {
        return this.objPromo.RecordType.Developername == OP_OFF_SALES_DRIVE;
    }

    public Boolean getIsOnPromoKit() {
        return this.objPromo.RecordType.Developername == OP_ON_PROMO_KIT;
    }

    public Boolean getIsOnSecondPlace() {
        return this.objPromo.RecordType.Developername == OP_ON_SECOND_PLACE;
    }

    public Boolean getIsListViewOptionRendered() {
        if (this.objPromo.RecordType.Developername == OP_ON_SECOND_PLACE) {
            return true;
        }
        return false;
    }

    public Boolean getIsCTaxOptionRendered() {
        if (this.objPromo.RecordType.Developername == OP_OFF_SPYDER || this.objPromo.RecordType.Developername == OP_OFF_SALES_DRIVE) {
            return true;
        }
        return false;
    }

    public Boolean getIsPRSOptionRendered() {
        //System.Debug('>>>RecordTYpe' + this.objPromo.RecordType.Developername);
        if (this.objPromo.RecordType.Developername == OP_ON_PROMO_KIT) {
            return true;
        }
        return false;
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

    public Boolean getIsProductSelectionSelected() {
        return selectedProductSelection != null && selectedProductSelection != 'none';
    }

    public Boolean getIsBrandSizeRendered() {
        //return this.objPromo.recordType.developername == OP_OFF_SKU_BOTTLES;
        return false;
    }

    public Boolean getIsBrandQualityRendered() {
        if (this.objPromo.recordType.developername == OP_ON_SECOND_PLACE || this.objPromo.recordType.developername == OP_ON_PROMO_KIT) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean getIsSKURendered() {
        return this.objPromo.recordType.developername == OP_OFF_SALES_DRIVE;
    }

    public Boolean getIsBrandSize() {
        return selectedProductSelection == 'size';
    }

    public Boolean getIsSKU() {
        return selectedProductSelection == 'sku';
    }

    public Boolean getIsBrandQuality() {
        return selectedProductSelection == 'quality';
    }

    public Integer getSpyderVolume() {
        return 1;
    }

    public List<EUR_CRM_ObjPromo_Target__c> getTargetsInSelectedProductLevel() {
        if (this.selectedProductSelection == null) {
            return null;
        }

        List<EUR_CRM_ObjPromo_Target__c> selectedTargets = new List<EUR_CRM_ObjPromo_Target__c>();

        for (EUR_CRM_ObjPromo_Target__c target : targets) {
            if (target.EUR_CRM_Product_Level__c.containsIgnoreCase(this.selectedProductSelection)) {
                selectedTargets.add(target);
            }
        }

        return selectedTargets;
    }

    public List<EUR_CRM_ObjPromo_Target__c> getTargetsInSpyderObjectiveLevel() {
        List<EUR_CRM_ObjPromo_Target__c> selectedTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        for (EUR_CRM_ObjPromo_Target__c target : targets) {
            selectedTargets.add(target);
        }

        return selectedTargets;
    }

    public override void add() {
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedProductId = ApexPages.CurrentPage().getParameters().get('p1');

        if (getIsBrandSize()) {
            target.EUR_CRM_BQS__c = (Id) addedProductId;
            target.EUR_CRM_BQS__r = (EUR_CRM_Size__c) itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
        } else if (getIsSKU()) {
            target.EUR_CRM_SKU__c = (Id) addedProductId;
            target.EUR_CRM_SKU__r = (EUR_CRM_SKU__c) itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_SKU__c';
        } else if (getIsBrandQuality()) {
            target.EUR_CRM_BQ__c = (Id) addedProductId;
            target.EUR_CRM_BQ__r = (EUR_CRM_Quality__c) itemMap.get((Id) addedProductId);
            target.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
        }

        /*if(this.getIsLeaflet() || this.getIsDistribution() || this.getIsTasting()) {
            target.recordTypeId = rtMap.get(OBJ_PRODUCT);
        } else {
            target.recordTypeId = rtMap.get(OBJ_VOLUME_TARGET);
        }*/

        if (this.getIsOnSecondPlace()) {
            target.recordTypeId = rtMap.get(OBJ_PRODUCT_TARGET);
        } else {
            target.recordTypeId = rtMap.get(OBJ_VOLUME_TARGET);
            target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 0;
            target.EUR_CRM_Target_Quantity_Promo_Kits__c = 0;
            target.EUR_CRM_Target_Quantity_Spyders__c = 0;
        }


        //

        //System.Debug(target);

        target.EUR_CRM_ObjPromo__c = objPromo.Id;
        targets.add(target);
        existingIds.add((ID) addedProductId);
        setDefaults(targets);
    }

    public void removeProduct() {
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c target = targets.remove(i - 1);
        if (target.id != null) {
            toDeleteTargets.add(target);
        }

        if (getIsBrandSize()) {
            existingIDs.remove(target.EUR_CRM_BQS__c);
        } else if (getIsSKU()) {
            existingIDs.remove(target.EUR_CRM_SKU__c);
        } else if (getIsBrandQuality()) {
            existingIDs.remove(target.EUR_CRM_BQ__c);
        }
    }

    /**
    * function: deleteOldTargets
    * deletes old targets as well as related manager level targets and sales rep targets
    * input: list of targets (objective level) to be deleted
    */
    public void deleteOldTargets(List<EUR_CRM_ObjPromo_Target__c> oldTargets) {
        List<String> targetIds = new List<String>();
        for (EUR_CRM_ObjPromo_Target__c target : oldTargets) {
            targetIds.add((String) target.Id);
        }

        Map<Id, EUR_CRM_ObjPromo_Target__c> oldManagerTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([
                SELECT Id
                FROM EUR_CRM_ObjPromo_Target__c
                WHERE EUR_CRM_O_P_Target__c IN :targetIds
        ]);

        if (oldManagerTargets != null && oldManagerTargets.size() > 0) {
            oldTargets.addAll(oldManagerTargets.values());

            Map<Id, EUR_CRM_ObjPromo_Target__c> oldSRTargets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([
                    SELECT Id
                    FROM EUR_CRM_ObjPromo_Target__c
                    WHERE EUR_CRM_O_P_Target__c IN :oldManagerTargets.keySet()
            ]);

            //System.Debug(oldManagerTargets);
            //System.Debug(oldSRTargets);

            if (oldSRTargets != null && oldSRTargets.size() > 0) {
                oldTargets.addAll(oldSRTargets.values());
            }
        }

        //System.Debug(oldTargets);
        //toDeleteTargets.addAll((List<EUR_CRM_ObjPromo_Target__c>)Database.query(query));

        delete oldTargets;
    }

    public pageReference quickSaveProducts() {
        try {

            if (toDeleteTargets.size() > 0) {
                deleteOldTargets(toDeleteTargets);
            }

            if (targets.size() > 0) {
                // Compare each target to the currently selected selection method, and remove
                // targets not belonging to that particular selection method.

                // Remove old O/P Targets
                List<EUR_CRM_ObjPromo_Target__c> oldTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                List<EUR_CRM_ObjPromo_Target__c> newTargets = new List<EUR_CRM_ObjPromo_Target__c>();

                for (EUR_CRM_ObjPromo_Target__c target : targets) {
                    if (target.EUR_CRM_Product_Level__c.containsIgnoreCase(this.selectedProductSelection)) {
                        newTargets.add(target);
                    } else {
                        oldTargets.add(target);
                    }
                }

                deleteOldTargets(oldTargets);
                setDefaults(newTargets);

                Boolean upsertResult = upsertTargets(newTargets);

                if (!upsertResult) {
                    return null;
                }

            } else {
                isProductSelectionDone = false;
            }
            If (this.objPromo.recordType.developername == OP_ON_SECOND_PLACE) {
                Integer OPTargetCount = [SELECT COUNT() FROM EUR_CRM_ObjPromo_Target__c Where EUR_CRM_ObjPromo__c = :this.objPromo.Id];
                //System.Debug('>>>Target Count:' + OPTargetCount);
                if (OPTargetCount > 0) {
                    isProductSelectionDone = true;
                }
            }

            setPublishStatus();

            return refresh('&pageReference=product');
        } catch (DMLException e) {
            throw e;
            //System.Debug(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }

    public PageReference saveProducts() {
        Boolean result = quickSaveProducts() != null;
        if (result) {
            setPublishStatus();
            return cancel();
        }
        return null;
    }

    public pageReference quickSaveObjectiveTargets() {
        try {
            // Only delete targets when it is in draft mode
            if (isDraft) {
                EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets);
            }

            /*For(EUR_CRM_ObjPromo_Target__c OPT : targets){
                System.Debug('QUick Save Obj: Update Bottle:' + OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c + ':' + OPT.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c);
                If(OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c != null && OPT.EUR_CRM_SKU__c != null){
                    OPT.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c * OPT.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c;
                }
            }*/ //Disable Conversion

            if (targets != null && targets.size() > 0) {
                for (EUR_CRM_ObjPromo_Target__c target : targets) {
                    setDefaults(target);
                }

                System.debug('#targets before upsert:' + JSON.serializePretty(targets));
                Boolean upsertResult = upsertTargets(targets);

                if (!upsertResult) {
                    return null;
                } else {
                    update this.objPromo;
                }
            }

            // TODO: Update O/P Is Quota

            return refresh('&pageReference=objective');
        } catch (DMLException e) {
//            system.debug(e);
//            throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Active End Date: Active End Date cannot be less than the date today.'));
            return null;
        }
    }

    public PageReference saveObjectiveTargets() {
        Boolean result = quickSaveObjectiveTargets() != null;
        return result ? cancel() : null;
    }

    public PageReference quickSaveRegionalTargets() {
        try {
            if (regionalTargets != null && regionalTargets.size() > 0 && regionalTargetWrap != null) {


                /*For(EUR_CRM_ObjPromo_Target__c OPT : regionalTargets){
                    System.Debug('QUick Save Regional Target: Update Bottle:' + OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c + ':' + OPT.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c);
                    If(OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c != null && OPT.EUR_CRM_SKU__c != null){
                        OPT.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c * OPT.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c;
                    }
                }*/ //Disable Conversion

                //System.Debug(regionalTargetWrap);
                for (EUR_CRM_OPTargetHelperClass.TargetWrap regTarget : regionalTargetWrap) {
                    if (!regTarget.getVolumeBottleMatchedExactly()) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                        return null;
                    }
                }
                setDefaults(regionalTargets);
                //System.Debug('RegionalTarget Checking:' + regionalTargets);

                Boolean upsertResult = upsertTargets(regionalTargets);

                if (!upsertResult) {
                    return null;
                }
            }

            return refresh('&pageReference=manager');
        } catch (DMLException e) {
            throw e;
            //System.Debug(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }

    public PageReference saveRegionalTargets() {
        Boolean result = quickSaveRegionalTargets() != null;
        return result ? cancel() : null;
    }

    public PageReference quickSaveSRTargets() {
        try {
            if (salesRepTargetWrap != null && salesRepTargetWrap.size() > 0) {

                List<EUR_CRM_ObjPromo_Target__c> newSRTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                setDefaults(salesRepTargetWrap);
                for (EUR_CRM_OPTargetHelperClass.TargetWrap srWrap : salesRepTargetWrap) {
                    If (this.objPromo.RecordType.DeveloperName == OP_OFF_SPYDER) {
                        //System.Debug('SP:' + srWrap.getVolumeBottleMatchedExactly());
                        if (!srWrap.getVolumeSpyderMatchedExactly() == false) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }
                    } else if (this.objPromo.RecordType.DeveloperName == OP_ON_PROMO_KIT) {
                        //System.Debug('BT:' + srWrap.getQtyPromoKitMatchedExactly() + 'PK:' + srWrap.getQtyPromoKitMatchedExactly());
                        //if(!srWrap.getVolumeBottleMatchedExactly() == false || !srWrap.getQtyPromoKitMatchedExactly() == false) {
                        if (!srWrap.getQtyPromoKitMatchedExactly() == false) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }
                    } else {
                        //System.Debug('BT:' + srWrap.getVolumeBottleMatchedExactly() + 'DP:' + srWrap.getVolumeDisplayMatchedExactly());
//                        if (!srWrap.getVolumeDisplayMatchedExactly() == false || !srWrap.getVolumeBottleMatchedExactly() == false) {
                        if (srWrap.getVolumeBottleNotOverlimit()==false || srWrap.getVolumeDisplayNotOverlimit()==false) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_TotalSRTargetsNotEqualToProductTarget));
                            return null;
                        }
                    }
//                    System.debug('srTargets:'+JSON.serializePretty(srTargets));
                    newSRTargets.addAll(srWrap.srTargets);
                }
                //upsert salesRepTargetWrap.srTargets;
                /*For(EUR_CRM_ObjPromo_Target__c OPT : newSRTargets){
                    System.Debug('QUick Save SR Target: Update Bottle:' + OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c + ':' + OPT.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c);
                    If(OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c != null && OPT.EUR_CRM_SKU__c != null){
                        OPT.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = OPT.EUR_CRM_Qty_Sell_in_Amount_Display__c * OPT.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c;
                    }
                }*/ //Disable Conversion

                setDefaults(newSRTargets);

//                System.debug('newSRTargets:'+JSON.serializePretty(newSRTargets));
                Boolean upsertResult = upsertTargets(newSRTargets);

                if (!upsertResult) {
                    return null;
                }
            }

            return refresh('&pageReference=salesRep');
        } catch (DMLException e) {
            //System.Debug(e);
            throw e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
            return null;
        }
    }

    public PageReference saveSRTargets() {
        PageReference pr = quickSaveSRTargets();
        If (pr != null) {
            return cancel();
        } else {
            return null;
        }
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference refresh(String referenceField) {
        PageReference pageRef = new PageReference('/apex/EUR_CRM_BE_ObjPromoManagePage?ObjPromoId=' + objPromo.Id + referenceField);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private void setDefaults(List<EUR_CRM_ObjPromo_Target__c> targetList) {
        for (EUR_CRM_ObjPromo_Target__c targetItem : targetList) {
            setDefaults(targetItem);
        }
    }

    private void setDefaults(List<EUR_CRM_ObjPromo_Target__c> targetList, Decimal bottles) {
        for (EUR_CRM_ObjPromo_Target__c targetItem : targetList) {
            setDefaults(targetItem, bottles);
        }
    }

    private void setDefaults(EUR_CRM_ObjPromo_Target__c targetItem) {
        if (getIsSKU() && targetItem.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c != 'Bottle') {
            Decimal bottlesPerCase = targetItem.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c != null ? targetItem.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c : 0;
            Decimal targetQuantity = targetItem.EUR_CRM_Qty_Sell_in_Amount_Display__c != null ? targetItem.EUR_CRM_Qty_Sell_in_Amount_Display__c : 0;
//            System.debug('EUR_CRM_Qty_Sell_in_Amount_Bottle__c old:'+targetItem.EUR_CRM_Qty_Sell_in_Amount_Bottle__c);
//            System.debug('EUR_CRM_Qty_Sell_in_Amount_Bottle__c new:'+bottlesPerCase * targetQuantity);
            targetItem.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = bottlesPerCase * targetQuantity;
        }
        setDefaultsVolumes(targetItem);
    }

    private void setDefaults(EUR_CRM_ObjPromo_Target__c target, Decimal bottles) {
        Decimal bottlesPerCase = bottles != null ? bottles : 0;
        Decimal targetQuantity = target.EUR_CRM_Qty_Sell_in_Amount_Display__c != null ? target.EUR_CRM_Qty_Sell_in_Amount_Display__c : 0;
        target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = bottlesPerCase * targetQuantity;
        setDefaultsVolumes(target);
    }

    private void setDefaults(List<EUR_CRM_OPTargetHelperClass.TargetWrap> targetList) {
        for (EUR_CRM_OPTargetHelperClass.TargetWrap targetItem : targetList) {
            setDefaults(targetItem.target);
            if (getIsSKU() && targetItem.target.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c != 'Bottle') {
                Decimal bottlesPerCase = targetItem.target.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c;
                setDefaults(targetItem.srTargets, bottlesPerCase);
            }
        }
    }

    private void setDefaultsVolumes(EUR_CRM_ObjPromo_Target__c target) {
        if (target.EUR_CRM_Actual_Volume_Displays__c == null) {
            target.EUR_CRM_Actual_Volume_Displays__c = 0;
        }
        if (target.EUR_CRM_Actual_Volume_Bottles__c == null) {
            target.EUR_CRM_Actual_Volume_Bottles__c = 0;
        }
    }

    private List<EUR_CRM_Account__c> getEuAccounts() {
        Set<Id> taxonomyIds = EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo.id);
        Set<Id> accountIdsFromOPMapping = EUR_CRM_OPTargetHelperClass.retrieveAccountsByOPAccountMapping(objPromo.Id);
        return [
                SELECT id, EUR_CRM_Territory__r.EUR_CRM_Region__c, Name,
                        EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name,
                        EUR_CRM_Territory__r.EUR_CRM_Region__r.Name,
                        EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName,
                        EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
                FROM EUR_CRM_Account__c
                WHERE EUR_JB_Customer_Taxonomy__c in :taxonomyIds
                OR Id IN:accountIdsFromOPMapping
        ];
    }

    private List<EUR_CRM_Account__c> getEuAccounts(Set<Id> taxonomyIds) {
        Set<Id> accountIdsFromOPMapping = EUR_CRM_OPTargetHelperClass.retrieveAccountsByOPAccountMapping(objPromo.Id);
        return [
                SELECT id, EUR_CRM_Territory__r.EUR_CRM_Region__c, Name,
                        EUR_CRM_Status__c,EUR_CRM_Status_of_Customer__c, ownerId,owner.name,
                        EUR_CRM_Territory__r.EUR_CRM_Region__r.Name,
                        EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.UserRole.developerName,
                        EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
                FROM EUR_CRM_Account__c
                WHERE EUR_JB_Customer_Taxonomy__c in :taxonomyIds
                OR Id IN:accountIdsFromOPMapping
        ];
    }

    private void initEuAccounts() {
        if (euAccounts == null) {
            euAccounts = getEuAccounts();
        }
    }

    private void initEuAccounts(Set<Id> taxonomyIds) {
        if (euAccounts == null) {
            euAccounts = getEuAccounts(taxonomyIds);
        }
    }

    private Boolean upsertTargets(List<EUR_CRM_ObjPromo_Target__c> currentTargets) {
        if (this.hasWriteAccess) {
            upsert currentTargets;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveErrorAccessLimited + ' ' + this.objPromo.Name + ' [' + this.objPromo.Id + '].'));
            return false;
        }
        return true;
    }
}