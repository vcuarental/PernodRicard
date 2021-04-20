public with sharing class EUR_CRM_AttachmentHandler extends EUR_CRM_TriggerHandler {

	private final EUR_CRM_AttachmentService.ContractsUpdater contractService = new EUR_CRM_AttachmentService.ContractsUpdater();
	private final EUR_CRM_AttachmentService.SObjectsUpdater sobjectsService = new EUR_CRM_AttachmentService.SObjectsUpdater();

	protected override void beforeInsert() {

	}

	protected override void beforeUpdate() {
	}

	protected override void beforeDelete() {
	}

	protected override void afterInsert() {
		contractService.updateContractUploadedField(Trigger.new, null);
		sobjectsService.updateIsPhotoAttachedAfterInsert(Trigger.new);
	}

	protected override void afterUpdate() {
		contractService.updateContractUploadedField(Trigger.new, (Map<Id, Attachment>) Trigger.oldMap);
	}

	protected override void afterDelete() {
		contractService.updateContractUploadedField(Trigger.old);
		sobjectsService.updateIsPhotoAttachedAfterDelete(Trigger.old);
	}

	protected override void afterUndelete() {
		sobjectsService.updateIsPhotoAttachedAfterUndelete(Trigger.new);

	}



}