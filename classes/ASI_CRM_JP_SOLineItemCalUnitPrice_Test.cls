@isTest
public class ASI_CRM_JP_SOLineItemCalUnitPrice_Test {
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
        directSalesCustomer.ASI_CRM_Active__c= true;
        insert directSalesCustomer;
        
        
        Map<String, Object> directSalesShipToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_SHIP_TO_DEFAULT_VALUE_MAP;
        directSalesShipToCustomerFieldValueMap.put('ASI_CRM_Customer__c', directSalesCustomer.Id);
        directSalesShipToCustomerFieldValueMap.remove('ASI_CRM_KR_Salesman__c');
        ASI_CRM_AccountsAdditionalField__c directSalesShipToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesShipToCustomerFieldValueMap);
        directSalesShipToCustomer.ASI_CRM_Active__c = true;
        insert directSalesShipToCustomer;
        
        Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
        ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
        directSalesBillToCustomer.ASI_CRM_Active__c = true;
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
            skuCode.ASI_CRM_Ex_Price__c = 1;
            skuCode.ASI_HK_CRM_Active__c = true;
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
            itemAvailabilityFieldValueMap2.put('ASI_Warehouse_Location__c', '177');
            ASI_CRM_JP_Item_Availability__c itemAvailability2 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap2);
            itemAvailabilityList.add(itemAvailability2);
        }
        insert itemAvailabilityList;
        
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
        priceList.ASI_CRM_JP_Effective_Date__c = Date.today().addDays(2);
        insert priceList;

        List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
        for(String itemBasePriceRecordTypeId : ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_RECORD_TYPE.values()) {
            Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
            itemBasePriceFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            itemBasePriceFieldValueMap.put('RecordTypeId', itemBasePriceRecordTypeId);
            itemBasePriceFieldValueMap.put('ASI_Customer_Name__c', directSalesCustomer.Id);
            ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
            itemBasePrice.ASI_SKU_Lookup__c = skuCodeList[0].Id;
            itemBasePriceList.add(itemBasePrice);
        }
        // 20190624 Wilson Chow
        insert itemBasePriceList;

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                .getRecordTypeInfosByName()
                .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c testCustomer1 =  new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Testcompany',
                RecordTypeId = customerRecTypeId
        );

        ASI_CRM_Pay_To__c payTo = new ASI_CRM_Pay_To__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),ASI_CRM_Active__c=true);
        payTo.ASI_CRM_JP_PRJ_Bank_Account__c = true;
        insert payTo;

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        //directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'Invoice');
        //directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
//            directSO.ASI_CRM_Ship_To__c = lstCustomers[1].Id;
        //directSO.ASI_CRM_Sold_To__c = lstCustomers[2].Id;
        directSO.ASI_CRM_Ship_To__c = testCustomer1.Id;
        directSO.ASI_CRM_Bank_Account__c = payTo.Id;
        insert directSO;

        Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
        salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', directSO.Id);
        salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
        salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', directSO.ASI_CRM_Branch_Plant__c);
        salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
        ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
        salesOrderItem.ASI_CRM_SKU__c = skuCodeList[0].Id;
        insert salesOrderItem;

        salesOrderItem.ASI_CRM_Unit_Price__c = 1;
        update salesOrderItem;
        // 20190624 Wilson Chow
    }
    
    public static testMethod void testDirectSalesPDF() {
        /*
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();

        List<ASI_CRM_AccountsAdditionalField__c> lstCustomers = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c ];
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        */

        // 20190624 Wilson Chow
        /*
        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                .getRecordTypeInfosByName()
                .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c testCustomer1 =  new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Testcompany',
                RecordTypeId = customerRecTypeId
        );


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

        List<ASI_MFM_SKU_Code__c> lstSKUCode = [SELECT Id
                                               FROM ASI_MFM_SKU_Code__c];

        Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
        ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
        itemBasePrice.ASI_SKU_Lookup__c = lstSKUCode[0].Id;
        insert itemBasePrice;


        ASI_CRM_Pay_To__c payTo = new ASI_CRM_Pay_To__c(Name = 'test', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Pay_To__cASI_CRM_JP_Pay_To'),ASI_CRM_Active__c=true);
        payTo.ASI_CRM_JP_PRJ_Bank_Account__c = true;
        insert payTo;

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        //directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('ASI_CRM_Salesman__c', u.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'Invoice');
        //directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
//            directSO.ASI_CRM_Ship_To__c = lstCustomers[1].Id;
        //directSO.ASI_CRM_Sold_To__c = lstCustomers[2].Id;
        directSO.ASI_CRM_Ship_To__c = testCustomer1.Id;
        directSO.ASI_CRM_Bank_Account__c = payTo.Id;
        insert directSO;

        System.debug('Debug Log : ' + directSO);

        Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
        salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', directSO.Id);
        salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
        salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', directSO.ASI_CRM_Branch_Plant__c);
        salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
        ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
        salesOrderItem.ASI_CRM_SKU__c = lstSKUCode[0].Id;
        insert salesOrderItem;

        ASI_CRM_JP_Sales_Order_Item__c salesOrderItem =
            [select Id, ASI_CRM_Unit_Price__c, ASI_CRM_Sales_Order__c, ASI_CRM_SKU__c, ASI_CRM_JP_Base_Price__c
            from ASI_CRM_JP_Sales_Order_Item__c limit 1];
        // 20190624 Wilson Chow

        salesOrderItem.ASI_CRM_Unit_Price__c = 1;
        update salesOrderItem;

        Map<Id,ASI_CRM_JP_Sales_Order_Item__c> mapSOI = new Map<Id,ASI_CRM_JP_Sales_Order_Item__c>();
        mapSOI.put(salesOrderItem.Id, salesOrderItem);
        List<ASI_CRM_JP_Sales_Order_Item__c> lstSOI = new List<ASI_CRM_JP_Sales_Order_Item__c>();
        lstSOI.add(salesOrderItem);

        ASI_CRM_JP_SOLineItemCalUnitPrice soli = new ASI_CRM_JP_SOLineItemCalUnitPrice();
        soli.assignUnitPrice(lstSOI);

        }
        */
        // 20190624 Wilson Chow
    }
}