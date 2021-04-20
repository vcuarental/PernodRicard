/*
* LAT_SchemaBuilderDashBoardController,
* Author: Martin Prado (martin@zimmic.com)
* Date: 09/14/2018
*/
global with sharing  class  LAT_SchemaBuilderDashBoardController {


	public List<LAT_FormBuilderSchema__c> 	fbs 			{get;set;}
	public List<LAT_FormBuilderEntries__c> 	ent 			{get;set;}

	// Pagination
	private Integer ENTRYSIZE = 10;
	public integer entriesBlock 							{ get;set;}
	public integer entryTotalRecs 							{get;set;}
	public integer entriesBlockSize							{get;set;}

	public integer entriesIndex {get;set;}
	// public String entrySearchTerm 							{get;set;}

	public String formSoql;
	public String formSearchTerm {get;set;}
	public Boolean formFetchCalled;
	public integer formTotalRecs {get;set;}
	public integer formIndex {get;set;}
	public integer formBlockSize {get;set;}


	public LAT_SchemaBuilderDashBoardController()  {
		entriesBlock = ENTRYSIZE;
		formBlockSize = ENTRYSIZE;
		entriesBlockSize = ENTRYSIZE*2;

		formIndex = entriesIndex = 0;

		entryTotalRecs = [select count() from LAT_FormBuilderEntries__c ];
		formTotalRecs = [select count() from LAT_FormBuilderSchema__c ];

		formFetchCalled = false;
		fbs = getMyForms();
		ent = getEntries();
	}


	private List<LAT_FormBuilderEntries__c> getEntries() {
		List<LAT_FormBuilderEntries__c> entries;
		String query = 'Select Fields_Populated__c,CreatedById, Status__c, CreatedBy.Name, Form_Builder_Schema__c , Name, Form_Builder_Schema__r.Name, Form_Builder_Schema__r.Fields_Count__c, createddate  from LAT_FormBuilderEntries__c order by createddate desc limit :entriesBlockSize OFFSET : entriesIndex';
		entries = Database.Query(query);
		return entries;
	}

	public void nextBatch() {
		entriesBlock = entriesBlock + ENTRYSIZE;
		ent = getEntries();
	}


	public boolean getHasMoreForms() {
		if( entriesBlock >= entryTotalRecs)
			return true;
		else
			return false;
	}


	public void fetchForms( )
	{

		formSoql = 'Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c, TotalEntries__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c ';

		if(formSearchTerm != '' )
		{
			formSoql += ' WHERE (name LIKE  \'%' + String.escapeSingleQuotes(formSearchTerm) + '%\' OR  Country__c LIKE  \'%' + String.escapeSingleQuotes(formSearchTerm) + '%\'  OR  Status__c LIKE  \'%' + String.escapeSingleQuotes(formSearchTerm) + '%\'  )';
		}

		List<LAT_FormBuilderSchema__c> tempLead = Database.Query(formSoql);
		formTotalRecs = tempLead.size();

		formSoql += 'order by createdDate';

		formSoql += ' LIMIT ' + formBlockSize + ' OFFSET ' + formIndex;
		formFetchCalled = true;

	}

	public List<LAT_FormBuilderSchema__c> getMyForms() {
		List<LAT_FormBuilderSchema__c> forms;
		if(formFetchCalled)
		{
			fetchForms();
		}
		else
		{

			formSoql = 'Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c, TotalEntries__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c order by CreatedDate desc  LIMIT : formblockSize OFFSET : formIndex';
		}
		forms = Database.Query(formSoql);
		System.debug('Values are ' + forms);
		return forms;
	}


	public void formBeginning() { formIndex = 0;  fbs = getMyForms(); }
	public void entriesBeginning() { entriesIndex = 0;  ent = getEntries(); }

	public void changeSearch() {

		if(formSearchTerm != '') {
			formIndex = 0;
			formFetchCalled = true;
			formTotalRecs = [select count() from LAT_FormBuilderSchema__c  where  (name Like  : formSearchTerm  OR  Country__c  LIKE :formSearchTerm  OR  Status__c  LIKE :formSearchTerm) ];
		} else {
			formIndex = 0;
			formTotalRecs = [select count() from LAT_FormBuilderSchema__c ];
			formFetchCalled = false;
		}


		fbs = getMyForms();
		//ent = getMyEntries(myFormsIds);

	}

	public void formPrevious() { formIndex = formIndex - formBlockSize; fbs = getMyForms(); }
	public void entriesPrevious() { entriesIndex = entriesIndex - entriesBlockSize; ent = getEntries(); }

	public void formNext() { formIndex = formIndex + formBlockSize; fbs = getMyForms(); }
	public void entriesNext() { entriesIndex = entriesIndex + entriesBlockSize; ent = getEntries(); }

	public void formEnd() { formIndex = formTotalRecs - math.mod(entryTotalRecs,formBlockSize);  fbs = getMyForms(); }
	public void entriesEnd() { entriesIndex = entryTotalRecs - math.mod(entryTotalRecs,entriesBlockSize);  ent = getEntries(); }

	public boolean getformPrev() {
		if(formIndex == 0)
			return true;
		else
			return false;
	}

	public boolean getentriesPrev() {
		if(entriesIndex == 0)
			return true;
		else
			return false;
	}

	public boolean getformNxt() {
		if((formIndex + formBlockSize) >= formTotalRecs)
			return true;
		else
			return false;
	}

	public boolean getentriesNxt() {
		if((entriesIndex + entriesBlockSize) >= entryTotalRecs)
			return true;
		else
			return false;
	}


	public Integer getCurrentPage() {
		return (formIndex != 0) ? (formIndex / formblockSize)+1 : 1 ;
	}


	@RemoteAction
	global static Boolean checkName(String schemaName) {
		//return schemaName;
		List<LAT_FormBuilderSchema__c> schemas = [SELECT id, name from LAT_FormBuilderSchema__c where name =:schemaName ];
		return schemas.size() > 0;

	}


	@RemoteAction
	global static String cloneSchema(String schemaName, String schemaId) {

		// Clone schema
		LAT_FormBuilderSchema__c schemaParent = [Select  Name, Fields_Count__c, Country__c, TotalEntries__c, Pages_Count__c , Status__c from LAT_FormBuilderSchema__c where Id =: schemaId];
		LAT_FormBuilderSchema__c schemaChild  = schemaParent.clone(false);
		schemaChild.Status__c = 'Draft';
		schemaChild.Name = schemaName;
		insert schemaChild;

		// clone pages
		List<LAT_FormBuilderPages__c> clonedPages = new List<LAT_FormBuilderPages__c>();
		for (LAT_FormBuilderPages__c pi : [Select  Json__c, Order__c, Form_Builder_Schema__c , Fields_Count__c, Name from LAT_FormBuilderPages__c where Form_Builder_Schema__c =: schemaId]) {
			 LAT_FormBuilderPages__c newPI = pi.clone(false);
			 newPI.Form_Builder_Schema__c = schemaChild.Id;
			 clonedPages.add(newPI);
		}
		insert clonedPages;


		return schemaChild.Id;
		// //return schemaName;
		// List<LAT_FormBuilderSchema__c> schemas = [SELECT id, name from LAT_FormBuilderSchema__c where name =:schemaName ];
		// return schemas.size() > 0;

	}


}