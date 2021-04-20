public with sharing class EUR_CRM_AttachmentService {

	public class ContractsUpdater {
		private EUR_CRM_AttachmentService parent;
		private Selector selector;
		private final Set<SObjectType> SOBJECTS_TO_UPDATE = new Set<SObjectType>{
			EUR_CRM_Contract__c.SObjectType
		};

		public ContractsUpdater() {
			this.parent = new EUR_CRM_AttachmentService();
			this.selector = new Selector();
		}

		private final Set<String> VALID_RTS = new Set<String>{
			'EUR_DE_Contract',
			'EUR_GB_Contract',
			'EUR_FI_Chain_Contract',
			'EUR_FI_Independent_Contract'
		};

		public void updateContractUploadedField(final List<Attachment> records, final Map<Id, Attachment> oldRecordById) {
			final List<Attachment> contractAttachments = parent.getAttachmentsIfParentSObjectTypes(records, this.SOBJECTS_TO_UPDATE);
			if (contractAttachments.isEmpty()) { return; }

			final Set<Id> contractIds = this.getContractIds(contractAttachments, oldRecordById);
			if (contractIds.isEmpty()) { return; }

			final List<EUR_CRM_Contract__c> contractsForUpdate = new List<EUR_CRM_Contract__c>();

			final Map<Id, EUR_CRM_Contract__c> contractById = new Map<Id, EUR_CRM_Contract__c>(selector.selectContractsWhereIdsAndRTs(contractIds, VALID_RTS));
			final Set<Id> contractIdsForValidation = new Set<Id>();
			for (Attachment att : contractAttachments) {
				EUR_CRM_Contract__c contract = contractById.get(att.ParentId);
				if (contract == null) { continue; }
				String fileName = contract.EUR_CRM_Contract_Copy_File_Name__c;
				if (this.isStringContains(att, fileName) && ! this.isContractUploaded(contract)) {
					contract.EUR_CRM_Contract_Uploaded__c = true;
					contractsForUpdate.add(contract);
				} else if (oldRecordById != null) {
					contractIdsForValidation.add(contract.Id);
				}
			}

			if (!contractIdsForValidation.isEmpty()) {
				final Set<Id> contractIdsToUncheckUploaded = new Set<Id>(contractIdsForValidation);

				List<Attachment> attachmentsOfContractsForValidation = selector.selectAttachmentsWhereParentIds(contractIdsForValidation);
				Set<Id> parentIds = this.getParentIdsIfNameContainsContractCopyFileName(attachmentsOfContractsForValidation, contractById);
				contractIdsToUncheckUploaded.removeAll(parentIds);

				if (!contractIdsToUncheckUploaded.isEmpty()) {
					for (Id contractId : contractIdsToUncheckUploaded) {
						EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(Id = contractId, EUR_CRM_Contract_Uploaded__c = false);
						contractsForUpdate.add(contract);
					}
				}
			}

			if (!contractsForUpdate.isEmpty()) {
				update contractsForUpdate;
			}
		}

		public void updateContractUploadedField(final List<Attachment> oldRecords) {
			final List<EUR_CRM_Contract__c> contractForUpdate = new List<EUR_CRM_Contract__c>();

			final List<Attachment> contractAttachments = parent.getAttachmentsIfParentSObjectTypes(oldRecords, this.SOBJECTS_TO_UPDATE);
			if (contractAttachments.isEmpty()) { return; }

			final Set<Id> contractIdsOfDeletedAttachments = this.getContractIds(contractAttachments, null);

			final Map<Id, EUR_CRM_Contract__c> contractById = new Map<Id, EUR_CRM_Contract__c>(selector.selectContractsWhereIdsAndRTs(contractIdsOfDeletedAttachments, VALID_RTS));

			final List<Attachment> notDeletedAttachments = selector.selectNotDeletedAttachmentsWhereParentIds(contractById, oldRecords);
			final Set<Id> parentIdsOfNotDeletedAttachments = this.getParentIdsIfNameContainsContractCopyFileName(notDeletedAttachments, contractById);

			final List<Attachment> allAttachments = selector.selectAttachmentsWhereParentIds(contractIdsOfDeletedAttachments);
			final Set<Id> allContractIds = this.getParentIdsIfNameContainsContractCopyFileName(allAttachments, contractById);

			final Map<Id, EUR_CRM_Contract__c> uploadedContractById = new Map<Id, EUR_CRM_Contract__c>(this.getUploadedContracts(contractById));

			for (Id contractId : contractIdsOfDeletedAttachments) {
				if (!allContractIds.contains(contractId) &&
					!parentIdsOfNotDeletedAttachments.contains(contractId) &&
					uploadedContractById.containsKey(contractId)) {
					EUR_CRM_Contract__c updatedContract = new EUR_CRM_Contract__c(Id = contractId, EUR_CRM_Contract_Uploaded__c = false);
					contractForUpdate.add(updatedContract);
				}
			}
			if (!contractForUpdate.isEmpty()) {
				update contractForUpdate;
			}
		}


		//Helpers
		private Set<Id> getContractIds(final List<Attachment> records, final Map<Id, Attachment> oldRecordById) {
			final Set<Id> contractIds = new Set<Id>();
			for (Attachment att : records) {
				if (this.SOBJECTS_TO_UPDATE.contains(att.ParentId.getSobjectType())) {
					if (oldRecordById == null || oldRecordById.isEmpty()) {
						contractIds.add(att.ParentId);
					} else if (this.isAttachmentNameChanged(att, oldRecordById)) {
						contractIds.add(att.ParentId);
					}
				}
			}
			return contractIds;
		}

		private Set<Id> getParentIdsIfNameContainsContractCopyFileName(final List<Attachment> attachments, final Map<Id, EUR_CRM_Contract__c> contractById) {
			final Set<Id> parentIds = new Set<Id>();
			for (Attachment att : attachments){
				final EUR_CRM_Contract__c contract = contractById.get(att.ParentId);
				if (contract == null) { continue; }
				final String fileName = contract.EUR_CRM_Contract_Copy_File_Name__c;
				if (this.isStringContains(att, fileName)){
					parentIds.add(att.ParentId);
				}
			}
			return parentIds;
		}

		private List<EUR_CRM_Contract__c> getUploadedContracts(final Map<Id, EUR_CRM_Contract__c> contractById) {
			final List<EUR_CRM_Contract__c> uploadedContracts = new List<EUR_CRM_Contract__c>();
			for (EUR_CRM_Contract__c contract : contractById.values()) {
				if (contract.EUR_CRM_Contract_Uploaded__c == true) {
					uploadedContracts.add(contract);
				}
			}
			return uploadedContracts;
		}

		private Boolean isAttachmentNameChanged(final Attachment att, final Map<Id, Attachment> oldRecordById) {
			return att.Name != oldRecordById.get(att.Id).Name;
		}

		private Boolean isContractUploaded(final EUR_CRM_Contract__c contract) {
			return contract.EUR_CRM_Contract_Uploaded__c != false;
		}

		private Boolean isStringContains(final Attachment att, final String fileName) {
			return String.isNotBlank(fileName) && att.Name.contains(fileName);
		}
	}


	public class SObjectsUpdater {
		private EUR_CRM_AttachmentService parent;
		private final Selector selector;

		private final Map<SObjectType, Set<Id>> IDS_BY_SOBJECT_TO_UPDATE = new Map<SObjectType, Set<Id>>{
			EUR_CRM_Account__c.SObjectType => new Set<Id>()
		,	EUR_CRM_Brand_Security_Infringement__c.SObjectType => new Set<Id>()
		,	EUR_CRM_Competitor_Promo_Tracking_Item__c.SObjectType => new Set<Id>()
		,	EUR_CRM_GB_Objective__c.SObjectType => new Set<Id>()
		,	EUR_CRM_POSM_Audit_Item__c.SObjectType => new Set<Id>()
		,	EUR_CRM_OP_Visit_Action__c.SObjectType => new Set<Id>()
		,	EUR_CRM_Visit_Action__c.SObjectType => new Set<Id>()
		,	EUR_CRM_Visit_Sub_Action__c.SObjectType => new Set<Id>()
		};

		private final String IS_PHOTO_ATTACHED_FIELD = 'EUR_CRM_IsPhotoAttached__c';
		private final Pattern regex = Pattern.compile('(?i)(.*png|.*jpg|.*jpeg)');

		public SObjectsUpdater() {
			this.parent = new EUR_CRM_AttachmentService();
			this.selector = new Selector();
		}

		public void updateIsPhotoAttachedAfterInsert(final List<Attachment> records) {
			//populate IDS_BY_SOBJECT_TO_UPDATE map
			this.populateIdsBySObjToUpdate(records);

			final Map<SObjectType, List<SObject>> sobjectToUpdateBySObjectType = this.getSobjectToUpdateBySObjectType();

			//Update sobjects checkbox to true
			for (SObjectType sobjectType : sobjectToUpdateBySObjectType.keySet()) {
				List<SObject> sObjects = sobjectToUpdateBySObjectType.get(sobjectType);
				for (SObject sobj : sObjects) {
					this.updateField(sobj, true);
				}
				//DML operation in the loop should not cause the error and used consciously (only 6 sobjects to proceed)
				Database.update(sObjects, false);
			}
		}

		public void updateIsPhotoAttachedAfterDelete(final List<Attachment> records) {
			this.updateIsPhotoAttached(records, false);
		}

		public void updateIsPhotoAttachedAfterUndelete(final List<Attachment> records) {
			this.updateIsPhotoAttached(records, true);
		}

		public void updateIsPhotoAttached(final List<Attachment> records, Boolean isPhotoAttached) {
			//populate IDS_BY_SOBJECT_TO_UPDATE map
			this.populateIdsBySObjToUpdate(records);

			//get aggregate result from all attachments by parentIds with IsPhotoAttached = true
			final Map<Id, Integer> attachmentsCountBySObjectId = this.getSObjIdByAttachmentsCount();

			final Map<SObjectType, List<SObject>> sobjectsToUpdateBySObjectType = this.updateSObjectsAndGetBySObjectType(attachmentsCountBySObjectId, isPhotoAttached);

			for (SObjectType sObjectType : sobjectsToUpdateBySObjectType.keySet()) {
				List<SObject> sObjects = sobjectsToUpdateBySObjectType.get(sObjectType);
				//DML operation in the loop should not cause the error (only 6 sobjects to proceed)
				Database.update(sObjects, false);
			}
		}



		//Helpers
		private Map<SObjectType, List<SObject>> getSobjectToUpdateBySObjectType() {
			final Map<SObjectType, List<SObject>> sobjectToUpdateBySObjectType = new Map<SObjectType, List<SObject>>();
			for (SObjectType sobjType : IDS_BY_SOBJECT_TO_UPDATE.keySet()) {
				Set<Id> parentIds = IDS_BY_SOBJECT_TO_UPDATE.get(sobjType);
				if (parentIds.isEmpty()) { continue; }

				//SOQL in the loop should not cause the error and used consciously
				sobjectToUpdateBySObjectType.put(sobjType, selector.selectSObjectsToUpdate(sobjType, parentIds, IS_PHOTO_ATTACHED_FIELD));
			}
			return sobjectToUpdateBySObjectType;
		}

		private Map<SObjectType, List<SObject>> updateSObjectsAndGetBySObjectType(Map<Id, Integer> attachmentsCountBySObjectId, Boolean isPhotoAttached) {
			final Map<SObjectType, List<SObject>> sobjectsToUpdateBySObjectType = new Map<SObjectType, List<SObject>>();
			for (SObjectType sObjectType : IDS_BY_SOBJECT_TO_UPDATE.keySet()) {
				Set<Id> parentIds = IDS_BY_SOBJECT_TO_UPDATE.get(sObjectType);
				for (Id parentId : parentIds) {
					if (attachmentsCountBySObjectId.containsKey(parentId)) { continue; }
					if ( ! sobjectsToUpdateBySObjectType.containsKey(sObjectType)) {
						sobjectsToUpdateBySObjectType.put(sObjectType, new List<SObject>());
					}
					sobjectsToUpdateBySObjectType.get(sObjectType).add(this.updateFieldById(parentId, sObjectType, isPhotoAttached));
				}
			}
			return sobjectsToUpdateBySObjectType;
		}

		private Map<Id, Integer> getSObjIdByAttachmentsCount() {
			final Map<Id, Integer> attachmentsCountBySObjectId = new Map<Id, Integer>();
			for (SObjectType sObjectType : IDS_BY_SOBJECT_TO_UPDATE.keySet()) {
				Set<Id> parentIds = IDS_BY_SOBJECT_TO_UPDATE.get(sObjectType);
				if (parentIds.isEmpty()) { continue; }

				//SOQL in the loop should not cause the error and used consciously
				for (AggregateResult ar : selector.aggregateAttachmentsWhereParentIds(sObjectType, parentIds, true)) {
					attachmentsCountBySObjectId.put((Id) ar.get('ParentId'), (Integer) ar.get('Attachments'));
				}
			}
			return attachmentsCountBySObjectId;
		}

		private SObject updateFieldById(Id sobjId, SObjectType sObjectType, Boolean isPhotoAttached) {
			SObject sobj = sObjectType.newSObject(sobjId);
			this.updateField(sobj, isPhotoAttached);
			return sobj;
		}

		private void populateIdsBySObjToUpdate(final List<Attachment> records) {
			for (Attachment record : records) {
				if (this.isNeedToUpdateParent(record)) {
					IDS_BY_SOBJECT_TO_UPDATE.get(record.ParentId.getSobjectType()).add(record.ParentId);
				}
			}
		}

		private void updateField(SObject sobj, Boolean value) {
			try {
				sobj.put(IS_PHOTO_ATTACHED_FIELD, value);
			} catch(Exception e) {
				System.debug('ERROR => ' + e.getMessage() + ' ' + e.getCause() + ' ' + e.getLineNumber());
			}
		}

		private Boolean isNeedToUpdateParent(Attachment record) {
			return IDS_BY_SOBJECT_TO_UPDATE.containsKey(record.ParentId.getSobjectType()) &&
				this.isImage(record);
		}

		private Boolean isImage(Attachment record) {
			return regex.matcher(record.Name).matches();
		}

	}


	//Helpers
	private List<Attachment> getAttachmentsIfParentSObjectTypes(final List<Attachment> records, final Set<SObjectType> sObjectTypes) {
		final List<Attachment> contractAttachments = new List<Attachment>();
		for (Attachment record : records) {
			if (sObjectTypes.contains(record.ParentId.getSobjectType())) {
				contractAttachments.add(record);
			}
		}
		return contractAttachments;
	}

	public class Selector {
		private List<EUR_CRM_Contract__c> selectContractsWhereIdsAndRTs(Set<Id> contractIds, Set<String> rts) {
			return [
				SELECT Id
					,   EUR_CRM_Contract_Uploaded__c
					,   EUR_CRM_Contract_Copy_File_Name__c
				FROM EUR_CRM_Contract__c
				WHERE Id IN :contractIds
				AND RecordType.DeveloperName IN :rts
			];
		}

		private List<Attachment> selectNotDeletedAttachmentsWhereParentIds(Map<Id, EUR_CRM_Contract__c> contractById, List<Attachment> oldRecords) {
			return [
				SELECT Id
					,   Name
					,   ParentId
				FROM Attachment
				WHERE ParentId IN :contractById.keySet()
				AND Id NOT IN :oldRecords
			];
		}

		private List<Attachment> selectAttachmentsWhereParentIds(Set<Id> contractIdForValidation) {
			return [
				SELECT Id
					,   Name
					,   ParentId
				FROM Attachment
				WHERE ParentId IN:contractIdForValidation];
		}

		private List<SObject> selectSObjectsToUpdate(SObjectType sObjectType, Set<Id> parentIds, String field) {
			return new EUR_CRM_QueryBuilder(sObjectType)
				.qbField(field)
				.qbCondition().add(
				new EUR_CRM_QueryBuilder.ComplexCondition()
					.startCondition(new EUR_CRM_QueryBuilder.InCondition('Id').inCollection(parentIds))
					.andCondition(new EUR_CRM_QueryBuilder.CompareCondition(field).eq(false))
					.build()
			)
				.endCondition()
				.toList();
		}

		private List<AggregateResult> aggregateAttachmentsWhereParentIds(SObjectType sObjectType, Set<Id> parentIds, Boolean isPhotoAttached) {
			String query = 'SELECT ParentId, count(Id) Attachments FROM Attachment ' +
				' WHERE Parent.Type = \'' + sObjectType + '\' ' +
				' AND (Name LIKE \'%png\' OR Name LIKE \'%jpg\' OR Name LIKE \'%jpeg\' ' +
				') ' +
				' AND ParentId IN ( ' +
				' SELECT Id FROM ' + sObjectType +
				' WHERE Id IN (\'' + String.join(new List<Id>(parentIds), '\', \'') + '\')' +
				' AND EUR_CRM_IsPhotoAttached__c = ' + isPhotoAttached +
				' ) ' +
				'GROUP BY ParentId';
			return Database.query(query);
		}

	}

}