/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_OutletPromotion_RollUp_Test
 * Description: Test class for ASI_CRM_VN_OutletPromotionReqRollUp
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-05       Andy Zhang              Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_OutletPromotionRollUp_Test {
    @IsTest static void testBehavior() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        User user = ASI_CRM_VN_TestClassHelper.createUserByProfileName('System Administrator');
        user.ManagerId = UserInfo.getUserId();
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
        contractExpenditure.ASI_CRM_VN_Item__c = 'Outlet Promotion';
        insert contractExpenditure;

        ASI_CRM_Trade_A_P_Plan__c plan = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        insert plan;
        ASI_CRM_Trade_A_P_Plan_Item__c planItem = ASI_CRM_VN_TestClassHelper.createPromotionPlanItem(plan.Id);
        insert planItem;

        plan.ASI_CRM_Status__c = 'Approved';
        update plan;

        System.runAs(user) {
            test.startTest();



            ASI_CRM_VN_Contract_Expenditure__c expenditure= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
            expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
            insert expenditure;

            ASI_CRM_VN_Contract_Expenditure__c expenditure2= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
            expenditure2.ASI_CRM_VN_Item__c = 'Promotion';
            insert expenditure2;

            ASI_GiftBox_Request_Header__c requestHeader = ASI_CRM_VN_TestClassHelper.createPromotionRequest(contract.Id);
            requestHeader.ASI_CRM_Trade_A_P_Plan__c = plan.Id;
            requestHeader.RecordTypeId                         = Global_RecordTypeCache.getRtId('ASI_GiftBox_Request_Header__c' + 'ASI_CRM_VN_Outlet_Promotion_Request');
            insert(requestHeader);
            requestHeader.ASI_GiftBox_Status__c = 'Complete';
            update requestHeader;
            test.stopTest();

            ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPromotionRequestItem(requestHeader.Id);
            insert requestItem;

        }
    }
}