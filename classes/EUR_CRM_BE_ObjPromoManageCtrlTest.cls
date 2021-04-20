@isTest
public class EUR_CRM_BE_ObjPromoManageCtrlTest {
    
    static User eurSysUser;
    static User regionalManager;
    static Profile eurSysProfile = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
    
    static void setUser() {
        UserRole r = [select id from UserRole where Developername ='EUR_BE_Area_Manager_GDL_Off_Trade'];
        eurSysUser = new User(Alias = 'standt', Email='testingEmail1234@test.com', userroleid=r.id,
                              EmailEncodingKey='UTF-8', LastName='Testing1234', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='testCase@testing.com');
        insert eurSysUser;
    }
    
    static void setRegionalManager() {
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_BE_Area_Manager_GDL_Off_Trade'];
        regionalManager =  new User(Alias = 'regmgr', Email='testingEmail1234Manager@test.com', userroleid=r.id,
                                    EmailEncodingKey='UTF-8', LastName='Manager test 1', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testCaseManager@testing.com');
        insert regionalManager;
        
        regionalManager = [SELECT Id FROM User WHERE Email = 'testingEmail1234Manager@test.com'];
    }
    
    static testMethod void test(){
        setUser();
        setRegionalManager();
        System.runAs(eurSysUser) {
            
            EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_BE_TestClassHelper.createCustomerTaxonomy('Test Taxonomy', 'EUR_BE_Customer_Taxonomy');
            insert customerTaxonomy;
            
            Id currentUserId = UserInfo.getUserId();
            List<EUR_CRM_Region__c> regions = EUR_CRM_BE_TestClassHelper.createRegion(5,'EUR',currentUserId);
            insert regions;
            
            EUR_CRM_Account__c euaccount = EUR_CRM_BE_TestClassHelper.createEUAccount('Test EU ACCOUNT');
            euaccount.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
            insert euaccount;
            
            EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_BE_TestClassHelper.createActionListTemplate();
            insert template;
            // Create Promo
            List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_BE_TestClassHelper.createObjPromo(1,'EUR_BE_On_Trade_Promo_Kit_Activation','Test Promo',template);
            List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
            List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
            for(EUR_CRM_ObjPromo__c p: promos){
                p.EUR_CRM_Status__c='Draft';
                promosToInsert.add(p);
            }
            insert promosToInsert;
            
            for(EUR_CRM_ObjPromo__c p :promosToInsert){
                p.EUR_CRM_Active_End_Date__c = Date.today();
                p.EUR_CRM_Status__c='Active';
                p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
                promosToUpdate.add(p);
            }
            update promosToUpdate;
            
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMap = EUR_CRM_BE_TestClassHelper.createCustomerTaxonomyMapping('EUR_FI_O_P_Customer_Taxonomy_Mapping', customerTaxonomy.Id, promos[0].Id);
            insert customerTaxonomyMap;
            
            Test.startTest();
            
            EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMapping = EUR_CRM_BE_TestClassHelper.createobjPromoAccMapping('EUR_BE_O_P_Account_Mapping', euaccount.Id, promos[0].Id);
            insert objPromoAccMapping;
            
            EUR_CRM_SKU__c sku = EUR_CRM_BE_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_BE_SKU' );
            
            List<EUR_CRM_ObjPromo_Target__c> objTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
            EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Volume_Target',promos[0].Id,null).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
            objTargetList.add(objTarget);  
            
            EUR_CRM_ObjPromo_Target__c objTarget2 = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Volume_Target',promos[0].Id,null).get(0);
            objTarget2.EUR_CRM_SKU__c = sku.id;
            objTarget2.EUR_CRM_SKU__r = sku;
            objTarget2.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget2.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTarget2.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            objTargetList.add(objTarget2); 
            
            EUR_CRM_ObjPromo_Target__c objTarget3 = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Volume_Target',promos[0].Id,null).get(0);
            objTarget3.EUR_CRM_SKU__c = sku.id;
            objTarget3.EUR_CRM_SKU__r = sku;
            objTarget3.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget3.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTarget3.EUR_CRM_Product_Level__c = 'EUR_CRM_SKU__c';
            objTargetList.add(objTarget3); 
            
            insert objTargetList;          
            
            
            
            Test.setCurrentPage(Page.EUR_CRM_BE_ObjPromoManagePage);
            ApexPages.currentPage().getParameters().put('objPromoId',promos[0].Id);
            ApexPages.currentPage().getParameters().put('rowIndex','1');
            ApexPages.standardController sc = new ApexPages.standardController(promos[0]);
            EUR_CRM_BE_ObjPromoManageController controller = new EUR_CRM_BE_ObjPromoManageController(sc);
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> targetWrap = controller.salesRepTargetWrap;
            controller.regionmanager = regionalManager.Id;
            controller.getPromoKitUnits();
            controller.firstPage();
            controller.lastPage();
            controller.nextPage();
            controller.previousPage();
            controller.getRegionalAndSalesAgencyTargetWraps();
            controller.getRegionalManagerOptions();
            controller.resetSalesRepTargetWrap();
            //controller.setPublishStatus();
            controller.getProductSelectionTabVisibility();
            controller.getIsProductionSelectionRendered();
            controller.getIsTargetManagementRendered();
            controller.getTargetManagementTabVisibility();
            controller.getTargetManagementSpyderTabVisibility();
            controller.getTargetManagementPromoKitTabVisibility();
            controller.getTargetManagerTabVisibility();
            controller.getIsSpyder();
            controller.getIsSalesDrive();
            controller.getIsOnPromoKit();
            controller.getIsOnSecondPlace();
            controller.getIsListViewOptionRendered();
            controller.getIsCTaxOptionRendered();
            controller.getIsPRSOptionRendered();
            controller.getIsAccountListView();
            controller.getIsCustomerTaxonomy();
            controller.getIsPRS();                
            controller.getIsProductSelectionSelected();
            controller.getIsBrandSizeRendered();
            controller.getIsBrandQualityRendered();
            controller.getIsSKURendered();
            controller.getIsBrandSize();
            controller.getIsSKU();
            controller.getIsBrandQuality();
            controller.getSpyderVolume();
            controller.getTargetsInSelectedProductLevel();
            controller.getTargetsInSpyderObjectiveLevel();
            controller.add();
            controller.removeProduct();
            //controller.deleteOldTargets();
            //controller.quickSaveProducts();
            controller.saveProducts();
            //controller.quickSaveObjectiveTargets();
            //controller.saveObjectiveTargets();
            //controller.quickSaveRegionalTargets();
            controller.saveRegionalTargets();
            // controller.quickSaveSRTargets();
            controller.saveSRTargets();
            controller.cancel();
            //controller.refresh();
            controller.initializeAccountSelection();
            Test.stopTest();
        }
    }
    
    static testMethod void test2(){
        setUser();
        setRegionalManager();
        System.runAs(eurSysUser) {
            
            EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_BE_TestClassHelper.createCustomerTaxonomy('Test Taxonomy', 'EUR_BE_Customer_Taxonomy');
            insert customerTaxonomy;
            
            EUR_CRM_Account__c euaccount = EUR_CRM_BE_TestClassHelper.createEUAccount('Test EU ACCOUNT');
            euaccount.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
            insert euaccount;
            
            EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_BE_TestClassHelper.createActionListTemplateWithExternal('BE_Off_Trade_Secondary_placement_Spyder_display');
            insert template;
            // Create Promo
            List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_BE_TestClassHelper.createObjPromo(1,'EUR_BE_Off_Trade_Secondary_placement_Spyder_display','Test Promo',template);
            List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
            List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
            for(EUR_CRM_ObjPromo__c p: promos){
                p.EUR_CRM_Status__c='Draft';
                p.EUR_CRM_Is_Publish_ready__c = true;
                promosToInsert.add(p);
            }
            insert promosToInsert;
            
            for(EUR_CRM_ObjPromo__c p :promosToInsert){
                p.EUR_CRM_Active_End_Date__c = Date.today();
                p.EUR_CRM_Status__c='Active';
                p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
                promosToUpdate.add(p);
            }
            update promosToUpdate;
            
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMap = EUR_CRM_BE_TestClassHelper.createCustomerTaxonomyMapping('EUR_FI_O_P_Customer_Taxonomy_Mapping', customerTaxonomy.Id, promos[0].Id);
            insert customerTaxonomyMap;
            
            
            EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMapping = EUR_CRM_BE_TestClassHelper.createobjPromoAccMapping('EUR_BE_O_P_Account_Mapping', euaccount.Id, promos[0].Id);
            insert objPromoAccMapping;
            
            EUR_CRM_SKU__c sku = EUR_CRM_BE_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_BE_SKU' );
            
            List<EUR_CRM_ObjPromo_Target__c> objTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
            EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Volume_Target',promos[0].Id,null).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            objTargetList.add(objTarget);  
            
            
            insert objTargetList;
            
            
            Test.startTest();
            
            Test.setCurrentPage(Page.EUR_CRM_BE_ObjPromoManagePage);
            ApexPages.currentPage().getParameters().put('objPromoId',promos[0].Id);
            ApexPages.currentPage().getParameters().put('rowIndex','2');
            ApexPages.standardController sc = new ApexPages.standardController(promos[0]);
            EUR_CRM_BE_ObjPromoManageController controller = new EUR_CRM_BE_ObjPromoManageController(sc);
            controller.regionmanager = regionalManager.Id;
            controller.initializeProductSelection();
            controller.getPromoKitUnits();
            controller.firstPage();
            controller.lastPage();
            controller.nextPage();
            controller.previousPage();
            controller.getRegionalAndSalesAgencyTargetWraps();
            controller.getRegionalManagerOptions();
            controller.resetSalesRepTargetWrap();
            controller.getProductSelectionTabVisibility();
            controller.getIsProductionSelectionRendered();
            controller.getIsTargetManagementRendered();
            controller.getTargetManagementTabVisibility();
            controller.getTargetManagementSpyderTabVisibility();
            controller.getTargetManagementPromoKitTabVisibility();
            controller.getTargetManagerTabVisibility();
            controller.getIsSpyder();
            controller.getIsSalesDrive();
            controller.getIsOnPromoKit();
            controller.getIsOnSecondPlace();
            controller.getIsListViewOptionRendered();
            controller.getIsCTaxOptionRendered();
            controller.getIsPRSOptionRendered();
            controller.getIsAccountListView();
            controller.getIsCustomerTaxonomy();
            controller.getIsPRS();
            controller.getIsProductSelectionSelected();
            controller.getIsBrandSizeRendered();
            controller.getIsBrandQualityRendered();
            controller.getIsSKURendered();
            controller.getIsBrandSize();
            controller.getIsSKU();
            controller.getIsBrandQuality();
            controller.getSpyderVolume();
            controller.getTargetsInSelectedProductLevel();
            controller.getTargetsInSpyderObjectiveLevel();
            controller.add();
            controller.removeProduct();
            //controller.deleteOldTargets();
            controller.quickSaveProducts();
            //controller.saveProducts();
            controller.quickSaveObjectiveTargets();
            controller.saveObjectiveTargets();
            controller.quickSaveRegionalTargets();
            //controller.saveRegionalTargets();
            controller.quickSaveSRTargets();
            //controller.saveSRTargets();
            controller.cancel();
            //controller.refresh();
            //

            List<EUR_CRM_OPTargetHelperClass.TargetWrap> salesRepTargetWrap = controller.salesRepTargetWrap;
            controller.getPagedEUAccounts();

            controller.isDraft = true;
            controller.isAccountSelectionDone = true;
            controller.setPublishStatus();

            Test.stopTest();
        }
    }
}