/*********************************************************************************
 * Name: ASI_CRM_JP_SalesOrderItemTriggerTest
 * Description: Test class for all sales order item trigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_SalesOrderItemTriggerTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createRunningNumber();
   		ASI_CRM_JP_TestHelper.createApprovalRoute();
		ASI_CRM_JP_TestHelper.createBusinessDay();
        
        Map<String, Object> postalCodeFieldValueMap = ASI_CRM_JP_TestHelper.POSTAL_CODE_DEFAULT_VALUE_MAP;
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestHelper.createPostalCode(postalCodeFieldValueMap);
        insert postalCode;
        
        Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
        directSalesCustomerFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Customer'));
        ASI_CRM_AccountsAdditionalField__c directSalesCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap);
        insert directSalesCustomer;
        
        Map<String, Object> directSalesShipToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_SHIP_TO_DEFAULT_VALUE_MAP;
        directSalesShipToCustomerFieldValueMap.put('ASI_CRM_Customer__c', directSalesCustomer.Id);
        directSalesShipToCustomerFieldValueMap.remove('ASI_CRM_KR_Salesman__c');
        ASI_CRM_AccountsAdditionalField__c directSalesShipToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesShipToCustomerFieldValueMap);
        insert directSalesShipToCustomer;
        
        Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
        ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
        insert directSalesBillToCustomer;
        
        insert ASI_CRM_JP_TestHelper.createBillTo(directSalesCustomer.Id, directSalesBillToCustomer.Id);
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        insert itemGroup;
        
        List<ASI_MFM_SKU_Code__c> skuCodeList = new List<ASI_MFM_SKU_Code__c>();
        for(Integer index = 0 ; index < 2 ; index++) {
            Map<String, Object> skuCodeFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
            skuCodeFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            ASI_MFM_SKU_Code__c skuCode = ASI_CRM_JP_TestHelper.createSKU(skuCodeFieldValueMap);
            skuCodeList.add(skuCode);
        }
        insert skuCodeList;
        
        List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList = new List<ASI_CRM_JP_Item_Availability__c>();
        for(ASI_MFM_SKU_Code__c skuCode : skuCodeList) {
            Map<String, Object> itemAvailabilityFieldValueMap1 = ASI_CRM_JP_TestHelper.ITEM_AVAILABILITY_DEFAULT_VALUE_MAP;
            itemAvailabilityFieldValueMap1.put('ASI_SKU__c', skuCode.Id);
            itemAvailabilityFieldValueMap1.put('ASI_Warehouse_Location__c', '111');
            ASI_CRM_JP_Item_Availability__c itemAvailability1 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap1);
            itemAvailabilityList.add(itemAvailability1);
            
            Map<String, Object> itemAvailabilityFieldValueMap2 = ASI_CRM_JP_TestHelper.ITEM_AVAILABILITY_DEFAULT_VALUE_MAP;
            itemAvailabilityFieldValueMap2.put('ASI_SKU__c', skuCode.Id);
            itemAvailabilityFieldValueMap2.put('ASI_Warehouse_Location__c', '131');
            ASI_CRM_JP_Item_Availability__c itemAvailability2 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap2);
            itemAvailabilityList.add(itemAvailability2);
        }
        insert itemAvailabilityList;
        
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
        insert priceList;
        
        List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
        for(String itemBasePriceRecordTypeId : ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_RECORD_TYPE.values()) {
        	Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
            itemBasePriceFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            itemBasePriceFieldValueMap.put('RecordTypeId', itemBasePriceRecordTypeId);
            ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
            itemBasePriceList.add(itemBasePrice);
        }
        insert itemBasePriceList;
    }
    
    public static testMethod void testTrigger() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
        	customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        ASI_CRM_Bill_To__c billTo   = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];
        List<ASI_MFM_SKU_Code__c> skuCodeList = [SELECT Id FROM ASI_MFM_SKU_Code__c];
        
        Map<String, Object> userRoleFieldValueMap = ASI_CRM_JP_TestHelper.USER_ROLE_DEFAULT_VALUE_MAP;
        UserRole uRole = ASI_CRM_JP_TestHelper.createUserRole(userRoleFieldValueMap);
        insert uRole;
        
        Map<String, Object> userFieldValueMap = ASI_CRM_JP_TestHelper.USER_DEFAULT_VALUE_MAP;
        userFieldValueMap.put('UserRoleId', uRole.Id);
        User u = ASI_CRM_JP_TestHelper.createUser(userFieldValueMap);
        insert u;
        
        System.runAs(u) {
            Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
            directSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
            directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
            directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
            directSOFieldValueMap.put('ASI_CRM_Salesman__c', u.Id);
            directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

            directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
            directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
            directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
            directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

            ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
            insert directSO;
            
            System.debug('Debug Log : ' + directSO);
            
            Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
            salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', directSO.Id);
            salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
            salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', directSO.ASI_CRM_Branch_Plant__c);
            salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
            ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
			insert salesOrderItem;
            
            Test.startTest();
                salesOrderItem.ASI_CRM_SKU__c = skuCodeList.get(1).Id;
                update salesOrderItem;
				
            	directSO.ASI_CRM_Branch_Plant__c = '131';
                directSO.ASI_CRM_Status__c = 'Final';
                update directSO;
            Test.stopTest();
        }
    }
    
}