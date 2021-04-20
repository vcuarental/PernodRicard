/**
* @Description: Test class for the EUR_NIM_ProductPickerController Apex class
* @Author: Minakshi
* @Copyright: PARX
*/
@IsTest
public class EUR_NIM_ProductPickerController_Test 
{
    @testSetup static void testSetup() 
    {
        EUR_CRM_Account__c acct = EUR_COMMON_TestUtils.createAccount('EUR IDL On Trade Account');
        EUR_COMMON_TestUtils.createProductCatalogItem();
    }

    @isTest static void test_getAllProducts()
    {
        List<EUR_NIM_Service.LineItemWrapper> allProductList = EUR_NIM_ProductPickerController.getAllProducts();
        system.assertEquals(1, allProductList.size());
    }

    @isTest static void test_getFilteredProducts()
    {
        EUR_CRM_Account__c acct = [SELECT Id, Name, RecordTypeId, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c WHERE Name='account test1' LIMIT 1];
        /*String filter = '{"filter":{';
        filter = filter + '"EUR_CRM_SKU__r.Name":{\"\\\"Label\\\"\":\"\\\"Test SKU\\\"\",\"\\\"operator\\\"\":\"\\\"LIKE\\\"\"},';
        filter = filter + '"EUR_CRM_SKU__r.EUR_CRM_Article_no__c":{\"\\\"Label\\\"\":\"\\\"10113050\\\"\",\"\\\"operator\\\"\":\"\\\"LIKE\\\"\"},';
        filter = filter + '"EUR_CRM_SKU__r.EUR_CRM_Category_Name__c":{\"\\\"Label\\\"\":\"\\\"TestCategoryName\\\"\",\"\\\"operator\\\"\":\"\\\"=\\\"\"},';
        filter = filter + '"EUR_CRM_SKU__r.EUR_CRM_Brand__c":{\"\\\"Label\\\"\":\"\\\"TestBrandName\\\"\",\"\\\"operator\\\"\":\"\\\"=\\\"\"}}}';*/
        
        String filter = '{"filter":{';
        filter = filter + '"EUR_CRM_SKU__r.Name":{"Label":"Test SKU","operator":"LIKE"},';
        filter = filter + '"EUR_CRM_SKU__r.EUR_CRM_Article_no__c":{"Label":"10113050","operator":"LIKE"},';
        filter = filter + '"EUR_CRM_SKU__r.EUR_CRM_Category_Name__c":{"Label":"TestCategoryName","operator":"="},';
        filter = filter + '"EUR_CRM_SKU__r.EUR_CRM_Brand__c":{"Label":"TestBrandName","operator":"="}}}';
        
        List<EUR_NIM_Service.LineItemWrapper> productResult = EUR_NIM_ProductPickerController.getFilteredProducts(filter, acct.Id);
        system.debug('productResult: ' + productResult);
    }
}