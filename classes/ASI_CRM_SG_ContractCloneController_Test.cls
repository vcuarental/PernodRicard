/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController_Test
 * Created : Vincent Lam
 * Revision History:
 * 1. 26 Apr 2016 - Created
 * 2. 03 Aug 2016 - Updated. Add test setup function
 **********************************************************************************/

@isTest
private class ASI_CRM_SG_ContractCloneController_Test{
    
    @TestSetup
    public static void setupTestData() {
    	ASI_CRM_SG_TestClassHelper.createDataSettings();

        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(false);
        ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(false, customerC.customer);
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        customerList.add(customerC.customer);
        customerList.add(customerC2.customer);
        insert customerList;

        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(false, customerC.customer);
        ASI_CRM_SG_TestClassHelper.contractData contractC2 = new ASI_CRM_SG_TestClassHelper.contractData(false, customerC2.customer, 'Approved');
        
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        contractList.add(contractC.contract);
        contractList.add(contractC2.contract);
        insert contractList;

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(0));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(1));

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC3 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC2.contract, skuList.get(0));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC4 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC2.contract, skuList.get(1));
    
        List<ASI_CRM_ContractTarget__c> contractTarget = new List<ASI_CRM_ContractTarget__c>();
        contractTarget.add(contractTargetC1.contractTarget);
        contractTarget.add(contractTargetC2.contractTarget);
        contractTarget.add(contractTargetC3.contractTarget);
        contractTarget.add(contractTargetC4.contractTarget);
        insert contractTarget;
    }
    
    static testMethod void testRenew() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
        pageRef.getParameters().put('id',contract.id);
        pageRef.getParameters().put('copy', '0');
        System.Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(contract);

        ASI_CRM_SG_ContractCloneController controller =
            new ASI_CRM_SG_ContractCloneController(stdController);
            
        System.Test.startTest();
            controller.cloneContracts();
        System.Test.stopTest();
    }

    static testMethod void testCopy() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
        pageRef.getParameters().put('id',contract.id);
        pageRef.getParameters().put('copy', '1');
        System.Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(contract);

        ASI_CRM_SG_ContractCloneController controller =
            new ASI_CRM_SG_ContractCloneController(stdController);
            
        System.Test.startTest();
            controller.cloneContracts();
        System.Test.stopTest();
    }

    static testMethod void testRevise() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c = 'Contract Approved' LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
        pageRef.getParameters().put('id',contract.id);
        pageRef.getParameters().put('copy', '2');
        System.Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(contract);

        ASI_CRM_SG_ContractCloneController controller =
            new ASI_CRM_SG_ContractCloneController(stdController);
            
        System.Test.startTest();
            controller.cloneContracts();
        System.Test.stopTest();
    }

    static testMethod void testConvert() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractClonePage;
        pageRef.getParameters().put('id',contract.id);
        pageRef.getParameters().put('copy', '3');
        System.Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController =
            new ApexPages.StandardController(contract);

        ASI_CRM_SG_ContractCloneController controller =
            new ASI_CRM_SG_ContractCloneController(stdController);
            
        System.Test.startTest();
            controller.cloneContracts();
        System.Test.stopTest();
    }

}