public with sharing class EUR_CRM_BQCpiUpdateService {

	private static final Set<String> BQ_RT_TO_UPDATE_CPI_TOTAL_SPENT_FREE_CASES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet('EUR_CRM_BQCpiUpdateService', 'BQ_RT_TO_UPDATE_CPI_TOTAL_SPENT_FREE_CASES');

	private static final Map<Id, RecordTypeInfo> bqRtInfoById = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosById();


	/* ========================================================= */
	/*      Interfaces
	/* ========================================================= */
	public void updateCpiTotalSpentFreeCases(List<EUR_CRM_Quality__c> bqs, Map<Id, EUR_CRM_Quality__c> oldBqById) {
		List<EUR_CRM_Quality__c> bqsToUpdateCpi = this.getBqsToUpdateCpi(bqs, oldBqById);
		System.debug('\n bqsToUpdateCpi.size() => ' + bqsToUpdateCpi.size() + '\n');
		System.debug('\n bqsToUpdateCpi => ' + JSON.serializePretty(bqsToUpdateCpi) + '\n');

		List<EUR_CRM_Contract_Product_Item__c> cpis = this.selectCpisWhereBqIds(bqsToUpdateCpi);
		System.debug('\n cpis.size() => ' + cpis.size() + '\n');
		System.debug('\n cpis => ' + JSON.serializePretty(cpis) + '\n');
		if (cpis.isEmpty()) { return; }

		List<EUR_CRM_Contract_Product_Item__c> cpisToUpdate = this.getCpisToUpdate(cpis);

		update cpisToUpdate;
	}




	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Quality__c> getBqsToUpdateCpi(List<EUR_CRM_Quality__c> bqs, Map<Id, EUR_CRM_Quality__c> oldBqById) {
		List<EUR_CRM_Quality__c> bqsToUpdateCpi = new List<EUR_CRM_Quality__c>();

		for (EUR_CRM_Quality__c bq : bqs) {
			Boolean isNeetToUpdateCpi = this.isNeedToUseBqToUpdateCpi(bq, oldBqById.get(bq.Id));
			System.debug('\n bq => ' + JSON.serializePretty(bq) + '\n');
			System.debug('\n isNeetToUpdateCpi => ' + JSON.serializePretty(isNeetToUpdateCpi) + '\n');
			if ( ! isNeetToUpdateCpi) { continue; }
			bqsToUpdateCpi.add(bq);
		}
		return bqsToUpdateCpi;
	}

	private List<EUR_CRM_Contract_Product_Item__c> getCpisToUpdate(List<EUR_CRM_Contract_Product_Item__c> cpis) {
		List<EUR_CRM_Contract_Product_Item__c> cpisToUpdate = new List<EUR_CRM_Contract_Product_Item__c>();
		for (EUR_CRM_Contract_Product_Item__c cpi : cpis) {
			cpi.EUR_CRM_Total_Spent_Free_cases_cur__c = cpi.EUR_CRM_Total_Spend_inc_free_cases__c;
			cpisToUpdate.add(cpi);
		}
		return cpisToUpdate;
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isNeedToUseBqToUpdateCpi(EUR_CRM_Quality__c bq, EUR_CRM_Quality__c oldBq) {
		return this.isValidRecType(bq)
			&& this.isOSGchanged(bq, oldBq);
	}

	private Boolean isValidRecType(EUR_CRM_Quality__c bq) {
		if ( ! bqRtInfoById.containsKey(bq.RecordTypeId)) { return false; }
		return BQ_RT_TO_UPDATE_CPI_TOTAL_SPENT_FREE_CASES.contains(bqRtInfoById.get(bq.RecordTypeId).getDeveloperName());
	}

	private Boolean isOSGchanged(EUR_CRM_Quality__c bq, EUR_CRM_Quality__c oldBq) {
		return bq.EUR_CRM_OSG__c != oldBq.EUR_CRM_OSG__c;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_Contract_Product_Item__c> selectCpisWhereBqIds(List<EUR_CRM_Quality__c> bqs) {
		return [
			SELECT Id
				,	EUR_CRM_Total_Spend_inc_free_cases__c
				,	EUR_CRM_Total_Spent_Free_cases_cur__c
			FROM EUR_CRM_Contract_Product_Item__c
			WHERE EUR_CRM_Brand_Quality__c IN :bqs
			AND EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__r.EUR_CRM_Status__c = 'Draft'

		];
	}
}