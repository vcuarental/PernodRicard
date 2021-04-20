@isTest
private class PJ_ByFor_Batch_DeleteAttachments_TEST {

    static testMethod void AP01FichierTemporaire_Batch_TEST() {
		List<PJ_ByFor_AttachmentFile__c> fichiers = new List<PJ_ByFor_AttachmentFile__c>();
		for(Integer i=0;i<200;i++)
			fichiers.add(new PJ_ByFor_AttachmentFile__c());
		insert fichiers;
		test.startTest();
		PJ_ByFor_Batch_DeleteAttachments bacth1 = new PJ_ByFor_Batch_DeleteAttachments();
		ID batchprocessid = Database.executeBatch(bacth1);
		test.stopTest();
    }
}