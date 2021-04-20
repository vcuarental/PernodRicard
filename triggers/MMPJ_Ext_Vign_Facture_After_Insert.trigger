trigger MMPJ_Ext_Vign_Facture_After_Insert on MMPJ_Ext_Vign_Facture__c (after insert) {
	MMPJ_Ext_Vign_Notifications.createFactureNotification(trigger.new);
}