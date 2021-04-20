@isTest
private class MMPJ_Ext_Vign_BatchDeleteNotifDocs_TEST {
    static testMethod void MMPJ_Ext_Vign_BatchDeleteNotifDocs_TEST() {
        
        Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
		
		MMPJ_Ext_Vign_Societe__c acc1 = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert acc1;

		List<MMPJ_Ext_Vign_Documents_Fournis__c> docs = new List<MMPJ_Ext_Vign_Documents_Fournis__c>();
		for(Integer i = 0;i<200;i++)
			docs.add(new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c=acc1.id));

		insert docs;

    	List<MMPJ_Ext_Vign_Notification_Document__c> notifs = new List<MMPJ_Ext_Vign_Notification_Document__c>();
		for(Integer i = 0;i<200;i++)
			notifs.add(new MMPJ_Ext_Vign_Notification_Document__c(MMPJ_Ext_Vign_Document_fournis__c=docs[i].Id,MMPJ_Ext_Vign_Lu__c=true));
		insert notifs;

        test.startTest();

        MMPJ_Ext_Vign_BatchDeleteNotifDocs batch1 = new MMPJ_Ext_Vign_BatchDeleteNotifDocs();
        batch1.createdDateStart = System.now().addDays(2);

        ID batchprocessid = Database.executeBatch(batch1);

        test.stopTest();

        System.assertEquals(0,[select count() from MMPJ_Ext_Vign_Notification_Document__c where MMPJ_Ext_Vign_Document_fournis__c IN:docs]);


        MMPJ_Ext_Vign_BatchDeleteNotifDocs batch2 = new MMPJ_Ext_Vign_BatchDeleteNotifDocs();
        ID batchprocessid2 = Database.executeBatch(batch2);
            
    }
}