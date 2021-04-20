/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_ManagePromotionRequestTest
 * Description: Test class for ASI_CRM_VN_ManagePromotionRequestTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-18       Jeffrey Cheung          Created
 * 2019-01-04       Andy Zhang              Insert valid expenditure
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_ManagePromotionRequestTest {
    @IsTest static void controllerTest() {
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
        
        ASI_CRM_VN_Contract_Expenditure__c expenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure;
        
        ASI_GiftBox_Request_Header__c requestHeader = ASI_CRM_VN_TestClassHelper.createPromotionRequest(contract.Id);
        requestHeader.ASI_CRM_Trade_A_P_Plan__c = plan.Id;
        requestHeader.ASI_CRM_VN_Image_Level__c = 'test image level';
        insert requestHeader;

        ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPromotionRequestItem(requestHeader.Id);
        insert requestItem;


        PageReference myVfPage = Page.ASI_CRM_VN_ManagePromotionRequestPage;
        Test.setCurrentPage(myVfPage);

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', requestHeader.Id);
        ApexPages.currentPage().getParameters().put('updateLineItemListJson', JSON.serialize(new List<ASI_GiftBox_Request_Item__c>()));
        ApexPages.currentPage().getParameters().put('isQuickSave', 'false');


        ApexPages.StandardController sc = new ApexPages.StandardController(requestHeader);
        ASI_CRM_VN_ManagePromotionReqController controller = new ASI_CRM_VN_ManagePromotionReqController(sc);

        System.assert(controller.getPromotionPlanItemsJSON().contains(planItem.Id));
        System.assert(controller.getPromotionRequestItemsJSON().contains(requestItem.Id));

        controller.saveRecord();
    }
}