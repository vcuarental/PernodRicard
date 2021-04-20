/*********************************************************************************
 * Name: ASI_CRM_SG_BottleIncentiveGenerationTest
 * Description: Test class for ASI_CRM_SG_GenBottleIncentiveBatch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/02/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_SG_BottleIncentiveGenerationTest {
	@testSetup
	public static void setupTestData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();

        List<ASI_MFM_Sub_brand__c> subBrand = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();

        ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        for(integer i = 0 ; i < 2 ; i++) {
        	ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer);
        	contractData.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
			contractData.contract.ASI_CRM_Contract_Exist_Before_RTM__c = true;
            contractList.add(contractData.contract);
        }
        insert contractList;
        
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            for(ASI_MFM_SKU_Code__c sku : skuList) {
                ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contract, sku);
                contractTargetData.contractTarget.ASI_CRM_Subbrand__c = subBrand[0].Id;
                contractTargetList.add(contractTargetData.contractTarget);
            }
        }
        insert contractTargetList;

        ASI_CRM_SG_TestClassHelper.offtakeData offtakeData = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractList[0].Id, customerData.customer.Id, skuList[0].Id);
        offtakeData.offtake.ASI_CRM_FromWS__c = customerData.customer.Id;
        offtakeData.offtake.ASI_TH_CRM_Sub_brand__c = subBrand[0].Id;
        insert offtakeData.offtake;
	}

	public static testmethod void testBatch() {
		Date todayDate = Date.today();

		String fromMonth = String.valueOf(todayDate.month());
		String fromYear  = String.valueOf(todayDate.year());
		String toMonth   = String.valueOf(todayDate.month());
		String toYear    = String.valueOf(todayDate.year());
		ASI_CRM_SG_GenBottleIncentiveBatch genBottleIncentiveBatch = new ASI_CRM_SG_GenBottleIncentiveBatch(fromMonth, fromYear, toMonth, toYear);
		Database.executeBatch(genBottleIncentiveBatch);
	}
}