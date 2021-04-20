@isTest (SeeAllData = false)
private with sharing class EUR_CRM_DE_TestPrestigeAccountHndlr{

    //create 2 territories
    static EUR_CRM_Territory__c onTradeTerritory;
    static EUR_CRM_Territory__c prestigeTerritory; 
    static User onTradeUser;
    static User prestigeUser;
    static User regionUser;
    
    public static void initData(){  
        onTradeUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_GSL_South', 'sdad2323asd@sales.com', 'salesagentNorth@sales.com', 'accTest12990');
        prestigeUser = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_GSL_Prestige', 'asdasd23@sales.com', 'salesagentSouth@sales.com', 'accTest13990');
        regionUser= EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_Regional_Sales_Manager_On_Trade_North_East', 'asdasd23@sales.com', 'adsdas23213@sales.com', 'accTest19490');
        system.runAs(regionUser){
            EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', regionUser.Id,'DE Region');
            
            onTradeTerritory= EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory' , onTradeUser.id, region.id, 'DE Territory');
            prestigeTerritory= EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory' , prestigeUser.id, region.id, 'DE Territory');
            
            EUR_CRM_Postal_Code_Territory_Mapping__c onTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('123123', '12345' , onTradeTerritory.id, 'DE On Trade Postal Code - Territory Mapping');
            EUR_CRM_Postal_Code_Territory_Mapping__c prestigeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('asdasdqwe', '12345' , prestigeTerritory.id, 'DE On Trade Prestige Postal Code - Territory Mapping');
          
        }        
    }
    
    public testmethod static void testPrestige(){
        initData();
        System.runAs(regionUser){           
                
           Test.startTest();
           EUR_CRM_Account__c accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount('euAccount1 ', '12345' , 'DE ON Gastronomy', null);
           accountEU.EUR_CRM_Is_Prestige_Account__c = true;
           accountEU.EUR_CRM_Status_of_Customer__c= 'Active';
            try{
                update accountEU;
            }catch(Exception e){
                
            }
           
           accountEU.EUR_CRM_Is_Prestige_Account__c = false;
           try{
                update accountEU;
            }catch(Exception e){
                
            }
            Test.stopTest();
       }
    
    }
    
    

}