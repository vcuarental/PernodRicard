public with sharing class ASI_FOC_FreeGoodRequestGenerator {
	
	public static final String DEF_VALUE_REQ_TYPE_TRADE = 'Trade A&P';
	public static final String DEF_VALUE_TRADE_PO_NUM_TRADE = 'TPO00001';
	public static final String RT_NORMAL = 'ASI_FOC_CN_Free_Goods_Request';
	public static final String RT_READONLY_HEADER = 'ASI_FOC_CN_Free_Goods_Request_Read_Only';
	public static final String RT_READONLY_HEADER_DETAIL = 'ASI_FOC_CN_Request_and_Items_Read_Only';
    public static final String POSM_NORMAL = 'ASI_FOC_CN_POSM';
    public static final String POSM_READONLY = 'ASI_FOC_CN_POSM_Read_Only';

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_FOC_Free_Goods_Request__c'];
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
	
	public ASI_FOC_Free_Goods_Request__c generateBasicFreeGoodRequest(String reqType, ASI_FOC_PO__c cust_po, String trade_po_num) {
		return new ASI_FOC_Free_Goods_Request__c(
			ASI_FOC_Request_Type__c = reqType
			, ASI_FOC_PO__c = cust_po != null ? cust_po.Id : null
			, ASI_FOC_Trade_A_P_PO_Number__c = trade_po_num
		);
	}

	public ASI_FOC_Free_Goods_Request__c generateTradeFreeGoodRequest() {
		ASI_FOC_Free_Goods_Request__c result = generateBasicFreeGoodRequest(DEF_VALUE_REQ_TYPE_TRADE, null, DEF_VALUE_TRADE_PO_NUM_TRADE);
		result.RecordTypeId = getRecordTypeByDevName(RT_NORMAL).Id;
		return result;
	}
    
    public ASI_FOC_Free_Goods_Request__c generatePOSMRequest() {
		ASI_FOC_Free_Goods_Request__c result = generateBasicFreeGoodRequest(DEF_VALUE_REQ_TYPE_TRADE, null, DEF_VALUE_TRADE_PO_NUM_TRADE);
		result.RecordTypeId = getRecordTypeByDevName(POSM_NORMAL).Id;
		return result;
	}
	
}