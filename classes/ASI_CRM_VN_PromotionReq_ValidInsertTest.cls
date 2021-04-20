/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromotionReq_ValidInsertTest
 * Description: Test class for ASI_CRM_VN_PromotionRequest_ValidInsert
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-05       Jeffrey Cheung          Created
 * 2019-01-05       Andy Zhang              Insert valid contract expenditure
 ****************************************************************************************************************************/
@IsTest
public class ASI_CRM_VN_PromotionReq_ValidInsertTest {
    @IsTest
    public static void testPromotionRequestInsert() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
		ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        User u = ASI_CRM_VN_TestClassHelper.createUser(systemAdminProfile.Id);
        u.ManagerId = UserInfo.getUserId();
        insert u;

        ASI_GiftBox_Inventory_Master__c inventoryItem = ASI_CRM_VN_TestClassHelper.createInventoryItem();
        insert inventoryItem;

        ASI_GiftBox_Inventory_Detail__c inventoryItemDetail = ASI_CRM_VN_TestClassHelper.createInventoryItemDetail(inventoryItem.Id);
        insert inventoryItemDetail;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        customer.OwnerId = u.Id;
        customer.ASI_CRM_Service_Pack__c = servicePack.Id;
        customer.ASI_CRM_Check_Image__c = 'Leading';
        insert customer;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(customer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        insert contract;

        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure.ASI_CRM_VN_Item__c = 'Promotion';
        insert contractExpenditure;

        ASI_CRM_Trade_A_P_Plan__c promotionPlan = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        promotionPlan.ASI_CRM_Total_Outlet__c = 1;
        insert promotionPlan;

        ASI_CRM_Trade_A_P_Plan_Item__c planItem = ASI_CRM_VN_TestClassHelper.createPromotionPlanItem(promotionPlan.Id);
        insert planItem;

        promotionPlan.ASI_CRM_Status__c = 'Approved';
        promotionPlan.ASI_CRM_PROS_Image__c = 'Leading';
        update promotionPlan;

        ASI_CRM_VN_Contract_Expenditure__c expenditure= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure;

        ASI_GiftBox_Request_Header__c requestHeader = ASI_CRM_VN_TestClassHelper.createPromotionRequest(contract.Id);
        requestHeader.ASI_CRM_Trade_A_P_Plan__c = promotionPlan.Id;
        requestHeader.ASI_CRM_VN_Image_Level__c = 'Leading';
        insert requestHeader;

        requestHeader.ASI_GiftBox_Status__c = 'Submitted';
        update requestHeader;

        promotionPlan = [SELECT Id, ASI_CRM_Committed_Outlet__c, ASI_CRM_Outlet_Balance__c FROM ASI_CRM_Trade_A_P_Plan__c WHERE Id = :promotionPlan.Id];
        System.assertEquals(1, promotionPlan.ASI_CRM_Committed_Outlet__c);
        System.assertEquals(0, promotionPlan.ASI_CRM_Outlet_Balance__c);

        Test.startTest();
        ASI_GiftBox_Request_Header__c requestHeader2 = ASI_CRM_VN_TestClassHelper.createPromotionRequest(contract.Id);
        requestHeader2.ASI_CRM_Trade_A_P_Plan__c = promotionPlan.Id;
        requestHeader2.ASI_CRM_Outlet_Sub_Type__c = 'Family KTV';
        insert requestHeader2;
        Test.stopTest();
    }

}