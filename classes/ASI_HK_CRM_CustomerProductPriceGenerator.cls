public with sharing class ASI_HK_CRM_CustomerProductPriceGenerator {
	
	public static final String DEF_VALUE_CODE = 'HK_{0}';
	public static final Decimal DEF_VALUE_PRICE_BT = 100;
	public static final Date DEF_VALUE_EFFECTIVE_DATE = System.today().addDays(-1);
	public static final Date DEF_VALUE_EXPIRY_DATE = System.today().addDays(90);
	public static final String RT_Default = 'ASI_HK_CRM_Customer_Product_Price';
	public static Integer countAll = 1;
/*
	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Customer_Product_Price__c'];
				RTMap = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMap.put(rt.DeveloperName, rt);
				}
			}
			return RTMap;
		}
		set;
	}

	public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
	
	public ASI_HK_CRM_Customer_Product_Price__c generateBasicCustomerProductPrice(Account acct, ASI_MFM_SKU_Code__c sku) {
		nextCount();
		return new ASI_HK_CRM_Customer_Product_Price__c(
			ASI_HK_CRM_Cus_Product_Price_External_ID__c = curExternalId()
			, ASI_HK_CRM_Customer_Name__c = acct.Id
			, ASI_HK_CRM_SKU_Lookup__c = sku.Id
			, ASI_HK_CRM_Bottle_Price__c = DEF_VALUE_PRICE_BT
			, ASI_HK_CRM_Effective_Date__c = DEF_VALUE_EFFECTIVE_DATE
			, ASI_HK_CRM_Expiry_Date__c = DEF_VALUE_EXPIRY_DATE
		);
	}

	public ASI_HK_CRM_Customer_Product_Price__c generateCustomerProductPrice(Account acct, ASI_MFM_SKU_Code__c sku, ID rtID) {
		ASI_HK_CRM_Customer_Product_Price__c result = generateBasicCustomerProductPrice(acct, sku);
		result.RecordTypeId = rtID;
		return result;
	}

	public ASI_HK_CRM_Customer_Product_Price__c generateCustomerProductPrice(Account acct, ASI_MFM_SKU_Code__c sku, String rtDevName) {
		return generateCustomerProductPrice(acct, sku, getRecordTypeByDevName(rtDevName).Id);
	}
	
	public static Integer nextCount() { return ++countAll; }
	public static String curExternalId() { return String.format(DEF_VALUE_CODE, new String[] {String.valueOf(countAll)}); }
*/	
}