/*********************************************************************************
 * Name: ASI_CRM_VN_ContractCtrlTest
 * Description: Test class for all bottle analysis trigger class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created
 * 10/01/2019       Andy Zhang              insert custom settings
*/
@isTest
public class ASI_CRM_VN_BottleAnalysisTriggerTest {
    @TestSetup
    public static void setupData() {
        //ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
    	insert onTradeCustomer;

        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        insert contract;
    }
    
    public static testMethod void testCalAllocation() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_MFM_SKU_Code__c sku         = [SELECT Id FROM ASI_MFM_SKU_Code__c LIMIT 1];
        
        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        bottleAnalysis.ASI_CRM_Target_Per_Month__c = 100;
        update bottleAnalysis;
    }
    
    public static testMethod void testDelete() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_MFM_SKU_Code__c sku         = [SELECT Id FROM ASI_MFM_SKU_Code__c LIMIT 1];
        
        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        delete bottleAnalysis;
    }
}