public with sharing class EUR_CRM_CPIbeforeInsertService {

	private final Set<String> CPI_RT_TO_UPDATE_QUANTITY = EUR_CRM_RecordTypeHelper_v2.getSettingsSet('EUR_CRM_CPIbeforeInsertService', 'CPI_RT_TO_UPDATE_QUANTITY');
	private final Set<String> CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet('EUR_CRM_CPIbeforeInsertService', 'CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES');
//	private final Set<String> CPI_RT_TO_UPDATE_QUANTITY = new Set<String> {
//		'EUR_DE_Contract_Product_Item'
//	};

//	private final Set<String> CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES = new Set<String> {
//		'EUR_GB_Contract_Product_Item'
//	};

	private static final Map<Id, Schema.RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosById();

	public EUR_CRM_CPIbeforeInsertService() {}


	/* ========================================================= */
	/*      Interfaces
	/* ========================================================= */
	public void updateQuantity(List<EUR_CRM_Contract_Product_Item__c> cpis) {
		List<EUR_CRM_Contract_Product_Item__c> cpiToUpdateQuantity = this.getCpisToUpdateQuantity(cpis);
		System.debug('\n cpiToUpdateQuantity.size() => ' + cpiToUpdateQuantity.size() + '\n');
		System.debug('\n cpiToUpdateQuantity => ' + JSON.serializePretty(cpiToUpdateQuantity) + '\n');
		if (cpiToUpdateQuantity.isEmpty()) { return; }

		List<EUR_CRM_Contract_Product_Item__c> cpisWithUpdatedQuantity = this.setQuantity(cpiToUpdateQuantity);
		System.debug('\n cpisWithUpdatedQuantity.size() => ' + cpisWithUpdatedQuantity.size() + '\n');
		System.debug('\n cpisWithUpdatedQuantity => ' + JSON.serializePretty(cpisWithUpdatedQuantity) + '\n');
	}

	public void updateTotalSpentFreeCases(List<EUR_CRM_Contract_Product_Item__c> cpis, Map<Id, EUR_CRM_Contract_Product_Item__c> oldCpiById) {
		List<EUR_CRM_Contract_Product_Item__c> cpisToUpdateTotalSpentFreeCases = this.getCpisToUpdateTotalSpentFreeCases(cpis, oldCpiById);
		if (cpisToUpdateTotalSpentFreeCases.isEmpty()) { return; }

		Map<Id, EUR_CRM_Contract_Product_Item__c> cpiByIdWhereContractIsDraft = new Map<Id, EUR_CRM_Contract_Product_Item__c>(this.selectCpisWhereIds(cpisToUpdateTotalSpentFreeCases));
		List<EUR_CRM_Contract_Product_Item__c> cpisWithUpdateTotalSpendFreeCases;
		if ( ! oldCpiById.isEmpty()){
			cpisWithUpdateTotalSpendFreeCases = this.setTotalSpendFreeCases(cpisToUpdateTotalSpentFreeCases, cpiByIdWhereContractIsDraft);
			return;
		} else {
			cpisWithUpdateTotalSpendFreeCases = this.setTotalSpendFreeCases(cpiByIdWhereContractIsDraft.values());
			update cpisWithUpdateTotalSpendFreeCases;
		}
	}


	/*================================================
	*  High Level Helpers
	* ================================================*/
	private List<EUR_CRM_Contract_Product_Item__c> getCpisToUpdateQuantity(List<EUR_CRM_Contract_Product_Item__c> cpis) {
		List<EUR_CRM_Contract_Product_Item__c> cpiToUpdate = new List<EUR_CRM_Contract_Product_Item__c>();
		for (EUR_CRM_Contract_Product_Item__c cpi : cpis) {
			if ( ! this.isNeedToUpdateQuantity(cpi)) { continue; }
			cpiToUpdate.add(cpi);
		}
		return cpiToUpdate;
	}

	private List<EUR_CRM_Contract_Product_Item__c> getCpisToUpdateTotalSpentFreeCases(List<EUR_CRM_Contract_Product_Item__c> cpis, Map<Id, EUR_CRM_Contract_Product_Item__c> oldCpiById) {
		List<EUR_CRM_Contract_Product_Item__c> cpiToUpdate = new List<EUR_CRM_Contract_Product_Item__c>();
		for (EUR_CRM_Contract_Product_Item__c cpi : cpis) {
			if ( ! this.isNeedToUpdateTotalSpentFreeCases(cpi, oldCpiById.get(cpi.Id))) { continue; }
			cpiToUpdate.add(cpi);
		}
		return cpiToUpdate;
	}



	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Contract_Product_Item__c> setQuantity(List<EUR_CRM_Contract_Product_Item__c> cpiToUpdate) {
		for (EUR_CRM_Contract_Product_Item__c cpi : cpiToUpdate) {
			Decimal quantity = cpi.EUR_CRM_Volume_lt__c;
			cpi.EUR_CRM_Quantity__c = quantity;
		}
		return cpiToUpdate;
	}

	private List<EUR_CRM_Contract_Product_Item__c> setTotalSpendFreeCases(List<EUR_CRM_Contract_Product_Item__c> cpiToUpdate) {
		for (EUR_CRM_Contract_Product_Item__c cpi : cpiToUpdate) {
			if ( ! this.isContractDraft(cpi)) { continue; }
			this.setTotalSpendFreeCases(cpi);
		}
		return cpiToUpdate;
	}

	private List<EUR_CRM_Contract_Product_Item__c> setTotalSpendFreeCases(List<EUR_CRM_Contract_Product_Item__c> cpiToUpdate, Map<Id, EUR_CRM_Contract_Product_Item__c> cpiByIdWhereContractIsDraft) {
		for (EUR_CRM_Contract_Product_Item__c cpi : cpiToUpdate) {
			if ( ! this.isContractDraft(cpiByIdWhereContractIsDraft.get(cpi.Id))) { continue; }
			this.setTotalSpendFreeCases(cpi);
		}
		return cpiToUpdate;
	}

	private void setTotalSpendFreeCases(EUR_CRM_Contract_Product_Item__c cpi) {
		cpi.EUR_CRM_Total_Spent_Free_cases_cur__c = cpi.EUR_CRM_Total_Spend_inc_free_cases__c;
	}




	/*================================================
	*  Low Level Helpers
	* ================================================*/
	private Boolean isNeedToUpdateQuantity(EUR_CRM_Contract_Product_Item__c cpi) {
		return this.isValidRecType(CPI_RT_TO_UPDATE_QUANTITY, cpi)
			&& this.isQuantityBlank(cpi);
	}

	private Boolean isNeedToUpdateTotalSpentFreeCases(EUR_CRM_Contract_Product_Item__c cpi, EUR_CRM_Contract_Product_Item__c oldCpi) {
		if (oldCpi == null) { return true; }
		return this.isValidRecType(CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES, cpi)
			&& this.isTotalSpendFormulaChanged(cpi, oldCpi);
	}

	private Boolean isValidRecType(Set<String> validRts, EUR_CRM_Contract_Product_Item__c cpi) {
		if ( ! rtInfoById.containsKey(cpi.RecordTypeId)) { return false; }
		return validRts.contains(rtInfoById.get(cpi.RecordTypeId).getDeveloperName());
	}

	private Boolean isQuantityBlank(EUR_CRM_Contract_Product_Item__c cpi) {
		return cpi.EUR_CRM_Quantity__c == 0 || cpi.EUR_CRM_Quantity__c == null;
	}

	private Boolean isTotalSpendFormulaChanged(EUR_CRM_Contract_Product_Item__c cpi, EUR_CRM_Contract_Product_Item__c oldCpi) {
		return cpi.EUR_CRM_Total_Spend_inc_free_cases__c != oldCpi.EUR_CRM_Total_Spend_inc_free_cases__c;
	}

	private Boolean isContractDraft(EUR_CRM_Contract_Product_Item__c cpi) {
		return cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__r.EUR_CRM_Status__c == 'Draft';
	}

	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_Contract_Product_Item__c> selectCpisWhereIds(List<EUR_CRM_Contract_Product_Item__c> cpis) {
		return [
			SELECT Id
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__r.EUR_CRM_Status__c
			,	EUR_CRM_Total_Spend_inc_free_cases__c
			,	EUR_CRM_Total_Spent_Free_cases_cur__c
			,	EUR_Min_Qty_Per_Annum_9L__c
			FROM EUR_CRM_Contract_Product_Item__c
			WHERE Id IN :cpis
		];
	}
}