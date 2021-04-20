/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for 
                    EUR_CRM_DE_PrestigeAccountHandler
                    EUR_CRM_DE_TerritoryAccountHandler
                    EUR_CRM_DE_TerritoryUpdateController
History
28/04/2014        IPC     Created
01/07/2014        IPC     REnamed
01/08/2014        IPC     REnamed
------------------------------------------------------------*/
@isTest
public with sharing class EUR_CRM_DE_TestTerritoryManagement  {

   private static EUR_CRM_Region__c testRegion;
   private static EUR_CRM_Territory__c onTradeTerritory;
   private static EUR_CRM_Territory__c onTradePrestigeTerritory;
   private static EUR_CRM_Territory__c offTradeTerritory;
   private static EUR_CRM_Postal_Code_Territory_Mapping__c onTradeTerritoryMapping;
   private static EUR_CRM_Postal_Code_Territory_Mapping__c onTradePrestigeTerritoryMapping;
   private static EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping;
   private static EUR_CRM_Customer_Taxonomy__c customerTaxonomy;
   private static EUR_CRM_Account__c onTradeEUAccount;
   private static EUR_CRM_Account__c offTradeEUAccount;
   private static final String postalCode = '12345';
   private static User prestigeUser ;
   private static User onTradeUser ;
    static void setUpUsers(){
        prestigeUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser12390@test.com', 'testuser12390@test.com', 'test89844');
        onTradeUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');

    }
    static void dataSetUp(){
         testRegion = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', onTradeUser.id,'DE Region');
        onTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('onTradeTerritory' , onTradeUser.id, testRegion.id, 'DE Territory');
        onTradePrestigeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('onTradePrestigeTerritory' , prestigeUser.id, testRegion.id, 'DE Territory');
        offTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory' , onTradeUser.id, testRegion.id, 'DE Territory');

        onTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('onTradeTerritoryMapping ', postalCode , onTradeTerritory.id, 'DE On Trade Postal Code - Territory Mapping');
        onTradePrestigeTerritoryMapping= EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('onTradePrestigeTerritoryMapping', postalCode , onTradePrestigeTerritory.id, 'DE On Trade Prestige Postal Code - Territory Mapping');
        offTradeTerritoryMapping= EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', postalCode , offTradeTerritory.id, 'DE Off Trade Postal Code - Territory Mapping');

        customerTaxonomy= EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('customerTaxonomy' ,onTradeUser.id, 'DE Customer Taxonomy');

    }
    static testmethod void testOnTrade(){
        setUpUsers();
        System.runAs(onTradeUser){

            Test.startTest();
            dataSetUp();
                  createTemplate(customerTaxonomy.id);

                onTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', postalCode , 'DE ON Gastronomy', customerTaxonomy.id);
             Test.stopTest();
        }
    }
    static testmethod void testOffTrade(){
        setUpUsers();
        System.runAs(onTradeUser){

        Test.startTest();
        dataSetUp();
            offTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', postalCode , 'DE OFF STD', customerTaxonomy.id);
        Test.stopTest();
        }
    }
    static testmethod void testOnTradeUpdatePrestige(){
        setUpUsers();
        System.runAs(onTradeUser){

        Test.startTest();
        dataSetUp();
            onTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', postalCode , 'DE ON Gastronomy', customerTaxonomy.id);
            onTradeEUAccount.EUR_CRM_Is_Prestige_Account__c = true;
            update onTradeEUAccount;
        Test.stopTest();}
    }
    static testmethod void testOnTradeCreatePrestige(){
        setUpUsers();
        System.runAs(onTradeUser){

        Test.startTest();
        dataSetUp();
            onTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaPrestigeEUAccount('euAccount ', postalCode , 'DE ON Gastronomy', customerTaxonomy.id);
            onTradeEUAccount.EUR_CRM_Is_Prestige_Account__c = false;
            update onTradeEUAccount;

        Test.stopTest();
        }
    }
    @IsTest
    static void testOnTradeCreatePrestige2(){
        setUpUsers();
        System.runAs(onTradeUser){

        Test.startTest();
        dataSetUp();
            onTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaPrestigeEUAccount('euAccount ', postalCode , 'DE OFF STD', customerTaxonomy.id);
        Test.stopTest();
        }
    }
    static testmethod void testOnTradeWrongPostal(){
        setUpUsers();
        System.runAs(onTradeUser){

            Test.startTest();
            dataSetUp();
                try{
                EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', '88889', 'DE ON Gastronomy', customerTaxonomy.id);
                }catch(Exception e){

                }
            Test.stopTest();
        }
    }



    static testmethod void testTerritoryOwnerUpdateController(){
        setUpUsers();
        System.runAs(onTradeUser){

        Test.startTest();
            dataSetUp();
            offTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', postalCode , 'DE OFF STD', customerTaxonomy.id);
            Apexpages.StandardController sc = new Apexpages.standardController(offTradeTerritory);
            EUR_CRM_DE_TerritoryUpdateController c = new EUR_CRM_DE_TerritoryUpdateController(sc);
            c.massUpdateGermanyAccounts();
        Test.stopTest();
        }
    }

    private static EUR_CRM_JB_Template__c createTemplate(Id custId){
        EUR_CRM_JB_Template__c template = new EUR_CRM_JB_Template__c(
        Name = 'test',
        RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_JB_Template__c','DE OFF-Trade Template'),
        EUR_CRM_Customer_Taxonomy__c = custId,
        EUR_CRM_Module__c = 'Module 2 x 1m'
        );
        insert template ;
        return template;
    }
}