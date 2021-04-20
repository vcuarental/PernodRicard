/*
* LAT_SchemaBuilderConnectionController,
* Author: Martin Prado (martin@zimmic.com)
* Date: 12/7/2018
*/
global with sharing class LAT_SchemaBuilderConnectionController {

	public LAT_FormBuilderConnection__c connection	{ get; set; }
	public LAT_FormBuilderSchema__c 	fbs 		{ get; set; }
	public List<String> 				objectList  { get; set; }

	// Constructor
	public LAT_SchemaBuilderConnectionController() {

		Id connectionId = ApexPages.currentPage().getParameters().get('id');
        Id schemaId = ApexPages.currentPage().getParameters().get('schema');

		fbs = [Select id, Name, (Select Id from LAT_Schema_Connections__r ) , (Select Name, Json__c from Form_Builder_Pages__r ORDER BY Order__c ASC,  CreatedDate DESC) ,Pages_Count__c, Status__c from LAT_FormBuilderSchema__c where Id =: schemaId];

		if(connectionId != null) {
			connection = [Select Name, UpdateBasedOnLookup__c, SkipIfValueProvided__c, SkipIfValueNotProvided__c, ObjectLabel__c , ObjectName__c, LAT_FormBuilderSchema__c, Sequence__c, Mapping__c, IsActive__c,  Id from LAT_FormBuilderConnection__c where Id =: connectionId];

		} else {
			connection = new LAT_FormBuilderConnection__c();
			connection.name = 'New Connection';
			Integer sequenceNumber =  fbs.LAT_Schema_Connections__r.size() + 1;
			connection.Sequence__c = sequenceNumber;
			connection.ObjectLabel__c = '';
			connection.ObjectName__c = '';
		}

		objectList = getObjectsList();

	}


	/*
	* getObjects
	*
	*/

	private  List<String> getObjectsList() {

		List<String> objectNames = new List<String>();
		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		List<String> entities = new List<String>(schemaMap.keySet());
		entities.sort();
		for(String name : entities) {
		String myName = '"'+ schemaMap.get(name).getDescribe().getLabel() + ' - ('+ schemaMap.get(name).getDescribe().getName() + ')"';
		if(myName.contains('PRH_') || myName.contains('Milestone1_') || myName.contains('LightningComponent') || myName.contains('\'') || myName.contains('USA_') || myName.contains('Apex') ||  myName.contains('__Tag')  || myName.contains('BMCServiceDesk') || myName.contains('gvp__') || myName.contains('MMPJ_') || myName.contains('EUR_') || myName.contains('AME_') || myName.contains('ESN_') || myName.contains('ccpt__') || myName.contains('et4ae5__S') || myName.contains('cms__') || myName.contains('ASI_')){


		} else {
		 objectNames.add(myName);
		}



	     if( objectNames.size() == 2000 ){
	          return objectNames;
	     }
	 }


	 return objectNames;
	}


	@RemoteAction
    global static List<String> getFields(String objectApiName) {

        system.debug('$$$$$' + objectApiName);
        List<String> names = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                if(dfield.getname() != 'id' ) {
                    String ret =  dfield.getLabel () + ' - (' + dfield.getname()+')';
                    names.add(ret);
                }

            }

        return names;

    }
}