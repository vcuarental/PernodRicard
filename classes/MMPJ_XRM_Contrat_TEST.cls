@isTest
public class MMPJ_XRM_Contrat_TEST {
    static testMethod void testMyController(){
		Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Vigneron' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		insert societe;

		Id rtCourtier = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Courtier_Champagne' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c courtier = new MMPJ_Ext_Vign_Societe__c(Name='Courtier',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		insert courtier;

		Id rtCentre = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Centre_de_pressurage' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c centre = new MMPJ_Ext_Vign_Societe__c(Name='Courtier',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
		insert centre;

		String RT_Id = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Contrat__c' and DeveloperName='MMPJ_Ext_Vign_Appro_Press' LIMIT 1].Id;
		MMPJ_Ext_Vign_Contrat__c con = new MMPJ_Ext_Vign_Contrat__c(Name = '88888',RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-2), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today().addMonths(12), MMPJ_Ext_Vign_Livreur__c=societe.id,MMPJ_Ext_Vign_Courtier__c=courtier.Id,MMPJ_XRM_Pressoir__c=centre.id);
		insert con;

		MMPJ_Ext_Vign_Contrat__c con2 = new MMPJ_Ext_Vign_Contrat__c(Name = '8888998',RecordTypeId=RT_Id, MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-2), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today().addMonths(12), MMPJ_Ext_Vign_Livreur__c=societe.id,MMPJ_Ext_Vign_Courtier__c=courtier.Id,MMPJ_XRM_Pressoir__c=centre.id);
		insert con2;
	}
}