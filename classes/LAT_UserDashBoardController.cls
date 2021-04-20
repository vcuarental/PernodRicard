/*
* LAT_UserDashBoardController,
* Author: Martin Prado (martin@zimmic.com)
* Date: 11/16/2018
*/
global with sharing  class LAT_UserDashBoardController {


	public List<LAT_FormBuilderSchema__c> 	fbs {get;set;}
	public List<LAT_FormBuilderEntries__c> 	ent {get;set;}
	public Map<Id, String> 					formLevel {get;set;}
	Set<Id>									myFormsIds  {get;set;}


	public String entrySoql;
	public String entrySearchTerm {get;set;}
	public Boolean entryFetchCalled;
	public integer entryTotalRecs {get;set;}
	public integer formTotalRecs {get;set;}
	public integer entryIndex {get;set;}
	public integer entryblockSize {get;set;}
	public integer formBlockSize {get;set;}


	private Integer FORMSIZE = 5;

	public LAT_UserDashBoardController()  {

		// Check the current Permissions
		Id userId = UserInfo.getUserId();
		//Id userAccountId;

		entryblockSize =  20;
		formBlockSize =  FORMSIZE;
		entryIndex = 0;

		List<String> groupId = new List<String>();
		myFormsIds = new Set<Id>();
		formLevel = new Map<Id, String>();
		//
		// List<User> currentUser = [SELECT Id, AccountId FROM User WHERE Id =: userId];
		//
		// // Get account Id
		// if(!currentUser.isEmpty()){
		// 	userAccountId = currentUser[0].AccountId;
		// }

		// All the groups to the users belongs to
		// List<GroupMember> mygroups = [Select  Group.Id,  Group.name from GroupMember where UserOrGroupId =: userId and Group.Type = 'Queue'];
		// for(GroupMember gm : mygroups) {
		//     groupId.add(String.valueOf(gm.Group.id));
		// }
		//
		// // Get all the forms when the user has Permission
		// // OR LAT_Group__c IN :mygroups - TO DO, groups doesn't works
		// List<LAT_FormBuilderShare__c> myForms = [Select name, LAT_FormBuilderSchema__c,   id,LAT_Account__c, LAT_Account__r.Name, LAT_AccessLevel__c, LAT_Group__c, LAT_GroupFromula__c, LAT_User__c, LAT_User__r.name from LAT_FormBuilderShare__c where LAT_Account__r.ownerId =: userId OR LAT_User__c =:userId OR LAT_Group__c IN: groupId ];
		// for(LAT_FormBuilderShare__c form : myForms) {
		// 	myFormsIds.add(form.LAT_FormBuilderSchema__c);
		// 	formLevel.put(form.LAT_FormBuilderSchema__c, form.LAT_AccessLevel__c );
		// }

		formLevel  = LAT_UserDashBoardController.getMySchemaForms(userId);
		myFormsIds =  formLevel.keySet();

		// Old Way


		//fbs = [Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c  where Id in: myFormsIds order by CreatedDate desc limit  :formBlockSize];
		//ent = [Select Fields_Populated__c,CreatedById,  CreatedBy.Name, Form_Builder_Schema__c , Status__c, Name, Form_Builder_Schema__r.Status__c, Form_Builder_Schema__r.Name, Form_Builder_Schema__r.Fields_Count__c, createddate  from LAT_FormBuilderEntries__c  where Form_Builder_Schema__c in: myFormsIds order by createddate desc limit 100];

		formTotalRecs = [select count() from LAT_FormBuilderSchema__c  where Id in: myFormsIds ];
		entryTotalRecs = [select count() from LAT_FormBuilderEntries__c  where Form_Builder_Schema__c in: myFormsIds ];
		entryFetchCalled = false;


		ent = getMyEntries(myFormsIds);
		fbs = getMyForms(myFormsIds);
	}



	public static Map<Id, String> getMySchemaForms(Id userId){

		List<String> groupId = new List<String>();
		Set<Id> myFormsIds = new Set<Id>();
		Map<Id, String> customFormLevel = new Map<Id, String>();

		// Check groups
		List<GroupMember> mygroups = [Select  Group.Id,  Group.name from GroupMember where UserOrGroupId =: userId and Group.Type = 'Queue'];
		for(GroupMember gm : mygroups) {
		    groupId.add(String.valueOf(gm.Group.id));
		}

		// Filter share permission by queue, user and owner account
		List<LAT_FormBuilderShare__c> myForms = [Select name, LAT_FormBuilderSchema__c,   id,LAT_Account__c, LAT_Account__r.Name, LAT_AccessLevel__c, LAT_Group__c, LAT_GroupFromula__c, LAT_User__c, LAT_User__r.name from LAT_FormBuilderShare__c where LAT_Account__r.ownerId =: userId OR LAT_User__c =:userId OR LAT_Group__c IN: groupId ];
		for(LAT_FormBuilderShare__c form : myForms) {
			customFormLevel.put(form.LAT_FormBuilderSchema__c, form.LAT_AccessLevel__c );
		}

		return customFormLevel;

	}




	public void fetchEntries(Set<Id> myFormsIds )
	{

		entrySoql = 'Select Fields_Populated__c,CreatedById,  CreatedBy.Name, Form_Builder_Schema__c , Status__c, Name, Form_Builder_Schema__r.Status__c, Form_Builder_Schema__r.Name, Form_Builder_Schema__r.Fields_Count__c, createddate  from LAT_FormBuilderEntries__c  where Form_Builder_Schema__c in: myFormsIds';

		if(entrySearchTerm != '' )
		{
			entrySoql += ' AND (name LIKE  \'%' + String.escapeSingleQuotes(entrySearchTerm) + '%\' OR  Form_Builder_Schema__r.Name LIKE  \'%' + String.escapeSingleQuotes(entrySearchTerm) + '%\'  )';
		}

		List<LAT_FormBuilderEntries__c> tempLead = Database.Query(entrySoql);
		entryTotalRecs = tempLead.size();

		entrySoql += 'order by Name desc';

		entrySoql += ' LIMIT ' + entryblockSize + ' OFFSET ' + entryIndex;
		entryFetchCalled = true;

	}

	private List<LAT_FormBuilderSchema__c> getMyForms(Set<Id> myFormsIds) {
		List<LAT_FormBuilderSchema__c> forms;
		String query = 'Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c  where Id in: myFormsIds order by CreatedDate desc limit  :formBlockSize ';
		forms = Database.Query(query);
		return forms;
	}

	public void nextBatch() {
		formBlockSize = formBlockSize + FORMSIZE;
		fbs = getMyForms(myFormsIds);
	}


	public List<LAT_FormBuilderEntries__c> getMyEntries(Set<Id> myFormsIds ) {
		List<LAT_FormBuilderEntries__c> entries;
		if(entryFetchCalled)
		{
			fetchEntries(myFormsIds);
		}
		else
		{
			entrySoql = 'Select Fields_Populated__c,CreatedById,  CreatedBy.Name, Form_Builder_Schema__c , Status__c, Name, Form_Builder_Schema__r.Status__c, Form_Builder_Schema__r.Name, Form_Builder_Schema__r.Fields_Count__c, createddate  from LAT_FormBuilderEntries__c  where Form_Builder_Schema__c in: myFormsIds order by Name desc LIMIT : entryblockSize OFFSET : entryIndex';
		}
		entries = Database.Query(entrySoql);
		System.debug('Values are ' + entries);
		return entries;
	}


	public void entryBeginning() { entryIndex = 0;  ent = getMyEntries(myFormsIds); }
	public void changeSearch() {

		if(entrySearchTerm != '') {
			entryIndex = 0;
			entryFetchCalled = true;
			entryTotalRecs = [select count() from LAT_FormBuilderEntries__c  where Form_Builder_Schema__c in: myFormsIds AND (name Like  : entrySearchTerm  OR  Form_Builder_Schema__r.Name LIKE :entrySearchTerm) ];
		} else {
			entryIndex = 0;
			entryTotalRecs = [select count() from LAT_FormBuilderEntries__c  where Form_Builder_Schema__c in: myFormsIds ];
			entryFetchCalled = false;
		}


		ent = getMyEntries(myFormsIds);
		//ent = getMyEntries(myFormsIds);

	}
	public void entryPrevious() { entryIndex = entryIndex - entryblockSize;  ent = getMyEntries(myFormsIds); }
	public void entryNext() { entryIndex = entryIndex + entryblockSize; ent = getMyEntries(myFormsIds); }
	public void entryEnd() { entryIndex = entryTotalRecs - math.mod(entryTotalRecs,entryblockSize);  ent = getMyEntries(myFormsIds); }

	public boolean getEntryPrev() {
		if(entryIndex == 0)
			return true;
		else
			return false;
	}

	public boolean getEntryNxt() {
		if((entryIndex + entryblockSize) >= entryTotalRecs)
			return true;
		else
			return false;
	}

	public boolean getHasMoreForms() {
		if( formBlockSize >= formTotalRecs)
			return true;
		else
			return false;
	}

	public Integer getCurrentPage() {
		return (entryIndex != 0) ? (entryIndex / entryblockSize)+1 : 1 ;
	}


}