/*********************************************************************************
 * Name: ASI_CRM_VN_ContractExpendTriggerTest
 * Description: Test class for all contract expenditure trigger class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_VN_ContractExpendTriggerTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
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
       
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        insert contract;
    }
    
    public static testMethod void testDelete() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        insert contractExpenditure;
        
        delete contractExpenditure;
    }
    
    public static testMethod void testDuplication() {
    	ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        insert contractExpenditure;
        
        try {
            List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
            for(Integer i = 0 ; i < 2 ; i++) {
                ASI_CRM_VN_Contract_Expenditure__c duplicatedContractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
                contractExpenditureList.add(duplicatedContractExpenditure);
            }
            insert contractExpenditureList;
        } catch(Exception e) {
        }
    }
    
    public static testMethod void testThreshold() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        
        ASI_CRM_VN_Contract_Expenditure__c pgUniform = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        pgUniform.ASI_CRM_VN_Item__c   = 'PG & Uniform';
        pgUniform.ASI_CRM_VN_Amount__c = 500;
        
        ASI_CRM_VN_Contract_Expenditure__c branding = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        branding.ASI_CRM_VN_Item__c   = 'Branding (Signage)';
        branding.ASI_CRM_VN_Amount__c = 500;
        
        ASI_CRM_VN_Contract_Expenditure__c vipRoom = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        vipRoom.ASI_CRM_VN_Item__c   = 'VIP Rooms';
        vipRoom.ASI_CRM_VN_Amount__c = 500;
        
        ASI_CRM_VN_Contract_Expenditure__c glassware = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        glassware.ASI_CRM_VN_Item__c   = 'Glassware (Including Ice Buckets)';
        glassware.ASI_CRM_VN_Amount__c = 500;
        
        ASI_CRM_VN_Contract_Expenditure__c podiumStandAndGlorifiers = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        podiumStandAndGlorifiers.ASI_CRM_VN_Item__c   = 'Podium Stands & Glorifiers';
        podiumStandAndGlorifiers.ASI_CRM_VN_Amount__c = 500;
        
        contractExpenditureList.add(pgUniform);
        contractExpenditureList.add(branding);
        contractExpenditureList.add(vipRoom);
        contractExpenditureList.add(glassware);
        contractExpenditureList.add(podiumStandAndGlorifiers);
        
        insert contractExpenditureList;
    }
    
}