/**
 * Contract Activity Item Trigger class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_ContractActivityTriggerHandler {

	private final Set<String> VALID_CAI_RT_TO_UPDATE_CPPP = new Set<String> {
		'EUR_DE_Contract_Activity_Item'
	};

	/* ========================================================= */
	/*      Interfaces
	/* ========================================================= */
	public void afterUpdate(List<EUR_CRM_Contract_Activity_Item__c> cais, Map<Id, EUR_CRM_Contract_Activity_Item__c> oldCAIbyId) {
		this.createDraftTransactions(cais, oldCAIbyId);
		this.doUpdateCPPPs(cais, oldCAIbyId);
	}


	/* ========================================================= */
	/*      Delegate methods
	/* ========================================================= */
	private void createDraftTransactions(List<EUR_CRM_Contract_Activity_Item__c> cais, Map<Id, EUR_CRM_Contract_Activity_Item__c> oldCAIbyId) {
		List<Id> contractIdsToUpdate = new List<Id>();
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			EUR_CRM_Contract_Activity_Item__c oldCAI = oldCAIbyId.get(cai.Id);
			if (this.isCAIchanged(cai, oldCAI)) { contractIdsToUpdate.add(cai.EUR_CRM_Contract__c); }
		}

		if (contractIdsToUpdate.isEmpty()) { return ; }
		EUR_ISP_ContractTransactionsServiceDE.createDraftTransactions(contractIdsToUpdate);
		EUR_ISP_ContractTransactionsServiceDE.commitTransactions();
	}

	private void doUpdateCPPPs(List<EUR_CRM_Contract_Activity_Item__c> newCAIs, Map<Id, EUR_CRM_Contract_Activity_Item__c> oldCAIbyId) {
		System.debug('\n newCAIs.size() => ' + newCAIs.size() + '\n');
		System.debug('\n newCAIs => ' + JSON.serializePretty(newCAIs) + '\n');
		Set<Id> validCAIrtIds = this.getValidCAIrtIds();
		System.debug('\n validCAIrtIds.size() => ' + validCAIrtIds.size() + '\n');
		System.debug('\n validCAIrtIds => ' + JSON.serializePretty(validCAIrtIds) + '\n');

		List<EUR_CRM_Contract_Activity_Item__c> caisToUpdateCPPP = this.getValidCAItoUpdateCPPP(newCAIs, oldCAIbyId, validCAIrtIds);
		System.debug('\n caisToUpdateCPPP.size() => ' + caisToUpdateCPPP.size() + '\n');
		System.debug('\n caisToUpdateCPPP => ' + JSON.serializePretty(caisToUpdateCPPP) + '\n');
		if (caisToUpdateCPPP.isEmpty()) { return; }

		List<EUR_CRM_Contract_Activity_Item__c> caisWithRelatives = this.selectCAIsWhereIds(caisToUpdateCPPP);
		System.debug('\n caisWithRelatives.size() => ' + caisWithRelatives.size() + '\n');
		System.debug('\n caisWithRelatives => ' + JSON.serializePretty(caisWithRelatives) + '\n');
		if (caisWithRelatives.isEmpty()) { return; }

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsToUpdate = this.updateCPPPs(caisWithRelatives);
		System.debug('\n cpppsToUpdate.size() => ' + cpppsToUpdate.size() + '\n');
		System.debug('\n cpppsToUpdate => ' + JSON.serializePretty(cpppsToUpdate) + '\n');
		if (cpppsToUpdate.isEmpty()) { return; }
		update cpppsToUpdate;
	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private Set<Id> getValidCAIrtIds() {
		Map<String, RecordTypeInfo> rtInfoByDevName = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName();
		Set<Id> validCAIrtIds = new Set<Id>();
		for (String rt : this.VALID_CAI_RT_TO_UPDATE_CPPP) {
			if ( ! rtInfoByDevName.containsKey(rt)) { continue; }
			validCAIrtIds.add(rtInfoByDevName.get(rt).getRecordTypeId());
		}
		return validCAIrtIds;
	}

	private List<EUR_CRM_Contract_Activity_Item__c> getValidCAItoUpdateCPPP(List<EUR_CRM_Contract_Activity_Item__c> newCAIs,
		Map<Id, EUR_CRM_Contract_Activity_Item__c> oldCAIbyId, Set<Id> validCAIrtIds) {
		List<EUR_CRM_Contract_Activity_Item__c> caisToUpdateCPPP = new List<EUR_CRM_Contract_Activity_Item__c>();
		for (EUR_CRM_Contract_Activity_Item__c cai : newCAIs) {
			if ( ! this.isCAIvalid(cai, oldCAIbyId.get(cai.Id), validCAIrtIds)) { continue; }
			caisToUpdateCPPP.add(cai);
		}
		return caisToUpdateCPPP;

	}

	private List<EUR_CRM_Contract_Payment_Plan_Period__c> updateCPPPs(List<EUR_CRM_Contract_Activity_Item__c> cais) {
		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsToUpdate = new List<EUR_CRM_Contract_Payment_Plan_Period__c>();
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			if (this.isPouringRefund(cai)) { continue; }
			for (EUR_CRM_Contract_Payment_Plan_Period__c cppp : cai.Contract_Payment_Plan_Periods__r) {
				cpppsToUpdate.add(this.updateCPPP(cai, cppp));
			}
		}
		return cpppsToUpdate;
	}

	private EUR_CRM_Contract_Payment_Plan_Period__c updateCPPP(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Payment_Plan_Period__c cppp) {
		System.debug('\n cai => ' + JSON.serializePretty(cai) + '\n');

		cppp.EUR_CRM_CPPP_Amount__c = cai.EUR_CRM_Amount__c;
		cppp.EUR_CRM_Payment_Period_Start_Date__c = cai.EUR_CRM_Start_Date__c;
		cppp.EUR_CRM_Payment_Period_End_Date__c = cai.EUR_CRM_End_Date__c;
		cppp.EUR_CRM_CPPP_Payment_Term__c= cai.EUR_CRM_Payment_Term__c;
		return cppp;
	}

	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isCAIvalid(EUR_CRM_Contract_Activity_Item__c newCAI, EUR_CRM_Contract_Activity_Item__c oldCAI, Set<Id> validCAIrtIds) {
		return validCAIrtIds.contains(newCAI.RecordTypeId)
			&& (newCAI.EUR_CRM_Start_Date__c != oldCAI.EUR_CRM_Start_Date__c
			|| newCAI.EUR_CRM_End_Date__c != oldCAI.EUR_CRM_End_Date__c
			|| newCAI.EUR_CRM_Payment_Term__c != oldCAI.EUR_CRM_Payment_Term__c
			|| newCAI.EUR_CRM_Amount__c != oldCAI.EUR_CRM_Amount__c)
		;
	}

	private Boolean isPouringRefund(EUR_CRM_Contract_Activity_Item__c cai) {
		return cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == 'EUR_DE_Pouring_Refund';
	}

	private Boolean isProductExist(EUR_CRM_Contract_Payment_Plan_Period__c cppp) {
		return cppp.EUR_CRM_Contract_Product_Item__c != null;
	}

	private Boolean isCAIchanged(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Activity_Item__c oldCAI) {
		return this.isCAItotalChanged(cai, oldCAI)
			&& this.isDatesChanged(cai, oldCAI);
	}

	private Boolean isCAItotalChanged(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Activity_Item__c oldCAI) {
		return cai.EUR_CRM_Contract_Activity_Total__c == oldCAI.EUR_CRM_Contract_Activity_Total__c;
	}

	private Boolean isDatesChanged(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Activity_Item__c oldCAI) {
		return cai.EUR_CRM_Start_Date__c != oldCAI.EUR_CRM_Start_Date__c
			|| cai.EUR_CRM_End_Date__c != oldCAI.EUR_CRM_End_Date__c
			;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_Contract_Activity_Item__c> selectCAIsWhereIds(List<EUR_CRM_Contract_Activity_Item__c> cais) {
		return [
			SELECT Id
				,	EUR_CRM_Start_Date__c
				,	EUR_CRM_End_Date__c
				,	EUR_CRM_Payment_Term__c
				,	EUR_CRM_Amount__c
				,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				,	(
				SELECT Id
					,	EUR_CRM_Payment_Period_Start_Date__c
					,	EUR_CRM_Payment_Period_End_Date__c
					,	EUR_CRM_CPPP_Payment_Term__c
					,	EUR_CRM_CPPP_Amount__c
					,	EUR_CRM_Contract_Product_Item__r.EUR_CRM_Amount_Spent__c
				FROM Contract_Payment_Plan_Periods__r
			)
			FROM EUR_CRM_Contract_Activity_Item__c
			WHERE Id IN :cais
		];
	}

}