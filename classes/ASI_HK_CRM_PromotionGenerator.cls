public with sharing class ASI_HK_CRM_PromotionGenerator {
	public static final String DEF_VALUE_NAME = 'Test Promotion';
	public static final String DEF_VALUE_CODE_FORMAT = 'PMT-{0}';
	public static final Date DEF_VALUE_START_DATE = System.today().addDays(1);
	public static final Date DEF_VALUE_END_DATE = System.today().addDays(27);
	public static final String RT_Global = 'ASI_HK_CRM_National';
	public static final String RT_Team = 'ASI_HK_CRM_Tailor_Made';
	public static final String RT_Detail_Brand = 'ASI_HK_CRM_Sub_Brand';
	public static final String RT_Detail_Account = 'ASI_HK_CRM_Account';
	private static Integer autoNum = 0;

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Promotion__c'];
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
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Promotion_Detail__c'];
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
	
	public ASI_HK_CRM_Promotion__c generateBasicPromotion(String pmtName, String pmtCode, Date startDate, Date endDate) {
		return new ASI_HK_CRM_Promotion__c(
			Name = pmtCode
			, ASI_HK_CRM_Promotion_Name__c = pmtName
			, ASI_HK_CRM_Promotion_Start_Date__c = startDate
			, ASI_HK_CRM_Promotion_End_Date__c = endDate
		);
	}
	
	public ASI_HK_CRM_Promotion__c generateGlobalPromotion(Date startDate, Date endDate) {
		ASI_HK_CRM_Promotion__c result = generateBasicPromotion(DEF_VALUE_NAME, getNextPromotionCode(), startDate, endDate);
		result.RecordTypeId = getRecordTypeByDevName(RT_Global).Id;
		return result;
	}
	public ASI_HK_CRM_Promotion__c generateGlobalPromotion() {
		ASI_HK_CRM_Promotion__c result = generateGlobalPromotion(DEF_VALUE_START_DATE, DEF_VALUE_END_DATE);
		result.RecordTypeId = getRecordTypeByDevName(RT_Global).Id;
		return result;
	}
	
	public ASI_HK_CRM_Promotion__c generateTeamPromotion(Date startDate, Date endDate) {
		ASI_HK_CRM_Promotion__c result = generateBasicPromotion(DEF_VALUE_NAME, getNextPromotionCode(), startDate, endDate);
		result.RecordTypeId = getRecordTypeByDevName(RT_Team).Id;
		return result;
	}
	
	public ASI_HK_CRM_Promotion_Detail__c generatePromotionSubBrandDetail(ASI_HK_CRM_Promotion__c pmt, ASI_MFM_Sub_brand__c sb) {
		return new ASI_HK_CRM_Promotion_Detail__c(
			ASI_HK_CRM_Promotion__c = pmt.Id
			, ASI_HK_CRM_Sub_Brand__c = sb.Id
			, RecordTypeId = getDetailRecordTypeByDevName(RT_Detail_Brand).Id
		);
	}
	
	public ASI_HK_CRM_Promotion_Detail__c generatePromotionAccountDetail(ASI_HK_CRM_Promotion__c pmt, Account acct) {
		return new ASI_HK_CRM_Promotion_Detail__c(
			ASI_HK_CRM_Promotion__c = pmt.Id
			, ASI_HK_CRM_Account__c = acct.Id
			, RecordTypeId = getDetailRecordTypeByDevName(RT_Detail_Account).Id
		);
	}
	
	public List<ASI_HK_CRM_Promotion_Detail__c> generatePromotionDetails(ASI_HK_CRM_Promotion__c pmt, List<ASI_MFM_Sub_brand__c> sbList, List<Account> acctList) {
		List<ASI_HK_CRM_Promotion_Detail__c> pmtDetails = new List<ASI_HK_CRM_Promotion_Detail__c>();
		if (sbList != null) {
			for (ASI_MFM_Sub_brand__c sb : sbList)
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