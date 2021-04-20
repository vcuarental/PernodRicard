/***************************************************************************************************************************
 * Name:        DataRowCmpCtrl
 * Description:
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??????????		???????????				Created
 * 2019-06-13		Wilson Chow				Bug Fix: add save point for rollback & add error
 ****************************************************************************************************************************/

public with sharing class ASI_CRM_JP_DataTableController{

	private static final String ACTION_PARAMETER_SELECT_FIELDS = 'selectFields';
	private static final String ACTION_PARAMETER_SOBJECT_NAME = 'sObjectName';
	private static final String ACTION_PARAMETER_CRITERIA = 'criteria';
	private static final String ACTION_PARAMETER_PAGE_REQUEST = 'pageRequest';

	private static final String CRITERIA_FIELD = 'field';
	private static final String CRITERIA_KEYWORD = 'keyword';
	private static final String CRITERIA_OPERATOR = 'operator';
	private static final String CRITERIA_OPERATOR_LIKE = 'like';
	private static final String CRITERIA_OPERATOR_EQUALS = '=';
	private static final String CRITERIA_OPERATOR_BETWEEN = 'Range';
	private static final String CRITERIA_OPERATOR_GREATER_THAN = '>';
	private static final String CRITERIA_OPERATOR_LESSER_THAN = '<';

	public ASI_CRM_JP_DataTableService.PageRequest pageRequest{
		get; set;
	}

	public String pageRequestString{
		get{
			return JSON.serialize(pageRequest);
		} set;
	}

	public Id attributeRecordId{
		get; set;
	}

    @testVisible
	public String recordsJsonString{
		get {
			return JSON.serialize(records);
		}
	}
	@testVisible
	public String clonedRecordsJsonString{
		get {
			return JSON.serialize(clonedRecords);
		}
	}
	@testVisible
	public String unSavedRecordsJsonString{
		get {
			return JSON.serialize(unSavedRecords);
		} set;
	}

	public List<SObject> records;
	public List<SObject> clonedRecords = new List<SObject>();
	public List<SObject> unSavedRecords = new List<SObject>();
	public List<Id> deleteRecordIds = new List<Id>();
	public List<SObject> deleteRecords = new List<SObject>();


	public Boolean hasError {get;set;}

	public ASI_CRM_JP_DataTableController() {
		pageRequest = new ASI_CRM_JP_DataTableService.PageRequest();
	}

	public PageReference findRecords() {

		final PageReference pageReference;
		final Map <String, String> parameters = ApexPages.currentPage().getParameters();
		system.debug('parameters:' + parameters);
		final String pageRequestJsonString = parameters.get(ACTION_PARAMETER_PAGE_REQUEST);
		system.debug('pageRequestJsonString:' + pageRequestJsonString);
		final ASI_CRM_JP_DataTableService.PageRequest pr =
				ASI_CRM_JP_DataTableService.deserializePageRequest(pageRequestJsonString);
		system.debug('pr:' + pr);
		//		unSavedRecords = (List<SObject>) JSON.deserializeStrict(unSavedRecordsJsonString, List<SObject>.class);

		pageRequest = pr;
		records = getResults();

		return pageReference;
	}
	
	public PageReference updateRecords() {

		final PageReference pageReference;
		final SObjectType objectType = ASI_CRM_QueryUtil.getSObjectTypeByName(pageRequest.getsObjectName());
		final Map <String, String> parameters = ApexPages.currentPage().getParameters();
		final String recordListJsonString = parameters.get('recordList');
		final String clonedRecordListJsonString = parameters.get('clonedRecordList');
		final String addedRecordListJsonString = parameters.get('addedRecordList');
		final String addedClonedRecordListJsonString = parameters.get('addedClonedRecordList');

		List<SObject> records;
		List<SObject> clonedRecordList;
		List<SObject> addedRecordList;
		List<SObject> addedClonedRecordList;
		List<SObject> recordsToInsert = new List<sObject>();
		try {
			if(String.isNotBlank(recordListJsonString)) {
                records = (List<SObject>) JSON.deserializeStrict(recordListJsonString, List<SObject>.class);
			}
			if(String.isNotBlank(clonedRecordListJsonString)) {
                clonedRecordList = (List<SObject>) JSON.deserializeStrict(clonedRecordListJsonString, List<SObject>.class);

				if(clonedRecordList != null && !clonedRecordList.isEmpty()) {clonedRecordList = updateMissingFields(clonedRecordList, objectType);
					if (clonedRecordList != null & !clonedRecordList.isEmpty()) {recordsToInsert.addAll(clonedRecordList);
					}
				}
			}
			if(String.isNotBlank(addedRecordListJsonString)) {
				addedRecordList = (List<SObject>) JSON.deserializeStrict(addedRecordListJsonString, List<SObject>.class);

				if (addedRecordList != null & !addedRecordList.isEmpty()) {
					recordsToInsert.addAll(addedRecordList);
				}
			}
			if(String.isNotBlank(addedClonedRecordListJsonString)) {
				addedClonedRecordList = (List<SObject>) JSON.deserializeStrict(addedClonedRecordListJsonString, List<SObject>.class);
			}
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
			ASI_CRM_PageUtil.showError(e.getMessage());
			hasError = true;
		}

		System.Savepoint sp = database.setSavepoint();

		if(recordsToInsert != null && recordsToInsert.size() > 0) {
			try {
				System.debug(recordsToInsert);
				Database.insert(recordsToInsert);
//				Database.insert(recordsToInsert, false);
//				insert recordsToInsert;
			} catch (DmlException dmle) {
				Integer numOfError = dmle.getNumDml();
				for (Integer i = 0; i < numOfError; i++) {
					sObject errorSObj = recordsToInsert.get(dmle.getDmlIndex(i));
					errorSObj.addError(dmle.getDmlMessage(i));
				}
				database.rollback(sp);
				System.debug('rollback at recordsToInsert');
				hasError = true;
				return null;
			} catch (Exception e) {
				System.debug(e.getStackTraceString());
				System.debug(e.getMessage());
				ASI_CRM_PageUtil.showError(e.getMessage());
				database.rollback(sp);
				hasError = true;
				return null;
			}
		}
		if(records != null && records.size() > 0) {
			try {
				System.debug(records.size());
				System.debug(records);
				Database.update(records);
//				Database.update(records, false);
//				update records;
			} catch (DmlException dmle) {
				Integer numOfError = dmle.getNumDml();
				for (Integer i = 0; i < numOfError; i++) {sObject errorSObj = records.get(dmle.getDmlIndex(i));
					errorSObj.addError(dmle.getDmlMessage(i));
				}
				database.rollback(sp);
				System.debug('rollback at records');
				hasError = true;
				return null;
			} catch (Exception e) {
				System.debug(e.getStackTraceString());
				System.debug(e.getMessage());
				ASI_CRM_PageUtil.showError(e.getMessage());
				database.rollback(sp);
				hasError = true;
				return null;
			}
		}

		if(deleteRecords != null && deleteRecords.size() > 0) {
			try {
//				deleteRecordByIds(pageRequest.getsObjectName(), deleteRecordIds);
				Database.delete(deleteRecords);
			} catch (DmlException dmle) {
				Integer numOfError = dmle.getNumDml();
				for (Integer i = 0; i < numOfError; i++) {sObject errorSObj = deleteRecords.get(dmle.getDmlIndex(i));
					errorSObj.addError(dmle.getDmlMessage(i));
				}
				database.rollback(sp);
				System.debug('rollback at deleteRecords');
				hasError = true;
				return null;
			} catch (Exception e) {
				System.debug(e.getStackTraceString());
				System.debug(e.getMessage());
				ASI_CRM_PageUtil.showError(e.getMessage());
				database.rollback(sp);
				hasError = true;
				return null;
			}
		}

//		ASI_CRM_PageUtil.showInfo('Records updated');
		hasError = false;
		return pageReference;
        
	}

	public PageReference cloneRecord() {
		final PageReference pageReference;
		final Map <String, String> parameters = ApexPages.currentPage().getParameters();
        system.debug('parameters'+parameters);
		final Id recordId = parameters.get('recordId');
		system.debug('recordId'+recordId);
		final SObject clonedRecord = ASI_CRM_JP_DataTableService.cloneRecord(recordId);
		clonedRecords.add(clonedRecord);

		return pageReference;
	}

	public PageReference deleteRecord() {

		final PageReference pageReference;
		final Map <String, String> parameters = ApexPages.currentPage().getParameters();
		system.debug('parameters'+parameters);
        final String recordJsonString = parameters.get('record');
        system.debug('recordJsonString'+recordJsonString);
		final SObject record = (SObject) JSON.deserializeStrict(recordJsonString, SObject.class);
        System.debug('record'+record);
		deleteRecords.add(record);
		System.debug('deleteRecords:' + deleteRecords);
		deleteRecordIds.add(record.Id);
		System.debug(deleteRecordIds);

		return pageReference;
	}

	public PageReference redirectToRecord() {

		final PageReference pageReference = new PageReference('/' + attributeRecordId);
		pageReference.setRedirect(true);
		return pageReference;
	}
@testVisible
	private List<SObject> getResults() {

		String excludeItemsToDeleteCriteria = '';

		if (!deleteRecordIds.isEmpty()) {
			excludeItemsToDeleteCriteria = ' Id NOT IN ' + ASI_CRM_JP_DataTableService.getListForQuery(deleteRecordIds);
		}

		final List<String> customCriterion = new List<String>();

		if (String.isNotBlank(pageRequest.getCustomCriteria())) customCriterion.add(pageRequest.getCustomCriteria());
		if (String.isNotBlank(excludeItemsToDeleteCriteria)) customCriterion.add(excludeItemsToDeleteCriteria);

		pageRequest.setCustomCriteria(String.join(customCriterion, ' AND '));

		final String queryString = ASI_CRM_JP_DataTableService.getQueryString(pageRequest);
		System.debug(queryString);

		return Database.query(queryString);
	}

    @TestVisible
	private static void deleteRecordByIds(String sObjectName, List<Id> recordIds) {
		if (recordIds.isEmpty()) return ;

		final String queryToRetrieveRecordsToDelete =
				'SELECT Id FROM ' + sObjectName + ' WHERE Id IN ' +
				ASI_CRM_JP_DataTableService.getListForQuery(recordIds);

		Database.delete(Database.query(queryToRetrieveRecordsToDelete));

	}

	private static List<SObject> updateMissingFields(List<SObject> clonedRecordList, SObjectType objectType) {
		final List<String> cloneSourceIds = ASI_CRM_Util.getPropertyList(clonedRecordList, 'Id');
		final String query = ASI_CRM_QueryUtil.getSelectAllFieldsQueryString(
				objectType, 'WHERE Id in :cloneSourceIds'
		);
		final Map<String, SObject> fieldObjectMap = ASI_CRM_Util.getFieldObjectMap(Database.query(query), 'Id');
		final List<SObject> cloneObjectList = new List<SObject>();
		if(clonedRecordList != null && !clonedRecordList.isEmpty()) {
			for (SObject so : clonedRecordList) {
				final SObject originalObject = fieldObjectMap.get(String.valueOf(so.get('Id')));
				final SObject clonedObject = originalObject.clone(false, true, false, false);
				final List<String> sObjectFieldList = ASI_CRM_QueryUtil.getSObjectFieldList(
						objectType
				);

				for (String field : sObjectFieldList) {
					if (so.get(field) != null &&
							objectType.getDescribe().fields.getMap().get(field).getDescribe().isCreateable() &&
							objectType.getDescribe().fields.getMap().get(field).getDescribe().isUpdateable()
							) {
						//					so.put(field, originalObject.get(field));
						clonedObject.put(field, so.get(field));
					}
				}
				cloneObjectList.add(clonedObject);
			}
		}
		return cloneObjectList;
	}

	// FROM ASI_CRM_Payment_Invoice_Line_Item__c
	// WHERE (ASI_CRM_Payment_Invoice__c = 'aBMM0000000CbUSOA0') AND (RecordTypeId = '')
	// ORDER BY Name
}