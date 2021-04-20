public with sharing class MMPJ_XRM_Export_Excel_Controller {
	public List<MMPJ_Ext_Vign_Societe_Contact__c> lstContacts{get;set;}
	public String contentType{get;set;}
	public Map<Id,String> societeLieMap{get;set;}
	public list<String> parametersQuery{get;set;}
	//private String filters;
	public MMPJ_XRM_Export_Excel_Controller() {
		//filters = ApexPages.currentPage().getParameters().get('search');
		contentType = 'application/vnd.ms-excel#Export_requetes_' + DateTime.now().format('yyyy-MM-dd') +'.xls';

		lstContacts = new List<MMPJ_Ext_Vign_Societe_Contact__c>();
		societeLieMap = new Map<Id,String>();
		//if(!String.isBlank(filters))
			initContactsList();
	}

	private void initContactsList()
	{ 
		MMPJ_XRM_Segmentation_Controller segmentation = new MMPJ_XRM_Segmentation_Controller(new ApexPages.StandardController(new Campaign()));
		segmentation.searchCriterias = new List<MMPJ_XRM_Segmentation_Controller.searchCriteriaClass>();
		Boolean querySubAccount = Boolean.valueOf(ApexPages.currentPage().getParameters().get('querySubAccount'));
		Boolean queryTopAccount = Boolean.valueOf(ApexPages.currentPage().getParameters().get('queryTopAccount'));
		Integer idx = 0;
		do {
			String filter = ApexPages.currentPage().getParameters().get('search' + idx);
			if(String.isBlank(filter))
			{
				idx = -1;
			}
			else {
				System.debug('#### filter : ' + filter);
				filter = EncodingUtil.urlDecode(filter, 'UTF-8');
				System.debug('#### filter decoded : ' + filter);
				List<String> filtervalues = filter.split('\\|');
				System.debug('#### filtervalues : ' + filtervalues);
				MMPJ_XRM_Segmentation_Controller.searchCriteriaClass crit = new MMPJ_XRM_Segmentation_Controller.searchCriteriaClass(Integer.valueOf(filtervalues[0]));
				//crit.numero = Integer.valueOf(filtervalues[0]);
				crit.selectedCritere = filtervalues[1];
				crit.selectedOperateur = filtervalues[2];
				crit.searchText = filtervalues[3];
				segmentation.searchCriterias.add(crit);
				idx++;
			}

		} while (idx != -1);
		System.debug('### searchCriterias : ' + segmentation.searchCriterias);
		segmentation.querySubAccount = querySubAccount;
		segmentation.queryTopAccount = queryTopAccount;
		segmentation.search();
		System.debug('### results  : ' + segmentation.contacts);
		Set<Id> contactsId = segmentation.ContactIdList;
		lstContacts = [select MMPJ_Ext_Vign_Contact__c, MMPJ_Ext_Vign_Contact__r.Salutation, MMPJ_Ext_Vign_Contact__r.FirstName, MMPJ_Ext_Vign_Contact__r.LastName, MMPJ_Ext_Vign_Contact_Principal__c, MMPJ_XRM_Titre__c, MMPJ_Ext_Vign_Contact__r.Email, MMPJ_Ext_Vign_Contact__r.MMPJ_Ext_Vign_Telephone_portable_perso__c,MMPJ_Ext_Vign_Societe__r.Name,MMPJ_Ext_Vign_Societe__r.RecordType.Name, MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Ville__c,MMPJ_Ext_Vign_Societe__r.Owner.FirstName,MMPJ_Ext_Vign_Societe__r.MMPJ_XRM_Livreur__c,MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Statut__c,MMPJ_Ext_Vign_Societe__r.MMPJ_XRM_Superficie_exploitee__c,MMPJ_Ext_Vign_Societe__r.MMPJ_XRM_Categorie__c,MMPJ_Ext_Vign_Societe__r.MMPJ_XRM_Nb_de_cols__c,MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Adresse__c, MMPJ_Ext_Vign_Societe__r.MMPJ_Ext_Vign_Code_Postal__c from MMPJ_Ext_Vign_Societe_Contact__c where MMPJ_Ext_Vign_Contact__c IN:contactsId order by MMPJ_Ext_Vign_Societe__r.Name, MMPJ_Ext_Vign_Contact__r.LastName ];
		/*
		for(MMPJ_Ext_Vign_Societe_Contact__c sc:lstContacts)
		{
			if(!societeLieMap.containsKey(sc.MMPJ_Ext_Vign_Contact__c))
			{
				societeLieMap.put(sc.MMPJ_Ext_Vign_Contact__c, sc.MMPJ_Ext_Vign_Societe__r.Name + ' (' + sc.MMPJ_Ext_Vign_Societe__r.RecordType.Name + ')');
			} else {
				String societe = societeLieMap.get(sc.MMPJ_Ext_Vign_Contact__c);
				societe += '<br style="mso-data-placement:same-cell;"/>' + sc.MMPJ_Ext_Vign_Societe__r.Name + ' (' + sc.MMPJ_Ext_Vign_Societe__r.RecordType.Name + ')';
				societeLieMap.put(sc.MMPJ_Ext_Vign_Contact__c, societe);
			}
			
		}*/

		/*for(Id soc : societeLieMap.keySet())
			if(!societeLieMap.get(soc).contains('<br'))
				societeLieMap.put(soc,'');*/

		//Map un contact avec les sociétés pour lequel il travaille
		Set<Id> societeSet = new Set<Id>();

		for(MMPJ_Ext_Vign_Societe_Contact__c sc:lstContacts)
		{
			societeSet.add(sc.MMPJ_Ext_Vign_Societe__c);
			societeLieMap.put(sc.MMPJ_Ext_Vign_Societe__c, sc.MMPJ_Ext_Vign_Societe__r.Name + ' (' + sc.MMPJ_Ext_Vign_Societe__r.RecordType.Name + ')');
		}


		
		for(MMPJ_XRM_RelationSociete__c sc:[select MMPJ_XRM_Livreur__c, MMPJ_XRM_Societe_liee__r.Name, MMPK_XRM_Type_Relation__c from MMPJ_XRM_RelationSociete__c where MMPJ_XRM_Livreur__c IN:societeSet])
		{
			if(!societeLieMap.containsKey(sc.MMPJ_XRM_Livreur__c))
			{
				societeLieMap.put(sc.MMPJ_XRM_Livreur__c, sc.MMPJ_XRM_Societe_liee__r.Name + ' (' + sc.MMPK_XRM_Type_Relation__c + ')');
			} else {
				String societe = societeLieMap.get(sc.MMPJ_XRM_Livreur__c);
				societe += '<br style="mso-data-placement:same-cell;"/>' + sc.MMPJ_XRM_Societe_liee__r.Name + ' (' + sc.MMPK_XRM_Type_Relation__c + ')';
				societeLieMap.put(sc.MMPJ_XRM_Livreur__c, societe);
			}
			
		}

		Map<String,String> operateursMap = new Map<String,String>();
		for(SelectOption opt:segmentation.operateursOptions)
			operateursMap.put(opt.getValue(),opt.getLabel());
		//creating searchCriteria String
		parametersQuery = new List<String>();
		for(MMPJ_XRM_Segmentation_Controller.searchCriteriaClass crit:segmentation.searchCriterias)
		{
			String p = segmentation.criteresOptionsMap.get(crit.selectedCritere).libelle + ' ' + operateursMap.get(crit.selectedOperateur) + ' ' + crit.searchText;
			parametersQuery.add(p);
		}

	}

	/*public MMPJ_XRM_Export_Excel_Controller(List<Id> contactsId)
	{

	}*/
}