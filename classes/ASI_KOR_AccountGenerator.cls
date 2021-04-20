public with sharing class ASI_KOR_AccountGenerator {
	public static final String DEF_VALUE_NAME = 'Test Account {0}';
	public static final String DEF_VALUE_GRADE = 'C';
	public static final String DEF_VALUE_CUST_CODE = 'C{0}';
	public static final String RT_WS = 'ASI_KOR_Wholesaler';
	public static final String RT_Venue = 'ASI_KOR_Venue';
	public static Integer countCode = 1;
	public static Integer countName = 1;

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'Account'];
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
	
	public Account generateBasicAccount(String name, String grade) {
		return new Account(
			Name = name
			, ASI_KOR_Grade__c = grade
		);
	}

	public Account generateAccount(ID rtID) {
		Account result = generateBasicAccount(nextName(), DEF_VALUE_GRADE);
		result.RecordTypeId = rtID;
		if (rtID == getRecordTypeByDevName(RT_WS).Id) {
			result.ASI_KOR_Customer_Code__c = nextCode();
		}
		return result;
	}

	public Account generateAccount(String rtDevName) {
		return generateAccount(getRecordTypeByDevName(rtDevName).Id);
	}
	
	public String nextCode() { return String.format(DEF_VALUE_CUST_CODE, new String[] {String.valueOf(countCode++)}); }
	public String nextName() { return String.format(DEF_VALUE_NAME, new String[] {String.valueOf(countName++)}); }
}