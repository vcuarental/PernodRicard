/**
 * History service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_VolumeChangeHistoryService
{
	public static final String EUR_ISP_VOLUME_CHANGE_HISTORY = 'EUR_ISP_Volume_Change_History__c';
	public static final String DE_RECORD_TYPE = 'EUR_ISP_DE_Volume_Change_History_Layout';
	public static final String ISPEND_RECORD_TYPE = 'EUR_ISP_iSpend_Volume_Change_History_Layout';

	private static final String PREFIX_EUR_ISP = 'EUR_ISP_';
	private static final String PREFIX_NEW = 'EUR_ISP_New_Value_';
	private static final String PREFIX_OLD = 'EUR_ISP_Old_Value_';

	public static final Map<String, Map<String, String>> FIELD_MAPPING_OVERRIDS = new Map<String, Map<String, String>>
	{
		EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME => new Map<String, String> {
			'Id' => 'EUR_ISP_Spend_Activity__c'
		},
		EUR_ISP_Utils.EUR_ISP_SPEND_ITEM_API_NAME => new Map<String, String> {
			'Id' => 'EUR_ISP_Spend_Item__c',
			'EUR_ISP_Spend_Activity__c' => 'EUR_ISP_Spend_Activity__c',
			'EUR_ISP_Brand__c' => 'EUR_ISP_Brand__c',
			'EUR_ISP_Brand_Quality__c' => 'EUR_ISP_Brand_Quality__c',
			'EUR_ISP_Brand_Quality_Size__c' => 'EUR_ISP_Brand_Quality_Size__c',
			'EUR_ISP_SKU_EU__c' => 'EUR_ISP_SKU__c',
			'EUR_ISP_Family__c' => 'EUR_ISP_Wine_Spirits__c'
		}
	};

	public static final Map<String, Set<String>> FIELDS_MAPPING = new Map<String, Set<String>>
	{
		EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME => new Set<String> {
			'Activity_Start_Date__c',
			'Activity_End_Date__c',
			'Status__c',
			'Approval_Status__c',
			'Activity_Amount__c'
		},
		EUR_ISP_Utils.EUR_ISP_SPEND_ITEM_API_NAME => new Set<String> {
			'Volume__c',
			'Per_Unit_Amount__c',
			'Total_Spend_Item__c'
		}
	};

	public static void saveUpdatesToHistory(Map<Id, sObject> oldRecordsMap, List<sObject> newRecords, String sObjectName)
	{
		if (newRecords == null || String.isBlank(sObjectName) || !FIELDS_MAPPING.containsKey(sObjectName))
		{
			return;
		}

		oldRecordsMap = oldRecordsMap != null ? oldRecordsMap : new Map<Id, sObject>();
		Id currentUserId = UserInfo.getUserId();
		Map<String, String> mappingOverride = EUR_ISP_VolumeChangeHistoryService.getFieldMapping(sObjectName);

		List<EUR_ISP_Volume_Change_History__c> historyItems = new List<EUR_ISP_Volume_Change_History__c>();
		for (sObject record : newRecords)
		{
			Id recordId = (Id)record.get('Id');
			sObject oldRecord  = oldRecordsMap.get(recordId);

			EUR_ISP_Volume_Change_History__c item = new EUR_ISP_Volume_Change_History__c(
			    RecordTypeId = getHistoryRecordTypeId(sObjectName, record),
			    EUR_ISP_Changed_By__c = currentUserId,
			    EUR_ISP_Date_Time__c = Datetime.now()
			);

			for (String fieldName : mappingOverride.keySet())
			{
				item.put(mappingOverride.get(fieldName), record.get(fieldName));
			}

			for (String fieldName : FIELDS_MAPPING.get(sObjectName))
			{
				Object newValue = record.get(PREFIX_EUR_ISP + fieldName);
				if (oldRecord == null)
				{
					item.put(PREFIX_NEW + fieldName, newValue);
					continue;
				}

				Object oldValue = oldRecord.get(PREFIX_EUR_ISP + fieldName);
				if (newValue != oldValue)
				{
					item.put(PREFIX_OLD + fieldName, oldValue);
					item.put(PREFIX_NEW + fieldName, newValue);
				}
			}
			historyItems.add(item);
		}
		insert historyItems;
	}

	private static Id getHistoryRecordTypeId(String sObjectName, sObject record)
	{
		String countryCode = (String)record.get('EUR_ISP_Country_Code__c');
		String recordTypeName =  countryCode != EUR_ISP_Utils.COUNTRY_CODE_DE ? ISPEND_RECORD_TYPE : DE_RECORD_TYPE;
		return EUR_ISP_Utils.getRecordTypesMap().get(EUR_ISP_VOLUME_CHANGE_HISTORY + recordTypeName);
	}

	public static List<String> getFieldsToTrack(String sObjectName)
	{
		List<String> fields = new List<String>();
		if (!FIELDS_MAPPING.containsKey(sObjectName))
		{
			return fields;
		}

		for (String fieldName : FIELDS_MAPPING.get(sObjectName))
		{
			fields.add(PREFIX_EUR_ISP + fieldName);
		}
		return fields;
	}

	private static Map<String, String> getFieldMapping(String sObjectName)
	{
		Map<String, String> mapping = new Map<String, String>();
		if (FIELD_MAPPING_OVERRIDS.containsKey(sObjectName))
		{
			mapping = FIELD_MAPPING_OVERRIDS.get(sObjectName);
		}
		return mapping;
	}
}