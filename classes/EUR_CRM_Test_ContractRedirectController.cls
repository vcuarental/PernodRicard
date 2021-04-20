@isTest
public class EUR_CRM_Test_ContractRedirectController {
	
    public static testmethod void testRedirect() {
        RecordType contractDERecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Contract__c' and DeveloperName = 'EUR_DE_Contract' LIMIT 1];
        RecordType contractDKRecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Contract__c' and DeveloperName = 'EUR_DK_Contract' LIMIT 1];
        
        RecordType accountDERecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Account__c' and DeveloperName = 'EUR_DE_ON_Consumers' LIMIT 1];
        RecordType accountDKRecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Account__c' and DeveloperName = 'EUR_DK_On_Trade' LIMIT 1];
        
        EUR_CRM_Account__c accountDE = new EUR_CRM_Account__c();
        accountDE.recordType = accountDERecordType;
        
        EUR_CRM_Account__c accountDK = new EUR_CRM_Account__c();
        accountDK.recordType = accountDKRecordType;
        
        List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
        accountList.add(accountDE);
        accountList.add(accountDK);
        insert accountList;
        
        EUR_CRM_Contract__c contractDE = new EUR_CRM_Contract__c();
        contractDE.EUR_CRM_Account__c = accountDE.Id;
        contractDE.RecordTypeId = contractDERecordType.Id;
        contractDE.EUR_CRM_Start_Date__c = Date.Today();

        
        EUR_CRM_Contract__c contractDK = new EUR_CRM_Contract__c();
        contractDK.EUR_CRM_Account__c = accountDE.Id;
        contractDK.RecordTypeId = contractDKRecordType.Id;
        contractDK.EUR_CRM_Start_Date__c = Date.Today();
        contractDK.EUR_CRM_End_Date__c = Date.Today().addDays(365);
   
        List<EUR_CRM_Contract__c> contractList = new List<EUR_CRM_Contract__c>();
        contractList.add(contractDE);
        contractList.add(contractDK);
        insert contractList;

       	Test.startTest();
        	ApexPages.StandardController stdControllerDE = new ApexPages.StandardController(contractDE);
        	EUR_CRM_ContractRedirectController controllerDE = new EUR_CRM_ContractRedirectController(stdControllerDE);
        	controllerDE.redirectPage();
        
        	ApexPages.StandardController stdControllerDK = new ApexPages.StandardController(contractDK);
        	EUR_CRM_ContractRedirectController controllerDK = new EUR_CRM_ContractRedirectController(stdControllerDK);
        	controllerDK.redirectPage();
       	Test.stopTest();
        
    }
    
}