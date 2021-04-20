public with sharing class ASI_HK_CRM_SKUGenerator {
	
	public static final String DEF_VALUE_DESCRIPTION = 'Test SKU {0}';
	public static final String DEF_VALUE_CODE = 'SKUC{0}';
	public static final String DEF_VALUE_EXT_ID = 'SKUEXT{0}';
	public static final Integer DEF_VALUE_INVENTORY = 5000;
	public static final Decimal DEF_VALUE_BASE_PRICE = 200;
	public static final String RT_Default = 'ASI_HK_CRM_SKU';
	public static Integer countAll = 1;

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_MFM_SKU_Code__c'];
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
	
	public ASI_MFM_SKU_Code__c generateBasicSKU(Boolean isPOS) {
		nextCount();
		String description = curDescription();
		String code = curCode();
		return new ASI_MFM_SKU_Code__c(
			Name = fullNameByShortNameAndCode(description, code)
			, ASI_MFM_SKU_Description__c = description
			, ASI_MFM_SKU_Code__c = code
			, ASI_MFM_SKU_External_ID__c = curExternalId()
			, ASI_HK_CRM_External_Short_ID__c = countAll
			, ASI_HK_CRM_IsPOSProduct__c = isPOS
			, ASI_HK_CRM_Active__c = true
			, ASI_HK_CRM_Base_Price__c = DEF_VALUE_BASE_PRICE
			, ASI_HK_CRM_Inventory__c = DEF_VALUE_INVENTORY
			, RecordTypeId = RTMap.get(RT_Default).Id
			, ASI_HK_CRM_Packaging_Size__c = 30
		);
	}
	public ASI_MFM_SKU_Code__c generateBasicSKU(ASI_MFM_Item_Group__c itemGroup, Boolean isPOS) {
		ASI_MFM_SKU_Code__c result = generateBasicSKU(isPOS);
		result.ASI_MFM_Item_Group__c = itemGroup != null ? itemGroup.Id : null;
		result.ASI_MFM_Sub_brand__c = itemGroup != null ? itemGroup.ASI_MFM_Sub_brand__c : null;
		result.ASI_HK_CRM_Product_Brand__c = result.ASI_MFM_Sub_brand__c != null ? itemGroup.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c : null;
		result.ASI_HK_CRM_Product_Category__c = result.ASI_HK_CRM_Product_Brand__c != null ? itemGroup.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c : null;
		return result;
	}
	public ASI_MFM_SKU_Code__c generateBasicSKU(ASI_MFM_Sub_brand__c sb, Boolean isPOS) {
		ASI_MFM_SKU_Code__c result = generateBasicSKU(isPOS);
		result.ASI_MFM_Sub_brand__c = sb != null ? sb.Id : null;
		result.ASI_HK_CRM_Product_Brand__c = sb != null ? sb.ASI_MFM_Brand__c : null;
		result.ASI_HK_CRM_Product_Category__c = result.ASI_HK_CRM_Product_Brand__c != null ? sb.ASI_MFM_Brand__r.ASI_HK_CRM_Product_Category__c : null;
		return result;
	}

	public ASI_MFM_SKU_Code__c generateSKU(ASI_MFM_Item_Group__c itemGroup, Boolean isPOS) {
		ASI_MFM_SKU_Code__c result = generateBasicSKU(itemGroup, isPOS);
		return result;
	}
	public ASI_MFM_SKU_Code__c generateSKU(ASI_MFM_Sub_brand__c sb, Boolean isPOS) {
		ASI_MFM_SKU_Code__c result = generateBasicSKU(sb, isPOS);
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