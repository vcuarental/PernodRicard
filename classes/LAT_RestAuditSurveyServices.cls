/*
* LAT_RestAuditSurveyServices,
* Author: Martin Prado (martin@zimmic.com)
* Date: 4/12/2018
*/

@RestResource(urlMapping='/LAT_RestAuditSurveyServices/*')

global with sharing class LAT_RestAuditSurveyServices {

	@HttpPost
	global static void post(String userId, Datetime lastSync) {

		RestContext.response.addHeader('Content-Type', 'application/json');

		try {
			Set<Id> myFormsIds = new Set<Id>();
			Map<Id, String> formLevel = new Map<Id, String>();

			// We dont need the user permission, on iCRM Edit or Fill has the same permission
			formLevel  = LAT_UserDashBoardController.getMySchemaForms(userId);
			myFormsIds =  formLevel.keySet();
			List<LAT_FormBuilderSchema__c> fbs;
			if(lastSync != null) {
	            fbs = [Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c  where Id in: myFormsIds AND Status__c = 'Active' AND lastmodifieddate >= :lastSync order by lastmodifieddate desc limit 100];

			} else {
	            fbs = [Select id, CreatedById,  CreatedBy.Name, Fields_Count__c, Country__c,  Name, Pages_Count__c , Status__c, createddate from LAT_FormBuilderSchema__c  where Id in: myFormsIds AND Status__c = 'Active' order by CreatedDate desc limit 100];

			}
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(fbs));
            RestContext.response.statusCode = 200;

        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            RestContext.response.statusCode = 500;
        }

	}

	@HttpGet
	global static void getEntryById() {

		RestContext.response.addHeader('Content-Type', 'application/json');

    	String sfdcId = RestContext.request.params.get('sfdcId');
    	System.debug('%%%%% sfdcId : '+ sfdcId);

		try {
			LAT_FormBuilderEntries__c entry;
			if(sfdcId.startsWith(LAT_FormBuilderEntries__c.sObjectType.getDescribe().getKeyPrefix()) && sfdcId.length() < 19){
				entry = [SELECT Id, Form_Builder_Schema__c, JsonData__c, Status__c, LAT_IcrmExternalId__c FROM LAT_FormBuilderEntries__c WHERE Id = :sfdcId];
			} else {
				entry = [SELECT Id, Form_Builder_Schema__c, JsonData__c, Status__c, LAT_IcrmExternalId__c FROM LAT_FormBuilderEntries__c WHERE LAT_IcrmExternalId__c = :sfdcId];
			}
			System.debug('%%% entry encontrada: ' + entry);
			System.debug('%%% entry LAT_IcrmExternalId__c.: ' + entry.LAT_IcrmExternalId__c);
			if(entry != null) {
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(entry));
            	RestContext.response.statusCode = 200;
			} else {
				RestContext.response.responseBody = Blob.valueOf('{"message":"NOT FOUND"}');
            	RestContext.response.statusCode = 404;
			}
            

        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            RestContext.response.statusCode = 500;
        }

	}

}