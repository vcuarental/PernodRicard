/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_AccountHandler Class.
  @Author:      IPC
  @History:     AUG.1.2014 - Created
*/
@isTest (SeeAllData=true)
private with sharing class EUR_CRM_DE_TestAccountHandler{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy;
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy2;
    private static EUR_CRM_ObjPromo__c objPromo;
    private static EUR_CRM_ObjPromo_Account_Mapping__c aMapping;
    private static User onTradeUser ;
    private static EUR_CRM_Region__c testRegion;
    private static EUR_CRM_Territory__c offTradeTerritory;
    private static EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping;
    private static EUR_CRM_Postal_Code_Territory_Mapping__c onTradeTerritoryMapping;
    private static EUR_CRM_Territory__c onTradeTerritory;
    private static EUR_CRM_OP_Action_List_Template__c actionListTemplate;
    
    static void setUpUsers(){
        onTradeUser = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        insert onTradeUser;
    }
    
    static void dataInsert1(){
        testRegion = EUR_CRM_TestClassUtilityHelper.createRegion('region 1', UserInfo.getUserId(),'EUR_DE_Region');
        insert testRegion;
        onTradeTerritory = EUR_CRM_TestClassUtilityHelper.createTerritory('onTradeTerritory' , UserInfo.getUserId(), testRegion.id, 'EUR_DE_Territory');
        offTradeTerritory = EUR_CRM_TestClassUtilityHelper.createTerritory('offTradeTerritory' , UserInfo.getUserId(), testRegion.id, 'EUR_DE_Territory');
        insert new List<EUR_CRM_Territory__c>{onTradeTerritory, offTradeTerritory};
        offTradeTerritoryMapping = EUR_CRM_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', '12345' , onTradeTerritory.id, 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping');
        onTradeTerritoryMapping = EUR_CRM_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', '12345' , onTradeTerritory.id, 'EUR_DE_On_Trade_Postal_Code_Territory_Mapping');
        insert new List<EUR_CRM_Postal_Code_Territory_Mapping__c>{offTradeTerritoryMapping, onTradeTerritoryMapping};
        custTaxonomy = EUR_CRM_TestClassUtilityHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'EUR_DE_Customer_Taxonomy');
        custTaxonomy2 = EUR_CRM_TestClassUtilityHelper.createCustomerTaxonomy('test taxonomy2', UserInfo.getUserId(), 'EUR_DE_Customer_Taxonomy');
        insert new List<EUR_CRM_Customer_Taxonomy__c>{custTaxonomy, custTaxonomy2};
        system.assertNotEquals(custTaxonomy, null);

        //system.assertNotEquals(custTaxonomy2, null);
        //actionListTemplate = EUR_CRM_DE_TestClassUtilityHelper.createActionTemplate(1,'DE_OFF_ALT_Tasting','DE O/P Action List Template')[0];
        //insert actionListTemplate;
        
        objPromo = EUR_CRM_TestClassUtilityHelper.createObjPromo('EUR_DE_Off_Trade_Trade_Fair','objPromoTest', 'Active');
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today().addDays(1);
        objPromo.EUR_CRM_Active_End_Date__c = Date.today().addDays(7);
        //objPromo.EUR_CRM_Customer_Taxonomy__c = custTaxonomy.Id;
        insert objPromo;
        objPromo.EUR_CRM_Status__c = 'Active';
        update objPromo;

        EUR_CRM_OP_Customer_Taxonomy_Mapping__c mapping = EUR_CRM_TestClassUtilityHelper.createCustomerTaxonomyMapping(custTaxonomy2.Id, objPromo.id);
        insert mapping;
        System.assertNotEquals(objPromo, null);
    }
    
    static testMethod void testMapping(){
        setUpUsers();
        System.runAs(onTradeUser){
            Test.startTest();
                
                dataInsert1();
        //        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountEU('euAccount1 ', '12345' , 'EUR_DE_OFF_STD', custTaxonomy.Id);
                
         //       aMapping = new EUR_CRM_ObjPromo_Account_Mapping__c();
         //       aMapping.EUR_CRM_Account__c = accountEU.Id;
         //       aMapping.EUR_CRM_ObjPromo__c = objPromo.Id;
                //insert aMapping;
            Test.stopTest();
        }
    }
    
    static testMethod void testOffTrade(){
        setUpUsers();
        System.runAs(onTradeUser){
            Test.startTest();
                dataInsert1();
                
                //objPromo.EUR_CRM_Customer_Taxonomy__c = custTaxonomy2.Id;
                //update objPromo;
                accountEU = EUR_CRM_TestClassUtilityHelper.createAccountEU('euAccount1 ', '12345', null, null, null, 'EUR_DE_OFF_STD', custTaxonomy.Id);
                insert accountEU;
                accountEU.EUR_CRM_Status_of_Customer__c = 'Active';
                accountEU.EUR_JB_Customer_Taxonomy__c = custTaxonomy2.Id;
                update accountEU;
            Test.stopTest();
        }
    }
    
    static testMethod void testOnTrade(){
        setUpUsers();
        System.runAs(onTradeUser){
            Test.startTest();
                dataInsert1();
                
                accountEU = EUR_CRM_TestClassUtilityHelper.createAccountEU('euAccount1 ', '12345', null, null, null, 'EUR_DE_ON_Consumers', custTaxonomy.Id);
                insert accountEU;                
                accountEU.EUR_JB_Customer_Taxonomy__c = custTaxonomy2.Id;
                accountEU.EUR_CRM_Territory__c = offTradeTerritory.Id;
                accountEU.EUR_CRM_Status_of_Customer__c = 'Active';
                update accountEU;
            Test.stopTest();
        }
    }
}