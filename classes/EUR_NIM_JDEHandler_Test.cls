@IsTest
public class EUR_NIM_JDEHandler_Test 
{
    @testSetup static void testSetup() 
    {
        EUR_CRM_Account__c acct = EUR_COMMON_TestUtils.createAccount('EUR DE On Trade B2B');
        EUR_COMMON_TestUtils.createContact(acct);
        EUR_COMMON_TestUtils.createProductCatalogItem();
    }
    
    @isTest static void test_calculatePrice()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c, CurrencyIsocode, 
                                   EUR_CRM_Customer_Ship_To_No_ERP__c, EUR_CRM_Customer_No_ERP__c, EUR_CRM_ERPSoldToAccount__r.EUR_CRM_Customer_No_ERP__c 
                                   FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList = EUR_NIM_Service_Test.getSalesOrderLineItemList(true);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_NIM_JDEHandlerMock());
        EUR_NIM_JDEHandlerMock.methodName = 'calculatePrice';
        EUR_NIM_JDEHandler jdeHandlerObj = new EUR_NIM_JDEHandler();
        EUR_NIM_Service.RequestResponseWrapper calculatePriceResponse = jdeHandlerObj.calculatePrice(acct, '', salesOrderLineItemList);
        system.assertEquals(1, calculatePriceResponse.lines.size());
        Test.stopTest();          
    }
    
    @isTest static void test_calculateInventory()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c 
                                   FROM EUR_CRM_Account__c 
                                   WHERE Name='account test1' LIMIT 1];
        List<EUR_NIM_Service.LineItemWrapper> salesOrderLineItemList = EUR_NIM_Service_Test.getSalesOrderLineItemList(true);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EUR_NIM_JDEHandlerMock());
        EUR_NIM_JDEHandlerMock.methodName = 'calculateInventory';
        EUR_NIM_JDEHandler jdeHandlerObj = new EUR_NIM_JDEHandler();
        List<EUR_NIM_Service.LineItemWrapper> calculateInventoryResponse = jdeHandlerObj.calculateInventory(acct, '', salesOrderLineItemList);
        system.debug('calculateInventoryResponse:'+calculateInventoryResponse);
        system.assertEquals(1, calculateInventoryResponse.size()); 
        Test.stopTest(); 
    }
}