/**
* @Description: Test class for the EUR_NIM_DealService Apex class
* @Author: Minakshi
* @Copyright: PARX
*/
@IsTest
public class EUR_NIM_DealService_Test 
{
    @testSetup static void testSetup() 
    {
        EUR_CRM_Account__c account = EUR_COMMON_TestUtils.createAccount('EUR IDL On Trade Account');
        EUR_CRM_Account_Target_Group__c accountTargetGroup = EUR_COMMON_TestUtils.createAccountTargetGroup();
        EUR_CRM_Objectives_Promotions__c promo1 = EUR_COMMON_TestUtils.createObjectivePromotions(accountTargetGroup.Id);
        EUR_CRM_Objectives_Promotions__c promo2 = EUR_COMMON_TestUtils.createObjectivePromotions(accountTargetGroup.Id);
        EUR_CRM_Account_in_Target_Group__c accountTargetInGroup = EUR_COMMON_TestUtils.createAccountinTargetGroup(account.Id, accountTargetGroup.Id);
        EUR_CRM_Account_in_Promo__c accountInPromo = EUR_COMMON_TestUtils.createAccountinPromo(account.Id, promo1.Id);
        EUR_CRM_ProductCatalogItem__c productCatalogItem = EUR_COMMON_TestUtils.createProductCatalogItem();
        EUR_CRM_Deal__c deal1 = EUR_COMMON_TestUtils.createDeal('AND', true, promo1.Id);   
        EUR_CRM_Deal__c deal2 = EUR_COMMON_TestUtils.createDeal('AND', true, promo2.Id);    
        EUR_CRM_SKU__c sku = [SELECT Id FROM EUR_CRM_SKU__c LIMIT 1];
        EUR_CRM_Product_in_Deal__c productInDeal1 = EUR_COMMON_TestUtils.createProductInDeal(deal1.Id, sku.Id);
        EUR_CRM_ProductCatalogItemGrouping__c productCatalogItemGrouping1 = EUR_COMMON_TestUtils.createProductCatalogItemGrouping(deal1.Id, sku.Id);
        EUR_CRM_Product_in_Deal__c productInDeal2 = EUR_COMMON_TestUtils.createProductInDeal(deal2.Id, sku.Id);
        EUR_CRM_ProductCatalogItemGrouping__c productCatalogItemGrouping2 = EUR_COMMON_TestUtils.createProductCatalogItemGrouping(deal2.Id, sku.Id);
    }
    
 	@isTest static void test_getActiveDealsByAccount() 
    {
        Test.startTest();
        EUR_CRM_Account__c account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1];
        List<EUR_NIM_Service.GroupedDeals> groupDeals = EUR_NIM_DealService.getActiveDealsByAccount(account.Id);   
        system.assertEquals(2, groupDeals.size());
        Test.stopTest();
    }
    
    @isTest static void test_addDealProducts() 
    {
        Test.startTest();
    	List<EUR_CRM_Deal__c> dealList = [SELECT id FROM EUR_CRM_Deal__c];
        String dealId = '["' + dealList[0].Id + '", "' + dealList[1].Id + '"]';        
        List<EUR_NIM_Service.LineItemWrapper> lineItems = EUR_NIM_DealService.addDealProducts(dealId);    
        system.assertEquals(4, lineItems.size());
    	Test.stopTest();
    }
}