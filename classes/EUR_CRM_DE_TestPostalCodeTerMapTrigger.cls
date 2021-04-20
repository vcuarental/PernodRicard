/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for 
                    EUR_CRM_UpdatePostalCodeTerritoryMappingName
History
04/08/2014      IPC     Created 
------------------------------------------------------------*/
@isTest
public class EUR_CRM_DE_TestPostalCodeTerMapTrigger{

 private static EUR_CRM_Region__c testRegion;
   private static EUR_CRM_Territory__c onTradeTerritory;
   private static EUR_CRM_Territory__c onTradeTerritory2; 
   private static EUR_CRM_Postal_Code_Territory_Mapping__c onTradeTerritoryMapping;
   private static EUR_CRM_Postal_Code_Territory_Mapping__c onTradeTerritoryMapping2; 
   private static EUR_CRM_Customer_Taxonomy__c customerTaxonomy;
   private static EUR_CRM_Account__c onTradeEUAccount; 
   private static final String postalCode = '12345';
   private static final String postalCode2 = '67890'; 
   private static User onTradeUser ;
    static void setUpUsers(){
         onTradeUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_National_Sales_Manager_Off_Trade', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
       
    }
    static void dataSetUp(){
         testRegion = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', onTradeUser.id,'DE Region');
        onTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('onTradeTerritory' , onTradeUser.id, testRegion.id, 'DE Territory');
        onTradeTerritory2 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('onTradeTerritory2' , onTradeUser.id, testRegion.id, 'DE Territory');
         
        onTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('onTradeTerritoryMapping ', postalCode , onTradeTerritory.id, 'DE On Trade Postal Code - Territory Mapping');
        //onTradeTerritoryMapping2 = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('onTradeTerritoryMapping2 ', postalCode2 , onTradeTerritory2.id, 'DE On Trade Postal Code - Territory Mapping');
          
        customerTaxonomy= EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('customerTaxonomy' ,onTradeUser.id, 'DE Customer Taxonomy');
        
    }
    static testmethod void testOnTrade(){
        setUpUsers();
        System.runAs(onTradeUser){
            
            Test.startTest();     
            dataSetUp();
                  createTemplate(customerTaxonomy.id);
         
                onTradeEUAccount = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount ', postalCode , 'DE ON Gastronomy', customerTaxonomy.id);
             onTradeTerritoryMapping.EUR_CRM_Territory__c = onTradeTerritory2.id;
             update onTradeTerritoryMapping;
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