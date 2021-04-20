/*********************************************************************************
 * Name:ASI_TnE_GnH_TW_Validation
 * Description: Validation G&H Request Record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-07-25       Laputa: Hugo Cheung     Created
*********************************************************************************/
public without sharing class ASI_TnE_GnH_TW_Validation extends ASI_GnH_Request_TriggerAbstract {

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> newList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

		List<ASI_GnH_Request__c> requestList = (List<ASI_GnH_Request__c>) newList;
		Map<Id, ASI_GnH_Request__c> oldRequestMap = (Map<Id, ASI_GnH_Request__c>) oldMap;

		List<Id> requestIdList = new List<Id>();

		for(ASI_GnH_Request__c request : requestList) {

			requestIdList.add(request.Id);

		}

		Map<Id, ASI_GnH_Request__c> requestWithClaimDetailMap = new Map<Id, ASI_GnH_Request__c>([SELECT Id,
																									(SELECT Id FROM Travel_Entertainment_Claims_Detail__r) 
		                                               												FROM ASI_GnH_Request__c
		                                               													WHERE Id in :requestIdList]);
		for(ASI_GnH_Request__c request : requestList) {

			checkStatusChange(request, requestWithClaimDetailMap, oldRequestMap);

		}
	}

	private void checkStatusChange(ASI_GnH_Request__c request, Map<Id, ASI_GnH_Request__c> requestWithClaimDetailMap, Map<Id, ASI_GnH_Request__c> oldRequestMap) {

		if(request.ASI_GnH_Status__c.equals('Draft') && 
		   !oldRequestMap.get(request.Id).ASI_GnH_Status__c.equals(request.ASI_GnH_Status__c) &&
		   requestWithClaimDetailMap.get(request.Id).Travel_Entertainment_Claims_Detail__r.size() > 0) {

			request.addError(System.Label.ASI_TnE_GnH_Change_Status_Draft_Not_Allow);

		}

	}

}