@isTest
public class MMPJ_XRM_SocieteUpdate_TEST {
	static testmethod void updateEmailForPrimaryContact_TEST() {

		Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		MMPJ_Ext_Vign_Societe__c societe2 = new MMPJ_Ext_Vign_Societe__c(Name='Test2',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		MMPJ_Ext_Vign_Societe__c societe3 = new MMPJ_Ext_Vign_Societe__c(Name='Test2',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		insert new List<MMPJ_Ext_Vign_Societe__c>{societe,societe2,societe3};

		Account accCognac = new Account(Name='Test');
		insert accCognac;

		Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;

		Contact con = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Champagne',RecordTYpeId=rtCon, Email='test@xyz.com');
		insert con;
		Contact con2 = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Champagne',RecordTYpeId=rtCon, Email='test3@xyz.com');
		insert con2;

		MMPJ_Ext_Vign_Societe_Contact__c sCon1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con.id,MMPJ_Ext_Vign_Societe__c=societe.Id,MMPJ_Ext_Vign_Fonction__c='GERANT',MMPJ_Ext_Vign_Contact_Principal__c=true);
		MMPJ_Ext_Vign_Societe_Contact__c sCon2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con.id,MMPJ_Ext_Vign_Societe__c=societe2.Id,MMPJ_Ext_Vign_Fonction__c='GERANT',MMPJ_Ext_Vign_Contact_Principal__c=true);
		MMPJ_Ext_Vign_Societe_Contact__c sCon3 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con.id,MMPJ_Ext_Vign_Societe__c=societe3.Id,MMPJ_Ext_Vign_Fonction__c='GERANT',MMPJ_Ext_Vign_Contact_Principal__c=false);
		MMPJ_Ext_Vign_Societe_Contact__c sCon4 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con2.id,MMPJ_Ext_Vign_Societe__c=societe3.Id,MMPJ_Ext_Vign_Fonction__c='GERANT',MMPJ_Ext_Vign_Contact_Principal__c=true);
		insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{scon1,scon2,scon3,scon4};


		Test.startTest();

		con.Email = 'email@xyz.com';
		update con;

		System.assertEquals(2, [select count() from MMPJ_Ext_Vign_Societe__c where MMPJ_XRM_Email_contact_principal__c='email@xyz.com']);
		Test.stopTest();
	}
}