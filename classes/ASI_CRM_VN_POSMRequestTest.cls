/*********************************************************************************
 * Name: ASI_CRM_VN_POSMRequestTest
 * Description: Test class for all POSM request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created
 * 04/01/2019       Andy Zhang              Insert Contract expenditure for testing
*/
@isTest
public class ASI_CRM_VN_POSMRequestTest {
    
    @TestSetup
    public static void setupData() {
        
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        
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
       
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        insert contract;

        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure.ASI_CRM_VN_Item__c   = 'Glassware (Including Ice Buckets)';
        contractExpenditure.ASI_CRM_VN_Amount__c = 5000000;
        insert contractExpenditure;
    }
    
    public static testMethod void testPOSMRequest() {
        ASI_CRM_VN_Contract__c contract               = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_GiftBox_Inventory_Master__c inventoryItem = [SELECT Id FROM ASI_GiftBox_Inventory_Master__c LIMIT 1];

        ASI_CRM_VN_Contract_Expenditure__c expenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure;

        ASI_GiftBox_Request_Header__c posmRequest = ASI_CRM_VN_TestClassHelper.createPOSMRequest(contract.Id);
        insert posmRequest;
        
        List<ASI_GiftBox_Request_Item__c> requestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(Integer i = 0 ; i < 2 ; i++) {
            ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPOSMRequestItem(posmRequest.Id, inventoryItem.Id);
            requestItemList.add(requestItem);
        }
        insert requestItemList;
        
        posmRequest.ASI_GiftBox_Status__c = 'Waiting for HR Review';
        
        test.startTest();
        update posmRequest;
        test.stopTest();
    }  
}