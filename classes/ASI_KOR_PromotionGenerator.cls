public with sharing class ASI_KOR_PromotionGenerator {
	public static final String DEF_VALUE_NAME = 'Test Promotion';
	public static final String DEF_VALUE_CODE_FORMAT = 'PMT-{0}';
	public static final Date DEF_VALUE_START_DATE = System.today().addDays(1);
	public static final Date DEF_VALUE_END_DATE = System.today().addDays(27);
	public static final String RT_Global = 'ASI_KOR_Global';
	public static final String RT_Team = 'ASI_KOR_Team';
	public static final String RT_Detail_Brand = 'ASI_KOR_Brand';
	public static final String RT_Detail_Account = 'ASI_KOR_Account';
	private static Integer autoNum = 0;

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_KOR_Promotion__c'];
				RTMap = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMap.put(rt.DeveloperName, rt);
				}
			}
			return RTMap;
		}
		set;
	}

	private static Map<String, RecordType> RTMap_Detail {
		get {
			if (RTMap_Detail == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_KOR_Promotion_Details__c'];
				RTMap_Detail = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMap_Detail.put(rt.DeveloperName, rt);
				}
			}
			return RTMap_Detail;
		}
		set;
	}

	public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
	public static RecordType getDetailRecordTypeByDevName(String devName) { return RTMap_Detail.get(devName); }
	
	public ASI_KOR_Promotion__c generateBasicPromotion(String pmtName, String pmtCode, Date startDate, Date endDate) {
		return new ASI_KOR_Promotion__c(
			Name = pmtCode
			, ASI_KOR_Promotion_Name__c = pmtName
			, ASI_KOR_Promotion_Start_Date__c = startDate
			, ASI_KOR_Promotion_End_Date__c = endDate
		);
	}
	
	public ASI_KOR_Promotion__c generateGlobalPromotion(Date startDate, Date endDate) {
		ASI_KOR_Promotion__c result = generateBasicPromotion(DEF_VALUE_NAME, getNextPromotionCode(), startDate, endDate);
		result.RecordTypeId = getRecordTypeByDevName(RT_Global).Id;
		return result;
	}
	public ASI_KOR_Promotion__c generateGlobalPromotion() {
		ASI_KOR_Promotion__c result = generateGlobalPromotion(DEF_VALUE_START_DATE, DEF_VALUE_END_DATE);
		result.RecordTypeId = getRecordTypeByDevName(RT_Global).Id;
		return result;
	}
	
	public ASI_KOR_Promotion__c generateTeamPromotion(Date startDate, Date endDate) {
		ASI_KOR_Promotion__c result = generateBasicPromotion(DEF_VALUE_NAME, getNextPromotionCode(), startDate, endDate);
		result.RecordTypeId = getRecordTypeByDevName(RT_Team).Id;
		return result;
	}
	
	public ASI_KOR_Promotion_Details__c generatePromotionSubBrandDetail(ASI_KOR_Promotion__c pmt, ASI_KOR_Sub_Brand__c sb) {
		return new ASI_KOR_Promotion_Details__c(
			ASI_KOR_Promotion__c = pmt.Id
			, ASI_KOR_Brand__c = sb.Id
			, RecordTypeId = getDetailRecordTypeByDevName(RT_Detail_Brand).Id
		);
	}
	
	public ASI_KOR_Promotion_Details__c generatePromotionAccountDetail(ASI_KOR_Promotion__c pmt, Account acct) {
		return new ASI_KOR_Promotion_Details__c(
			ASI_KOR_Promotion__c = pmt.Id
			, ASI_KOR_Account__c = acct.Id
			, RecordTypeId = getDetailRecordTypeByDevName(RT_Detail_Account).Id
		);
	}
	
	public List<ASI_KOR_Promotion_Details__c> generatePromotionDetails(ASI_KOR_Promotion__c pmt, List<ASI_KOR_Sub_Brand__c> sbList, List<Account> acctList) {
		List<ASI_KOR_Promotion_Details__c> pmtDetails = new List<ASI_KOR_Promotion_Details__c>();
		if (sbList != null) {
			for (ASI_KOR_Sub_Brand__c sb : sbList)
				pmtDetails.add(generatePromotionSubBrandDetail(pmt, sb));
		}
		if (acctList != null) {
			for (Account acct : acctList)
				pmtDetails.add(generatePromotionAccountDetail(pmt, acct));
		}
		return pmtDetails;
	}
	
	private static String getNextPromotionCode() {
		return String.format(DEF_VALUE_CODE_FORMAT, new String[] {getNextAutoNum()});
	}
	
	private static String getNextAutoNum() {
		return String.valueOf(++autoNum);
	}

}