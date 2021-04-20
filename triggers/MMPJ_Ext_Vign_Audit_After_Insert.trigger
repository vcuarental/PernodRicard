trigger MMPJ_Ext_Vign_Audit_After_Insert on MMPJ_Ext_Vign_Audit__c (after insert) {
	MMPJ_Ext_Vign_Notifications.createAuditNotification(trigger.new);
}