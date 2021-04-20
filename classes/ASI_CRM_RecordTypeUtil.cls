public class ASI_CRM_RecordTypeUtil {

	public Static final Map<String, String> purchaseContractRecordTypeMap = new Map<String, String> {
	ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_SPTD_Contract.name() => ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_SPTD_Contract_Line_Item.name(),
	ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_Direct_Rebate_Contract.name() => ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_Direct_Rebate_Contract_Line_Item.name(),
	ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_Indirect_Rebate_Contract.name() => ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_Indirect_Rebate_Contract_Line_Item.name(),
	ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_SPTD_Contract_Read_Only.name() => ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_SPTD_Contract_Line_Item.name(),
	ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_Direct_Rebate_Contract_Read_Only.name() => ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_Direct_Rebate_Contract_Line_Item.name(),
	ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_Indirect_Rebate_Contract_Read_Only.name() => ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_Indirect_Rebate_Contract_Line_Item.name()
	};

	public static RecordTypeInfo getRecordTypeInfoByApiName(SObjectType objectType, String recordTypeApiName) {
		final Map<String, RecordTypeInfo> recordTypeApiNameInfoMap =
				objectType.getDescribe().getRecordTypeInfosByDeveloperName();

		return recordTypeApiNameInfoMap.get(recordTypeApiName);
	}

	public static Id getRecordTypeIdByApiName(SObjectType objectType, String recordTypeApiName) {
		final RecordTypeInfo recordTypeInfo = getRecordTypeInfoByApiName(objectType, recordTypeApiName);
		system.debug('recordTypeInfo'+recordTypeInfo);
		return recordTypeInfo.getRecordTypeId();
	}

	public static Map<String, String> getRecordTypeNameApiNameMap(SObjectType objectType,
																  Set<String> recordTypeApiNames) {

		final Map<String, RecordTypeInfo> recordTypeApiNameInfoMap =
				objectType.getDescribe().getRecordTypeInfosByDeveloperName();

		final Map<String, String> recordTypeNameApiNameMap = new Map<String, String>();
		for (String recordTypeApiName : recordTypeApiNameInfoMap.keySet()) {
			if (!recordTypeApiNames.contains(recordTypeApiName)) continue;

			recordTypeNameApiNameMap.put(recordTypeApiName, recordTypeApiNameInfoMap.get(recordTypeApiName).getName());
		}

		return recordTypeNameApiNameMap;
	}

	public static Map<String, RecordTypeInfo> getRecordTypeApiNameInfoMap(SObjectType objectType) {

		return objectType.getDescribe().getRecordTypeInfosByDeveloperName();
	}

	public static Map<Id, String> getRecordTypeIdApiNameMap(SObjectType objectType) {

		final Map<String, RecordTypeInfo> recordTypeApiNameInfoMap =
				objectType.getDescribe().getRecordTypeInfosByDeveloperName();
		final Map<Id, String> recordTypeIdApiNameMap = new Map<Id, String>();

		for (String recordTypeApiName : recordTypeApiNameInfoMap.keySet()) {
			final Id recordTypeId = recordTypeApiNameInfoMap.get(recordTypeApiName).getRecordTypeId();
			final String recordTypeName = recordTypeApiNameInfoMap.get(recordTypeApiName).getName();

			recordTypeIdApiNameMap.put(recordTypeId, recordTypeName);
		}

		return recordTypeIdApiNameMap;
	}

}