/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_MCF_Contract_BatchTest
 * Description: Test class for ASI_CRM_VN_MCF_Contract_Batch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-29       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_MCF_Contract_BatchTest {
    @TestSetup
    public static void setupData() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        ASI_CRM_VN_TestClassHelper.createCustomSettings();

        User u = ASI_CRM_VN_TestClassHelper.createUser(systemAdminProfile.Id);
        u.ManagerId = UserInfo.getUserId();
        insert u;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        ASI_MFM_Sub_brand__c subBrand2 = ASI_CRM_VN_TestClassHelper.createSubBrand();

        List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
        subBrandList.add(subBrand);
        subBrandList.add(subBrand2);
        insert subBrandList;

        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;

        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        ASI_TH_CRM_Actual_Offtake__c actualOfftake2 = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand2.Id);
        actualOfftakeList.add(actualOfftake);
        actualOfftakeList.add(actualOfftake2);
        insert actualOfftakeList;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        contract.RecordTypeId               = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract__c' + 'ASI_CRM_VN_Capsule_Agreement_Contract');
        insert contract;

        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;

        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createCapsuleContractExpenditure(contract.Id, subBrand.Id);
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure2 = ASI_CRM_VN_TestClassHelper.createCapsuleContractExpenditure(contract.Id, subBrand2.Id);
        contractExpenditureList.add(contractExpenditure);
        contractExpenditureList.add(contractExpenditure2);
        insert contractExpenditureList;
    }

    @IsTest static void testBehavior() {
        Test.startTest();

        ASI_CRM_VN_MCF_Contract_Scheduler scheduler = new ASI_CRM_VN_MCF_Contract_Scheduler();
		scheduler.execute(null);
        Test.stopTest();

//       TODO assertion
    }
}