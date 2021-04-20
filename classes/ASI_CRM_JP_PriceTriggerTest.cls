/*********************************************************************************
 * Name: ASI_CRM_JP_PriceTriggerTest
 * Description: Test class for all price list and item base price trigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_PriceTriggerTest {
    
    @TestSetup
    public static void setupData() {
   		ASI_CRM_JP_TestHelper.createApprovalRoute();
    }
    
    public static testMethod void testPrice() {
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
        insert priceList;
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        insert itemGroup;
        
        Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
        itemBasePriceFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_RECORD_TYPE.get('ASI_CRM_JP_Direct_Sales_Product_Price'));
        itemBasePriceFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
        ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
        insert itemBasePrice;
    }
}