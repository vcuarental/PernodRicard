/*
* LAT_SchemaBuilderShareController, class to share forms with users, queues and  accounts
*
*/
global with sharing class LAT_SchemaBuilderShareController {

	// Getters and Setters
	public  List<LAT_FormBuilderShare__c> existingShares 	{ get;set; }
	public LAT_FormBuilderSchema__c currentSchema 			{ get;set; }
	public LAT_FormBuilderShare__c newShare 				{ get;set; }
	public List<SelectOption>  groups						{ get;set; }
	public String  selectedGroup							{ get;set; }


	// Constructor
	public LAT_SchemaBuilderShareController(){

		Id objectId = ApexPages.currentPage().getParameters().get('id');

		existingShares = new  List<LAT_FormBuilderShare__c>();
		newShare = new LAT_FormBuilderShare__c();

		List<LAT_FormBuilderSchema__c> schemaFinder = [Select Id, Name,Fields_Count__c , country__c, Pages_Count__c ,Status__c, ( Select name,  id,LAT_Account__c, LAT_Account__r.Name, LAT_AccessLevel__c, LAT_Group__c, LAT_GroupFromula__c, LAT_User__c, LAT_User__r.name from Form_Builder_Sharings__r )  from LAT_FormBuilderSchema__c where id =: objectId];
		if(!schemaFinder.isEmpty()) {
			currentSchema = schemaFinder.get(0);
			existingShares = currentSchema.Form_Builder_Sharings__r;
		}

		groups = getGroups();

	}

	/*
	* getGroups
	* //
	*/
	private List<selectOption> getGroups() {
		List<Group> currentGroups =  [select Id,  Name , developername from Group where Type = 'Queue' AND developername LIKE 'LAT_Sch%'];
		List<SelectOption> availableGroups = new List<SelectOption>();

		for(Group gro: currentGroups){
		  	availableGroups.add(new SelectOption(gro.Id, gro.name));
		}
		return availableGroups;
	}


	/*
	* updateSharePerms
	* Update Permission Levels
	*/
	@RemoteAction
   	global static String updateSharePerms(String picklistValue, String objectId) {
		String result = 'ok';
	    LAT_FormBuilderShare__c currentShare = [SELECT Id, LAT_AccessLevel__c
				  FROM LAT_FormBuilderShare__c WHERE Id = :objectId];

		try {
			currentShare.LAT_AccessLevel__c = picklistValue;
			update currentShare;
		} catch(DmlException e) {
			result =  e.getMessage();
		}
	   	return result;
   	}

	/*
	* deletePermission
	* Delete Share object
	*/
	@RemoteAction
   	global static String deletePermission(String objectId) {
		String result = 'ok';
	    LAT_FormBuilderShare__c currentShare = [SELECT Id
				  FROM LAT_FormBuilderShare__c WHERE Id = :objectId];

		try {
			//delete currentShare;
		} catch(DmlException e) {
			result =  e.getMessage();
		}
	   	return result;
   	}

	/*
	* SavePerm
	* Insert Share object
	*/
	@RemoteAction
   	global static String SavePerm(String type, String name, String objectId, String level, String schema) {

		String result = 'ok';
		LAT_FormBuilderShare__c share = new LAT_FormBuilderShare__c();
		share.Name = objectId;
		share.LAT_AccessLevel__c = level;
		share.LAT_FormBuilderSchema__c = schema;
		if(type == 'user'){
			share.LAT_User__c = objectId;
		} else if(type == 'account'){
			share.LAT_Account__c = objectId;
		} else if(type == 'group'){
			share.LAT_Group__c = name;
		}

		try {
			insert share;
		} catch(DmlException e) {
			result =  e.getMessage();
		}
	   	return result;
   	}
}