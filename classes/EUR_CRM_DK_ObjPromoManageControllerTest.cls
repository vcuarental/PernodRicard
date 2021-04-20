@isTest
public class EUR_CRM_DK_ObjPromoManageControllerTest {
    
    static User eurSysUser;
    static User regionalManager;
    static Profile eurSysProfile = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
    static EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
    static EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
    static EUR_CRM_ObjPromo_Target__c objTarget =  new EUR_CRM_ObjPromo_Target__c();
    static EUR_CRM_ObjPromo_Target__c objTargetSub =  new EUR_CRM_ObjPromo_Target__c();
    static EUR_CRM_ObjPromo__c objPromo;
    static EUR_CRM_Region__c region;
    static EUR_CRM_Territory__c territory;
    static EUR_CRM_Customer_Taxonomy__c customerTaxonomy;
    static List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
    static List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappings = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
    static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
  static EUR_CRM_OP_Action_List_Template__c  actionListTemplate;
    static EUR_CRM_ObjPromo_Account_Mapping__c opaccmap;
    static EUR_CRM_OP_Customer_Taxonomy_Mapping__c ctmapping;

    
    static string PROFILE_NAME       = 'EUR System Admin';
    static string ROLE_NAME        = 'EMEA';
    static String OBJ_PRODUCT         = 'EUR_DK_Objective_Product';
    static String OBJ_VOLUME_TARGET   = 'EUR_DK_Objective_Volume_Target';
    static String MGR_VOLUME_TARGET   = 'EUR_DK_Manager_Volume_Target';
    static String SR_VOLUME_TARGET    = 'EUR_DK_SR_Volume_Target';
    static String OP_OFF_SKU_BOTTLES  = 'EUR_DK_Off_Trade_Sales_Drive_SKU_Bottles';
    static String OP_OFF_SKU_DISPLAYS = 'EUR_DK_Off_Trade_Sales_Drive_SKU_Displays';
    static String OP_OFF_SKU_CARTONS  = 'EUR_DK_OFF_Trade_Sales_Drive_SKU_Cartons';
    static String OP_OFF_LEAFLET      = 'EUR_DK_Off_Trade_Leaflet_Campaign';
    static String OP_OFF_TASTING      = 'EUR_DK_Off_Trade_Tasting_Campaign';
    static String OP_OFF_DISTRIBUTION = 'EUR_DK_Off_Trade_Distribution_Drive';
    static String DK_CUSTOMER_TAXONOMY = 'EUR_DK_Customer_Taxonomy';
    static String DK_TERRIORY = 'EUR_DK_Territory';
    static String DK_OP_ACTION_LIST_TEMP = 'EUR_DK_OP_Action_List_Template';
    static String DK_ACC_OFF_TRADE    = 'EUR_DK_OFF_Trade';
    
    private Map<String, String> productLevelToFieldName = new Map<String, String>{
      'EUR_CRM_Size__c' => 'EUR_CRM_BQS',
      'EUR_CRM_SKU__c' => 'EUR_CRM_SKU' 
    };
            
    static void setUser() {
        eurSysUser = EUR_CRM_DK_TestClassHelper.createUser(PROFILE_NAME,ROLE_NAME,'user_dk@test.com','user_dk@test.com','LastName');
        eurSysUser.ManagerId = regionalManager.Id;
        /*UserRole r = [select id from UserRole where Developername ='EUR_RU_SR_OFF_South_Krasnodar'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail11234ru@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail11234rulastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail11234ru@test.com');
        insert eurSysUser;*/
    }

    static void setRegionalManager() {
        regionalManager = EUR_CRM_DK_TestClassHelper.createUser(PROFILE_NAME,ROLE_NAME,'manager_dk@test.com','manager_dk@test.com','LastName');
        /*UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_RU_CM_South_Stavropol_Krasnodar'];
        regionalManager =  new User(Alias = 'regmgr', Email='userEmail112345ru@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail112345rulastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail112345ru@test.com');
        insert regionalManager;

        regionalManager = [SELECT Id FROM User WHERE Email = 'userEmail112345ru@test.com'];*/
    }
    
    static void setMasterData(String opRecordTypeDevName, String accountRecordTypeDevName,Boolean hasTarget, Boolean setMgrTarget) {
        
        apexConfig = EUR_CRM_DK_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        String opActionListTemplateExternalId = EUR_CRM_RecordTypeHelper.ObjectivePromoHandler_opActionMap.get(opRecordTypeDevName);

        // put region
        List<EUR_CRM_Region__c> regionList = EUR_CRM_DK_TestClassHelper.createRegion(1, 'EUR', regionalManager.Id);
    System.Debug('@@insert region');
        insert regionList;
        
        region = regionList[0];
        
        // put territory
        territory = EUR_CRM_DK_TestClassHelper.createTerritory('testTerritory', regionalManager.Id, region.Id, DK_TERRIORY); // inserted
          
    // Action List Template
    actionListTemplate = EUR_CRM_DK_TestClassHelper.createActionListTemplate();
        System.Debug('@@insert action list template');
    insert actionListTemplate;
        
        // Customer Tax
        customerTaxonomy = EUR_CRM_DK_TestClassHelper.createCustomerTaxonomy('TestChain',regionalManager.Id, 'EUR_DK_Customer_Taxonomy' );
        
    // Account
        euaccount = EUR_CRM_DK_TestClassHelper.createEUAccountsDKOFF('DK_Testing_Acc');
        euaccount.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
        System.Debug('@@insert account');
        //euaccount.EUR_CRM_Customer_Taxonomy_Chain__c = 'TEST CHAIN';
        //euaccount.EUR_CRM_Customer_Taxonomy_SubChain__c = 'TEST CHAIN';
        insert euaccount;
        // Create ObjPromo
        objPromo = EUR_CRM_DK_TestClassHelper.createObjPromo(1,OP_OFF_LEAFLET,'TEST_DK_OP',actionListTemplate)[0];
        System.Debug('@@insert ObjPromo');
        insert objPromo;
        
        
        opaccmap = EUR_CRM_DK_TestClassHelper.createOPAccountMapping(objPromo,euaccount);
        insert opaccmap;
        
        
        ctmapping = EUR_CRM_DK_TestClassHelper.createCustomerTaxonomyMapping(customerTaxonomy,objPromo,'EUR_DK_OP_Customer_Taxonomy_Mapping');
        insert ctmapping;
        
        sku = EUR_CRM_DK_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_DK_SKU' );
        
        if(hasTarget){          
            
            Id opTargetId = null;
            objTarget = EUR_CRM_DK_TestClassHelper.createOPTarget(1, 'DK Objective Product', objPromo.Id, opTargetId ).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = eurSysUser.id;
            objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
            /*
            if(hasTarget){
                objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            }
            else{
                objTarget.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
            }*/
            System.Debug('@@insert objTarget');
            insert objTarget;
           
        }

        if(setMgrTarget){
            Id opTargetId = null;
            objTargetSub = EUR_CRM_DK_TestClassHelper.createOPTarget(1, 'DK Manager Volume Target', objPromo.Id, opTargetId ).get(0);
            objTargetSub.EUR_CRM_SKU__c = sku.id;
            objTargetSub.EUR_CRM_SKU__r = sku;
            objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
            objTargetSub.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            /*
            if(hasTarget){
                //objTargetSub.EUR_CRM_Product_Level__c = 'EUR_CRM_Quality__c';
            }
            else{
                //objTargetSub.EUR_CRM_Product_Level__c = 'EUR_CRM_Size__c';
            }*/
            System.Debug('@@insert objTargetSub');
            insert objTargetSub;
        }
       
        
        // Insert EUR_CRM_Brand__c
        // Insert EUR_CRM_Brand_Quality
    }

    static void setTargets() {
        // Insert EUR_CRM_ObjPromo_Account_Mapping__c
        for(EUR_CRM_Account__c acc: accounts) {
            opAccountMappings.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                EUR_CRM_Account__c = acc.Id,
                EUR_CRM_ObjPromo__c = objPromo.Id
            ));
        }

        insert opAccountMappings;
    }
    

    
    static testMethod void testInitializePhase2() {
        System.Debug('@@Running testInitializePhase2');
        setRegionalManager();
        setUser();
        
        //System.runAs(eurSysUser)
        
        System.runAs(eurSysUser) {
          Test.startTest();
            setMasterData(OP_OFF_LEAFLET, DK_ACC_OFF_TRADE,true,false);
            System.Debug('@@Page objPromo' + objPromo);
            
            Test.stopTest();

            PageReference pageRef = Page.EUR_CRM_DK_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_DK_ObjPromoManageController con = new EUR_CRM_DK_ObjPromoManageController(sc);
            
            con.getPagedEUAccounts();
            con.initializeTargets();
            con.getRegionalAndSalesAgencyTargetWraps();
      con.getRegionalManagerOptions();
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> getWrap = con.salesRepTargetWrap;

            //List<EUR_CRM_OPTargetHelperClass.TargetWrap> opt = con.salesRepTargetWrap; 
            //List<EUR_CRM_ObjPromo_Target__c> t = new List<EUR_CRM_ObjPromo_Target__c>(); 
            //t.add(objTarget);
            //con.deleteOldTargets(t);
            
            //con.firstPage();
            //con.nextPage();
            //con.previousPage();
            //con.lastPage();
            //con.resetSalesRepTargetWrap();
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
            
        }
    }

    
    
    
    static testMethod void testInitializePhase1() {
        System.Debug('@@Running testInitializePhase1');
        setRegionalManager();
        setUser();
        
        //System.runAs(eurSysUser)
        
        System.runAs(regionalManager) {
          Test.startTest();
            setMasterData(OP_OFF_LEAFLET, DK_ACC_OFF_TRADE,true,true);
            System.Debug('@@Page objPromo' + objPromo);
            
            Test.stopTest();

            PageReference pageRef = Page.EUR_CRM_DK_ObjPromoManagePage;
            pageRef.getParameters().put('objPromoId', objPromo.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objPromo);

            EUR_CRM_DK_ObjPromoManageController con = new EUR_CRM_DK_ObjPromoManageController(sc);
            
            con.initializeAccountSelection();
            con.getPagedEUAccounts();
            con.initializeTargets();
            con.initializeTargetManagement();
            con.getRegionalAndSalesAgencyTargetWraps();
            con.initializeProductSelection();
            con.getProductSelectionTabVisibility();
            con.getProductSelectionTabVisibility();
            con.getTargetManagementTabVisibility();
            con.getIsTargetManagementRendered();
            con.getIsListViewOptionRendered();
            con.getIsCTaxOptionRendered();
            con.getIsAccountListView();
            con.getIsCustomerTaxonomy();
            con.getIsProductSelectionSelected();
            con.getIsBrandSizeRendered();
            con.getIsSKURendered();
            con.getRegionalManagerOptions();
            con.getTargetsInSelectedProductLevel();
            con.add();
      con.quickSaveObjectiveTargets();
            con.saveObjectiveTargets();
            con.quickSaveRegionalTargets();
            con.saveRegionalTargets();
            con.quickSaveSRTargets();
            con.saveSRTargets();
            
            con.firstPage();
            con.lastPage();
            con.nextPage();
            con.previousPage();
            
            //con.removeProduct();
            
            List<EUR_CRM_OPTargetHelperClass.TargetWrap> getWrap = con.salesRepTargetWrap;

            //List<EUR_CRM_OPTargetHelperClass.TargetWrap> opt = con.salesRepTargetWrap; 
            //List<EUR_CRM_ObjPromo_Target__c> t = new List<EUR_CRM_ObjPromo_Target__c>(); 
            //t.add(objTarget);
            //con.deleteOldTargets(t);
            
            //con.firstPage();
            //con.nextPage();
            //con.previousPage();
            //con.lastPage();
            //con.resetSalesRepTargetWrap();
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
            
        }
    }
}