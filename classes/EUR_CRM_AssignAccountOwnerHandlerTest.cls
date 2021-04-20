/*
*    Description : Test class for EUR_CRM_AssignAccountOwnerHandler
*
*    Version    Author        Date        Description
*    1.0        Sid           01/19/2105  Initial Draft
*/

@isTest
public class EUR_CRM_AssignAccountOwnerHandlerTest {

    static RecordType regionRecType = [select Id from RecordType where SobjectType='EUR_CRM_Region__c' and DeveloperName = 'EUR_MA_Region' LIMIT 1];
    static RecordType territoryRecType = [select Id from RecordType where SobjectType='EUR_CRM_Territory__c' and DeveloperName = 'EUR_MA_Territory' LIMIT 1];
    static RecordType accountRecType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_MA_On_Trade' LIMIT 1];

    public static testMethod void beforeInsertAccountTest(){
        
        //Create Test Data for Region (EU)
        EUR_CRM_Region__c objRegion = new EUR_CRM_Region__c();
        objRegion.EUR_CRM_Channel__c = 'ON TRADE';
        objRegion.recordTypeId = regionRecType.Id;
        insert objRegion;
        
        //Create Test Data for Territory (EU)
        EUR_CRM_Territory__c objTerritory = new EUR_CRM_Territory__c();
        objTerritory.EUR_CRM_Region__c = objRegion.Id;
        objTerritory.recordTypeId = territoryRecType.Id;
        objTerritory.EUR_CRM_Territory_Owner__c = UserInfo.getUserId();
        insert objTerritory;
        
        //Create Test Data for Account (EU)
        EUR_CRM_Account__c objAccount = new EUR_CRM_Account__c();
        objAccount.recordTypeId = accountRecType.Id;
        objAccount.EUR_CRM_Territory__c = objTerritory.Id;
        
        test.startTest();
            insert objAccount;
        test.stopTest();
    }
    
    public static testMethod void beforeUpdateAccountTest(){
        
        //Create Test Data for Region (EU)
        EUR_CRM_Region__c objRegion = new EUR_CRM_Region__c();
        objRegion.EUR_CRM_Channel__c = 'ON TRADE';
        objRegion.recordTypeId = regionRecType.Id;
        insert objRegion;
        
        //Create Test Data for Territory (EU)
        EUR_CRM_Territory__c objTerritory = new EUR_CRM_Territory__c();
        objTerritory.EUR_CRM_Region__c = objRegion.Id;
        objTerritory.recordTypeId = territoryRecType.Id;
        insert objTerritory;
        
        //Create Test Data for Account (EU)
        EUR_CRM_Account__c objAccount = new EUR_CRM_Account__c();
        objAccount.recordTypeId = accountRecType.Id;
        objAccount.EUR_CRM_Territory__c = objTerritory.Id;
        insert objAccount;
        
        test.startTest();
            objAccount.Name = 'test';
            update objAccount;
        test.stopTest();
    }    
}