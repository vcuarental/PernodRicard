public with sharing class ASI_HK_CRM_SalesOrderDetailGenerator {
	public static final String DEF_VALUE_UOM = 'Bottle';
	public static final Decimal DEF_VALUE_QTY = 10;
	public static final Decimal DEF_VALUE_PRICE = 100;
	public static final String RT_Default = 'ASI_HK_CRM_Sales_Order_Item';

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Sales_Order_Item__c'];
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
	
	public ASI_HK_CRM_Sales_Order_Item__c generateBasicSalesOrderDetail(ASI_HK_CRM_Sales_Order__c so, ASI_MFM_SKU_Code__c sku, Decimal qty, Decimal price) {
		return new ASI_HK_CRM_Sales_Order_Item__c(
			ASI_HK_CRM_Sales_Order__c = so.Id
			, ASI_HK_CRM_SKU__c = sku.Id
			, ASI_HK_CRM_Quantity__c = qty
			, ASI_HK_CRM_Price__c = price
			, ASI_HK_CRM_UOM__c = DEF_VALUE_UOM
		);
	}

	public ASI_HK_CRM_Sales_Order_Item__c generateSalesOrderDetail(ASI_HK_CRM_Sales_Order__c so, ASI_MFM_SKU_Code__c sku, Decimal qty, Decimal price) {
		ASI_HK_CRM_Sales_Order_Item__c result = generateBasicSalesOrderDetail(so, sku, qty, price);
		result.RecordTypeId = getRecordTypeByDevName(RT_Default).Id;
		return result;
	}

	public ASI_HK_CRM_Sales_Order_Item__c generateSalesOrderDetail(ASI_HK_CRM_Sales_Order__c so, ASI_MFM_SKU_Code__c sku) {
		return generateSalesOrderDetail(so, sku, DEF_VALUE_QTY, DEF_VALUE_PRICE);
	}
	
}