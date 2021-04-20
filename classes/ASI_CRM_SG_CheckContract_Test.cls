/*********************************************************************************
 * Name:ASI_CRM_SG_CheckContract_Test
 * Description: Test class for ASI_CRM_SG_CheckContract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-29       Laputa: Hugo Cheung     Created
 * 2018-01-19       Wilken Leee     		[WL 2.0] Bug Fix to lock Start Date if there are transactions. Prevent invalid early termination of End Date
*********************************************************************************/

@isTest
public class ASI_CRM_SG_CheckContract_Test {
	
    @TestSetup
    public static void setupTestData() {
        
    }
    
	public static testmethod void testCheckContract() {
		
        ASI_CRM_SG_TestClassHelper.createDataSettings();
		
		List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 

		ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);

		ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
		ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractC1.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractC1.contract, skuList.get(2));
        
		ASI_CRM_SG_TestClassHelper.contractData contractC2 = new ASI_CRM_SG_TestClassHelper.contractData(false, customerC.customer);
		contractC2.contract.ASI_CRM_Converted_From__c = contractC1.contract.Id;
		insert contractC2.contract;

		ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC3 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractC2.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC4 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractC2.contract, skuList.get(2));
        
        Test.startTest();

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC5 = new ASI_CRM_SG_TestClassHelper.contractTargetData(true, contractC2.contract, skuList.get(0));

        Test.stopTest();
	}
	
	public static testmethod void testContractValidateDateChange() {
		
        ASI_CRM_SG_TestClassHelper.createDataSettings();
		
		ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);

		ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Yes');
		
		List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
		
		ASI_CRM_SG_TestClassHelper.offtakeData offtake = new ASI_CRM_SG_TestClassHelper.offtakeData(true, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, customerC.customer.Id, skuList.get(0).Id);		
		
		//ASI_CRM_SG_TestClassHelper.freeGoodsData foc = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, contractC1.contract, 'ASI_CRM_SG_FOC');
		
		ASI_CRM_SG_TestClassHelper.paymentData payment = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC1);
		
        Test.startTest();

		contractC1.contract.ASI_TH_CRM_Start_Date__c = date.today().adddays(30);
		
		try {
			//Test validation to block user to change contract start date
			update contractC1.contract;        
		}
		catch (Exception e){
		}

        Test.stopTest();
	}

}