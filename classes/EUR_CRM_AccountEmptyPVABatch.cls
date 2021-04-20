global with sharing class EUR_CRM_AccountEmptyPVABatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private static final String BATCH_NAME = 'EUR_CRM_AccountEmptyPVABatch';
	private static final String VARIABLE_NAME = 'CountryCodes';

	private String countryCode;

	//Constructor
	global EUR_CRM_AccountEmptyPVABatch(String countryCode) {
		this.countryCode = countryCode;
	}


	//Interfaces
	global String run() {
		if (this.isAlreadyLaunchedForCountryCode(this.countryCode)) {
			return 'Launched';
		}
		Database.executeBatch(this);
		return 'Success';
	}

	global Boolean isAlreadyLaunchedForCountryCode(String countryCode) {
		List<EUR_CRM_BatchCache__c> batchCaches = this.selectBatchCaches();
		if (batchCaches.isEmpty()) { return false; }
		Set<String> launchedCountryCodes = this.normalizeAndSplit(batchCaches[0].EUR_CRM_Value__c);
		return launchedCountryCodes.contains(countryCode);
	}

	global Integer countAccountsToUpdateField() {
		return this.getQueryBuilder( this.countryCode).toCount();
	}


	//Batch methods
	global Database.QueryLocator start(Database.BatchableContext bc) {
		this.writeInfoAboutStart();

		return Database.getQueryLocator(this.getStartQuery(this.countryCode));
	}

	global void execute(Database.BatchableContext bc, List<EUR_CRM_Account__c> accounts) {
		this.setEmptyPVAField(accounts);
		this.upsertRecords(accounts);
	}

	global override void finish(Database.BatchableContext BC) {
		this.writeInfoAboutFinish();
		this.sendEmailReport(BC);
	}


	//Helpers
	private EUR_CRM_QueryBuilder getQueryBuilder(String countryCode) {
		return new EUR_CRM_QueryBuilder(EUR_CRM_Account__c.class)
			.qbField(EUR_CRM_Account__c.EUR_CRM_ForceEmptyPVA__c)
			.qbField(EUR_CRM_Account__c.EUR_CRM_Country_Code__c)
			.qbCondition().add(
				new EUR_CRM_QueryBuilder.ComplexCondition()
					.startCondition(new EUR_CRM_QueryBuilder.CompareCondition(EUR_CRM_Account__c.EUR_CRM_Country_Code__c)
					.eq(countryCode))
					.andCondition(new EUR_CRM_QueryBuilder.CompareCondition(EUR_CRM_Account__c.EUR_CRM_ForceEmptyPVA__c)
					.eq(false))
				)
			.endCondition();
	}

	private String getStartQuery(String countryCode) {
		return this.getQueryBuilder(countryCode).toString();
	}

	private void writeInfoAboutStart() {
		List<EUR_CRM_BatchCache__c> batchCaches = this.selectBatchCaches();
		if (batchCaches.isEmpty()) {
			batchCaches.add(this.makeBatchCache());
		} else {
			Set<String> launchedCountryCodes = this.normalizeAndSplit(batchCaches[0].EUR_CRM_Value__c);
			if ( ! launchedCountryCodes.contains(this.countryCode)) {
				launchedCountryCodes.add(this.countryCode);
				this.setNewValue(batchCaches[0], launchedCountryCodes);
			}
		}
		this.upsertRecords(batchCaches);
	}

	private void writeInfoAboutFinish() {
		List<EUR_CRM_BatchCache__c> batchCaches = this.selectBatchCaches();
		Set<String> launchedCountryCodes = this.normalizeAndSplit(batchCaches[0].EUR_CRM_Value__c);
		if (launchedCountryCodes.contains(this.countryCode)) {
			launchedCountryCodes.remove(this.countryCode);
			this.setNewValue(batchCaches[0], launchedCountryCodes);
			this.upsertRecords(batchCaches);
		}
	}

	private void setEmptyPVAField(List<EUR_CRM_Account__c> accounts) {
		for (EUR_CRM_Account__c account : accounts) {
			account.EUR_CRM_ForceEmptyPVA__c = true;
		}
	}

	private Set<String> normalizeAndSplit(String s) {
		if (String.isBlank(s)) { return new Set<String>(); }
		return new Set<String>(s.normalizeSpace().split('[,; ]'));
	}

	private void setNewValue(EUR_CRM_BatchCache__c batchCache, Set<String> launchedCountryCodes) {
		String countryCodesAsString = String.join(new List<String>(launchedCountryCodes), ',');
		if ( ! String.isBlank(countryCodesAsString)) { countryCodesAsString += ','; }
		batchCache.put('EUR_CRM_Value__c', String.valueOf(countryCodesAsString));
	}


	//Makers
	private EUR_CRM_BatchCache__c makeBatchCache() {
		return new EUR_CRM_BatchCache__c(
			Name = BATCH_NAME,
			EUR_CRM_BatchName__c = BATCH_NAME,
			EUR_CRM_VariableName__c = VARIABLE_NAME,
			EUR_CRM_Value__c = this.countryCode
		);
	}


	//Selectors
	private List<EUR_CRM_BatchCache__c> selectBatchCaches() {
		return [
			SELECT Id, EUR_CRM_BatchName__c, EUR_CRM_VariableName__c, EUR_CRM_Value__c
			FROM EUR_CRM_BatchCache__c
			WHERE  EUR_CRM_BatchName__c =: BATCH_NAME
			AND EUR_CRM_VariableName__c =: VARIABLE_NAME
			FOR UPDATE
		];
	}

}