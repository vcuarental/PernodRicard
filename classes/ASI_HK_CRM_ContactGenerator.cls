public with sharing class ASI_HK_CRM_ContactGenerator {

	public static final String DEF_VALUE_LAST_NAME = 'Test Last Name';
	public static final String RT_Credit = 'ASI_HK_CRM_Wholesalers_Outlets';
	public static final String RT_Potential = 'ASI_HK_CRM_Potential_Accounts';

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'Contact'];
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
	
	public Contact generateBasicContact(Account acct) {
		return new Contact(
			LastName = DEF_VALUE_LAST_NAME
			, AccountId = acct.Id
		);
	}

	public Contact generateContact(Account acct, ID rtID) {
		Contact result = generateBasicContact(acct);
		result.RecordTypeId = rtID;
		return result;
	}

	public Contact generateContact(Account acct, String rtDevName) {
		return generateContact(acct, getRecordTypeByDevName(rtDevName).Id);
	}

}