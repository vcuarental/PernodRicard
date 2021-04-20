public with sharing class EUR_CRM_AccountGroupCreationBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	public static final List<String> ROLLOUT_COUNTRY_CODES = new List<String>();
	static {
		for(EUR_CRM_Rollout_Country__mdt setting :[SELECT DeveloperName FROM EUR_CRM_Rollout_Country__mdt]) {
			ROLLOUT_COUNTRY_CODES.add(setting.DeveloperName);
		}
	}

	@TestVisible private EUR_CRM_AccountGroupCreationBatch.Service service;
	public EUR_CRM_AccountGroupCreationBatch() {
		this.service = new EUR_CRM_AccountGroupCreationBatch.Service();
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,   EUR_CRM_External_ID__c
			,   EUR_CRM_Country_Code__c
			FROM EUR_CRM_Account__c
			WHERE EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES
			AND Id NOT IN (
				SELECT EUR_CRM_Account__c
				FROM EUR_CRM_AccountGroup__c
			)
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Account__c> accounts) {

		List<EUR_CRM_AccountGroup__c> agsToInsert = service.makeAGs(accounts);
		this.insertRecords(agsToInsert);
	}


	public class Service {

		@TestVisible
		private List<EUR_CRM_AccountGroup__c> makeAGs(List<EUR_CRM_Account__c> accsToCreateAG) {
			List<EUR_CRM_AccountGroup__c> agsToInsert = new List<EUR_CRM_AccountGroup__c>();
			for (EUR_CRM_Account__c acc : accsToCreateAG) {
				agsToInsert.add(this.makeAG(acc));
			}
			return agsToInsert;
		}

		private EUR_CRM_AccountGroup__c makeAG(EUR_CRM_Account__c acc) {
			return new EUR_CRM_AccountGroup__c(
				EUR_CRM_Account__c = acc.Id
			,   EUR_CRM_External_ID__c = acc.EUR_CRM_External_ID__c
			,   EUR_CRM_Country_Code__c = acc.EUR_CRM_Country_Code__c
			);
		}
	}

}