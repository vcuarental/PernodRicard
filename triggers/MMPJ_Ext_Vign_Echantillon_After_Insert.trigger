trigger MMPJ_Ext_Vign_Echantillon_After_Insert on MMPJ_Ext_Vign_Echantillon__c (after insert) {
	MMPJ_Ext_Vign_Notifications.createAnalyseNotification(trigger.new);
}