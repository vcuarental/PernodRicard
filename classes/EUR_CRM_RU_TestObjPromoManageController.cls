@isTest
private class EUR_CRM_RU_TestObjPromoManageController {

    // In this case, Sales Rep is eurSysUser
    static User eurSysUser;
    static User regionalManager;
    static Profile eurSysProfile = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
    static EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
    static EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
    static EUR_CRM_ObjPromo_Target__c objTarget =  new EUR_CRM_ObjPromo_Target__c();
    static EUR_CRM_ObjPromo_Target__c objTargetSub =  new EUR_CRM_ObjPromo_Target__c();
    Static EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
    
    static EUR_CRM_ObjPromo__c objPromo;
    static EUR_CRM_Region__c region;
    static EUR_CRM_Territory__c territory;
    static List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
    static List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappings = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
    static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    static EUR_CRM_Customer_Taxonomy__c testCustTaxonomy;
    
    
    static void setUser() {
        UserRole r = [select id from UserRole where Developername ='EUR_RU_SR_OFF_South_Krasnodar'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail11234ru@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail11234rulastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail11234ru@test.com');
        if (regionalManager != null)
        {
            eurSysUser.ManagerId = regionalManager.Id;
        }
        insert eurSysUser;
    }

    static void setRegionalManager() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_RU_Head_of_KAM_ON_Russia'];

        regionalManager =  new User(Alias = 'regmgr', Email='userEmail112345ru@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail112345rulastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail112345ru@test.com');
        insert regionalManager;

        regionalManager = [SELECT Id FROM User WHERE Email = 'userEmail112345ru@test.com'];
    }
    //testMethod
    static testMethod void testInitializePhase1() {
        System.Debug('@@@testInitializePhase1>Start');
        setRegionalManager();
        setUser();
        
        System.runAs(eurSysUser) {
            setMasterData('EUR_RU_ON_Trade_Phase_2', 'EUR_RU_On_Trade',true);

            Test.startTest();


            EUR_CRM_OPTargetHelperClass Helper = New EUR_CRM_OPTargetHelperClass();

            Id CTaxId = [SELECT Id FROM EUR_CRM_Customer_Taxonomy__c Where Name = 'TEST_TAXONOMY'].Id;
            Set<Id> CTaxIdSet = NEw Set<Id>();
            CTaxIdSet.add(CTaxId);

            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(CTaxId,regionalManager.Id);
            EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(CTaxIdSet,regionalManager.Id);
            


            PageReference pageRef = Page.EUR_CRM_RU_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_RU_ObjPromoManageController con = new EUR_CRM_RU_ObjPromoManageController(sc);

            
            
            con.getRegionalManagerOptions();
            con.getRegionalAndSalesAgencyTargetWraps();
            
            //List<EUR_CRM_OPTargetHelperClass.TargetWrap> r = con.salesRepTargetWrap;
            con.setPublishStatus();
            con.getTargetsInSelectedProductLevel();
            con.add();
            //con.removeProduct();
            //con.quickSaveProducts();
            con.quickSaveObjectiveTargets(); 
            con.saveObjectiveTargets();
            con.quickSaveRegionalTargets();
            con.quickSaveSRTargets();
            con.getIsOffPOSMPlacement();
            con.getIsOffTradeLeaflet();
            con.getIsOffTradeDiscount();
            con.getIsOffTradeModelStore();
            con.getIsOffTradeOnSitePromo();
            con.getIsOffTradeInStoreMedia();
            con.getIsOnTradePhase1();
            con.getProductSelectionTabVisibility();
            con.getTargetManagementTabVisibility();
            con.getIsListViewOptionRendered();
            con.getIsCTaxOptionRendered();
            con.getIsPROSOptionRendered();
            con.getIsCSVOptionRendered();
            con.getIsBrandSizeRendered();
            con.getIsSKURendered();
            con.getIsAccountListView();
            con.getIsCustomerTaxonomy();
            con.getIsPROS();
            con.getIsCSV();
            con.getIsProductSelectionSelected();
            con.getIsMultiSelectEnabled();
            
            con.getTargetsInSelectedProductLevelForTargetManagement();//
            con.getHideAddButtons();
            


            List<EUR_CRM_ObjPromo_Target__c> t = new List<EUR_CRM_ObjPromo_Target__c>(); 
            t.add(objTarget);
            con.deleteOldTargets(t);
            con.selectedProductSelection = 'pos';
            try{
                con.removeProduct();
            }
            catch(exception e){}
            con.getTargetsInSelectedProductLevel();
            con.selectedProductSelection = 'quality';
            con.add();
            try{
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.initializeTargets();
            con.selectedProductSelection = 'pos';
            con.add();
            con.initializeTargets();
            try{
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.selectedProductSelection = 'sku';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.selectedProductSelection = 'brand';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.selectedProductSelection = 'size';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            try{
                con.saveRegionalTargets();
            }
            catch(Exception e){}
            try{
                con.saveSRTargets();
            }
            catch(Exception e){}
                        
            con.firstPage();
            con.nextPage();
            con.previousPage();
            //con.lastPage();
            con.resetSalesRepTargetWrap();
            con.selectedProductSelection = 'quality';
            try{
                con.saveProducts();
            }
            catch(Exception e){}
            con.selectedProductSelection = 'pos';
            try{
                con.saveProducts();
            }
            catch(Exception e){}
            
            try{
                Set<Id> ctSet = new Set<Id>();
                ctSet.add(testCustTaxonomy.Id);
                List<User> HelperRS1 = New List<User>();
                List<EUR_CRM_Account__c> HelperRS2 = New List<EUR_CRM_Account__c>();
                Decimal HeplerRS3;
                //EUR_CRM_OPTargetHelperClass.retrieveTargets
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(ctSet, regionalManager.Id);
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(testCustTaxonomy.Id, regionalManager.Id);
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(ctSet);
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(testCustTaxonomy.Id);
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(accounts);    
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(testCustTaxonomy.Id);
                HelperRS1 = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(ctSet);
                HelperRS2 = EUR_CRM_OPTargetHelperClass.retrieveAccountsByTaxonomy(ctSet);
                
                Map<String, Id> rtMap;
                rtMap = new Map<String, Id>();
                for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_ObjPromo__c')) {
                    rtMap.put(rt.developername, rt.Id);
                }
                
                List<EUR_CRM_ObjPromo_Target__c > regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
                Id parentRecordTypeId = rtMap.get('EUR_RU_Manager_POSM_Target');
                Id subTargetRecordTypeId = rtMap.get('EUR_RU_Sales_Rep_POSM_Target');
                
                String targetField = 'EUR_CRM_SKU';
                List<User> regionalManagers = New List<User>();
                regionalManagers.add(regionalManager);
                
                Id rManager = null;
                
                List<String> additionalFields = new List<String>{
              'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c',
              'EUR_CRM_SKU__r.name', 'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
              'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
              'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name', 'EUR_CRM_Product_Level__c',
              'EUR_CRM_Promotion_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c',
              'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
                
                List<EUR_CRM_OPTargetHelperClass.TargetWrap> tempList  =  EUR_CRM_OPTargetHelperClass.retrieveTargets(
               objPromo.Id,regionalTargets ,parentRecordTypeId,subTargetRecordTypeId,
               targetField,regionalManagers, rManager ,additionalFields);

                System.debug('Target Wrap List' + tempList);
                
                //HelperRS2 = EUR_CRM_OPTargetHelperClass.getVolumeDisplayMatched();
                //HelperRS2 = EUR_CRM_OPTargetHelperClass.getVolumeBottleAchieved();
                //HelperRS2 = EUR_CRM_OPTargetHelperClass.getVolumeDisplayAchieved();
                //HeplerRS3 = EUR_CRM_OPTargetHelperClass.getSubTargetBottleTotal();
                //HeplerRS3 = EUR_CRM_OPTargetHelperClass.getSubTargetDisplayTotal();
                
            }catch(Exception e)
            {
                System.Debug('##Exception:'+ e);
            }
            
            Test.stopTest();
        }
        System.Debug('@@@testInitializePhase1>End');
    }
    
    static testMethod void testInitializePhase2() {
        System.Debug('@@@testInitializePhase2>Start');
        setRegionalManager();
        setUser();
        
        System.runAs(eurSysUser) {
            setMasterData('EUR_RU_ON_Trade_Phase_2', 'EUR_RU_On_Trade',true);

            Test.startTest();

            PageReference pageRef = Page.EUR_CRM_RU_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_RU_ObjPromoManageController con = new EUR_CRM_RU_ObjPromoManageController(sc);
            
            con.getRegionalAndSalesAgencyTargetWraps();
            con.getRegionalManagerOptions();
            //List<EUR_CRM_OPTargetHelperClass.TargetWrap> r = con.salesRepTargetWrap;
            con.setPublishStatus();
            con.getTargetsInSelectedProductLevel();
            con.add();
            //con.removeProduct();
            //con.quickSaveProducts();
            con.quickSaveObjectiveTargets(); 
            con.saveObjectiveTargets();
            con.quickSaveRegionalTargets();
            //con.quickSaveSRTargets();
            con.getIsOffPOSMPlacement();
            con.getIsOffTradeLeaflet();
            con.getIsOffTradeDiscount();
            con.getIsOffTradeModelStore();
            con.getIsOffTradeOnSitePromo();
            con.getIsOffTradeInStoreMedia();
            con.getIsOnTradePhase1();
            con.getProductSelectionTabVisibility();
            con.getTargetManagementTabVisibility();
            con.getIsListViewOptionRendered();
            con.getIsCTaxOptionRendered();
            con.getIsPROSOptionRendered();
            con.getIsCSVOptionRendered();
            con.getIsBrandSizeRendered();
            con.getIsSKURendered();
            con.getIsAccountListView();
            con.getIsCustomerTaxonomy();
            con.getIsPROS();
            con.getIsCSV();
            con.getIsProductSelectionSelected();
            con.getIsMultiSelectEnabled();
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> opt = con.salesRepTargetWrap; 
            List<EUR_CRM_ObjPromo_Target__c> t = new List<EUR_CRM_ObjPromo_Target__c>(); 
            t.add(objTarget);
            con.deleteOldTargets(t);
            
            con.firstPage();
            con.nextPage();
            con.previousPage();
            //con.lastPage();
            con.resetSalesRepTargetWrap();
            con.selectedProductSelection = 'quality';
            try{
                con.saveProducts();
            }
            catch(Exception e){}
            con.selectedProductSelection = 'pos';
            try{
                con.saveProducts();
            }
            catch(Exception e){}
            Test.stopTest();
        }
        System.Debug('@@@testInitializePhase2>End');
    }

    static testMethod void testInitializePhase3() {
        System.Debug('@@@testInitializePhase3>Start');
        setRegionalManager();
        setUser();
        
        System.runAs(eurSysUser) {
            setMasterData('EUR_RU_ON_Trade_Phase_2', 'EUR_RU_On_Trade',true);

            Test.startTest();

            PageReference pageRef = Page.EUR_CRM_RU_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_RU_ObjPromoManageController con = new EUR_CRM_RU_ObjPromoManageController(sc);

            System.Debug('Started?');
            



            

            
            con.getRegionalManagerOptions();
            con.getRegionalAndSalesAgencyTargetWraps();
            
            //List<EUR_CRM_OPTargetHelperClass.TargetWrap> r = con.salesRepTargetWrap;
            con.setPublishStatus();
            con.getTargetsInSelectedProductLevel();
            con.add();
            //con.removeProduct();
            //con.quickSaveProducts();
            con.quickSaveObjectiveTargets(); 
            con.saveObjectiveTargets();
            con.quickSaveRegionalTargets();
            con.quickSaveSRTargets();
            con.getIsOffPOSMPlacement();
            con.getIsOffTradeLeaflet();
            con.getIsOffTradeDiscount();
            con.getIsOffTradeModelStore();
            con.getIsOffTradeOnSitePromo();
            con.getIsOffTradeInStoreMedia();
            con.getIsOnTradePhase1();
            con.getProductSelectionTabVisibility();
            con.getTargetManagementTabVisibility();
            con.initializeTargetManagement();
            con.getIsListViewOptionRendered();
            con.getIsCTaxOptionRendered();
            con.getIsPROSOptionRendered();
            con.getIsCSVOptionRendered();
            con.getIsBrandSizeRendered();
            con.getIsSKURendered();
            con.getIsAccountListView();
            con.getIsCustomerTaxonomy();
            con.getIsPROS();
            con.getIsCSV();
            con.getIsProductSelectionSelected();
            con.getIsMultiSelectEnabled();
            
            con.getTargetsInSelectedProductLevelForTargetManagement();//
            con.getHideAddButtons();
            
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> opt = con.salesRepTargetWrap; 
            List<EUR_CRM_ObjPromo_Target__c> t = new List<EUR_CRM_ObjPromo_Target__c>(); 
            t.add(objTarget);
            con.deleteOldTargets(t);
            con.selectedProductSelection = 'pos';
            try{
                con.removeProduct();
            }
            catch(exception e){}
            con.getTargetsInSelectedProductLevel();
            con.selectedProductSelection = 'quality';
            con.add();
            try{
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.initializeTargets();
            con.selectedProductSelection = 'pos';
            con.add();
            con.initializeTargets();
            try{
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.selectedProductSelection = 'sku';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.selectedProductSelection = 'brand';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            con.selectedProductSelection = 'size';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){
                System.Debug('@@Exception:' + e.getMessage());
            }
            try{
                con.saveRegionalTargets();
            }
            catch(Exception e){}
            try{
                con.saveSRTargets();
            }
            catch(Exception e){}

            System.Debug('con.regionalManagers:' + con.regionalManagers);
            System.Debug('con.euAccounts:' + con.euAccounts);

            //List<User> regionalManagers = retrieveTargetOwnersAccountOwnerManagerLevel(con.euAccounts);
            //EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerManagerLevel(con.euAccounts, regionalManagers[0].Id);
            
            con.firstPage();
            con.nextPage();
            con.previousPage();
            //con.lastPage();
            con.resetSalesRepTargetWrap();
            con.selectedProductSelection = 'quality';
            try{
                con.saveProducts();
            }
            catch(Exception e){}
            con.selectedProductSelection = 'pos';
            try{
                con.saveProducts();
            }
            catch(Exception e){}

            con.getPageSize();
            con.getRecordSize();
            con.getPageNumber();
            con.getHasNextPage();
            con.getHasPreviousPage();
            con.getHasMoreThanOnePage();
            Test.stopTest();
        }
        System.Debug('@@@testInitializePhase1>End');
    }
    
    static testMethod void testTargetNull() {
        System.Debug('@@@testTargetNull>Start');
        setRegionalManager();
        setUser();
        
        System.runAs(eurSysUser) {
            setMasterData('EUR_RU_ON_Trade_Phase_2', 'EUR_RU_On_Trade',false);   

            Test.startTest();

            PageReference pageRef = Page.EUR_CRM_RU_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            pageRef.getParameters().put('rowIndex', '5');    
            
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_RU_ObjPromoManageController con = new EUR_CRM_RU_ObjPromoManageController(sc);
            con.getRegionalAndSalesAgencyTargetWraps();
            con.getRegionalManagerOptions();
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> r = con.salesRepTargetWrap; 
            con.isTargetManagementDone = false;
            con.totalPages = 1;
            con.isProductSelectionDone = true;
            con.setPublishStatus();
            con.isProductSelectionDone = false;
            con.setPublishStatus();
            con.isAccountSelectionDone = false;
            con.isDraft = false;
            con.setPublishStatus();
            con.isManagerLevelTargetDone = true;
            con.selectedProductSelection = 'pos';
            con.setPublishStatus();
            try{
                con.removeProduct();
            }
            catch(exception e){}
            con.getTargetsInSelectedProductLevel();
            con.selectedProductSelection = 'quality';
            con.add();
            try{
                con.removeProduct();
            }
            catch(Exception e){}
            con.initializeTargets();
            con.selectedProductSelection = 'pos';
            con.add();
            con.initializeTargets();
            try{
                con.removeProduct();
            }
            catch(Exception e){}
            con.selectedProductSelection = 'sku';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){}
            con.selectedProductSelection = 'brand';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){}
            con.selectedProductSelection = 'size';
            try{
                con.add();
                con.initializeTargets();
                con.removeProduct();
            }
            catch(Exception e){}
            try{
                con.saveRegionalTargets();
            }
            catch(Exception e){}
            try{
                con.saveSRTargets();
            }
            catch(Exception e){}
            
            con.selectedProductSelection = ''; 
            //con.removeProduct();
            con.quickSaveProducts();
            con.quickSaveObjectiveTargets(); 
            con.saveObjectiveTargets();
            con.quickSaveRegionalTargets();
            con.quickSaveSRTargets();
            con.getIsOffPOSMPlacement();
            con.getIsOffTradeLeaflet();
            con.getIsOffTradeDiscount();
            con.getIsOffTradeModelStore();
            con.getIsOffTradeOnSitePromo();
            con.getIsOffTradeInStoreMedia();
            con.getIsOnTradePhase1();
            con.getProductSelectionTabVisibility();
            con.getTargetManagementTabVisibility();
            con.getIsListViewOptionRendered();
            con.getIsCTaxOptionRendered();
            con.getIsPROSOptionRendered();
            con.getIsCSVOptionRendered();
            con.getIsBrandSizeRendered();
            con.getIsSKURendered();
            con.getIsAccountListView();
            con.getIsCustomerTaxonomy();
            con.getIsPROS();
            con.getIsCSV();
            con.getIsProductSelectionSelected();
            con.getIsMultiSelectEnabled();
            con.lastPage();
            con.firstPage();
            con.nextPage();
            con.previousPage();

            con.getPageSize();
            con.getRecordSize();
            con.getPageNumber();
            con.getHasNextPage();
            con.getHasPreviousPage();
            con.getHasMoreThanOnePage();

            //con.lastPage();
            Test.stopTest();
        }
        System.Debug('@@@testTargetNull>>End');
    }
    
    static void setMasterData(String opRecordTypeDevName, String accountRecordTypeDevName,Boolean hasTarget) {
        String opActionListTemplateExternalId = EUR_CRM_RecordTypeHelper.ObjectivePromoHandler_opActionMap.get(opRecordTypeDevName);

        // Insert EUR_CRM_Action_List_Template__c
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323', opActionListTemplateExternalId,'EUR_RU_OP_Action_List_Template');

        // Insert EUR_CRM_ObjPromo__c
        Id opRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + opRecordTypeDevName);
        objPromo = new EUR_CRM_ObjPromo__c(
            recordTypeId = opRecordTypeId,
            Name = opRecordTypeDevName + ' RU O/P',
            EUR_CRM_Active_Start_Date__c = Date.Today(),
            EUR_CRM_Active_End_Date__c = Date.Today() + 7,
            EUR_CRM_Evaluation_Period_End_Date__c = Date.Today() + 7,
            EUR_CRM_Is_Publish_ready__c = false
        );
        insert objPromo;

        // put region
        region = EUR_CRM_RU_TestClassHelper.createRegion('Ural', regionalManager.Id, 'EUR RU Region');

        // put territory
        territory = EUR_CRM_RU_TestClassHelper.createTerritory('Ural ON Territory Kyshtym', eurSysUser.Id, region.Id, 'EUR RU ON Trade Territory');
        
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        
        sku = EUR_CRM_RU_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_RU_SKU' );
        
        if(hasTarget){          
            Id opTargetId = null;
            objTarget = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Objective Product', objPromo.Id, opTargetId ).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
            if(hasTarget){
                objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            }
            else{
                objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
            }
            insert objTarget;
            
            objTargetSub = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Manager POSM Target', objPromo.Id, opTargetId ).get(0);
            objTargetSub.EUR_CRM_SKU__c = sku.id;
            objTargetSub.EUR_CRM_SKU__r = sku;
            objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
            if(hasTarget){
                objTargetSub.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            }
            else{
                objTargetSub.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
            }
            
            insert objTargetSub;
        }
        testCustTaxonomy = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomy('TEST_TAXONOMY', UserInfo.getUserId(), 'EUR RU OFF Trade Customer Taxonomy');
        
         // Insert EUR_CRM_Account__c
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test Acc 101', accountRecordTypeDevName, territory.Id, eurSysUser.Id);
        //euaccount.EUR_CRM_Sub_Channel__c = 'Local';
        //euaccount.EUR_CRM_Territory__c = territory.Id;
        //euaccount.EUR_JB_Customer_Taxonomy__c = testCustTaxonomy.Id;
        insert euaccount;
        
        accounts.add(euaccount);
        
        //System.Debug('@@acc' + euaccount.RecordTypeId + ' owner'+ euaccount.OwnerId);
        //User MgrUser = [SELECT Name,ManagerId FROM User WHERE Id =: euaccount.OwnerId LIMIT 1];
        //System.Debug('@@acc Manager' + MgrUser.Name );
        
        /*custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        System.Debug('@@Customer_Taxnonmy__id:TvsC' + 'a9IL00000000A4CMAU' +  testCustTaxonomy.Id);
        custTax.EUR_CRM_Customer_Taxonomy__c = testCustTaxonomy.Id;
        custTax.EUR_CRM_ObjPromo__c = objPromo.id;
        custTax.RecordTypeId = '012L00000008sjkIAA';
        insert custTax ;*/
        
      
        setTargets();



        // Insert EUR_CRM_Brand__c
        // Insert EUR_CRM_Brand_Quality
    }

    static void testTargetWrapper(){
        //Use DE to test the target Wapper 

        String RTSRTarget  = 'EUR_DE_SR_Volume_Target';
        String RTMGTarget  = 'EUR_DE_Regional_Volume_Target';
        String RTOPTarget  = 'EUR_DE_Objective_Volume_Target';

        String RTObjPromo  = 'EUR_DE_Off_Trade_Sales_Drive';
        String RTAccount   = 'EUR_DE_OFF_STD';
        String RTTerritory = 'EUR_DE_Territory';
        String RTRegion    = 'EUR_DE_Region';
        String RTVisitFeq  = 'EUR_DE_Visit_Frequency';
        String RTPostalmap = 'EUR_DE_Postal_Code_City_Mapping';
        
        String RoleMgr = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
        String RoleAcc = 'EUR_DE_BZL_South';

        Profile ProfileDE = [SELECT Id FROM Profile WHERE Name = 'EUR DE OFF Trade User'];

        setUser();



        String opRecordTypeDevName = 'EUR_DE_Off_Trade_Sales_Drive';
        String accountRecordTypeDevName = 'EUR_DE_OFF_STD';

        String opActionListTemplateExternalId = EUR_CRM_RecordTypeHelper.ObjectivePromoHandler_opActionMap.get(opRecordTypeDevName);

        System.runAs(eurSysUser) {

            UserRole rAcc = [SELECT Id FROM UserRole WHERE DeveloperName =: RoleAcc];
            UserRole rMgr = [SELECT Id FROM UserRole WHERE DeveloperName =: RoleMgr];


            User MgrUserInsert =  new User(Alias = 'mgrowner', Email='mgrowner@test.com', userroleid=rMgr.id,
            EmailEncodingKey='UTF-8', LastName='mgrowner', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = ProfileDE.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='mgrowner@test.com');
            insert MgrUserInsert;


            User AccUserInsert =  new User(Alias = 'accowner', Email='acc@test.com', userroleid=rAcc.id,
            EmailEncodingKey='UTF-8', LastName='accowner', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = ProfileDE.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='accowner@test.com');
            
            insert AccUserInsert;
        }

        User MgrUser = [SELECT Id FROM User Where Email = 'mgrowner@test.com'];
        User AccUser = [SELECT Id FROM User Where Email = 'accowner@test.com'];

        // put region
        region = EUR_CRM_RU_TestClassHelper.createRegion('DE OFF Trade Region 1', MgrUser.Id, RTRegion);

        // put territory
        territory = EUR_CRM_RU_TestClassHelper.createTerritory('DE Off Trade Territory 1', MgrUser.Id, region.Id, RTTerritory);
        
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;

        EUR_CRM_Account__c deAccount        = EUR_CRM_RU_TestClassHelper.createEUAccount('Test Acc 101', accountRecordTypeDevName, territory.Id, AccUser.Id);
        deAccount.EUR_CRM_Channel__c        = 'OFF TRADE';
        deAccount.EUR_CRM_Postal_Code__c    = '10001';
        deAccount.EUR_CRM_Territory__c      = territory.Id;
        //deAccount.EUR_JB_Customer_Taxonomy__c = testCustTaxonomy.Id;
        insert euaccount;


        // Insert EUR_CRM_Action_List_Template__c
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323', opActionListTemplateExternalId,'EUR_DE_OP_Action_List_Template');

        // Insert EUR_CRM_ObjPromo__c
        Id opRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + opRecordTypeDevName);
        objPromo = new EUR_CRM_ObjPromo__c(
            recordTypeId = opRecordTypeId,
            Name = opRecordTypeDevName + ' DE O/P',
            EUR_CRM_Active_Start_Date__c = Date.Today(),
            EUR_CRM_Active_End_Date__c = Date.Today() + 7,
            EUR_CRM_Evaluation_Period_End_Date__c = Date.Today() + 7,
            EUR_CRM_Is_Publish_ready__c = false
        );
        insert objPromo;


        
        sku = EUR_CRM_RU_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_DE_SKU' );

        Id opTargetId = null;
        EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_RU_TestClassHelper.createOPTarget(1, RTOPTarget, objPromo.Id, opTargetId ).get(0);
        objTarget.EUR_CRM_SKU__c = sku.id;
        objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
        objTarget.EUR_CRM_Target_Owner__c = eurSysUser.id;
        objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
        insert objTarget;

        EUR_CRM_ObjPromo_Target__c objTargetMgr = EUR_CRM_RU_TestClassHelper.createOPTarget(1, RTMGTarget, objPromo.Id, opTargetId ).get(0);
        objTargetMgr.EUR_CRM_SKU__c = sku.id;
        objTargetMgr.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
        objTargetMgr.EUR_CRM_Target_Owner__c = MgrUser.id;
        objTargetMgr.EUR_CRM_O_P_Target__c = objTarget.Id;
        objTargetMgr.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
        insert objTargetMgr;

        
        EUR_CRM_ObjPromo_Target__c objTargetSR = EUR_CRM_RU_TestClassHelper.createOPTarget(1, RTSRTarget, objPromo.Id, opTargetId ).get(0);
        objTargetSR.EUR_CRM_SKU__c = sku.id;
        objTargetSR.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
        objTargetSR.EUR_CRM_Target_Owner__c = AccUser.id;
        objTargetSR.EUR_CRM_O_P_Target__c = objTargetMgr.Id;
        objTargetSR.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
        insert objTargetSR;
    }

    static void setTargets() {
        // Insert EUR_CRM_ObjPromo_Account_Mapping__c
        System.Debug('@@setTargets');
        for(EUR_CRM_Account__c acc: accounts) {
            
            opAccountMappings.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                EUR_CRM_Account__c = acc.Id,
                EUR_CRM_ObjPromo__c = objPromo.Id
            ));
        }

        insert opAccountMappings;
    }

    //Part 2

    static User headUser;
    static User accUser;
    static Profile p = [SELECT Id FROM Profile WHERE Name = 'EUR RU ON Trade User'];

    static testMethod void testInitializePhase4() {
        System.Debug('@@@testInitializePhase4>Start');
        setUser();
        
        System.runAs(eurSysUser) {
            setMasterData2('EUR_RU_ON_Trade_Phase_2', 'EUR_RU_On_Trade',true);

            Test.startTest();

            PageReference pageRef = Page.EUR_CRM_RU_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_RU_ObjPromoManageController con = new EUR_CRM_RU_ObjPromoManageController(sc);

            con.getRegionalManagerOptions();
            con.getRegionalAndSalesAgencyTargetWraps();
            
            //List<EUR_CRM_OPTargetHelperClass.TargetWrap> r = con.salesRepTargetWrap;
            con.setPublishStatus();
            con.getTargetsInSelectedProductLevel();
            con.add();
            //con.removeProduct();
            //con.quickSaveProducts();
            con.quickSaveObjectiveTargets(); 
            con.saveObjectiveTargets();
            con.quickSaveRegionalTargets();
            con.quickSaveSRTargets();
            con.getIsOffPOSMPlacement();
            con.getIsOffTradeLeaflet();
            con.getIsOffTradeDiscount();
            con.getIsOffTradeModelStore();
            con.getIsOffTradeOnSitePromo();
            con.getIsOffTradeInStoreMedia();
            con.getIsOnTradePhase1();
            con.getProductSelectionTabVisibility();
            con.getTargetManagementTabVisibility();
            con.initializeTargetManagement();
            con.getIsListViewOptionRendered();
            con.getIsCTaxOptionRendered();
            con.getIsPROSOptionRendered();
            con.getIsCSVOptionRendered();
            con.getIsBrandSizeRendered();
            con.getIsSKURendered();
            con.getIsAccountListView();
            con.getIsCustomerTaxonomy();
            con.getIsPROS();
            con.getIsCSV();
            con.getIsProductSelectionSelected();
            con.getIsMultiSelectEnabled();
            
            con.getTargetsInSelectedProductLevelForTargetManagement();//
            con.getHideAddButtons();
            con.getPageSize();
            con.getRecordSize();
            con.getPageNumber();
            con.getHasNextPage();
            con.getHasPreviousPage();
            con.getHasMoreThanOnePage();

            con.firstPage();
            con.lastPage();
            con.nextPage();
            con.previousPage();
            con.getTotalPages();

            con.initializeTargetManagement();
            Boolean testIsTargetManagementDone = con.isTargetManagementDone;
            Boolean testeuAccountsPageHasMore = con.euAccountsPageHasMore;
            Integer testeuAccountsFirstIndex = con.euAccountsFirstIndex;



            List<EUR_CRM_ObjPromo_Target__c> testSRTarget = con.srTargets;
            System.Debug(testSRTarget);


        }
    }

    static void createAccountOwner(){
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_RU_KAM_ON_Moscow'];


        accUser =  new User(Alias = 'accowner', Email='accowner@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='accowner', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='accowner@test.com');
        insert accUser;

        accUser = [SELECT Id FROM User WHERE Email = 'accowner@test.com'];
    }

    static void createHeadManager(){
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_RU_Regional_Head_ON_Moscow'];

        headUser =  new User(Alias = 'headmgr', Email='headmgr@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='headmgr', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='headmgr@test.com');
        insert headUser;

        headUser = [SELECT Id FROM User WHERE Email = 'headmgr@test.com'];
    }

    static void setMasterData2(String opRecordTypeDevName, String accountRecordTypeDevName,Boolean hasTarget) {
        createAccountOwner();
        createHeadManager();

        String opActionListTemplateExternalId = EUR_CRM_RecordTypeHelper.ObjectivePromoHandler_opActionMap.get(opRecordTypeDevName);

        // Insert EUR_CRM_Action_List_Template__c
        EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323', opActionListTemplateExternalId,'EUR_RU_OP_Action_List_Template');

        // Insert EUR_CRM_ObjPromo__c
        Id opRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + opRecordTypeDevName);

        objPromo = new EUR_CRM_ObjPromo__c(
            recordTypeId = opRecordTypeId,
            Name = opRecordTypeDevName + ' RU O/P',
            EUR_CRM_MAF_ID__c = 'RU_OP_MAF_ID',
            EUR_CRM_External_ID__c = 'RU_OP_EXT_ID',
            EUR_CRM_Active_Start_Date__c = Date.Today(),
            EUR_CRM_Active_End_Date__c = Date.Today() + 7,
            EUR_CRM_Evaluation_Period_End_Date__c = Date.Today() + 7,
            EUR_CRM_Is_Publish_ready__c = false
        );
        insert objPromo;

        // put region
        region = EUR_CRM_RU_TestClassHelper.createRegion('Ural', headUser.Id, 'EUR RU Region');

        // put territory
        territory = EUR_CRM_RU_TestClassHelper.createTerritory('Ural ON Territory Kyshtym', headUser.Id, region.Id, 'EUR RU ON Trade Territory');
        
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
        EUR_CRM_Wine_Spirits__c spirits = EUR_CRM_RU_TestClassHelper.createWineSpirits(1,'EUR_RU_Wine_Spirits','RU_SP','Spirits')[0];
        insert spirits;
        EUR_CRM_Category__c category = EUR_CRM_RU_TestClassHelper.createCategory(1,'EUR_RU_Category','RU_Category_RH',spirits.Id)[0];
        insert category;
        EUR_CRM_Brand__c brand = EUR_CRM_RU_TestClassHelper.createBrand(1,'EUR_RU_Brand','HAVANA CLUB','RU_Brand_HCA_RH',category.Id)[0];
        insert brand;
        //sku = EUR_CRM_RU_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_RU_SKU' );
        
        Id opTargetId = null;
        objTarget = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Objective Product', objPromo.Id, opTargetId ).get(0);
        objTarget.EUR_CRM_Brand__c = brand.id;
        objTarget.EUR_CRM_Target_Quantity_Promo_Kits__c = 100;
        //objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
        objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Brand__c';

        insert objTarget;
        
        objTargetSub = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Manager POSM Target', objPromo.Id, opTargetId ).get(0);
        objTargetSub.EUR_CRM_Brand__c = brand.id;
        
        objTargetSub.EUR_CRM_Target_Quantity_Promo_Kits__c = 100;
        objTargetSub.EUR_CRM_Target_Owner__c = headUser.id;
        objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
        objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Brand__c';

        insert objTargetSub;


        //testCustTaxonomy = EUR_CRM_RU_TestClassHelper.createCustomerTaxonomy('TEST_TAXONOMY', UserInfo.getUserId(), 'EUR RU OFF Trade Customer Taxonomy');
        
         // Insert EUR_CRM_Account__c
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test Acc 101', accountRecordTypeDevName, territory.Id, accUser.Id);
        //euaccount.EUR_CRM_Sub_Channel__c = 'Local';
        //euaccount.EUR_CRM_Territory__c = territory.Id;
        //euaccount.EUR_JB_Customer_Taxonomy__c = testCustTaxonomy.Id;
        insert euaccount;
        
        accounts.add(euaccount);
        
        //System.Debug('@@acc' + euaccount.RecordTypeId + ' owner'+ euaccount.OwnerId);
        //User MgrUser = [SELECT Name,ManagerId FROM User WHERE Id =: euaccount.OwnerId LIMIT 1];
        //System.Debug('@@acc Manager' + MgrUser.Name );
        
        /*custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        System.Debug('@@Customer_Taxnonmy__id:TvsC' + 'a9IL00000000A4CMAU' +  testCustTaxonomy.Id);
        custTax.EUR_CRM_Customer_Taxonomy__c = testCustTaxonomy.Id;
        custTax.EUR_CRM_ObjPromo__c = objPromo.id;
        custTax.RecordTypeId = '012L00000008sjkIAA';
        insert custTax ;*/
        
      
        for(EUR_CRM_Account__c acc: accounts) {
            
            opAccountMappings.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                EUR_CRM_Account__c = acc.Id,
                EUR_CRM_ObjPromo__c = objPromo.Id
            ));
        }

        insert opAccountMappings;
        List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c',
            'EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c',
            'EUR_CRM_Brand__c', 'EUR_CRM_Brand__r.Name',
            'EUR_CRM_BQS__c', 'EUR_CRM_BQS__r.Name',
            'EUR_CRM_BQ__c', 'EUR_CRM_BQ__r.Name',
            'EUR_CRM_POS_Material__c', 'EUR_CRM_POS_Material__r.Name',
            'EUR_CRM_Product_Level__c',
            'EUR_CRM_Promotion_Type__c ','EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c',
            'EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c ','EUR_CRM_Qty_Sell_in_Amount_Display__c','EUR_CRM_Target_Quantity_Spyders__c','EUR_CRM_Target_Quantity_Promo_Kits__c ',
            'EUR_CRM_Unit_of_Measure__c','EUR_CRM_Grouping_Type__c'};
        EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerManagerLevel(accounts);
        EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerRegionalHeadLevel(accounts);
        EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(accounts,headUser.id);
        EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerLevel(accounts);

        List<EUR_CRM_ObjPromo_Target__c > Optarget1 = New List<EUR_CRM_ObjPromo_Target__c >{objTargetSub};
        List<EUR_CRM_ObjPromo_Target__c > Optarget2 = New List<EUR_CRM_ObjPromo_Target__c >{objTarget};
        List<User> MgrUserList = New List<User>{headUser};
        List<User> AccUserList = New List<User>{accUser};

        EUR_CRM_OPTargetHelperClass.retrieveTargetSpyder(   objPromo.id,
                                                            Optarget1,
                                                            objTarget.RecordTypeId,
                                                            objTargetSub.RecordTypeId, 
                                                            MgrUserList,
                                                            accUser.id,
                                                            additionalFields);

        EUR_CRM_OPTargetHelperClass.retrieveTargetsSKUnBQS( objPromo.id,
                                                            Optarget1,
                                                            objTarget.RecordTypeId,
                                                            objTargetSub.RecordTypeId, 
                                                            AccUserList,
                                                            headUser.Id,
                                                            additionalFields
                                                            );

        EUR_CRM_OPTargetHelperClass.TargetWrap Wrap = New EUR_CRM_OPTargetHelperClass.TargetWrap(Optarget1,objTarget);

        try{Wrap.getQuantityAchieved();}catch(Exception e){}
        try{Wrap.getSubTargetDisplayTotal();}catch(Exception e){}
        try{Wrap.getSubTargetPromoKitTotal();}catch(Exception e){}
        try{Wrap.getSubTargetSpyderTotal();}catch(Exception e){}
        try{Wrap.getSubTargetPeopleTotal();}catch(Exception e){}
        try{Wrap.getSubTargetVisitTotal();}catch(Exception e){}
        try{Wrap.getSubTargetListingTotal();}catch(Exception e){}
        try{Wrap.getVolumeDisplayAchieved();}catch(Exception e){}
        try{Wrap.getVolumeBottleAchieved();}catch(Exception e){}
        try{Wrap.getEverythingMatched();}catch(Exception e){}
        try{Wrap.getVolumeDisplayMatched();}catch(Exception e){}
        try{Wrap.getVolumeDisplayMatchedExactly();}catch(Exception e){}
        try{Wrap.getTargetPeopleMatched();}catch(Exception e){}
        try{Wrap.getTargetVisitMatched();}catch(Exception e){}
        try{Wrap.getTargetListingMatched();}catch(Exception e){}
        try{Wrap.getVolumeBottleMatchedexactly();}catch(Exception e){}

        try{Wrap.getIsCarton();}catch(Exception e){}
        try{Wrap.getisBottle();}catch(Exception e){}
        try{Wrap.getIsDisplay();}catch(Exception e){}
        try{Wrap.getIsSKU();}catch(Exception e){}
        try{Wrap.getISBQS();}catch(Exception e){}
        try{Wrap.getQtyPromoKitMatched();}catch(Exception e){}
        try{Wrap.getQtyPromoKitMatchedExactly();}catch(Exception e){}
        try{Wrap.getVolumeSpyderMatched();}catch(Exception e){}
        try{Wrap.getISBQS();}catch(Exception e){}
        
        // Insert EUR_CRM_Brand__c
        // Insert EUR_CRM_Brand_Quality
    }

}