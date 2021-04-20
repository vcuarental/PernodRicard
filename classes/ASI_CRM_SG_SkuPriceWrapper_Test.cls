/*
 *********************************************************************************
 * Name: ASI_CRM_SG_SkuPriceWrapper_Test
 * Description: Test class for ASI_CRM_SG_SkuPriceWrapper
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/11/2017       Jeffrey Cheung          Created
 */

@isTest
private class ASI_CRM_SG_SkuPriceWrapper_Test {
	private static testMethod void test() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
	    ASI_CRM_SG_SkuPriceWrapper wrapper = new ASI_CRM_SG_SkuPriceWrapper(skuList.get(1));
	    ASI_CRM_MY_SKUPriceCost__c price = new ASI_CRM_MY_SKUPriceCost__c();
	    price.ASI_CRM_SKU__c = skuList.get(1).Id;
	    price.ASI_CRM_Price__c = 100;
        price.ASI_CRM_EffectiveDate__c = Date.newInstance(2017, 1, 1);
        price.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler');

	    insert price;
	    wrapper.addSKUPrice(price);
	    
	   // test getSkuPriceMapByEffectiveDate
	    Map<String, ASI_CRM_MY_SKUPriceCost__c> result = wrapper.getSkuPriceMapByEffectiveDate(Date.newInstance(2017, 1, 1));
	    System.assertEquals(null, result);
	    
	    // test checkIsValidRecord
	    System.assertEquals(false, wrapper.checkIsValidRecord());
	}

}