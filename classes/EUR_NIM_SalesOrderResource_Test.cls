/**
* @Description: Test class for the EUR_NIM_SalesOrderResource Apex class
* @Author: Minakshi
* @Copyright: PARX
*/
@IsTest
public class EUR_NIM_SalesOrderResource_Test 
{
    @testSetup static void testSetup() 
    {
        EUR_CRM_Account__c acc = EUR_COMMON_TestUtils.createAccount('EUR DE On Trade B2B');
        Contact conAcc = EUR_COMMON_TestUtils.createContact(acc);
        EUR_CRM_Sales_Order_Items__c salesOrderItems = EUR_COMMON_TestUtils.createSalesOrderItems();
    }
	@isTest static void test_getSalesOrderByID() 
    {
        Test.startTest();
        EUR_CRM_Sales_Order__c salesOrder = [select Id, Name from EUR_CRM_Sales_Order__c limit 1];

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/salesorders/'+salesOrder.Id;
        request.httpMethod = 'Get';
        //request.requestBody = Blob.valueof(JSON.serialize(salesOrder.Id));
        RestContext.request = request;
        EUR_NIM_SalesOrderResource.getSalesOrderByID();
		Test.stopTest();
    }
    
    @isTest static void test_updateSalesOrderNumber() 
    {
        Test.startTest();

        EUR_CRM_Sales_Order__c salesOrder = [select Id, Name from EUR_CRM_Sales_Order__c limit 1];

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/salesorders/'+salesOrder.Id;
        request.httpMethod = 'Patch';
        //String body = '{"OrderExternalNumber":"123","Affiliate":"DE"}';
        String body = '{"OrderExternalNumber":"123","Affiliate":"DE","OrderLines":[{"OrderLineExternalNumber":"ERP1","UnitOfMeasure":"Case","Quantity":10,"QuantityShipped":10}]}';
        request.requestBody = Blob.valueof(body);
        RestContext.request = request;
        EUR_NIM_SalesOrderResource.updateSalesOrderNumber();
        Test.stopTest();
    }
    
    @isTest static void test_updateJDESalesOrdersAndItems() 
    {
        Test.startTest();
        
        EUR_CRM_Sales_Order__c salesOrder = [select Id, Name from EUR_CRM_Sales_Order__c limit 1];

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/salesorders/'+salesOrder.Id;
        request.httpMethod = 'Patch';
        EUR_CRM_Account__c account = [Select Id, Name from EUR_CRM_Account__c where Name = 'account test1'];
        account.EUR_CRM_Customer_Ship_To_No_ERP__c = account.Id;
        update account;
        
        String body = '{"OrderExternalNumber":"123","Affiliate":"DE","Account":"' + account.Id + '"}';
        request.requestBody = Blob.valueof(body);
        RestContext.request = request;
        EUR_NIM_SalesOrderResource.upsertJDESalesOrdersAndItems();
        Test.stopTest();

        salesOrder = [select Id, EUR_CRM_Order_Status__c from EUR_CRM_Sales_Order__c WHERE Id = :salesOrder.Id];
    }

    @isTest static void test_insertJDESalesOrdersAndItems() 
    {
        Test.startTest();

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/salesorders/';
        request.httpMethod = 'Patch';
        EUR_CRM_Account__c account = [Select Id, Name from EUR_CRM_Account__c where Name = 'account test1'];
        account.EUR_CRM_Customer_Ship_To_No_ERP__c = account.Id;
        update account;
        
        String body = '{"OrderExternalNumber":"123","Affiliate":"DE","Account":"' + account.Id + '"}';
        request.requestBody = Blob.valueof(body);
        RestContext.request = request;
        EUR_NIM_SalesOrderResource.upsertJDESalesOrdersAndItems();
        Test.stopTest();

        EUR_CRM_Sales_Order__c salesOrder  = [SELECT Id, EUR_CRM_Order_Nr_JDE__c, EUR_CRM_Order_Status__c 
            FROM EUR_CRM_Sales_Order__c WHERE EUR_CRM_Order_Nr_JDE__c != null LIMIT 1];

        System.assertEquals(EUR_NIM_SalesOrderResource.NEW_SO_STATUS, salesOrder.EUR_CRM_Order_Status__c);
    }
}