public with sharing class ASI_KOR_GMAGenerator {
	public static final String DEF_VALUE_NAME = 'Test GMA';
	public static final Date DEF_VALUE_DATE = Date.today();
	public static final String DEF_VALUE_ROUTE_SOURCE_CODE = 'RS01 Duty Free';
	
	public ASI_KOR_GMA__c generateBasicGMA(Account acct, ASI_KOR_Sub_Brand__c sb) {
		return new ASI_KOR_GMA__c(
			Name = DEF_VALUE_NAME
			, ASI_KOR_Venue__c = acct.Id
			, ASI_KOR_Importer_Name__c = 'Importer'
			, ASI_KOR_Sub_Brand__c = sb.Id
			, ASI_KOR_Size_cl__c = 500
			, ASI_KOR_Alcohol__c = 10
			, ASI_KOR_Quantity_Btl__c = 10
			, ASI_KOR_Price_Btl__c = 100
			, ASI_KOR_Total_Brand_Sales_Btl__c = 100
			, ASI_KOR_Estimated_Q_ty_of_GMA_Sales__c = 50
			, ASI_KOR_Date__c = DEF_VALUE_DATE
			, ASI_KOR_BL__c = true
			, ASI_KOR_Lot_No__c = 'LOT0001'
			, ASI_KOR_Front_Label__c = DEF_VALUE_NAME
			, ASI_KOR_Back_Label__c = DEF_VALUE_NAME
			, ASI_KOR_Route_Brand_Sales_Btl__c = DEF_VALUE_ROUTE_SOURCE_CODE
		);
	}

	public ASI_KOR_GMA__c generateGMA(Account acct, ASI_KOR_Sub_Brand__c sb) {
		ASI_KOR_GMA__c result = generateBasicGMA(acct, sb);
		return result;
	}
	
}