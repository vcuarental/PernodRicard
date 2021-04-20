public with sharing class ASI_HK_CRM_BrandGenerator {
	
	public static final String DEF_VALUE_DESCRIPTION = 'ABSOLUT';
	public static final String DEF_VALUE_CODE = 'ABS';
	public static final String DEF_VALUE_NAME = fullNameByShortNameAndCode(DEF_VALUE_DESCRIPTION, DEF_VALUE_CODE);
	public static final String DEF_VALUE_EXT_ID = 'HK_ABS';
	public static final String RT_Default = 'ASI_HK_CRM_Brand';
	
	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_MFM_Brand__c'];
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
	
	public ASI_MFM_Brand__c generateBasicBrand(String name, String code, String extId) {
		return new ASI_MFM_Brand__c(
			Name = fullNameByShortNameAndCode(name, code)
			, ASI_MFM_Brand_Description__c = name
			, ASI_MFM_Brand_Code__c = code
			, ASI_MFM_Brand_External_ID__c = extId
		);
	}

	public ASI_MFM_Brand__c generateBrand(ID rtID) {
		ASI_MFM_Brand__c result = generateBasicBrand(DEF_VALUE_DESCRIPTION, DEF_VALUE_CODE, DEF_VALUE_EXT_ID);
		result.RecordTypeId = rtID;
		return result;
	}
	public ASI_MFM_Brand__c generateBrand() {
		return generateBrand(getRecordTypeByDevName(RT_Default).Id);
	}
	
	public static String fullNameByShortNameAndCode(String name, String code) {
		return name + '-' + code;
	}
}