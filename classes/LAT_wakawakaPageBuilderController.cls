/*
* LAT_wakawakaFormsController, manage Json forms using the Waka-waka form builder App
* Author: Martin Prado (martin@zimmic.com)
* Date: 08/01/2018
*/
global with sharing  class LAT_wakawakaPageBuilderController {

	public LAT_FormBuilderSchema__c fbs {get;set;}
    public Boolean newSchema {get;set;}

    /*
    * Constructor
    */
    public LAT_wakawakaPageBuilderController(){

         Id objectId = ApexPages.currentPage().getParameters().get('id');
         if(objectId != null ){
            newSchema = false;
            fbs = [Select id, Name, (Select Name, Json__c from Form_Builder_Pages__r ORDER BY Order__c ASC,  CreatedDate DESC) ,Pages_Count__c, Status__c from LAT_FormBuilderSchema__c where Id =: objectId];
         } else {
             fbs = new LAT_FormBuilderSchema__c();
             fbs.name = 'New';
            newSchema = true;
         }

    }

	/*
    * getObjects
    *
    */
	 @RemoteAction
     global static List<SObject> getSalesforceObject(String fields, String objectName, String searchText, String filter) {

        List<List<sObject>> objectNames = new List<List<sObject>>();

        // we need the name field in each query
        fields = fields + ', Name ';

        String mySearch = searchText+'*';
        String searchquery = '';
        // Filter
        if(filter != '') {
            // the html send with "#"" to do more easy the parser, so we must to return the single quote
            filter = filter.replace('#', '\'');
            searchquery = 'FIND \''+mySearch+'\' IN  NAME FIELDS RETURNING '+objectName+'('+fields+' WHERE '+ filter+')  ' ;
        } else {
            searchquery = 'FIND \''+mySearch+'\' IN  NAME FIELDS RETURNING '+objectName+'('+fields+')';
        }

        System.debug('#searchquery \n'+ searchquery);
        objectNames = search.query(searchquery);

        List<sObject> contentData = new List<sObject>();
        for(List<sObject> obj:objectNames) {
            for(sObject customObj:obj) {
                 contentData.add(customObj);
            }

        }

        system.debug(contentData);



        return contentData;
    }
}