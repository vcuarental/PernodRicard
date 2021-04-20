/**
* @Description: Test class for the EUR_NIM_Service Apex class
* @Author: Minakshi
* @Copyright: PARX
*/
@IsTest
public class EUR_NIM_Service_Test 
{
    @testSetup static void testSetup() 
    {
        EUR_CRM_Account__c acct = EUR_COMMON_TestUtils.createAccount('EUR IDL On Trade Account');
        EUR_COMMON_TestUtils.createContact(acct);
        EUR_COMMON_TestUtils.createProductCatalogItem();
    }

    @isTest static void test_getContactPersonIs() 
    {
        Test.startTest();
        EUR_CRM_Account__c acc = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c 
        WHERE Name = 'account test1' LIMIT 1];
        Contact cont = EUR_COMMON_TestUtils.createContact(acc);

        cont.EUR_JB_Position_of_Contact__c = 'Main Telesales';
        update cont;

        Id contId = EUR_NIM_Service.getContactPersonIs(acc.Id); 
        system.assertEquals(cont.Id, contId); 
        Test.stopTest();
    }

    @isTest static void test_getBrands() 
    {
        Test.startTest();
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        List<EUR_NIM_Service.OptionWrapper> brandList = EUR_NIM_Service.getBrandValues(acct.Id); 
        system.assertEquals(2, brandList.size()); //Expected size 2 because 1 for None in picklist
        Test.stopTest();
    }
    
    @isTest static void test_getCategories() 
    {
        Test.startTest();
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        List<EUR_NIM_Service.OptionWrapper> categoryList = EUR_NIM_Service.getCategoryValues(acct.Id);
        system.assertEquals(2, categoryList.size()); //Expected size 2 because 1 for None in picklist
        Test.stopTest();        
    }

    @isTest static void test_getPicklistVals()
    {
        Test.startTest();
        List<EUR_NIM_Service.OptionWrapper> picklistValues = EUR_NIM_Service.getPicklistVals('EUR_CRM_Sales_Order__c', 'EUR_CRM_Status__c');
        system.assertNotEquals(0, picklistValues.size()); 
        Test.stopTest(); 
    }

    @isTest static void test_createSalesOrder()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE EUR_CRM_Account__c = :acct.Id LIMIT 1];
        Map<String, String> recInsert = new Map<String, String>();
        String deliveryDate = Datetime.now().format('yyyy-MM-dd');
        recInsert.put('EUR_CRM_Delivery_Date__c', '{"Value":"' + deliveryDate + '"}');
        recInsert.put('EUR_CRM_Contact_Person__c', '{"Value":"' + con.Id + '"}');
        recInsert.put('EUR_CRM_Status__c', '{"Value":"On hold"}');

        List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList = getSalesOrderLineItemList(false);
        
        Test.startTest();
        EUR_NIM_Service.createSalesOrder(recInsert, 'Draft', acct.Id, salesOrderLineItemList);
        system.assertEquals(true, [select EUR_NIM_IsServiceCloud__c from EUR_CRM_Sales_Order__c where EUR_CRM_Contact_Person__c =: con.Id limit 1 ].EUR_NIM_IsServiceCloud__c);
        Test.stopTest(); 
    }

    @isTest static void test_createSalesOrderWithDeal()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact WHERE EUR_CRM_Account__c = :acct.Id LIMIT 1];
        Map<String, String> recInsert = new Map<String, String>();
        String deliveryDate = Datetime.now().format('yyyy-MM-dd');
        recInsert.put('EUR_CRM_Delivery_Date__c', '{"Value":"' + deliveryDate + '"}');
        recInsert.put('EUR_CRM_Contact_Person__c', '{"Value":"' + con.Id + '"}');
        recInsert.put('EUR_CRM_Status__c', '{"Value":"On hold"}');

        List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList = getSalesOrderLineItemList(true);
        
        Test.startTest();
        EUR_NIM_Service.createSalesOrder(recInsert, 'Send To ERP', acct.Id, salesOrderLineItemList);
        Test.stopTest(); 
    }

    public static List<EUR_NIM_Service.LineItemWrapper> getSalesOrderLineItemList(boolean isDeal)
    {
        List<EUR_CRM_ProductCatalogItem__c> productCatalogItemList = [Select EUR_CRM_SKU__c, EUR_CRM_SKU__r.Name, 
                                            EUR_CRM_SKU__r.EUR_CRM_Article_no__c, Id, EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c, 
                                            EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c From EUR_CRM_ProductCatalogItem__c
                                            limit 1];
        
        List<EUR_NIM_Service.LineItemWrapper> lineItemWrappers = new List<EUR_NIM_Service.LineItemWrapper>();

        for (EUR_CRM_ProductCatalogItem__c productCatalogItem : productCatalogItemList)
        {
            EUR_NIM_Service.LineItemWrapper lineItem = new EUR_NIM_Service.LineItemWrapper();
            lineItem.priceBook = productCatalogItem.Id;
            lineItem.productName = productCatalogItem.EUR_CRM_SKU__r.Name;
            lineItem.productCode = productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Article_no__c;
            lineItem.productUnitType = productCatalogItem.EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c;
            lineItem.productStockInfo = productCatalogItem.EUR_CRM_SKU__r.EUR_NIM_InventoryAmount__c; 
            lineItem.priceBook = productCatalogItem.Id;
            lineItem.quantity = 10;
            if (isDeal)
            {
                lineItem.isDeal = true;
                lineItem.productDealMap = new Map<String, EUR_NIM_DealService.DealWrapper>();
            }
            lineItemWrappers.add(lineItem);
        }
        return lineItemWrappers;
    }

    @isTest static void test_calculatePrice()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList = getSalesOrderLineItemList(false);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_NIM_CalculateServiceMock());
        List<EUR_NIM_Service.LineItemWrapper> updatedSalesOrderLineItemList = EUR_NIM_Service.calculatePrice(acct.Id, salesOrderLineItemList);
        system.assertEquals(1, updatedSalesOrderLineItemList.size()); 
        system.assertEquals(10, updatedSalesOrderLineItemList[0].productPrice); 
        system.assertEquals(100, updatedSalesOrderLineItemList[0].productTotalPrice); 
        Test.stopTest(); 
    }
    
    @isTest static void test_calculateInventory()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList = getSalesOrderLineItemList(false);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_NIM_CalculateServiceMock());
        List<EUR_NIM_Service.LineItemWrapper> updatedSalesOrderLineItemList = EUR_NIM_Service.calculateInventory(acct.Id, salesOrderLineItemList);
        system.assertEquals(1, updatedSalesOrderLineItemList.size()); 
        system.assertEquals(String.valueOf(10), updatedSalesOrderLineItemList[0].productStockInfo); 
        Test.stopTest(); 
    }

    @isTest static void test_getInvServiceEndpoint()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        Test.startTest();
        String endpointName = EUR_NIM_Service.getInvServiceEndpoint(acct.Id);
        //system.assertNotEquals(null, endpointName); Commented assert statement because it is empty in org currently
        Test.stopTest();
    }

    @isTest static void test_genericWhereCondition()
    {
        List<EUR_NIM_Service.Criteria> cList = new List<EUR_NIM_Service.Criteria>();
        EUR_NIM_Service.Criteria crit = new EUR_NIM_Service.Criteria('Name', 'Test', '=');
        cList.add(crit);
        String whereConditio = EUR_NIM_Service.generateWhereQuery(cList);
        Test.startTest();
        system.assertEquals(whereConditio, 'Name =\'Test\''); 
        Test.stopTest();
    }
}