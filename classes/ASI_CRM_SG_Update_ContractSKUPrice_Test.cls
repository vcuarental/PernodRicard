/*********************************************************************************
 * Name: ASI_CRM_SG_Update_ContractSKUPrice_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 23/05/2016       Laputa:Hugo             Created
 * 03/08/2016		Laputa:Hugo 			Updated. Add test setup function
 *              
*/

@isTest
private class ASI_CRM_SG_Update_ContractSKUPrice_Test {
	
    @TestSetup
    public static void setupTestData() {
        
    }
    
	public static testmethod void testContractSKUPriceUpdate() {

		ASI_CRM_SG_TestClassHelper.createDataSettings();

		List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();

		ASI_CRM_SG_TestClassHelper.contractData contractD = new ASI_CRM_SG_TestClassHelper.contractData(true);
		ASI_CRM_SG_TestClassHelper.contractTargetData contractTarget1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractD.contract, skuList.get(0));
		ASI_CRM_SG_TestClassHelper.contractTargetData contractTarget2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractD.contract, skuList.get(1));

		System.Test.startTest();
        ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(
            Id = contractD.contract.Id,
            ASI_TH_CRM_Start_Date__c = date.today()
        );
		update contract;
		System.Test.stopTest();

	}

}