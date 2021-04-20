global with sharing class EUR_CRM_MassUpdateCentralObjActive implements Database.Batchable<sObject>{

	global final String query;
	global final Set<String> validRecordTypes = new Set<String> {
		'EUR_BG_Central_Promotion',
		'EUR_PT_On_Trade_Central_Promotion',
		'EUR_PT_Off_Trade_Central_Promotion'
	};

	global EUR_CRM_MassUpdateCentralObjActive() {
		query = 'SELECT Id, EUR_CRM_End_Date__c, EUR_CRM_Start_Date__c FROM EUR_CRM_GB_Objective__c ' +
				'WHERE EUR_CRM_Start_Date__c <= TODAY AND ' +
				'RecordType.DeveloperName in :validRecordTypes';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//List<EUR_CRM_GB_Objective__c> objectiveList = (List<EUR_CRM_GB_Objective__c>)scope;
		Map<Id, EUR_CRM_GB_Objective__c> objectiveMap = new Map<Id, EUR_CRM_GB_Objective__c>((List<EUR_CRM_GB_Objective__c>)scope);
		List<EUR_CRM_Visit_Action__c> visitActionToUpdate = new List<EUR_CRM_Visit_Action__c>();

		for(EUR_CRM_Visit_Action__c visitAction: [SELECT Id, EUR_CRM_Active__c,
													EUR_CRM_Is_Promo_Active__c,
													EUR_CRM_Objective__c
													FROM EUR_CRM_Visit_Action__c
													WHERE EUR_CRM_Objective__c IN :objectiveMap.keySet()]) {

			if(objectiveMap.get(visitAction.EUR_CRM_Objective__c).EUR_CRM_End_Date__c > Date.Today() && visitAction.EUR_CRM_Is_Promo_Active__c == false && visitAction.EUR_CRM_Active__c == false) {
				visitAction.EUR_CRM_Active__c = true;
				visitActionToUpdate.add(visitAction);
			} else if(objectiveMap.get(visitAction.EUR_CRM_Objective__c).EUR_CRM_End_Date__c < Date.Today()  && visitAction.EUR_CRM_Active__c == true) {
				visitAction.EUR_CRM_Active__c = false;
				visitActionToUpdate.add(visitAction);
			}
		}

		if(visitActionToUpdate.size() > 0) {
			update visitActionToUpdate;
		}
	}

	global void finish(Database.BatchableContext BC){   
	    EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
	}
}