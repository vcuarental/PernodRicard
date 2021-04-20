/*
*    Description : Test class for EUR_CRM_TerritoryUpdateController
*
*    Version    Author        Date        Description
*    1.0        Sid           01/19/2105  Initial Draft
*/

@isTest
public class EUR_CRM_TerritoryUpdateControllerTest {

    static RecordType regionRecType = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Region__c' AND DeveloperName = 'EUR_MA_Region' LIMIT 1];
    static RecordType territoryRecType = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Territory__c' AND DeveloperName = 'EUR_MA_Territory' LIMIT 1];
    static RecordType territoryRecType2 = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Territory__c' AND DeveloperName = 'EUR_DK_Territory' LIMIT 1];
    static RecordType territoryRecType3 = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Territory__c' AND DeveloperName = 'EUR_BG_Territory' LIMIT 1];
    static RecordType accountRecType = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Account__c' AND DeveloperName = 'EUR_MA_On_Trade' LIMIT 1];
    static RecordType accountRecType2 = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Account__c' AND DeveloperName = 'EUR_DK_On_Trade' LIMIT 1];
    static RecordType accountRecType3 = [SELECT Id FROM RecordType WHERE SobjectType='EUR_CRM_Account__c' AND DeveloperName = 'EUR_BG_On_Trade' LIMIT 1];

    public static testMethod void massUpdateAccountsTest(){
        
        //Create Test Data for Region (EU)
        EUR_CRM_Region__c objRegion = new EUR_CRM_Region__c();
        objRegion.EUR_CRM_Channel__c = 'ON TRADE';
        objRegion.RecordTypeId = regionRecType.Id;
        insert objRegion;
        
        //Create Test Data for Territory (EU)
        EUR_CRM_Territory__c objTerritory = new EUR_CRM_Territory__c();
        objTerritory.EUR_CRM_Region__c = objRegion.Id;
        objTerritory.RecordTypeId = territoryRecType.Id;
        objTerritory.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();

        EUR_CRM_Territory__c objTerritory2 = new EUR_CRM_Territory__c();
        objTerritory2.EUR_CRM_Region__c = objRegion.Id;
        objTerritory2.RecordTypeId = territoryRecType2.Id;
        objTerritory2.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        
        EUR_CRM_Territory__c objTerritory3 = new EUR_CRM_Territory__c();
        objTerritory3.EUR_CRM_Region__c = objRegion.Id;
        objTerritory3.RecordTypeId = territoryRecType3.Id;
        objTerritory3.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        
        List<EUR_CRM_Territory__c> objTerritoryList = new List<EUR_CRM_Territory__c>();
        objTerritoryList.add(objTerritory);
        objTerritoryList.add(objTerritory2);
        objTerritoryList.add(objTerritory3);
        
        insert objTerritoryList;
        
        //Create Test Data for Account (EU)
        EUR_CRM_Account__c objAccount = new EUR_CRM_Account__c();
        objAccount.RecordTypeId = accountRecType.Id;
        objAccount.EUR_CRM_Territory__c = objTerritory.Id;
        objAccount.EUR_CRM_Postal_Code__c = '112233';

        EUR_CRM_Account__c objAccount2 = new EUR_CRM_Account__c();
        objAccount2.RecordTypeId = accountRecType2.Id;
        objAccount2.EUR_CRM_Territory__c = objTerritory2.Id;
        objAccount2.EUR_CRM_Postal_Code__c = '112233';

        EUR_CRM_Account__c objAccount3 = new EUR_CRM_Account__c();
        objAccount3.RecordTypeId = accountRecType3.Id;
        objAccount3.EUR_CRM_Territory__c = objTerritory3.Id;
        objAccount3.EUR_CRM_Postal_Code__c = '112233';

        List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
        accountList.add(objAccount);
        accountList.add(objAccount2);
        accountList.add(objAccount3);

        insert accountList;

        test.startTest();
        
            PageReference pRef = Page.EUR_CRM_MassUpdateAccountTerritoryPage;
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objTerritory);
            EUR_CRM_TerritoryUpdateController objCtrl = new EUR_CRM_TerritoryUpdateController(stdCtrl);
            test.setCurrentPageReference(pRef);
            
            objCtrl.massUpdateAccounts();
        
            ApexPages.StandardController stdCtrl2 = new ApexPages.StandardController(objTerritory2);
            EUR_CRM_TerritoryUpdateController objCtrl2 = new EUR_CRM_TerritoryUpdateController(stdCtrl2);
            objCtrl2.massUpdateAccounts();
            
            ApexPages.StandardController stdCtrl3 = new ApexPages.StandardController(objTerritory3);
            EUR_CRM_TerritoryUpdateController objCtrl3 = new EUR_CRM_TerritoryUpdateController(stdCtrl3);
            objCtrl3.massUpdateAccounts();
        
        test.stopTest();                
    }

    public static testMethod void EUR_CRM_TerritoryOwner_UpdateController_Test(){

//        //Create Test Data for Region (EU)
//        EUR_CRM_Region__c objRegion = new EUR_CRM_Region__c();
//        objRegion.EUR_CRM_Channel__c = 'ON TRADE';
//        insert objRegion;
//
//        //Create Test Data for Territory (EU)
//        EUR_CRM_Territory__c objTerritory = new EUR_CRM_Territory__c();
//        objTerritory.EUR_CRM_Region__c = objRegion.Id;
//        objTerritory.RecordTypeId = territoryRecType.Id;
//        objTerritory.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
//
//        EUR_CRM_Territory__c objTerritory2 = new EUR_CRM_Territory__c();
//        objTerritory2.EUR_CRM_Region__c = objRegion.Id;
//        objTerritory2.RecordTypeId = territoryRecType2.Id;
//        objTerritory2.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
//
//        EUR_CRM_Territory__c objTerritory3 = new EUR_CRM_Territory__c();
//        objTerritory3.EUR_CRM_Region__c = objRegion.Id;
//        objTerritory3.RecordTypeId = territoryRecType3.Id;
//        objTerritory3.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
//
//        List<EUR_CRM_Territory__c> objTerritoryList = new List<EUR_CRM_Territory__c>();
//        objTerritoryList.add(objTerritory);
//        objTerritoryList.add(objTerritory2);
//        objTerritoryList.add(objTerritory3);
//
//        insert objTerritoryList;
//
//        //Create Test Data for Account (EU)
//        EUR_CRM_Account__c objAccount = new EUR_CRM_Account__c();
//        objAccount.EUR_CRM_Territory__c = objTerritory.Id;
//        objAccount.EUR_CRM_Postal_Code__c = '112233';
//
//        EUR_CRM_Account__c objAccount2 = new EUR_CRM_Account__c();
//        objAccount2.EUR_CRM_Territory__c = objTerritory2.Id;
//        objAccount2.EUR_CRM_Postal_Code__c = '112233';
//
//        EUR_CRM_Account__c objAccount3 = new EUR_CRM_Account__c();
//        objAccount3.EUR_CRM_Territory__c = objTerritory3.Id;
//        objAccount3.EUR_CRM_Postal_Code__c = '112233';
//
//        List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
//        accountList.add(objAccount);
//        accountList.add(objAccount2);
//        accountList.add(objAccount3);
//
//        insert accountList;

        test.startTest();

        EUR_CRM_TerritoryOwner_UpdateController objCtrl = new EUR_CRM_TerritoryOwner_UpdateController();
        objCtrl.countryFilter = 'GB';
        objCtrl.excludeRecordTypesFilter = 'EUR_GB_FS_Blitz';
        objCtrl.includeRecordTypesFilter = 'EUR_GB_FS_Indirect';
        objCtrl.extraQueryFilter = 'ORDER BY RecordType.DeveloperName';

        objCtrl.executeMassAccountOwnerUpdate();

        test.stopTest();
    }
}