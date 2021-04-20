@isTest
private class ASI_CRM_SG_ContractAfterInsertTest {

	private static testMethod void test() {
		ASI_CRM_SG_TestClassHelper.createDataSettings();
		List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwith7PriceData();
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(false);
        contractC.contract.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        contractC.contract.ASI_TH_CRM_Contract_Status__c = 'Draft';
        insert contractC.contract;
        delete contractC.contract;
	}
        
        

}