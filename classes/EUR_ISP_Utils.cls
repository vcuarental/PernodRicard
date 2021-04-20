/**
 * Utility class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public with sharing class EUR_ISP_Utils
{
	public static final String APPROVED_APPROVAL_STATUS = 'Approved';
	public static final String REJECTED_APPROVAL_STATUS = 'Rejected';
	public static final String PENDING_APPROVAL_STATUS = 'Pending';
	public static final String AWAITING_APPROVAL_STATUS = 'Awaiting Approval';

	public static final String APPROVE_APPROVAL = 'Approve';
	public static final String REJECT_APPROVAL = 'Reject';
	public static final String RECALL_APPROVAL = 'Removed';

	public static final String NEW_STATUS = 'New';
	public static final String RINGFENCE_STATUS = 'Ringfence';
	public static final String PLANNED_STATUS = 'Planned';
	public static final String INVOICED_STATUS = 'Invoiced';
	public static final String CANCELLED_STATUS = 'Cancelled';
	public static final String COMMITTED_STATUS = 'Committed';
	public static final String MATCHED_STATUS = 'Matched';

	public static final String EUR_ISP_SPEND_API_NAME = 'EUR_ISP_Spend__c';
	public static final String EUR_ISP_SPEND_ACTIVITY_API_NAME = 'EUR_ISP_Spend_Activity__c';
	public static final String EUR_ISP_SPEND_ACTIVITY_TYPE_API_NAME = 'EUR_ISP_Spend_Activity_Type__c';
	public static final String EUR_ISP_SPEND_ITEM_API_NAME = 'EUR_ISP_Spend_Item__c';
	public static final String EUR_ISP_ERROR_LOG_API_NAME = 'EUR_ISP_Error_Log__c';
	public static final String EUR_ISP_SETTLEMENT_API_NAME = 'EUR_ISP_Settlement__c';
	public static final String EUR_ISP_SETTLEMENT_LINE_API_NAME = 'EUR_ISP_Settlement_Line__c';
	public static final String EUR_CRM_CONTRACT_API_NAME = 'EUR_CRM_Contract__c';

	public static final String EUR_ISP_SPEND_COMMERCIAL_RT_NAME = 'EUR_ISP_Commercial_Plan';
	public static final String SFA_CONTRACT_RT_NAME = 'EUR_ISP_SFA_Contract';
	public static final String DE_CONTRACT_RT_NAME = 'EUR_DE_Contract';

	public static final Integer RECORDS_PER_PAGE_SIZE = 15;

	public static final String DE_PERMISSION_SET_NAME = 'EUR_ISP_SFA_DE_User';
	public static final String DE_PROJECT_NAME_SETTING = 'DE_SFA_PROJECT';
	public static String COUNTRY_CODE_DE = 'DE';

	public static final Map<String, String> EUR_ISP_ACTIVITY_TYPES_MAPPING = new Map<String, String>
	{
		'Family'             => 'EUR_ISP_Family__c',
		'Brand'              => 'EUR_ISP_Brand__c',
		'Brand Quality'      => 'EUR_ISP_Brand_Quality__c',
		'Brand Quality Size' => 'EUR_ISP_Brand_Quality_Size__c',
		'SKU'                => 'EUR_ISP_SKU_EU__c'
	};

	public static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();

	private static Map<String, Id> recordTypesMap = new Map<String, Id>();
	// objectName+RecordTypeDevName => RecordType obejct
	public static Map<String, Id> getRecordTypesMap()
	{
		if (!recordTypesMap.isEmpty())
		{
			return recordTypesMap;
		}

		List<String> sObjectNames = new List<String>
		{
			EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SETTLEMENT_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SETTLEMENT_LINE_API_NAME,
			EUR_ISP_Utils.EUR_ISP_ERROR_LOG_API_NAME,
			EUR_ISP_VolumeChangeHistoryService.EUR_ISP_VOLUME_CHANGE_HISTORY,
			EUR_ISP_BudgetService.EUR_CRM_BUDGET_API_NAME,
			EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME
		};

		for (RecordType theType : [SELECT Id, SobjectType, DeveloperName
		                           FROM RecordType
		                           WHERE SobjectType IN : sObjectNames])
		{
			recordTypesMap.put(theType.SobjectType + theType.DeveloperName, theType.Id);
		}
		return recordTypesMap;
	}

	public static Boolean isActivityAmountsMoreThenToleranceValue(EUR_ISP_Spend_Activity__c newActivity, EUR_ISP_Spend_Activity__c oldActivity, List<EUR_ISP_SystemSettings__c> settings)
	{
		if (newActivity.EUR_ISP_Approval_Status__c == EUR_ISP_Utils.APPROVED_APPROVAL_STATUS &&
		        newActivity.EUR_ISP_Status__c != EUR_ISP_Utils.INVOICED_STATUS &&
		        newActivity.EUR_ISP_Status__c != EUR_ISP_Utils.CANCELLED_STATUS)
		{
			if (!settings.isEmpty() && settings.get(0).EUR_ISP_Value_SFDC__c != null)
			{
				Decimal toleranceValue = Decimal.valueOf(settings.get(0).EUR_ISP_Value_SFDC__c);
				Decimal newAmount = newActivity.EUR_ISP_Total_Activity_Amount__c != null ? newActivity.EUR_ISP_Total_Activity_Amount__c : 0;
				Decimal oldAmount = oldActivity.EUR_ISP_Total_Activity_Amount__c != null ? oldActivity.EUR_ISP_Total_Activity_Amount__c : 0;

				return toleranceValue < (newAmount - oldAmount);
			}
		}
		return false;
	}

	public static Map<String, List<PicklistValue>> getPicklistValues(List<String> objectsAPINames)
	{
		Map<String, List<PicklistValue>> outputResults = new Map<String, List<PicklistValue>>();
		for (String objName : objectsAPINames)
		{
			Schema.DescribeSobjectResult objectDescribe = GLOBAL_DESCRIBE.get(objName).getDescribe();
			for (Schema.SObjectField fieldResult : objectDescribe.fields.getMap().values())
			{
				Schema.DescribeFieldResult results = fieldResult.getDescribe();
				if (results.isRestrictedPicklist() || results.getType() == Schema.DisplayType.PICKLIST)
				{
					List<PicklistValue> values = new List<PicklistValue>();
					for (Schema.PicklistEntry entry : results.getPicklistValues())
					{
						if (entry.isActive())
						{
							values.add(new PicklistValue(entry));
						}
					}
					outputResults.put(results.getName(), values);
				}
			}
		}
		return outputResults;
	}

	public static Map<String, List<PicklistValue>> getPicklistValuesForRecordTypes(List<String> objectsAPINames)
	{
		final String RECORD_TYPE_MARKER = 'RecordType';
		Map<String, List<PicklistValue>> outputResults = new Map<String, List<PicklistValue>>();

		List<PicklistValue> rtValues = new List<PicklistValue>();
		for (String objName : objectsAPINames)
		{
			Schema.DescribeSobjectResult objectDescribe = GLOBAL_DESCRIBE.get(objName).getDescribe();
			for (Schema.RecordTypeInfo theInfo : objectDescribe.getRecordTypeInfos())
			{
				if (theInfo.isAvailable() && !theInfo.isMaster())
				{
					rtValues.add(new PicklistValue(theInfo));
				}
			}
		}
		outputResults.put(RECORD_TYPE_MARKER, rtValues);
		return outputResults;
	}

	public static Map<String, List<PicklistValue>> getPicklistValuesForObject(String objectAPiName)
	{
		final List<String> objectApiNames = new List<String> {objectAPiName};
		Map<String, List<EUR_ISP_Utils.PicklistValue>> outputResults = new Map<String, List<EUR_ISP_Utils.PicklistValue>>();
		outputResults.putAll(
		    EUR_ISP_Utils.getPicklistValues(objectApiNames)
		);
		outputResults.putAll(
		    EUR_ISP_Utils.getPicklistValuesForRecordTypes(objectApiNames)
		);
		return outputResults;
	}

	/**
	 *	Get set of modified objects by defined list of modified fields.
	 */
	public static Set<sObject> getModifiedObjects(List<String> fieldsList, List<sObject> newObjects, Map<Id, sObject> oldObjectsMap)
	{
		Set<sObject> theResult = new Set<sObject>();
		if (newObjects != null)
		{
			for (sObject newObj : newObjects)
			{
				sObject oldObj = (oldObjectsMap != null) ? oldObjectsMap.get(newObj.Id) : null;
				if (oldObj == null)
				{
					theResult.add(newObj);
				}
				else
				{
					for (String aField : fieldsList)
					{
						if (newObj.get(aField) != oldObj.get(aField))
						{
							theResult.add(newObj);
						}
					}
				}
			}
		}
		else if (oldObjectsMap != null)
		{
			theResult.addAll(oldObjectsMap.values());
		}
		return theResult;
	}

	public class PicklistValue
	{
		@AuraEnabled
		public String value {get; set;}
		@AuraEnabled
		public String label {get; set;}

		public PicklistValue(Sobject theObject)
		{
			this.value = theObject.id;
			this.label = (String)theObject.get('Name');
		}

		public PicklistValue(Schema.RecordTypeInfo theInfo)
		{
			this.value = theInfo.getRecordTypeId();
			this.label = theInfo.getName();
		}

		public PicklistValue(Schema.PicklistEntry entry)
		{
			this.label = entry.getLabel();
			this.value = entry.getValue();
		}
	}

	public class AppConfigurationSettings
	{
		@AuraEnabled
		public Map<String, ObjectPermission> objectPermissions {get; set;}
		@AuraEnabled
		public List<EUR_ISP_SystemSettings__c> settings {get; set;}
		@AuraEnabled
		public User theUser {get; set;}
		@AuraEnabled
		public String projectName {get; set;}

		public AppConfigurationSettings()
		{
			this.objectPermissions = new Map<String, ObjectPermission>();
			this.settings = new List<EUR_ISP_SystemSettings__c>();
		}
	}

	public class ObjectPermission
	{
		@AuraEnabled
		public String sObjectName {get; set;}
		@AuraEnabled
		public EUR_ISP_Utils.ObjectCRUDPermission theObject {get; set;}
		@AuraEnabled
		public Map<String, EUR_ISP_Utils.FieldPermission> fields {get; set;}

		public ObjectPermission(Schema.DescribeSObjectResult objectDescribe)
		{
			this.sObjectName = objectDescribe.getName();
			this.theObject = new EUR_ISP_Utils.ObjectCRUDPermission(objectDescribe);
			this.fields = new Map<String, EUR_ISP_Utils.FieldPermission>();

			for (Schema.SObjectField field : objectDescribe.fields.getMap().values())
			{
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
				this.fields.put(fieldDescribe.getName(), new EUR_ISP_Utils.FieldPermission(fieldDescribe));
			}
		}
	}

	public class ObjectCRUDPermission
	{
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public String labelPlural {get; set;}
		@AuraEnabled
		public Boolean isAccessible {get; set;}
		@AuraEnabled
		public Boolean isDeletable {get; set;}
		@AuraEnabled
		public Boolean isCreateable {get; set;}
		@AuraEnabled
		public Boolean isUpdateable {get; set;}
		@AuraEnabled
		public List<EUR_ISP_Utils.PicklistValue> recordTypes {get; set;}
		@AuraEnabled
		public List<EUR_ISP_Utils.PicklistValue> recordTypesFull {get; set;}

		public ObjectCRUDPermission(Schema.DescribeSObjectResult objectDescribe)
		{
			this.label = objectDescribe.getLabel();
			this.labelPlural = objectDescribe.getLabelPlural();
			this.isAccessible = objectDescribe.isAccessible();
			this.isDeletable = objectDescribe.isDeletable();
			this.isCreateable = objectDescribe.isCreateable();
			this.isUpdateable = objectDescribe.isUpdateable();
			this.setRecordTypes(objectDescribe);
		}

		private void setRecordTypes(Schema.DescribeSObjectResult objectDescribe)
		{
			this.recordTypes = new List<EUR_ISP_Utils.PicklistValue>();
			this.recordTypesFull = new List<EUR_ISP_Utils.PicklistValue>();
			for (Schema.RecordTypeInfo theInfo : objectDescribe.getRecordTypeInfos())
			{
				if (theInfo.isAvailable() && !theInfo.isMaster())
				{
					this.recordTypes.add(new EUR_ISP_Utils.PicklistValue(theInfo));
				}
				if (!theInfo.isMaster())
				{
					this.recordTypesFull.add(new EUR_ISP_Utils.PicklistValue(theInfo));
				}
			}
		}
	}

	public class FieldPermission
	{
		@AuraEnabled
		public Boolean isAccessible {get; set;}
		@AuraEnabled
		public Boolean isCreateable {get; set;}
		@AuraEnabled
		public Boolean isDefaultedOnCreate {get; set;}
		@AuraEnabled
		public Boolean isNillable {get; set;}
		@AuraEnabled
		public Boolean isUpdateable {get; set;}
		@AuraEnabled
		public String helpText {get; set;}
		@AuraEnabled
		public String label {get; set;}
		@AuraEnabled
		public List<EUR_ISP_Utils.PicklistValue> picklistValues {get; set;}
		@AuraEnabled
		public Map<String, String> picklistValuesMap {get; set;}

		public FieldPermission(Schema.DescribeFieldResult fieldDescribe)
		{
			this.isAccessible = fieldDescribe.isAccessible();
			this.isCreateable = fieldDescribe.isCreateable();
			this.isDefaultedOnCreate = fieldDescribe.isDefaultedOnCreate();
			this.isNillable = fieldDescribe.isNillable();
			this.isUpdateable = fieldDescribe.isUpdateable();
			this.helpText = fieldDescribe.getInlineHelpText();
			this.label = fieldDescribe.getLabel();
			this.setPicklistValues(fieldDescribe);
		}

		private void setPicklistValues(Schema.DescribeFieldResult fieldDescribe)
		{
			this.picklistValues = new List<EUR_ISP_Utils.PicklistValue>();
			this.picklistValuesMap = new Map<String, String>();
			if (fieldDescribe.isRestrictedPicklist() || fieldDescribe.getType() == Schema.DisplayType.PICKLIST)
			{
				for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues())
				{
					if (entry.isActive())
					{
						this.picklistValuesMap.put(entry.getValue(), entry.getLabel());
						this.picklistValues.add(new EUR_ISP_Utils.PicklistValue(entry));
					}
				}
			}
		}
	}
}