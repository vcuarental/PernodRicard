global with sharing class ASI_KOR_ParentChildEditHelper {
	
	private static final String ERR_MSG_TIME_CONFLICT = 'Record is changed after previous sync';
	private String sObjTypeStr;
	private sObject parentRecord;
	private Schema.SObjectField upsertFieldSchema;
	private List<ASI_KOR_ChildRecords> childRecordLists;
	private Set<ID> allChildRecordIdSet;
	
	global ASI_KOR_ParentChildEditHelper(String sObjTypeStr, sObject parentRecord) {
		this(sObjTypeStr, parentRecord, null);
	}
	
	global ASI_KOR_ParentChildEditHelper(String sObjTypeStr, sObject parentRecord, Schema.SObjectField upsertFieldSchema) {
		this.sObjTypeStr = sObjTypeStr;
		this.parentRecord = parentRecord;
		this.upsertFieldSchema = upsertFieldSchema;
		this.childRecordLists = new List<ASI_KOR_ChildRecords>();
		this.allChildRecordIdSet = new Set<ID>();
		System.debug(parentRecord);
	}
	
	global void addChildRecords(String sObjTypeStr, String parentFieldName, String childRelationName, List<sObject> childRecords) {
		if (childRecords == null) childRecords = new List<sObject>();
		this.childRecordLists.add(new ASI_KOR_ChildRecords(sObjTypeStr, parentFieldName, childRelationName, childRecords));
		for (sObject child : childRecords)
			System.debug(child);
		for (sObject cr : childRecords) {
			ID crId = cr.Id;
			if (crId != null) {
				this.allChildRecordIdSet.add(crId);
			}
		}
	}
	
	global sObject commitChanges() {
		List<List<sObject>> deleteChildRecordLists = new List<List<sObject>>();
		ID parentRecordId = parentRecord.Id;
		// Query existing record to see which child records should be deleted
		List<String> childSOQLs = new List<String>();
		for (ASI_KOR_ChildRecords child : childRecordLists) {
			childSOQLs.add(child.genChildSOQL());
		}
		String queryStr = 'SELECT Id, LastModifiedDate'
			+ (childSOQLs.size() == 0 ? '' : ',(' + String.join(childSOQLs, '),(') + ')')
			+ ' FROM ' + this.sObjTypeStr
			+ ' WHERE Id = :parentRecordId';
		if (parentRecordId != null) {
			List<sObject> parentAndChildsList = database.query(queryStr);
			// Handle each child record type one by one
			if (parentAndChildsList.size() > 0) {
				sObject parentAndChilds = parentAndChildsList.get(0);
				// Check time conflict
				if ((Datetime)parentAndChilds.get('LastModifiedDate') > (Datetime)this.parentRecord.get('LastModifiedDate')) {
					throw new ASI_KOR_CustomException(ERR_MSG_TIME_CONFLICT);
				}
				for (ASI_KOR_ChildRecords childRecords : childRecordLists) {
					List<sObject> deleteRecords = new List<sObject>();
					List<sObject> queryRecords = parentAndChilds.getSObjects(childRecords.childRelationName);
					if (queryRecords != null) {
						Map<ID, sObject> submitChildRecordMap = childRecords.getChildRecordMap();
						for (sObject queryRecord : queryRecords) {
							// Check time conflict
							sObject submitChildRecord = submitChildRecordMap.get(queryRecord.Id);
							if (submitChildRecord != null && (Datetime)queryRecord.get('LastModifiedDate') > ((Datetime)submitChildRecord.get('LastModifiedDate')).addSeconds(1)) { // Add one second due to inaccuracy
								throw new ASI_KOR_CustomException(ERR_MSG_TIME_CONFLICT);
							}
							if (!this.allChildRecordIdSet.contains(queryRecord.Id)) {
								deleteRecords.add(queryRecord);
							}
						}
					}
					if (deleteRecords.size() > 0)
						deleteChildRecordLists.add(deleteRecords);
				}
			}
		}
		System.Savepoint sp = database.setSavepoint();
		try {
			// Upsert parent record
			if (upsertFieldSchema == null)
				upsert parentRecord;
			else
				database.upsert(parentRecord, upsertFieldSchema);
			
			parentRecordId = parentRecord.Id;
			
			// Delete child records
			if (deleteChildRecordLists.size() > 0) {
				for (List<sObject> deleteRecords : deleteChildRecordLists) {
					delete deleteRecords;
				}
			}
			
			// Upsert child records
			for (ASI_KOR_ChildRecords cr : childRecordLists) {
				if (cr.childRecords.size() > 0) {
					// Assign parent ID if needed
					List<sObject> theChildRecords = cr.childRecords;
					String parentFieldName = cr.parentFieldName;
					for (sObject child : theChildRecords) {
						try {
							if (child.get(parentFieldName) == null)
								child.put(parentFieldName, parentRecordId);
						} catch (SObjectException soe) {
							child.put(parentFieldName, parentRecordId);
						}
					}
					upsert theChildRecords;
				}
			}
		} catch (Exception e) {
			database.rollback(sp);
			String errorMsg = 'Unknown Error';
			if (!(e instanceof DmlException)) {
				errorMsg = e.getMessage();
			} else {
				DmlException dmle = (DmlException)e;
				Integer numOfErrors = dmle.getNumDml();
				Set<String> errMsgs = new Set<String>();
				for (Integer i = 0; i < numOfErrors; i++) {
					errMsgs.add(dmle.getDmlMessage(i));
					// Show at most 10 different errors
					if (errMsgs.size() > 10)
						break;
				}
				if (errMsgs.size() > 0) {
					errorMsg = '';
					for (String tempErrMsg : errMsgs) {
						errorMsg += tempErrMsg + '\n';
					}
				}
			}
			throw new ASI_KOR_CustomException(errorMsg);
		}
		System.debug('parentRecordId: ' + parentRecordId);
		List<sObject> returnResults = database.query(queryStr);
		if (returnResults.size() > 0) {
			// TODO: Follow the order of input child records
			return returnResults.get(0);
		}
		return null;
	}
	
	private with sharing class ASI_KOR_ChildRecords {
		public String sObjTypeStr;
		public String parentFieldName;
		public String childRelationName;
		public List<sObject> childRecords;
		
		public ASI_KOR_ChildRecords(String sObjTypeStr, String parentFieldName, String childRelationName, List<sObject> childRecords) {
			this.sObjTypeStr = sObjTypeStr;
			this.parentFieldName = parentFieldName;
			this.childRelationName = childRelationName;
			this.childRecords = childRecords;
		}
		
		public String genChildSOQL() {
			return 'SELECT Id, LastModifiedDate FROM ' + childRelationName;
		}
		
		public Map<ID, sObject> getChildRecordMap() {
			Map<ID, sObject> resultMap = new Map<ID, sObject>();
			for (sObject childRecord : childRecords) {
				if (childRecord.Id != null) {
					resultMap.put(childRecord.Id, childRecord);
				}
			}
			return resultMap;
		}
	}
}