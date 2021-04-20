trigger EUR_CRM_AttachmentTrigger on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	new EUR_CRM_AttachmentHandler().run();
}