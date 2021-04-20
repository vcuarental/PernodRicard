public with sharing class ASI_KOR_StockInTradeGenerator {
	public static final String DEF_VALUE_YEAR = String.valueOf(System.today().year());
	public static final String DEF_VALUE_MONTH_PREVIOUS = 'November';
	public static final String DEF_VALUE_MONTH = 'December';
	private static Map<String, Integer> monthPLValueToIntMap;
	
	public static Integer convertMonthPLValueToInteger(String plValue) {
		return getMonthPLValueToIntegerMap().get(plValue);
	}
	public static Map<String, Integer> getMonthPLValueToIntegerMap() {
		if (monthPLValueToIntMap == null) {
			monthPLValueToIntMap = new Map<String, Integer>();
			List<Schema.PicklistEntry> monthPLEntryList = ASI_KOR_Stock_In_Trade__c.ASI_KOR_Month__c.getDescribe().getPicklistValues();
			Integer month = 0;
			for (Schema.PicklistEntry plEntry : monthPLEntryList) {
				if (plEntry.isActive() && plEntry.getLabel() != null && plEntry.getLabel().trim() != '') {
					month++;
					monthPLValueToIntMap.put(plEntry.getValue(), month);
				}
			}
		}
		return monthPLValueToIntMap;
	}
	
	public ASI_KOR_Stock_In_Trade__c generateBasicStockInTrade(Account acct, String theYear, String theMonth) {
		return new ASI_KOR_Stock_In_Trade__c(
			ASI_KOR_Wholesaler__c = acct.Id
			, ASI_KOR_Year__c = theYear
			, ASI_KOR_Month__c = theMonth
		);
	}

	public ASI_KOR_Stock_In_Trade__c generateStockInTrade(Account acct) {
		ASI_KOR_Stock_In_Trade__c result = generateBasicStockInTrade(acct, DEF_VALUE_YEAR, DEF_VALUE_MONTH);
		return result;
	}
}