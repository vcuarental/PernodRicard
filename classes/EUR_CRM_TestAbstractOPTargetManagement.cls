@isTest

private with sharing class EUR_CRM_TestAbstractOPTargetManagement{
    /*
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_ObjPromo__c objPromo {get;set;}
    private static EUR_CRM_ObjPromo_Target__c objPromoTarget {get;set;}
    public static List<EUR_CRM_ObjPromo_Target__c> objPromoTargetNat= new List<EUR_CRM_ObjPromo_Target__c>();

   public static void dataInsert1(){
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
        custTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy;

    }

    static testMethod void testretrieveTargetOwnersSRLevel(){
      EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            test.StartTest();
            
            dataInsert1();
            
            EUR_CRM_AbstractOPTargetManagement.retrieveTargetOwnersSRLevel(custTaxonomy.Id,true);
            EUR_CRM_AbstractOPTargetManagement.retrieveTargetOwnersSRLevel(custTaxonomy.Id,false);
            EUR_CRM_AbstractOPTargetManagement.retrieveTargetOwnersRegionalLevel(custTaxonomy.Id);
            test.stopTest();
        }  
    }
    */
    public static List<EUR_CRM_ObjPromo_Target__c> objPromoTargetNat= new List<EUR_CRM_ObjPromo_Target__c>();
    static testMethod void testRetrieveTargets(){
        try{
            EUR_CRM_DE_TestClassUtilityHelper.initUsers();
            system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
                EUR_CRM_DE_TestClassUtilityHelper.initData();
                Id customerTaxonomyId = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
                Id regionalManager = EUR_CRM_DE_TestClassUtilityHelper.regionalUser.id;
                EUR_CRM_Account__c euAccount = EUR_CRM_DE_TestClassUtilityHelper.euAccount;    
                EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );

                EUR_CRM_SKU__c sku = EUR_CRM_DE_TestClassUtilityHelper.createSKU('Absolut', '70351300', EUR_CRM_DE_TestClassUtilityHelper.DE_SKU );

                EUR_CRM_ObjPromo__c objPromo2 = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
                objPromo2.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
                //objPromo2.EUR_CRM_Customer_Taxonomy__c = customerTaxonomyId;
                insert objPromo2;
                Id opTargetId = null;
                EUR_CRM_ObjPromo_Target__c objTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', objPromo2.Id, opTargetId ).get(0);
                objTarget.EUR_CRM_SKU__c = sku.id;
                objTarget.EUR_CRM_SKU__r = sku;
                objTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100;
                objTarget.EUR_CRM_Target_Owner__c = regionalManager;
                insert objTarget;
                objPromoTargetNat.add(objTarget);
                system.debug('@objPromoTargetNat'+objPromoTargetNat);

                String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
                String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target'; // Level 2 - Mid
                String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target'; // Level 3 - Low SR
                String SALES_AGENCY_TARGET = 'EUR_DE_Sales_Agency_Managed_Target'; //
                Map<String,Id> rtMap = new Map<String,Id>();
                for(RecordType rt : [select id, developername from RecordType where developername in (:REG_VOL_TARGET,:SR_VOL_TARGET,:OBJ_VOL_TARGET,:SALES_AGENCY_TARGET ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
                rtMap.put(rt.developername,rt.id);
                }
     
                List<User> targetOwners = [Select Id from User where Id=:regionalManager];
                List<User> targetOwnersOthers = [Select Id from User];
                List<EUR_CRM_ObjPromo_Target__c > regionalTargets = new List<EUR_CRM_ObjPromo_Target__c >();
                Id parentRecordTypeId = rtMap.get(OBJ_VOL_TARGET);
                Id subTargetRecordTypeId = rtMap.get(REG_VOL_TARGET);
                String targetField =  'EUR_CRM_SKU';
                Id rManager = null;
                //List<String> additionalFields = new List<String>{'EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Article_no__c', 'EUR_CRM_SKU__r.name','EUR_CRM_Promotion_Type__c '};
                List<EUR_CRM_AbstractOPTargetManagement.TargetWrap> targetWraps = EUR_CRM_AbstractOPTargetManagement.retrieveTargets(objPromo2.Id,objTarget,objPromoTargetNat ,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwners,regionalManager);
                
                for(EUR_CRM_AbstractOPTargetManagement.TargetWrap targetWrap: targetWraps){
                      targetWrap.getVolumeBottleAchieved();
                      targetWrap.getVolumeDisplayAchieved(); 
                }
                List<EUR_CRM_AbstractOPTargetManagement.TargetWrap> targetWraps2 = EUR_CRM_AbstractOPTargetManagement.retrieveTargets(objPromo2.Id,objTarget,objPromoTargetNat ,parentRecordTypeId,subTargetRecordTypeId,targetField,targetOwnersOthers,regionalManager);
                
            }
        }
        catch(Exception e){

        }    
    } 
    
    private static List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList;
    private static List<EUR_CRM_Account__c> euAccountList;
    private static List<User> offtradeRegionalUsers;
    private static List<EUR_CRM_Postal_Code_Territory_Mapping__c> postalCodeTerritoryMappingList;
    private static List<EUR_CRM_Region__c>  regionList;
    private static List<EUR_CRM_Territory__c> territoryList;

    static void createTestData(){
       
        regionList = EUR_CRM_DE_TestDummyData.createRegion('Test_Region', UserInfo.getUserId(),EUR_CRM_DE_TestDummyData.DE_REGION_RECORD_TYPE_DEVELOPERNAME,3,true);
        territoryList = EUR_CRM_DE_TestDummyData.createTerritory('territory', offtradeRegionalUsers[0].id,regionList[0].id, EUR_CRM_DE_TestDummyData.DE_TERRITORY_RECORD_TYPE_DEVELOPERNAME,2,true);
        postalCodeTerritoryMappingList = EUR_CRM_DE_TestDummyData.createPostalCodeMapping('postalmap' , EUR_CRM_DE_TestDummyData.TEST_POSTAL , territoryList[0].id, EUR_CRM_DE_TestDummyData.DE_POSTAL_CODE_MAPPING_RECORD_TYPE_DEVELOPERNAME,2,true);
        customerTaxonomyList = EUR_CRM_DE_TestDummyData.createCustomerTaxonomy('testtaxonomy', offtradeRegionalUsers[0].id, EUR_CRM_DE_TestDummyData.DE_CUSTOMER_TAXONOMY_RECORD_TYPE_DEVELOPERNAME,2,true);     
        euAccountList = EUR_CRM_DE_TestDummyData.creaEUAccount('testname', EUR_CRM_DE_TestDummyData.TEST_POSTAL , EUR_CRM_DE_TestDummyData.DE_EUACCOUNT_RECORD_TYPE_DEVELOPERNAME , customerTaxonomyList[0].Id,2,true);
      
    }

    static testMethod void testretrieveTargetOwnersSRLevel(){
        offtradeRegionalUsers = EUR_CRM_DE_TestDummyData.getUser(EUR_CRM_DE_TestDummyData.DE_OFF_TRADE_USER_PROFILE, 
                                            EUR_CRM_DE_TestDummyData.REGIONAL_OFF_TRADE_MANAGER_ROLE,'testdezxc@testemail.com', 'testdezxc@testemail.com', 'testdezxc',2,true);

        system.runAs(offtradeRegionalUsers[0]){   
            createTestData();      
            EUR_CRM_AbstractOPTargetManagement.retrieveTargetOwnersSRLevel(customerTaxonomyList[0].Id,true);
            EUR_CRM_AbstractOPTargetManagement.retrieveTargetOwnersSRLevel(customerTaxonomyList[0].Id,false);
            EUR_CRM_AbstractOPTargetManagement.retrieveTargetOwnersRegionalLevel(customerTaxonomyList[0].Id);
        }
    }    
}