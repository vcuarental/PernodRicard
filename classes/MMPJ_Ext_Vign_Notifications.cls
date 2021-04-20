public with sharing class MMPJ_Ext_Vign_Notifications {

	public static Map<String, String> typeFactures = new Map<String, String>{
		'Facture' => 'Facture',
		'Facture d\'approvisionnement' => 'Facture d\'approvisionnement',
		'Facture d\'enlèvement' => 'Facture d\'enlèvement',
		'Facture de pressurage et vinification' => 'Facture de pressurage et vinification',
		'Prestation de services' => 'Facture prestation de services'
	};

	public static void createFactureNotification(List<MMPJ_Ext_Vign_Facture__c> factures) {
		Set<Id> societes = new Set<Id>();
		for(MMPJ_Ext_Vign_Facture__c fac:factures)
			if(!societes.contains(fac.MMPJ_Ext_Vign_Societe__c))
				societes.add(fac.MMPJ_Ext_Vign_Societe__c);

		List<id> contacts = MMPJ_Ext_Vign_Notifications.makeContactList(societes,'MMPJ_Ext_Vign_Nouvelle_facture__c');
		createNotifications(contacts,'Facture','Nouvelle Facture');

		/*Map<String,Set<Id>> societes = new Map<String,Set<Id>>();
		Map<Id,String> recordTypes = new Map<Id,String>();

		for(MMPJ_Ext_Vign_Facture__c fac:factures)
		{
			if(!recordTypes.containsKey(fac.recordtypeid))
			{
				recordTypes.put(fac.recordtypeid,Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(fac.recordtypeid).getname());
				societes.put(recordTypes.get(fac.recordtypeid),new Set<Id>());
			}
			
			if(!societes.get(fac.recordtypeid).contains(fac.MMPJ_Ext_Vign_Societe__c))
				societes.get(fac.recordtypeid).add(fac.MMPJ_Ext_Vign_Societe__c);
		}

		for(String s:societes.keySet())
		{
			List<id> contacts = MMPJ_Ext_Vign_Notifications.makeContactList(societes.get(s),'MMPJ_Ext_Vign_Nouvelle_facture__c');
			createNotifications(contacts,typeFactures.get(s),'Nouvelle Facture ' + s);
		}*/

	}


	public static void createAuditNotification(List<MMPJ_Ext_Vign_Audit__c> audits) {

		Set<Id> societes = new Set<Id>();
		for(MMPJ_Ext_Vign_Audit__c audit:audits)
			if(!societes.contains(audit.MMPJ_Ext_Vign_Livreur__c))
				societes.add(audit.MMPJ_Ext_Vign_Livreur__c);
				
		List<id> contacts = makeContactList(societes,'MMPJ_Ext_Vign_Nouvel_Audit__c');
		createNotifications(contacts,'Audit','Nouvel Audit');

	}

	public static void createAnalyseNotification(List<MMPJ_Ext_Vign_Echantillon__c> audits) {

		Set<Id> societes = new Set<Id>();
		for(MMPJ_Ext_Vign_Echantillon__c audit:audits)
			if(!societes.contains(audit.MMPJ_Ext_Vign_Livreur__c))
				societes.add(audit.MMPJ_Ext_Vign_Livreur__c);
				
		List<id> contacts = makeContactList(societes,'MMPJ_Ext_Vign_Nouvelle_analyse__c');
		createNotifications(contacts,'Analyse','Nouvelle Analyse');

	}

	public static void createCampaignMeberNotification(List<CampaignMember> members) {
	
		Set<id> contacts = new Set<Id>();
		for(CampaignMember m:members)
			contacts.add(m.ContactId);

		for(Contact con:[select Id from Contact where Id IN:contacts and MMPJ_Ext_Vign_Nouvelle_invitation__c = false])
			contacts.remove(con.Id);

		createNotifications(new List<Id>(contacts),'Invitation','Nouvelle Invitation');

	}

	public static void createDocumentNotification(List<MMPJ_Ext_Vign_Documents_Fournis__c> docs) {

		Set<Id> societes = new Set<Id>();
		for(MMPJ_Ext_Vign_Documents_Fournis__c doc:docs)
			if(!societes.contains(doc.MMPJ_Ext_Vign_Livreur__c))
				societes.add(doc.MMPJ_Ext_Vign_Livreur__c);
				
		List<id> contacts = makeContactList(societes,'MMPJ_Ext_Vign_Nouveau_Brouillon_Declarat__c');
		createNotifications(contacts,'Brouillon de déclaration de récolte','Nouveau Brouillon de déclaration de récolte');

	}


	private static List<id> makeContactList(Set<Id> societes, String fieldName)
	{
		Map<Id,List<Id>> contactsMap = new Map<Id,List<Id>>();
		Map<Id,Boolean> contactsPrincipals = new Map<Id,Boolean>();
		for(Id myId:societes)
		{
			contactsMap.put(myId, new List<Id>());
			contactsPrincipals.put(myId,false);
		}

		String queryString = 'select MMPJ_Ext_Vign_Contact_Principal__c,MMPJ_Ext_Vign_Societe__c, MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Societe__c IN:societes and MMPJ_Ext_Vign_Contact__r.' + fieldName + '=true';

		//for(MMPJ_Ext_Vign_Societe_Contact__c con:[select MMPJ_Ext_Vign_Contact_Principal__c,MMPJ_Ext_Vign_Societe__c, MMPJ_Ext_Vign_Contact__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Societe__c IN:societes])
		for(MMPJ_Ext_Vign_Societe_Contact__c con:Database.query(queryString))
		{
			if(con.MMPJ_Ext_Vign_Contact_Principal__c)
			{
				contactsPrincipals.put(con.MMPJ_Ext_Vign_Societe__c,true);
				contactsMap.get(con.MMPJ_Ext_Vign_Societe__c).clear();
				contactsMap.get(con.MMPJ_Ext_Vign_Societe__c).add(con.MMPJ_Ext_Vign_Contact__c);
			} else if(!con.MMPJ_Ext_Vign_Contact_Principal__c && !contactsPrincipals.get(con.MMPJ_Ext_Vign_Societe__c)){
				contactsMap.get(con.MMPJ_Ext_Vign_Societe__c).add(con.MMPJ_Ext_Vign_Contact__c);
			}
		}

		List<id> contacts = new List<Id>();
		for(Id socId:ContactsMap.KeySet())
			contacts.addAll(contactsMap.get(socId));

		return contacts;
	}

	private static void createNotifications(List<id> contacts, String typeNotif, String intitule)
	{
		List<MMPJ_Ext_Vign_Notification__c> notifications = new List<MMPJ_Ext_Vign_Notification__c>();
		
		for(Id conId:contacts)
			notifications.add(new MMPJ_Ext_Vign_Notification__c(MMPJ_Ext_Vign_Contact__c=conId,MMPJ_Ext_Vign_Type__c=typeNotif,MMPJ_Ext_Vign_Date__c=Date.today(),MMPJ_Ext_Vign_Intitule__c=intitule));
		
		if(notifications.size() > 0)
			insert notifications;
	}
}