/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromotionRequest_ValidTest
 * Description: Test class for ASI_CRM_VN_PromotionRequest_ValidCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-31       Jeffrey Cheung          Created
 * 2019-01-05       Andy Zhang              Insert valid contract expenditure
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_PromotionRequest_ValidTest {
    @IsTest static void testBehavior() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        String profileId = [SELECT Id FROM Profile WHERE Name = 'ASI VN Standard User'].Id;

        User user = ASI_CRM_VN_TestClassHelper.createUser(profileId);
        insert user;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        customer.OwnerId = user.Id;
        customer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert customer;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(customer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        insert contract;

        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure.ASI_CRM_VN_Item__c = 'Promotion';
        insert contractExpenditure;

        ASI_CRM_Trade_A_P_Plan__c plan = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        insert plan;

        ASI_CRM_Trade_A_P_Plan_Item__c planItem = ASI_CRM_VN_TestClassHelper.createPromotionPlanItem(plan.Id);
        insert planItem;

        plan.ASI_CRM_Status__c = 'Approved';
        update plan;

        ASI_CRM_VN_Contract_Expenditure__c expenditure= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure;

        ASI_GiftBox_Request_Header__c request = ASI_CRM_VN_TestClassHelper.createPromotionRequest(contract.Id);
        request.ASI_CRM_Trade_A_P_Plan__c = plan.Id;
        insert request;

        ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPromotionRequestItem(request.Id);
        insert requestItem;

        ApexPages.currentPage().getParameters().put('id', request.Id);
        ASI_CRM_VN_PromotionRequest_ValidCtrl controller = new ASI_CRM_VN_PromotionRequest_ValidCtrl();

        System.assert(String.isEmpty(controller.errorMsg));

    }
}