public with sharing class MMPJ_XRM_Export_Excel_Campaign_Ctrl {
	//private Map<Id, contactClass> contactsMap;
	public List<contactClass> lstContacts{get;set;}
	public Campaign campagne{get;set;}
	public String contentType {get;set;}
	public MMPJ_XRM_Export_Excel_Campaign_Ctrl() {
		String campaignId = ApexPages.currentPage().getParameters().get('Id');
		if(!String.isBlank(campaignId))
			campagne = [select Id, Name,StartDate,MMPJ_Ext_Vign_Heure_debut__c, EndDate, MMPJ_Ext_Vign_Heure_fin__c,MMPJ_Ext_Vign_Nb_personnes_inscrites__c,MMPJ_Ext_Vign_Nb_personnes_accompagnant__c,MMPJ_Ext_Vign_Nb_total_personnes_prevues__c,MMPJ_Ext_Vign_Lieu__c,MMPJ_XRM_Accompagnateur__r.FirstName, MMPJ_XRM_Accompagnateur__r.LastName,MMPJ_XRM_Accompagnateur_2__r.FirstName, MMPJ_XRM_Accompagnateur_2__r.LastName,MMPJ_XRM_Accompagnateur_3__r.FirstName, MMPJ_XRM_Accompagnateur_3__r.LastName  from Campaign where Id=:campaignId];
		else
			campagne = new Campaign(Name='');

		String fileName = campagne.Name.replace(' ','_');
		contentType = 'application/vnd.ms-excel#Export_invites_' + fileName + '_' +  DateTime.now().format('yyyy-MM-dd') +'.xls';

		//contactsMap = new Map<Id,contactClass>();

		lstContacts = new List<contactClass>();
		if(!String.isBlank(campaignId))
			initContactsList();
	}

	private void initContactsList()
	{
		//List<id> contactsIdList = new List<Id>();
		Map<Id,CampaignMember> contactCampaignMemberMap = new Map<Id,CampaignMember>();
		for (CampaignMember cmb:[select ContactId,Status,MMPJ_Ext_Vign_Participation__c,MMPJ_Ext_Accompagnants__c,MMPJ_Ext_Vign_Presence__c,MMPJ_Ext_Vign_Commentaire__c from CampaignMember where CampaignId=:campagne.Id order by Contact.LastName, Contact.FirstName])
		{
			//contactsIdList.add(cmb.ContactId);
			contactCampaignMemberMap.put(cmb.ContactId,cmb);
			/*contactClass cc = new contactClass();
			cc.cmb = cmb;
			contactsMap.put(cmb.ContactId,cc);*/
		}
 
		for(MMPJ_Ext_Vign_Societe_Contact__c c:[select MMPJ_Ext_Vign_Contact__c, MMPJ_XRM_Titre__c ,MMPJ_Ext_Vign_Contact__r.FirstName, MMPJ_Ext_Vign_Contact__r.Salutation, MMPJ_Ext_Vign_Contact__r.LastName, MMPJ_Ext_Vign_Contact__r.Email, MMPJ_Ext_Vign_Contact__r.MMPJ_Ext_Vign_Telephone_portable_perso__c,MMPJ_Ext_Vign_Societe__r.Name,MMPJ_Ext_Vign_Societe__r.RecordType.Name,MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Ville__c,MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Adresse__c, MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Code_Postal__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Contact__c IN:contactCampaignMemberMap.KeySet() order by MMPJ_Ext_Vign_Societe__r.Name,MMPJ_Ext_Vign_Contact__r.LastName])
		{
			//contactClass cc = contactsMap.get(c.MMPJ_Ext_Vign_Contact__c);
			contactClass cc = new contactClass();
			cc.cmb = contactCampaignMemberMap.get(c.MMPJ_Ext_Vign_Contact__c);
			cc.con = c;
			lstContacts.add(cc);
		}

	}

	class contactClass {
		public CampaignMember cmb {get;set;}
		public MMPJ_Ext_Vign_Societe_Contact__c con{get;set;}
		public contactClass()
		{
		}
	}

	/*public MMPJ_XRM_Export_Excel_Controller(List<Id> contactsId)
	{

	}*/
}