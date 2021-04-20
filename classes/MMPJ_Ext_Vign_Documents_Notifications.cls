public without sharing class MMPJ_Ext_Vign_Documents_Notifications {
	public static void createDocumentNotifications(List<MMPJ_Ext_Vign_Documents_Fournis__c> documents) {
		/*Set<Id> livreurs = new Set<Id>();

		for(MMPJ_Ext_Vign_Documents_Fournis__c doc : documents)
			if(!livreurs.contains(doc.MMPJ_Ext_Vign_Livreur__c));
				livreurs.add(doc.MMPJ_Ext_Vign_Livreur__c);

		Date endDate = (Date.today() < Date.newInstance(Date.today().year(), 8, 31)) ? Date.newInstance(Date.today().year() - 1, 8, 31) : Date.newInstance(Date.today().year(), 8, 31);;
		Set<Id> comptesNotif = new Set<Id>();
		for(MMPJ_Ext_Vign_Contrat__c contrat:[select MMPJ_Ext_Vign_BP__c, MMPJ_Ext_Vign_Courtier__c from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Livreur__c IN : livreurs and (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c <= :endDate)];
		{
			if(contrat.MMPJ_Ext_Vign_BP__c != null && !comptesNotif.contains(contrat.MMPJ_Ext_Vign_BP__c))
				comptesNotif.add(contrat.MMPJ_Ext_Vign_BP__c);

			if(contrat.MMPJ_Ext_Vign_Courtier__c != null && !comptesNotif.contains(contrat.MMPJ_Ext_Vign_Courtier__c))
				comptesNotif.add(contrat.MMPJ_Ext_Vign_Courtier__c);
		}

		Set<Id> contactsAll = new Set<Id>();
		for(MMPJ_Ext_Vign_Societe_Contact__c scon:[select MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Societe__c IN:comptesNotif])
			if(!contactsAll.contains(scon.MMPJ_Ext_Vign_Contact__c))
				contactsAll.get(scon.MMPJ_Ext_Vign_Contact__c);

		Set<Id> contacts = new Set<Id>();
		for(User u:[select ContactId from User where ContactId IN : contactsAll])
			contacts.add(u.ContactId);
*/

		Set<Id> livreurs = new Set<Id>();

		for(MMPJ_Ext_Vign_Documents_Fournis__c doc : documents)
			if(!livreurs.contains(doc.MMPJ_Ext_Vign_Livreur__c))
				livreurs.add(doc.MMPJ_Ext_Vign_Livreur__c);

		//Date endDate = (Date.today() < Date.newInstance(Date.today().year(), 8, 31)) ? Date.newInstance(Date.today().year() - 1, 8, 31) : Date.newInstance(Date.today().year(), 8, 31);
		Date endDate = (Date.today() < Date.newInstance(Date.today().year(), 6, 30)) ? Date.newInstance(Date.today().year() - 2, 6, 30) : Date.newInstance(Date.today().year() -1, 6, 30);

		Map<Id,Set<Id>> livreursComptesMap = new Map<Id,Set<Id>>();
		Set<id> comptes = new Set<Id>();
		//for(MMPJ_Ext_Vign_Contrat__c contrat:[select MMPJ_Ext_Vign_Livreur__c,MMPJ_Ext_Vign_BP__c, MMPJ_Ext_Vign_Courtier__c from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Livreur__c IN : livreurs and (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c <= :endDate)])
		for(MMPJ_Ext_Vign_Contrat__c contrat:[select MMPJ_Ext_Vign_Livreur__c,MMPJ_Ext_Vign_BP__c, MMPJ_Ext_Vign_Courtier__c from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Livreur__c IN : livreurs and (MMPJ_Ext_Vign_Date_de_fin_du_contrat__c = null or MMPJ_Ext_Vign_Date_de_fin_du_contrat__c >= :endDate)])
        {
            if(!livreursComptesMap.containsKey(contrat.MMPJ_Ext_Vign_Livreur__c)){
                livreursComptesMap.put(contrat.MMPJ_Ext_Vign_Livreur__c,new Set<Id>());
            }

			if(contrat.MMPJ_Ext_Vign_BP__c != null && !livreursComptesMap.get(contrat.MMPJ_Ext_Vign_Livreur__c).contains(contrat.MMPJ_Ext_Vign_BP__c))
			{
				livreursComptesMap.get(contrat.MMPJ_Ext_Vign_Livreur__c).add(contrat.MMPJ_Ext_Vign_BP__c);
				comptes.add(contrat.MMPJ_Ext_Vign_BP__c);
			}

			if(contrat.MMPJ_Ext_Vign_Courtier__c != null && !livreursComptesMap.get(contrat.MMPJ_Ext_Vign_Livreur__c).contains(contrat.MMPJ_Ext_Vign_Courtier__c))
			{
				livreursComptesMap.get(contrat.MMPJ_Ext_Vign_Livreur__c).add(contrat.MMPJ_Ext_Vign_Courtier__c);
				comptes.add(contrat.MMPJ_Ext_Vign_Courtier__c);
			}
		}
        
		Map<Id,Set<Id>> accountContactsMap = new Map<Id,Set<Id>>();
		for(MMPJ_Ext_Vign_Societe_Contact__c scon:[select MMPJ_Ext_Vign_Contact__c, MMPJ_Ext_Vign_Societe__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Societe__c IN:comptes])
		{
			if(!accountContactsMap.containsKey(scon.MMPJ_Ext_Vign_Societe__c))
				accountContactsMap.put(scon.MMPJ_Ext_Vign_Societe__c, new Set<Id>());

			accountContactsMap.get(scon.MMPJ_Ext_Vign_Societe__c).add(scon.MMPJ_Ext_Vign_Contact__c);
		}
        
		List<MMPJ_Ext_Vign_Notification_Document__c> notifDocuments = new List<MMPJ_Ext_Vign_Notification_Document__c>();
		for(MMPJ_Ext_Vign_Documents_Fournis__c doc : documents)
		{
			if(livreursComptesMap.containsKey(doc.MMPJ_Ext_Vign_Livreur__c))
			{
				for(Id courtierAndbp:livreursComptesMap.get(doc.MMPJ_Ext_Vign_Livreur__c))
				{
					if(accountContactsMap.containsKey(courtierAndbp))
					{
						for(Id ctc:accountContactsMap.get(courtierAndbp))
						{
							notifDocuments.add(new MMPJ_Ext_Vign_Notification_Document__c(MMPJ_Ext_Vign_Document_fournis__c=doc.Id,MMPJ_Ext_Vign_Contact__c=ctc));
						}
					}
				}
			}
		}
        
		if(notifDocuments.size() > 0)
			insert notifDocuments;
	}
}