public with sharing class ASI_KOR_ContactGenerator {

	public static final String DEF_VALUE_LASTNAME = 'Test Name';
	public static final String RT_Keyman = 'ASI_KOR_Keyman';
	public static final String RT_WSContact = 'ASI_KOR_Wholesaler_Contact';

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
			LastName = DEF_VALUE_LASTNAME
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