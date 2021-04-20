public with sharing class ASI_KOR_SalesOrderRequestGenerator {
	public static final Decimal DEF_VALUE_DETAIL_QUANTITY = 5;
	public static final String DEF_VALUE_PD_USAGE = 'General';
	public static final String DEF_VALUE_UOM = 'Case';
	
	public ASI_KOR_Sales_Order_Request__c generateBasicRequest(Account acct) {
		return new ASI_KOR_Sales_Order_Request__c(
			ASI_KOR_Wholesaler_Name__c = acct.Id
		);
	}

	public ASI_KOR_Sales_Order_Request__c generateRequest(Account acct) {
		return generateBasicRequest(acct);
	}
	
	public ASI_KOR_Sales_Order_Transaction__c generateBasicDetail(ASI_KOR_Sales_Order_Request__c header, ASI_KOR_Item_Group__c itemGroup) {
		return new ASI_KOR_Sales_Order_Transaction__c(
			ASI_KOR_Sales_Order_Request__c = header.Id
			, ASI_KOR_Item_Group_Code__c = itemGroup.Id
			, ASI_KOR_Order_Qty__c = DEF_VALUE_DETAIL_QUANTITY
			, ASI_KOR_Product_Usage__c = DEF_VALUE_PD_USAGE
			, ASI_KOR_SOT_UOM__c = DEF_VALUE_UOM
		);
	}

	public ASI_KOR_Sales_Order_Transaction__c generateDetail(ASI_KOR_Sales_Order_Request__c header, ASI_KOR_Item_Group__c itemGroup) {
		return generateBasicDetail(header, itemGroup);
	}
	
}