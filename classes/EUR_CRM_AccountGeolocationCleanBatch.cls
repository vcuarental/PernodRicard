public with sharing class EUR_CRM_AccountGeolocationCleanBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {

	private String countryCode;
	public EUR_CRM_AccountGeolocationCleanBatch(String countryCode) {
		this.countryCode = countryCode;
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
				, Name
				, EUR_CRM_Country_Code__c
				, EUR_CRM_Outlet_Geolocation__Latitude__s
				, EUR_CRM_Outlet_Geolocation__Longitude__s
				, EUR_CRM_Outlet_Geolocation__c
				, EUR_CRM_OutletGeolocationRecalculation__c
			FROM EUR_CRM_Account__c
			WHERE EUR_CRM_Country_Code__c =: this.countryCode
			AND EUR_CRM_OutletGeolocationRecalculation__c = FALSE
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Account__c> accounts) {
		for (EUR_CRM_Account__c acc : accounts) {
			acc.EUR_CRM_Outlet_Geolocation__Latitude__s = null;
			acc.EUR_CRM_Outlet_Geolocation__Longitude__s = null;
			acc.EUR_CRM_OutletGeolocationRecalculation__c = true;
		}

		this.upsertRecords(accounts);
	}

	public override void finish(Database.BatchableContext bc) {
		super.finish(bc);
	}

}