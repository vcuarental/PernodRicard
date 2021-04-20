public with sharing class ASI_KOR_StockInTradeDetailGenerator {
	public static final Integer DEF_VALUE_END_STOCK = 0;

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				RTMap = new Map<String, RecordType>();
			}
			return RTMap;
		}
		set;
	}

	public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
	
	public ASI_KOR_WS_Stock_In_Trade_Detail__c generateBasicStockInTradeDetail(ASI_KOR_Stock_In_Trade__c sit, ASI_KOR_Item_Group__c itemGroup) {
		return new ASI_KOR_WS_Stock_In_Trade_Detail__c(
			Stock_In_Trade__c = sit.Id
			, ASI_KOR_Item_Group_Code__c = itemGroup.Id
			, ASI_KOR_WS_SIT_End_Stock__c = DEF_VALUE_END_STOCK
		);
	}

	public ASI_KOR_WS_Stock_In_Trade_Detail__c generateStockInTradeDetail(ASI_KOR_Stock_In_Trade__c sit, ASI_KOR_Item_Group__c itemGroup) {
		return generateBasicStockInTradeDetail(sit, itemGroup);
	}
	
}