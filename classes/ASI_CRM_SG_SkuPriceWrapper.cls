/*
*********************************************************************************
 * Name: ASI_CRM_SG_SkuPriceWrapper
 * Description: A wrapper class for storing sku and it's price
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/11/2017       Hugo Cheung             Created
*/
public class ASI_CRM_SG_SkuPriceWrapper {
	public ASI_MFM_SKU_Code__c sku {get; set;}
    public Map<String, List<ASI_CRM_MY_SKUPriceCost__c>> skuPriceRecordTypeMap {get; set;}
        
    public ASI_CRM_SG_SkuPriceWrapper(ASI_MFM_SKU_Code__c sku) {	
       	this.sku = sku;
        this.skuPriceRecordTypeMap = new Map<String, List<ASI_CRM_MY_SKUPriceCost__c>>();
    }
        
    public void addSKUPrice(ASI_CRM_MY_SKUPriceCost__c skuPrice) {
        List<ASI_CRM_MY_SKUPriceCost__c> tempSKUPriceList = skuPriceRecordTypeMap.containsKey(skuPrice.RecordType.DeveloperName) 
			                                              ? skuPriceRecordTypeMap.get(skuPrice.RecordType.DeveloperName)
			                                              : new List<ASI_CRM_MY_SKUPriceCost__c>();
		tempSKUPriceList.add(skuPrice);
		skuPriceRecordTypeMap.put(skuPrice.RecordType.DeveloperName, tempSKUPriceList);
    }
        
    public Boolean checkIsValidRecord() {
       	return skuPriceRecordTypeMap.size() == 7;
    }

    public Map<String, ASI_CRM_MY_SKUPriceCost__c> getSkuPriceMapByEffectiveDate(Date effectiveDate) {
    	Map<String, ASI_CRM_MY_SKUPriceCost__c> skuPriceByEffectiveDataMap = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();

    	for(String recordTypeDevName : skuPriceRecordTypeMap.keySet()) {
    		for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceRecordTypeMap.get(recordTypeDevName)) {
    			if(skuPriceByEffectiveDataMap.containsKey(recordTypeDevName)) continue;

    			if(effectiveDate >= skuPrice.ASI_CRM_EffectiveDate__c) skuPriceByEffectiveDataMap.put(recordTypeDevName, skuPrice);
    		}
    	}

    	return skuPriceByEffectiveDataMap.size() == 7 ? skuPriceByEffectiveDataMap : null;
    }
}