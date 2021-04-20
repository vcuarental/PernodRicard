@isTest
private class MMPJ_XRM_BatchSuppAnnuelleContrat_TEST {
    static testMethod void MMPJ_XRM_BatchSuppAnnuelleContrat_TEST() {
        

		Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Vigneron' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		insert societe;

		Id rtCourtier = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Courtier_Champagne' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c courtier = new MMPJ_Ext_Vign_Societe__c(Name='Courtier',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtCourtier);
		insert courtier;

		Id rtCentre = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Centre_de_pressurage' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c centre = new MMPJ_Ext_Vign_Societe__c(Name='Courtier',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtCentre);
		insert centre;

		MMPJ_Ext_Vign_Societe__c centre2 = new MMPJ_Ext_Vign_Societe__c(Name='Courtier 2',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtCentre);
		insert centre2;

		String RT_Id = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Contrat__c' and DeveloperName='MMPJ_Ext_Vign_Appro_Press' LIMIT 1].Id;
		List<MMPJ_Ext_Vign_Contrat__c> contrats = new List<MMPJ_Ext_Vign_Contrat__c>();
		for(Integer i=0;i<198;i++)
			contrats.add(new MMPJ_Ext_Vign_Contrat__c(Name = 'Test' + i,RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-36), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today(), MMPJ_Ext_Vign_Livreur__c=societe.id,MMPJ_Ext_Vign_Courtier__c=courtier.Id,MMPJ_XRM_Pressoir__c=centre.id,MMPJ_Ext_Vign_Contrat_Segmentation__c = 'Champagne',MMPJ_XRM_annee__c = String.valueOf(Date.today().year() - 1)));
		
		contrats.add(new MMPJ_Ext_Vign_Contrat__c(Name = 'Test 198',RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-36), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today(), MMPJ_Ext_Vign_Livreur__c=societe.id,MMPJ_Ext_Vign_Courtier__c=courtier.Id,MMPJ_XRM_Pressoir__c=centre2.id,MMPJ_Ext_Vign_Contrat_Segmentation__c = 'Champagne',MMPJ_XRM_annee__c = String.valueOf(Date.today().year() - 1)));

		contrats.add(new MMPJ_Ext_Vign_Contrat__c(Name = 'Test 199',RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-36), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today(), MMPJ_Ext_Vign_Livreur__c=societe.id,MMPJ_Ext_Vign_Courtier__c=courtier.Id,MMPJ_XRM_Pressoir__c=centre2.id,MMPJ_Ext_Vign_Contrat_Segmentation__c = 'Champagne',MMPJ_XRM_annee__c = String.valueOf(Date.today().year())));


		insert contrats;


        test.startTest();

        MMPJ_XRM_BatchSuppAnnuelleContrat batch1 = new MMPJ_XRM_BatchSuppAnnuelleContrat();
        ID batchprocessid = Database.executeBatch(batch1);

        test.stopTest();

        Integer nbContrats = [select count() from MMPJ_Ext_Vign_Contrat__c];

        System.assertEquals(1,nbContrats);
            
    }
}