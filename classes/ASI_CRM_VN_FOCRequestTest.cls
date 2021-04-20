/*********************************************************************************
 * Name: ASI_CRM_VN_FOCRequestTest
 * Description: Test class for all FOC request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_VN_FOCRequestTest {
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        ASI_GiftBox_Inventory_Master__c inventoryItem = ASI_CRM_VN_TestClassHelper.createInventoryItem();
        inventoryItem.ASI_CRM_Category__c = 'FOC';
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
        insert contractExpenditure;
    }
    
    public static testMethod void testFOCRequest() {
        ASI_CRM_VN_Contract__c contract               = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_GiftBox_Inventory_Master__c inventoryItem = [SELECT Id FROM ASI_GiftBox_Inventory_Master__c LIMIT 1];
        
    	ASI_GiftBox_Request_Header__c focRequest = ASI_CRM_VN_TestClassHelper.createFOCRequest(contract.Id);
        insert focRequest;
        
        List<ASI_GiftBox_Request_Item__c> requestItemList = new List<ASI_GiftBox_Request_Item__c>();
        for(Integer i = 0 ; i < 2 ; i++) {
        	ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createFOCRequestItem(focRequest.Id, inventoryItem.Id);
            requestItemList.add(requestItem);
        }
        insert requestItemList;
        
        requestItemList[0].ASI_GiftBox_Request_Quantity__c = 50;
        update requestItemList[0];
        
        focRequest.ASI_GiftBox_Status__c = 'Complete';
        update focRequest;
    } 
}