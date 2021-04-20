public with sharing class MMPJ_XRM_SocieteUpdate {
	public static void updateEmailForPrimaryContact(List<Contact> contacts) {
		List<MMPJ_Ext_Vign_Societe__c> societes = new List<MMPJ_Ext_Vign_Societe__c>();
		for(MMPJ_Ext_Vign_Societe_Contact__c sc:[select MMPJ_Ext_Vign_Societe__c,MMPJ_Ext_Vign_Contact__r.Email from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Contact_Principal__c=true and MMPJ_Ext_Vign_Contact__c IN:contacts])
		{
			societes.add(new MMPJ_Ext_Vign_Societe__c(Id=sc.MMPJ_Ext_Vign_Societe__c,MMPJ_XRM_Email_contact_principal__c=sc.MMPJ_Ext_Vign_Contact__r.Email));
		}

		if(societes.size() > 0)
			update societes;
	}
}