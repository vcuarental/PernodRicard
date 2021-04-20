/*********************************************************************************
 * Name: ASI_CRM_VN_ContractTriggerTest
 * Description: Test class for all contract trigger class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created
 * 07/01/2019       Andy Zhang              Create settings
 * 03/05/2019       Wilken Lee              [WL 1.0] Test class fix for Extend Contract scenario
*/
@isTest
public class ASI_CRM_VN_ContractTriggerTest {
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
    	insert onTradeCustomer;

        //Create settings
        //Andy Zhang
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        //2019-01-07

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        insert contract;
    }
    
    public static testMethod void testDuplicationRule() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        List<ASI_CRM_VN_Contract__c> contractList = new List<ASI_CRM_VN_Contract__c>();
        for(Integer i = 0 ; i < 2 ; i++) {
        	ASI_CRM_VN_Contract__c duplicatedContract = ASI_CRM_VN_TestClassHelper.createContract(contract.ASI_CRM_Outlet_WS__c, contract.ASI_CRM_Key_Brand__c);
            contractList.add(duplicatedContract);
        }
        
        try {
            insert contractList;
        } catch(Exception e) {
        }
  	}
    
    public static testMethod void testDelete() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        delete contract;
    }
    
    public static testMethod void testLockChildRecord() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_MFM_SKU_Code__c sku         = [SELECT Id FROM ASI_MFM_SKU_Code__c LIMIT 1];
        
        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        insert contractExpenditure;
        
        contract.ASI_CRM_Contract_Status__c = 'Submitted';
        update contract;
    }

    public static testMethod void testExtendEndDate() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Original_End_Date__c, ASI_CRM_End_Date__c, ASI_CRM_Valid_Claim_Date__c, ASI_CRM_New_End_Date__c  FROM ASI_CRM_VN_Contract__c LIMIT 1];
        contract.ASI_CRM_Original_End_Date__c = Date.today().toStartOfMonth().addDays(-1);
		contract.ASI_CRM_New_End_Date__c = contract.ASI_CRM_End_Date__c.addMonths(2).toStartOfMonth().addDays(-1);	//WL 1.0
        update contract;
    }

    public static testMethod void testFXRate() {
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Original_End_Date__c FROM ASI_CRM_VN_Contract__c LIMIT 1];

        update contract;
    }
}