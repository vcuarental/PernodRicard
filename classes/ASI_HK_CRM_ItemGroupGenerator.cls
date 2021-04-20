public with sharing class ASI_HK_CRM_ItemGroupGenerator {
	
	public static final String DEF_VALUE_DESCRIPTION = 'Test Item Group {0}';
	public static final String DEF_VALUE_CODE = 'IGC{0}';
	public static final String DEF_VALUE_EXT_ID = 'IGEXT{0}';
	public static final String RT_Default = 'ASI_HK_CRM_Item_Group';
	public static Integer countAll = 1;

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_MFM_Item_Group__c'];
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
	
	public ASI_MFM_Item_Group__c generateBasicItemGroup(ASI_MFM_Sub_brand__c sb) {
		nextCount();
		String description = curDescription();
		String code = curCode();
		return new ASI_MFM_Item_Group__c(
			Name = fullNameByShortNameAndCode(description, code)
			, ASI_MFM_Item_Group_Description__c = description
			, ASI_MFM_Item_Group_Code__c = code
			, ASI_MFM_Item_Group_External_ID__c = curExternalId()
			, ASI_MFM_Sub_brand__c = sb != null ? sb.Id : null
			, ASI_MFM_Sub_brand__r = sb
			, RecordTypeId = RTMap.get(RT_Default).Id
		);
	}

	public ASI_MFM_Item_Group__c generateItemGroup(ASI_MFM_Sub_brand__c sb) {
		ASI_MFM_Item_Group__c result = generateBasicItemGroup(sb);
		return result;
	}
	
	public static String fullNameByShortNameAndCode(String name, String code) {
		return name + '-' + code;
	}
	
	public static Integer nextCount() { return ++countAll; }
	public static String curCode() { return String.format(DEF_VALUE_CODE, new String[] {String.valueOf(countAll)}); }
	public static String curDescription() { return String.format(DEF_VALUE_DESCRIPTION, new String[] {String.valueOf(countAll)}); }
	public static String curExternalId() { return String.format(DEF_VALUE_EXT_ID, new String[] {String.valueOf(countAll)}); }
	
}