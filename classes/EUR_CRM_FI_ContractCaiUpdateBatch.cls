public with sharing class EUR_CRM_FI_ContractCaiUpdateBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private static final String FI_CAI_RT = 'EUR_FI_Contract_Activity_Item';

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,	(
				SELECT Id
				,	EUR_CRM_Mechanic_Type__c
				,	EUR_CRM_Contract__c
				FROM EUR_CRM_Contract_Activity_Items__r
			)
			FROM EUR_CRM_Contract__c
			WHERE EUR_CRM_Country_Code__c = 'FI'
			AND EUR_CRM_Status__c = 'Draft'
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Contract__c> contracts) {

		RecordTypeInfo rtInfo = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(FI_CAI_RT);
		if (rtInfo == null) { return; }

		Id caiRtId = rtInfo.getRecordTypeId();
		System.debug('\n contracts.size() => ' + contracts.size() + '\n');
		Map<Id, Set<Id>> mtIdByContrId = this.getMtIdByContrId(contracts);
		System.debug('\n mtIdByContrId.size() => ' + mtIdByContrId.size() + '\n');
		System.debug('\n mtIdByContrId => ' + JSON.serializePretty(mtIdByContrId) + '\n');

		List<EUR_CRM_Contract_Activity_Item__c> caisToInsert = this.getCaisToInsert(mtIdByContrId, caiRtId);
		System.debug('\n caisToInsert.size() => ' + caisToInsert.size() + '\n');
		System.debug('\n caisToInsert => ' + JSON.serializePretty(caisToInsert) + '\n');
		this.upsertRecords(caisToInsert);

		this.finish(bc);
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Contract_Activity_Item__c> getCaisToInsert(Map<Id, Set<Id>> mtIdByContrId, Id caiRtId) {
		Map<Id, EUR_CRM_Mechanic_Type__c> mtById = new Map<Id, EUR_CRM_Mechanic_Type__c>(this.selectMts());
		Map<String, EUR_CRM_CTM_Contract_setting__mdt> csByMtExtId = this.getCsByMtExtId();
		List<EUR_CRM_Contract_Activity_Item__c> caisToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
		for (Id contrId : mtIdByContrId.keySet()) {
			Set<Id> contractMtIds = mtIdByContrId.get(contrId);
			for (Id mtId : mtById.keySet()) {
				if ( ! contractMtIds.contains(mtId)) {
					caisToInsert.add(this.makeCAI(caiRtId, contrId, mtId, csByMtExtId.get(mtId)));
				}
			}
		}
		return caisToInsert;
	}

	private Map<Id, Set<Id>> getMtIdByContrId(List<EUR_CRM_Contract__c> contracts) {
		Map<Id, Set<Id>> mtIdByContrId = new Map<Id, Set<Id>>();
		for (EUR_CRM_Contract__c contract : contracts) {
			mtIdByContrId.put(contract.Id, new Set<Id>());
			for (EUR_CRM_Contract_Activity_Item__c cai : contract.EUR_CRM_Contract_Activity_Items__r) {
				mtIdByContrId.get(cai.EUR_CRM_Contract__c).add(cai.EUR_CRM_Mechanic_Type__c);
			}
		}
		return mtIdByContrId;
	}

	private Map<String, EUR_CRM_CTM_Contract_setting__mdt> getCsByMtExtId() {
		Map<String, EUR_CRM_CTM_Contract_setting__mdt> csByMtExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();
		List<EUR_CRM_CTM_Contract_setting__mdt> cSs = this.selectContractSettings();
		if (cSs.isEmpty()) { return csByMtExtId; }

		for (EUR_CRM_CTM_Contract_setting__mdt cs : cSs) {
			csByMtExtId.put(cs.EUR_CRM_Mechanic_ExtID__c, cs);
		}
		return csByMtExtId;
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private EUR_CRM_Contract_Activity_Item__c makeCAI(Id rtId, Id contrId, Id mtId, EUR_CRM_CTM_Contract_setting__mdt cs) {
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Contract__c = contrId
		,	EUR_CRM_Mechanic_Type__c = mtId
		,	EUR_CRM_Item_Type__c = cs == null ? '' : cs.EUR_CRM_Setting_Type__c
		,	EUR_CRM_Product_level__c = cs == null ? '' : cs.EUR_CRM_Product_level__c
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_CTM_Contract_setting__mdt> selectContractSettings() {
		return [
			SELECT
				DeveloperName
			,	EUR_CRM_Mechanic_ExtID__c
			,	EUR_CRM_Product_level__c
			,	EUR_CRM_Setting_Type__c
			FROM EUR_CRM_CTM_Contract_setting__mdt
			WHERE EUR_CRM_Country_Code__c = 'FI'
		];
	}

	private List<EUR_CRM_Mechanic_Type__c> selectMts() {
		return [
			SELECT Id
			,	EUR_CRM_External_ID__c
			FROM EUR_CRM_Mechanic_Type__c
			WHERE EUR_CRM_Country_Code__c = 'FI'
		];
	}

}