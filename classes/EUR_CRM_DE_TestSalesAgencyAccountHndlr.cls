/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_SalesAgencyAccountHandler Class.
  @Author:      IPC
  @History:     SEPT.26.2014 - Created
*/
@isTest (SeeAllData = false)
private with sharing class EUR_CRM_DE_TestSalesAgencyAccountHndlr{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy;
    private static User accountUserNorth;
    private static User accountUserSouth;
    private static User accountUserWest;
    private static EUR_CRM_Territory__c offTradeTerritory;
     
    static void dataInsert1(){
        accountUserNorth = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_Regional_Sales_Manager_Off_Trade_North_East', 'salesagentNorth@sales.com', 'salesagentNorth@sales.com', 'accTest1990');
        accountUserSouth = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_Regional_Sales_Manager_Off_Trade_South', 'salesagenSouth@sales.com', 'salesagentSouth@sales.com', 'accTest1990');
        accountUserWest = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_Regional_Sales_Manager_Off_Trade_West', 'salesagentWest@sales.com', 'salesagentWest@sales.com', 'accTest1990');
        
        System.runAs(accountUserNorth){
            EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', accountUserNorth.Id,'DE Region');
            
            offTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory' , UserInfo.getUserId(), region.id, 'DE Territory');
            
            EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', '12345' , offTradeTerritory.id, 'DE Off Trade Postal Code - Territory Mapping');
            
            custTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'DE Customer Taxonomy');
            system.assertNotEquals(custTaxonomy, null);
        }
    }
    
    static testMethod void testAccountShareNorth(){
        dataInsert1();
        System.runAs(accountUserNorth){
            Test.startTest();
                
                accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount1 ', '12345' , 'DE OFF STD', custTaxonomy.Id);
                accountEU.EUR_CRM_Status_of_Customer__c= 'Agency Managed';
                update accountEU;
            Test.stopTest();
        }
    }
    
    static testMethod void testAccountShareSouth(){
        dataInsert1();
        System.runAs(accountUserSouth){
            Test.startTest();
                
                accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount1 ', '12345' , 'DE OFF STD', custTaxonomy.Id);
                accountEU.EUR_CRM_Status_of_Customer__c= 'Agency Managed';
                update accountEU;
            Test.stopTest();
        }
    }
    
    static testMethod void testAccountShareWest(){
        dataInsert1();
        System.runAs(accountUserSouth){
            Test.startTest();
                
                accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount1 ', '12345' , 'DE OFF STD', custTaxonomy.Id);
                accountEU.EUR_CRM_Status_of_Customer__c= 'Agency Managed';
                update accountEU;
            Test.stopTest();
        }
    }
    
    static testMethod void testAccountShareNotSAgent(){
        dataInsert1();
        System.runAs(accountUserSouth){
            Test.startTest();
                
                accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount1 ', '12345' , 'DE OFF STD', custTaxonomy.Id);
                accountEU.EUR_CRM_Status_of_Customer__c= 'Inactive';
                update accountEU;
            Test.stopTest();
        }
    }
}