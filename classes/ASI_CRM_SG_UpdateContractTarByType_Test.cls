/***************************************************************************************************************************
 * Name:		ASI_CRM_SG_UpdateContractTarByType_Test
 * Description:	
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 2017-11-XX		Jeffrey Cheung          Created				
 ****************************************************************************************************************************/
@isTest
private class ASI_CRM_SG_UpdateContractTarByType_Test {
    @TestSetup
    public static void setupTestData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        //contractC1.contract.ASI_CRM_Type__c = 'Open';
        ASI_CRM_SG_TestClassHelper.contractData contractC2 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        contractC2.contract.ASI_CRM_Type__c = 'Partner';

        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        contractList.add(contractC1.contract);
        contractList.add(contractC2.contract);
        insert contractList;

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC1.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC2.contract, skuList.get(2));

        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        contractTargetList.add(contractTargetC1.contractTarget);
        contractTargetList.add(contractTargetC2.contractTarget);
        insert contractTargetList;
    }

    // modify contract type to meet coverage
	private static testMethod void test() {
        //ASI_TH_CRM_Contract__c openContract = [SELECT Id, ASI_CRM_Type__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_Type__c = 'Open' LIMIT 1];
        ASI_TH_CRM_Contract__c partnerContract = [SELECT Id, ASI_CRM_Type__c FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_Type__c = 'Key Account' LIMIT 1];
        
        //openContract.ASI_CRM_Type__c = 'Partner';
        partnerContract.ASI_CRM_Type__c = 'Partner';
        
        List<ASI_TH_CRM_Contract__c> contracts = new List<ASI_TH_CRM_Contract__c>();
        //contracts.add(openContract);
        contracts.add(partnerContract);
        update contracts;

	}
	
	

}