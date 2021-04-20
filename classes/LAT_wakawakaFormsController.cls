/*
* LAT_wakawakaFormsController, manage Json forms using the Waka-waka form builder App
* Author: Martin Prado (martin@zimmic.com)
* Date: 08/01/2018
*/
global with sharing class LAT_wakawakaFormsController {

    public LAT_FormBuilderSchema__c fbs                         {get;set;}
    public Boolean newSchema                                    {get;set;}
    public String schemaName                                    {get;set;}
    public String schemaCountry                                 {get;set;}
    public String backUrl                                       {get;set;}
    public List<LAT_FormBuilderConnection__c> connections       {get;set;}


    /*
    * Constructor
    * This time for Africa
    */
    public LAT_wakawakaFormsController(){

         Id objectId = ApexPages.currentPage().getParameters().get('id');
         String isAdmin = ApexPages.currentPage().getParameters().get('isAdmin');
         connections = new  List<LAT_FormBuilderConnection__c>();

         schemaName = '';
         schemaCountry = '';

         if(objectId != null ){
            newSchema = false;
            fbs = [Select id, Name, (Select Name from Form_Builder_Pages__r ORDER BY Order__c ASC,  CreatedDate DESC), (Select Name, ObjectLabel__c , Id from LAT_Schema_Connections__r)  , Pages_Count__c, Status__c from LAT_FormBuilderSchema__c where Id =: objectId];
            if(!fbs.LAT_Schema_Connections__r.isEmpty()) {
                connections = fbs.LAT_Schema_Connections__r;
            }
         } else {
             fbs = new LAT_FormBuilderSchema__c();
             fbs.name = 'New';
             newSchema = true;

         }
         if(isAdmin != null){
            backUrl =  'LAT_SchemaBuilderDashBoard';
         } else {
            // By default redirect to the standar dashboard
            backUrl = 'LAT_UserDashboard';
         }


    }


    public PageReference publish(){
        fbs.status__c = 'Active';
        update fbs;
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;

    }

    public PageReference saveSchema() {
        fbs.name = Apexpages.currentPage().getParameters().get('name');
        fbs.status__c = 'Draft';
        fbs.country__c =  Apexpages.currentPage().getParameters().get('country');
        insert fbs;

        LAT_FormBuilderPages__c page = new LAT_FormBuilderPages__c();
        page.Form_Builder_Schema__c = fbs.id;
        page.Json__c = '[]';
        page.Name = 'Default';
        page.Order__c = 0;
        insert page;

        String isAdmin = ApexPages.currentPage().getParameters().get('isAdmin');
        String adminParam = '';
        // https://pernod-ricard--latsb3conf--c.cs107.visual.force.com/one/one.app#/alohaRedirect/apex/LAT_wakawakaForms?id=aTt1q000000001xCAA&isAdmin=true
        if(isAdmin != null){
           adminParam =  '&isAdmin=true';
        } else {
           // By default redirect to the standar dashboard
           adminParam = '';
        }
        PageReference pageRef = new PageReference('/apex/LAT_wakawakaForms?id='+fbs.Id+adminParam);
        pageRef.setRedirect(true);
        return pageRef;
        //return null;
    }



    /*
    * getObjects
    *
    */
	// @RemoteAction
    public static List<String> getObjectsList() {

        List<String> objectNames = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		List<String> entities = new List<String>(schemaMap.keySet());
		entities.sort();
		for(String name : entities)
        {
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

    /*
    * getObjects
    *
    */
	 @RemoteAction
     global static List<String> getObjects() {

        List<String> objectNames = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		List<String> entities = new List<String>(schemaMap.keySet());
		entities.sort();
		for(String name : entities)
        {
            String myName = '"'+ schemaMap.get(name).getDescribe().getLabel() + ' - ('+ schemaMap.get(name).getDescribe().getName() + ')"';
            objectNames.add(myName);
            if( objectNames.size() == 500 ){return objectNames;}
        }


        return objectNames;
    }




    /*
    * getPages
    *
    */
    @RemoteAction
    global static List<LAT_FormBuilderPages__c> getPages(String objectId) {

        List<LAT_FormBuilderPages__c> pages = [Select id, Json__c, Order__c, Form_Builder_Schema__c , Name from LAT_FormBuilderPages__c where Form_Builder_Schema__c =: objectId ORDER BY Order__c ASC,  CreatedDate DESC];
        return pages;

    }

    @RemoteAction
    global static List<String> getFields(String objectApiName) {

        system.debug('$$$$$' + objectApiName);
        List<String> names = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                system.debug('#######' + dfield );


                // Filter Name and Id
                if(dfield.getname() != 'id' && dfield.getname() != 'name' ) {
                    //"Id - (id)"
                    String ret =  dfield.getLabel () + ' - (' + dfield.getname()+')';
                    names.add(ret);
                }

            }

        return names;
        // List<LAT_FormBuilderPages__c> pages = [Select id, Json__c, Order__c, Form_Builder_Schema__c , Name from LAT_FormBuilderPages__c where Form_Builder_Schema__c =: objectId ORDER BY Order__c ASC,  CreatedDate DESC];
        // return pages;

    }






}