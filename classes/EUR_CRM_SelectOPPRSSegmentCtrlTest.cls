/***********************************************************************************
* Name: EUR_CRM_SelectOPPRSSegmentCtrlTest
* Description: Test Class for EUR_CRM_SelectOPPRSSegmentCtrl 
*
* Version History
* Date         Developer   			Comments
* ----------   -------------------  	--------------------------------------------    
*  10-7-2017  	[Laputa] Kevin Choi  	Created
***********************************************************************************/
@isTest
public class EUR_CRM_SelectOPPRSSegmentCtrlTest{
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
    
    static testmethod void test() {
        setUser();
        setRegionalManager();
        System.runAs(eurSysUser) {
            EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
            EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
            EUR_CRM_Region__c region= new EUR_CRM_Region__c();
            EUR_CRM_ObjPromo_Target__c objTarget =  new EUR_CRM_ObjPromo_Target__c();
            EUR_CRM_ObjPromo_Target__c objTargetSub =  new EUR_CRM_ObjPromo_Target__c();
            EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
            EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
            EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c proSegmentMapping=new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
            
            apexConfig = EUR_CRM_BE_TestClassHelper.createApexConfig();
            insert apexConfig;
            
            euaccount = EUR_CRM_BE_TestClassHelper.createEUAccount('Test EU ACCOUNT');
            insert euaccount;
            
            EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_BE_TestClassHelper.createActionListTemplate();
            insert template;
            // Create Promo
            List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_BE_TestClassHelper.createObjPromo(20,'EUR_BE_On_Trade_Promo_Kit_Activation','Test Promo',template);
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
            region = EUR_CRM_BE_TestClassHelper.createRegion('testRegion', regionalManager.Id, 'EUR_BE_Region');
            
            List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_BE_TestClassHelper.createOPAccountMapping(10,'EUR_BE_O_P_Account_Mapping',euaccount,promos[0]);
            List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
                m.EUR_CRM_Is_Active__c = true;
                m.EUR_CRM_Evaluation_Required__c = false;
                opMappingToInsert.add(m);
            }
            insert opMappingToInsert;
            
            EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_BE_TestClassHelper.createObjPromoAction();
            objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
            insert objPromoAction;
            
            EUR_CRM_Visit_Action__c visitAction = EUR_CRM_BE_TestClassHelper.createVisitAction(euaccount,promos[0]);
            visitAction.EUR_CRM_Stage__c = 'Execution';
            visitAction.EUR_CRM_Status__c ='Participating';
            insert visitAction;
            
            sku = EUR_CRM_BE_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_BE_SKU' );
            
            
            Id opTargetId = null;
            objTarget = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Product',promosToUpdate[0].Id, opTargetId ).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
            insert objTarget;
            
            objTargetSub = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Volume_Target', promosToUpdate[0].Id, opTargetId ).get(0);
            objTargetSub.EUR_CRM_SKU__c = sku.id;
            objTargetSub.EUR_CRM_SKU__r = sku;
            objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
            insert objTargetSub;
            
            proSegmentMapping = EUR_CRM_BE_TestClassHelper.createProsSegmentMapping(promosToUpdate[0],'EUR_FI_OP_PROS_Segment_Mapping');
            insert  proSegmentMapping;
            
            groupOutletType = EUR_CRM_BE_TestClassHelper.createGroupOutletType('EUR_BE_PRS_On_Trade_Group_Outlet_Type');
            insert groupOutletType;
            
            Test.startTest();
            
            EUR_CRM_SelectOPPRSSegmentCtrl con = new EUR_CRM_SelectOPPRSSegmentCtrl();
            con.countryCode = 'BE';
            con.groupOutletTypeFilter = 'EUR_BE_PRS_On_Trade_Group_Outlet_Type';
            //EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper objPromoWrapper = new EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper(true, 1, 'oImage', 'otype');
            //con.opWrapList.add(objPromoWrapper);
            ApexPages.StandardSetController cont = con.con;
            con.objPromo = promosToUpdate[0];
            try{
                Boolean initDummyVar = con.initDummyVar;
            }
            catch(exception e){}
            con.sortFieldName = 'fld1';
            con.oldSortFieldName = 'old1';
            con.init();
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
    
    static testmethod void testWithWhereClause() {
        setUser();
        setRegionalManager();
        System.runAs(eurSysUser) {
            EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
            EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
            EUR_CRM_Region__c region= new EUR_CRM_Region__c();
            EUR_CRM_ObjPromo_Target__c objTarget =  new EUR_CRM_ObjPromo_Target__c();
            EUR_CRM_ObjPromo_Target__c objTargetSub =  new EUR_CRM_ObjPromo_Target__c();
            EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c();
            EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c();
            EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c proSegmentMapping=new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
            
            apexConfig = EUR_CRM_BE_TestClassHelper.createApexConfig();
            insert apexConfig;
            
            euaccount = EUR_CRM_BE_TestClassHelper.createEUAccount('Test EU ACCOUNT');
            insert euaccount;
            
            EUR_CRM_SelectOPPRSSegmentCtrl.euAccountsWrapper accWrapper = new EUR_CRM_SelectOPPRSSegmentCtrl.euAccountsWrapper(euaccount,true);
            
            EUR_CRM_OP_Action_List_Template__c template = EUR_CRM_BE_TestClassHelper.createActionListTemplate();
            insert template;
            // Create Promo
            List<EUR_CRM_ObjPromo__c> promos = EUR_CRM_BE_TestClassHelper.createObjPromo(20,'EUR_BE_On_Trade_Promo_Kit_Activation','Test Promo',template);
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
            region = EUR_CRM_BE_TestClassHelper.createRegion('testRegion', regionalManager.Id, 'EUR_BE_Region');
            
            List<EUR_CRM_ObjPromo_Account_Mapping__c>  opMapping =  EUR_CRM_BE_TestClassHelper.createOPAccountMapping(10,'EUR_BE_O_P_Account_Mapping',euaccount,promos[0]);
            List<EUR_CRM_ObjPromo_Account_Mapping__c> opMappingToInsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            for(EUR_CRM_ObjPromo_Account_Mapping__c m: opMapping){
                m.EUR_CRM_Is_Active__c = true;
                m.EUR_CRM_Evaluation_Required__c = false;
                opMappingToInsert.add(m);
            }
            insert opMappingToInsert;
            
            EUR_CRM_ObjPromo_Action__c objPromoAction = EUR_CRM_BE_TestClassHelper.createObjPromoAction();
            objPromoAction.EUR_CRM_OP_Action_List_Template__c = template.Id;
            insert objPromoAction;
            
            EUR_CRM_Visit_Action__c visitAction = EUR_CRM_BE_TestClassHelper.createVisitAction(euaccount,promos[0]);
            visitAction.EUR_CRM_Stage__c = 'Execution';
            visitAction.EUR_CRM_Status__c ='Participating';
            insert visitAction;
            
            sku = EUR_CRM_BE_TestClassHelper.createSKU('Absolut', '70351300', 'EUR_BE_SKU' );
            
            
            Id opTargetId = null;
            objTarget = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Product',promosToUpdate[0].Id, opTargetId ).get(0);
            objTarget.EUR_CRM_SKU__c = sku.id;
            objTarget.EUR_CRM_SKU__r = sku;
            objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTarget.EUR_CRM_Target_Owner__c = regionalManager.id;
            insert objTarget;
            
            objTargetSub = EUR_CRM_BE_TestClassHelper.createOPTarget(1, 'EUR_BE_Objective_Volume_Target', promosToUpdate[0].Id, opTargetId ).get(0);
            objTargetSub.EUR_CRM_SKU__c = sku.id;
            objTargetSub.EUR_CRM_SKU__r = sku;
            objTargetSub.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
            objTargetSub.EUR_CRM_Target_Owner__c = regionalManager.id;
            objTargetSub.EUR_CRM_O_P_Target__c = objTarget.Id;
            insert objTargetSub;
            
            proSegmentMapping = EUR_CRM_BE_TestClassHelper.createProsSegmentMapping(promosToUpdate[0],'EUR_FI_OP_PROS_Segment_Mapping');
            insert  proSegmentMapping;
            
            groupOutletType = EUR_CRM_BE_TestClassHelper.createGroupOutletType('EUR_BE_PRS_On_Trade_Group_Outlet_Type');
            insert groupOutletType;
            
            Test.startTest();
            
            EUR_CRM_SelectOPPRSSegmentCtrl con = new EUR_CRM_SelectOPPRSSegmentCtrl();
            con.countryCode = 'BE';
            con.groupOutletTypeFilter = 'EUR_BE_PRS_On_Trade_Group_Outlet_Type';
            con.whereClauseString = 'recordType.DeveloperName = \'EUR_BE_On_Trade\'';

            ApexPages.StandardSetController cont = con.con;
            con.objPromo = promosToUpdate[0];
            try{
                Boolean initDummyVar = con.initDummyVar;
            }
            catch(exception e){}
            con.sortFieldName = 'fld1';
            con.oldSortFieldName = 'old1';
            con.init();
            con.opWrapList = new List<EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper>();
            EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper objPromoWrapper = new EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper(true, 1, 'Iconic', 'Restaurant');
            EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper objPromoWrapper2 = new EUR_CRM_SelectOPPRSSegmentCtrl.ObjectPromWrapper(true, 1, 'Premium', 'Night Club');
            con.opWrapList.add(objPromoWrapper);
            con.opWrapList.add(objPromoWrapper2);
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
}