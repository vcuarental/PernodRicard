@isTest
public class EUR_CRM_DK_TestContractPageController {
	
    public static testmethod void testContractPageController() {
        RecordType contractDKRecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Contract__c' and DeveloperName = 'EUR_DK_Contract' LIMIT 1];
        RecordType accountDKRecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Account__c' and DeveloperName = 'EUR_DK_On_Trade' LIMIT 1];
        RecordType mechanicDKRecordType = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Mechanic_Type__c' and DeveloperName = 'EUR_DK_Mechanic_Type' LIMIT 1];
        
        EUR_CRM_Account__c accountDK = new EUR_CRM_Account__c();
        accountDK.recordType = accountDKRecordType;
        insert accountDK;
        
        EUR_CRM_Contract__c contractDK = new EUR_CRM_Contract__c();
        contractDK.EUR_CRM_Account__c = accountDK.Id;
        contractDK.RecordTypeId = contractDKRecordType.Id;
        contractDK.EUR_CRM_Start_Date__c = Date.Today();
        contractDK.EUR_CRM_End_Date__c = Date.Today().addDays(365);
        insert contractDK;
        
        EUR_CRM_Mechanic_Type__c mechanic = new EUR_CRM_Mechanic_Type__c();
        mechanic.Name = 'Pouring Wine';
        mechanic.RecordTypeId = mechanicDKRecordType.Id;
        insert mechanic; 
        
        EUR_CRM_Contract__c emptyContract = new EUR_CRM_Contract__c();
        
        Test.startTest();
        	ApexPages.StandardController stdController = new ApexPages.StandardController(contractDK);
        	EUR_CRM_DK_ContractPageController controller = new EUR_CRM_DK_ContractPageController(stdController);
        	String mechanicTypesIdsString = controller.mechanicTypesIdsString;
        	controller.getMechanicTypes();
        
        	ApexPages.StandardController stdController2 = new ApexPages.StandardController(emptyContract);
        	EUR_CRM_DK_ContractPageController controller2 = new EUR_CRM_DK_ContractPageController(stdController);
       	Test.stopTest();
    }
    
}