public with sharing class ASI_KOR_POSMOrderRequestGenerator {
	public static final Decimal DEF_VALUE_DETAIL_QUANTITY = 5;
	
	public ASI_KOR_POSM_Order_Request__c generateBasicRequest(Account acct) {
		return new ASI_KOR_POSM_Order_Request__c(
			ASI_KOR_POSM_TO_Venue__c = acct.Id
		);
	}

	public ASI_KOR_POSM_Order_Request__c generateRequest(Account acct) {
		return generateBasicRequest(acct);
	}
	
	public ASI_KOR_POSM_Order_Detail__c generateBasicDetail(ASI_KOR_POSM_Order_Request__c header, ASI_KOR_POSM_Product__c posmPd) {
		return new ASI_KOR_POSM_Order_Detail__c(
			ASI_KOR_POSM_Order_Request__c = header.Id
			, ASI_KOR_Item_Name__c = posmPd.Id
			, ASI_KOR_Quantity__c = DEF_VALUE_DETAIL_QUANTITY
		);
	}

	public ASI_KOR_POSM_Order_Detail__c generateDetail(ASI_KOR_POSM_Order_Request__c header, ASI_KOR_POSM_Product__c posmPd) {
		return generateBasicDetail(header, posmPd);
	}

}