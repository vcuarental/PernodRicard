@isTest
public class MMPJ_Ext_Vign_Documents_Notif_TEST {
	static testmethod void test_method() {
		Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
		
		MMPJ_Ext_Vign_Societe__c acc1 = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert acc1;
		MMPJ_Ext_Vign_Societe__c acc2 = new MMPJ_Ext_Vign_Societe__c(Name='Test2',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert acc2;

		MMPJ_Ext_Vign_Societe__c courtier = new MMPJ_Ext_Vign_Societe__c(Name='courtier',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert courtier;
		MMPJ_Ext_Vign_Societe__c bp = new MMPJ_Ext_Vign_Societe__c(Name='bp',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert bp;

		Account accCognac = new Account(Name='Test');
		insert accCognac;

		Contact con1 = new Contact(LastName='Test1',AccountId=accCognac.Id);
		Contact con2 = new Contact(LastName='Test2',AccountId=accCognac.Id);
		Contact con3 = new Contact(LastName='Test3',AccountId=accCognac.Id);

		Contact con6 = new Contact(LastName='Test6',AccountId=accCognac.Id);
		Contact con7 = new Contact(LastName='Test7',AccountId=accCognac.Id);
		Contact con8 = new Contact(LastName='Test8',AccountId=accCognac.Id);
		Contact con9 = new Contact(LastName='Test9',AccountId=accCognac.Id);

		insert new List<Contact>{con1,con2,con3,con6,con7,con8,con9};

		Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;
		try {
			//Si les manuals steps de déploiement n'ont pas été réalisé, MMPJ_Ext_Vign_ContactBeforeInsert risque de planter
			Contact con4 = new Contact(LastName='Test4',MMPJ_Ext_Vign_NUMERO_LIEN__c='999444',RecordTYpeId=rtCon);
			Contact con5 = new Contact(LastName='Test4',MMPJ_Ext_Vign_Id_Apport__c='666444',RecordTYpeId=rtCon);
			insert con4;
			insert con5;
		} catch(Exception ex) {}

		MMPJ_Ext_Vign_Societe_Contact__c sCon1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con1.id,MMPJ_Ext_Vign_Societe__c=acc1.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sCon2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con2.id,MMPJ_Ext_Vign_Societe__c=acc1.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sCon3 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con3.id,MMPJ_Ext_Vign_Societe__c=acc2.Id, MMPJ_Ext_Vign_Contact_Principal__c=true);

		MMPJ_Ext_Vign_Societe_Contact__c sCon6 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con6.id,MMPJ_Ext_Vign_Societe__c=courtier.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sCon7 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con7.id,MMPJ_Ext_Vign_Societe__c=courtier.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sCon8 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con8.id,MMPJ_Ext_Vign_Societe__c=bp.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sCon9 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con9.id,MMPJ_Ext_Vign_Societe__c=bp.Id);

		insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{scon1,scon2,scon3,scon6,scon7,scon8,scon9};

		String RT_Id = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Contrat__c' and DeveloperName='MMPJ_Ext_Vign_Appro_Press' LIMIT 1].Id;
		MMPJ_Ext_Vign_Contrat__c contrat1 = new MMPJ_Ext_Vign_Contrat__c(Name = 'YYYY11',RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-2), MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_BP__c=bp.id,MMPJ_Ext_Vign_Courtier__c=courtier.id);
		insert contrat1;
		MMPJ_Ext_Vign_Contrat__c contrat2 = new MMPJ_Ext_Vign_Contrat__c(Name = 'YYYY12',RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-2), MMPJ_Ext_Vign_Livreur__c=acc2.id,MMPJ_Ext_Vign_BP__c=bp.id,MMPJ_Ext_Vign_Courtier__c=courtier.id);
		insert contrat2;

		List<MMPJ_Ext_Vign_Documents_Fournis__c> docs = new List<MMPJ_Ext_Vign_Documents_Fournis__c>();
		for(Integer i=0;i<100;i++)
			docs.add(new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Type__c = 'Calendrier de Traitement'));

		for(Integer i=100;i<200;i++)
			docs.add(new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c=acc2.Id,MMPJ_Ext_Vign_Type__c = 'Déclaration de récolte'));

		Test.startTest();
		insert docs;
		Test.stopTest();

	}
}