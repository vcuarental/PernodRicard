@isTest
private class EUR_CRM_SelectOPPROSSegmentCtrlTest {
   
    static User eurSysUser;
    static User regionalManager;
    static Profile eurSysProfile = [SELECT Id FROM Profile WHERE Name = 'EUR System Admin'];
    static void setUser() {
      UserRole r = [select id from UserRole where Developername ='EUR_RU_SR_OFF_South_Krasnodar'];
      eurSysUser = new User(Alias = 'standt', Email='userEmail11234ru@test.com', userroleid=r.id,
      EmailEncodingKey='UTF-8', LastName='userEmail11234rulastName', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='userEmail11234ru@test.com');
      insert eurSysUser;
    }

    static void setRegionalManager() {
      UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EUR_RU_CM_South_Stavropol_Krasnodar'];
      regionalManager =  new User(Alias = 'regmgr', Email='userEmail112345ru@test.com', userroleid=r.id,
      EmailEncodingKey='UTF-8', LastName='userEmail112345rulastName', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = eurSysProfile.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='userEmail112345ru@test.com');
      insert regionalManager;

      regionalManager = [SELECT Id FROM User WHERE Email = 'userEmail112345ru@test.com'];
    }
    static testmethod void test() {
        setUser();
        setRegionalManager();
        System.runAs(eurSysUser) {
        EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        EUR_CRM_Region__c region= new EUR_CRM_Region__c();
        EUR_CRM_ObjPromo_Target__c objTarget =  new EUR_CRM_ObjPromo_Target__c();
        EUR_CRM_ObjPromo_Target__c objTargetSub =  new EUR_CRM_ObjPromo_Target__c();
        EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
        EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c proSegmentMapping=new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
        
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
          
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test EU ACCOUNT');
        insert euaccount;
          
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
          // Create Promo
          List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
          List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
          List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
          for(EUR_CRM_ObjPromo__c p: promos){
              p.EUR_CRM_Status__c='Draft';
              promosToInsert.add(p);
          }
          insert promosToInsert;
          for(EUR_CRM_ObjPromo__c p :promosToInsert){
              p.EUR_CRM_Active_End_Date__c = Date.today()-1;  
              p.EUR_CRM_Status__c='Active';
              p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
              promosToUpdate.add(p);
          }
          update promosToUpdate;
          
  
        
          
          // put region
        region = EUR_CRM_RU_TestClassHelper.createRegion('testRegion', regionalManager.Id, 'EUR RU Region');
         
          List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount,promos[0]);
          List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
          for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
              m.EUR_CRM_Is_Active__c = true;
              m.EUR_CRM_Evaluation_Required__c = false;
              opMappingToInsert.add(m);
          }
          insert opMappingToInsert;
          
          EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
          objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
          insert objPromoAction;
          
          EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount,promos[0]);
          visitAction.EUR_CRM_Stage__c = 'Execution';
          visitAction.EUR_CRM_Status__c ='Participating';
          insert visitAction;
          
          sku = EUR_CRM_RU_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_RU_SKU' );
          
  
         Id opTargetId = null;
          objTarget = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Objective Product',promosToUpdate[0].Id, opTargetId ).get(0);
          objTarget.EUR_CRM_SKU__c = sku.id;
          objTarget.EUR_CRM_SKU__r = sku;
          objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
          objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
          insert objTarget;
          
          objTargetSub = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Manager POSM Target', promosToUpdate[0].Id, opTargetId ).get(0);
          objTargetSub.EUR_CRM_SKU__c = sku.id;
          objTargetSub.EUR_CRM_SKU__r = sku;
          objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
          objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
          objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
          insert objTargetSub;
  
          proSegmentMapping = EUR_CRM_RU_TestClassHelper.createProsSegmentMapping(promosToUpdate[0],'EUR_FI_OP_PROS_Segment_Mapping');
          insert  proSegmentMapping;
          
        Test.startTest();

            EUR_CRM_SelectOPPROSSegmentCtrl con = new EUR_CRM_SelectOPPROSSegmentCtrl();
            con.countryCode = 'RU';
            ApexPages.StandardSetController cont = con.con;
            con.objPromo = promosToUpdate[0];
            try{
                Boolean initDummyVar = con.initDummyVar;
            }
            catch(exception e){}
            con.sortFieldName = 'fld1';
            con.oldSortFieldName = 'old1';
            con.filter();
            con.sort();
            con.doNext();
            con.doPrevious();
            con.first();
            con.last();
            con.getHasPrevious();
            con.getHasNext();
            con.getPageNumber();
            con.getTotalPages();
            Integer pageNumber = con.pageNumber;
            con.getPageSize();
            con.getRecordSize();
            String contextItem = con.contextItem;
            con.doSelectItem();
            con.getSelectedAccounts();
            con.doDeselectItem();
            con.getHasSelectedAccounts();
            con.selectAll();
            con.deSelectAll();
            con.getIsDeactivated();
            con.saveAccounts();
            con.quickSaveContinue();
            con.cancel();
            con.refresh();
                
        Test.stopTest();
      }
    }
    
    static testmethod void testError() {
        setUser();
        setRegionalManager();
        System.runAs(eurSysUser) {
        EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
        EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        EUR_CRM_Region__c region= new EUR_CRM_Region__c();
        EUR_CRM_ObjPromo_Target__c objTarget =  new EUR_CRM_ObjPromo_Target__c();
        EUR_CRM_ObjPromo_Target__c objTargetSub =  new EUR_CRM_ObjPromo_Target__c();
        EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
        EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c proSegmentMapping=new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
        
        apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
          
        euaccount = EUR_CRM_RU_TestClassHelper.createEUAccount('Test EU ACCOUNT');
        insert euaccount;
          
        EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert template;
          // Create Promo
          List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_RU_TestClassHelper.createObjPromo(20,'EUR_RU_ON_Trade_Phase_1','Test Promo',template);
          List<EUR_CRM_ObjPromo__c> promosToInsert = new List<EUR_CRM_ObjPromo__c>();
          List<EUR_CRM_ObjPromo__c> promosToUpdate = new List<EUR_CRM_ObjPromo__c>();
          for(EUR_CRM_ObjPromo__c p: promos){
              p.EUR_CRM_Status__c='Draft';
              promosToInsert.add(p);
          }
          insert promosToInsert;
          for(EUR_CRM_ObjPromo__c p :promosToInsert){
              p.EUR_CRM_Active_End_Date__c = Date.today()-1;  
              p.EUR_CRM_Status__c='Active';
              p.EUR_CRM_Evaluation_Period_End_Date__c = Date.today()-1;
              promosToUpdate.add(p);
          }
          update promosToUpdate;
          
  
        
          
          // put region
        region = EUR_CRM_RU_TestClassHelper.createRegion('testRegion', regionalManager.Id, 'EUR RU Region');
         
          List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_RU_TestClassHelper.createOPAccountMapping(10,'EUR_RU_O_P_Account_Mapping',euaccount,promos[0]);
          List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
          for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
              m.EUR_CRM_Is_Active__c = true;
              m.EUR_CRM_Evaluation_Required__c = false;
              opMappingToInsert.add(m);
          }
          insert opMappingToInsert;
          
          EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_RU_TestClassHelper.createObjPromoAction();
          objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
          insert objPromoAction;
          
          EUR_CRM_Visit_Action__c visitAction = EUR_CRM_RU_TestClassHelper.createVisitAction(euaccount,promos[0]);
          visitAction.EUR_CRM_Stage__c = 'Execution';
          visitAction.EUR_CRM_Status__c ='Participating';
          insert visitAction;
          
          sku = EUR_CRM_RU_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_RU_SKU' );
          
  
         Id opTargetId = null;
          objTarget = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Objective Product',promosToUpdate[0].Id, opTargetId ).get(0);
          objTarget.EUR_CRM_SKU__c = sku.id;
          objTarget.EUR_CRM_SKU__r = sku;
          objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
          objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
          insert objTarget;
          
          objTargetSub = EUR_CRM_RU_TestClassHelper.createOPTarget(1, 'RU Manager POSM Target', promosToUpdate[0].Id, opTargetId ).get(0);
          objTargetSub.EUR_CRM_SKU__c = sku.id;
          objTargetSub.EUR_CRM_SKU__r = sku;
          objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
          objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
          objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
          insert objTargetSub;
  
          proSegmentMapping = EUR_CRM_RU_TestClassHelper.createProsSegmentMapping(promosToUpdate[0],'EUR_FI_OP_PROS_Segment_Mapping');
          insert  proSegmentMapping; 
          
        Test.startTest();
            EUR_CRM_SelectOPPROSSegmentCtrl.euAccountsWrapper wrap = new EUR_CRM_SelectOPPROSSegmentCtrl.euAccountsWrapper(euaccount,true);
            EUR_CRM_SelectOPPROSSegmentCtrl con = new EUR_CRM_SelectOPPROSSegmentCtrl();
            con.countryCode = 'RU';
            ApexPages.StandardSetController cont = con.con;
            try{
                Boolean initDummyVar = con.initDummyVar;
            }
            catch(exception e){}
                        
            try{
                con.quickSaveAccounts();
            }
            catch(Exception e){}
            Boolean isSelectorRendered = con.isSelectorRendered;
            Boolean initialized = con.initialized;
            ApexPages.StandardController standardController = con.standardController;
                
        Test.stopTest();
      }
    }
}