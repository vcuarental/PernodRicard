/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_DisplayListing_CheckBalTest
 * Description: Test class for ASI_CRM_VN_DisplayListing_CheckBalance and ASI_CRM_VN_DisplayListing_RollUpToExpen
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-30       Jeffrey Cheung          Created
 * 2019-01-05       Andy Zhang              Insert valid contract expenditure and resolve SOQL limitation error
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_DisplayListing_CheckBalTest {
    @IsTest static void testBehavior() {
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

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;

        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        insert actualOfftake;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        contract.ASI_CRM_Contract_Number__c = '123';
        contract.ASI_CRM_Area_Code__c = 'abc';
        insert contract;

        ASI_CRM_VN_Contract_Expenditure__c expenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Display/Listing Fee';
        insert expenditure;

        ASI_CRM_VN_Contract_Expenditure__c expenditure2= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure2;

        test.startTest();
        ASI_GiftBox_Request_Header__c requestHeader = ASI_CRM_VN_TestClassHelper.createDisplayListingRequest(contract.Id);
        insert requestHeader;


        ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createDisplayListingRequestItem(requestHeader.Id);
        requestItem.ASI_GiftBox_Request_Item__c = inventoryItem.Id;
        insert requestItem;
        test.stopTest();
//        ASI_CRM_VN_DisplayListing_RollUpToExpen coverage
        requestHeader.ASI_GiftBox_Status__c = 'Complete';
        update requestHeader;

        requestItem.ASI_GiftBox_Request_Quantity__c = 200;
        update requestItem;
        // TODO assertion

    }
}