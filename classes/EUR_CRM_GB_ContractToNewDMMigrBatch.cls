/*
	EUR_CRM_GB_ContractToNewDMMigrBatch.cls migrates Contract Line Items of each GB contract to Contract Activity Item
	with related Contract Product Items.

	0. In each C will be updated fields:
		EUR_CRM_Contract_Type__c (if field is blank), EUR_CRM_Supplier_Account__c (if field value not equals EUR_CRM_Nominated_Supplier__c field value).

	1. CAI will be created only if CLI has MT.EUR_CRM_External_ID__c != null.
	2. CAI will be created only if in current C doesn't exist CAI with MT.EUR_CRM_External_ID__c like in CLI from which it needs to be created.
	2a. Update from 18.11.2019 - after 2 batch will create all missed CAIs for all MTs with no CPIs.


	3. CPI will be created for each CLI which has B, BQ, BQS, SKU populated.
	4. CPI will be created only if CPI doesn't exist in current C and CAI with MT.EUR_CRM_External_ID__c like in CLI from which it needs to be created.

	C - Contract
	CAI - Contract Activity Item
	CPI - Contract Product Item
	CLI - Contract Line Item
	CC - Contract Cocktail
	M - Mechanic
	MT - Mechanic Type
	CM - Contract Mechanic
	B - Brand
	BQ - Brand-Quality
	BQS - Brand-Quality-Size
	SKU - SKU

* */
public with sharing class EUR_CRM_GB_ContractToNewDMMigrBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {

	private static final String GB_LUMP_SUM_MT = 'GB_Lump_Sum';
	private static final String GB_MARKETING_SUPPORT_MT = 'GB_Marketing_Support';
	private static final String GB_CAI_RT = 'EUR_GB_Contract_Activity_Item';
	private static final String GB_CPI_RT = 'EUR_GB_Contract_Product_Item';
	private static final String STANDARD_CONTRACT = 'Standard Contract';

	private static final RecordTypeInfo caiRtInfo = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(GB_CAI_RT);
	private static final RecordTypeInfo cpiRtInfo = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(GB_CPI_RT);

	private static Map<String, EUR_CRM_Mechanic_Type__c> mechTypeByExtId = new Map<String, EUR_CRM_Mechanic_Type__c>();

	private Id contrId;

	public EUR_CRM_GB_ContractToNewDMMigrBatch() {}

	public EUR_CRM_GB_ContractToNewDMMigrBatch(Id contrId) {
		this.contrId = contrId;
	}
	public Database.QueryLocator start(Database.BatchableContext bc) {
		if (this.contrId != null) {
			return Database.getQueryLocator([
				SELECT Id
					,	RecordType.DeveloperName
					,	EUR_CRM_Contract_Type__c
					,	EUR_CRM_Nominated_Supplier__c
					,	EUR_CRM_Supplier_Account__c
					,	(
					SELECT Id
						,	EUR_CRM_Contract_Mechanic__c
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.Name
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c
						,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_SkU__c
						,	EUR_CRM_Cocktail_Percent__c
						,	EUR_Min_Qty_Per_Annum_9L__c
						,	EUR_CRM_Retro_Per_9L__c
						,	EUR_CRM_No_of_Cocktails__c
						,	EUR_CRM_Stock_Deal__c
						,	EUR_CRM_Mechanic_Name__c
						,	EUR_CRM_No_of_People__c
						,	EUR_CRM_Value__c
						,	EUR_CRM_Contract__c
						,	EUR_CRM_Process_Option_Lump_Sum__c
						,	EUR_CRM_Available_by_the_Glass__c
					FROM Contract_Line_Items__r
					WHERE EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c != NULL
				)
					,	(
					SELECT Id
						,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
						,	EUR_CRM_Mechanic_Type__c
					FROM EUR_CRM_Contract_Activity_Items__r
				)
				FROM EUR_CRM_Contract__c
				WHERE RecordType.DeveloperName = 'EUR_GB_Contract'
					AND Id =: this.contrId
					]);
		}
		return Database.getQueryLocator([
			SELECT Id
			,	RecordType.DeveloperName
			,	EUR_CRM_Contract_Type__c
			,	EUR_CRM_Nominated_Supplier__c
			,	EUR_CRM_Supplier_Account__c
			,	(
				SELECT Id
				,	EUR_CRM_Contract_Mechanic__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.Name
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c
				,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_SkU__c
				,	EUR_CRM_Cocktail_Percent__c
				,	EUR_Min_Qty_Per_Annum_9L__c
				,	EUR_CRM_Retro_Per_9L__c
				,	EUR_CRM_No_of_Cocktails__c
				,	EUR_CRM_Stock_Deal__c
				,	EUR_CRM_Mechanic_Name__c
				,	EUR_CRM_No_of_People__c
				,	EUR_CRM_Value__c
				,	EUR_CRM_Contract__c
				,	EUR_CRM_Process_Option_Lump_Sum__c
				,	EUR_CRM_Available_by_the_Glass__c
				FROM Contract_Line_Items__r
				WHERE EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c != NULL
			)
			,	(
				SELECT Id
				,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				,	EUR_CRM_Mechanic_Type__c
				FROM EUR_CRM_Contract_Activity_Items__r
			)
			FROM EUR_CRM_Contract__c
			WHERE
			RecordType.DeveloperName = 'EUR_GB_Contract'
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Contract__c> contracts) {
		System.debug('\n contracts.size() => ' + contracts.size() + '\n');
		List<EUR_CRM_Contract__c> contractsToUpdate = this.updateContractType(contracts);
		System.debug('\n contractsToUpdate.size() => ' + contractsToUpdate.size() + '\n');
		System.debug('\n contractsToUpdate => ' + JSON.serializePretty(contractsToUpdate) + '\n');
		if ( ! contractsToUpdate.isEmpty()) {
			this.upsertRecords(contractsToUpdate);
		}

		Id caiRTid = caiRtInfo == null ? null : caiRtInfo.getRecordTypeId();
		Id cpiRTid = cpiRtInfo == null ? null : cpiRtInfo.getRecordTypeId();

		System.debug('\n caiRTid => ' + JSON.serializePretty(caiRTid) + '\n');
		System.debug('\n cpiRTid => ' + JSON.serializePretty(cpiRTid) + '\n');
		if (caiRTid == null || cpiRTid == null) { return; }

		Map<String, EUR_CRM_CTM_Contract_setting__mdt> contrSettingByMtExtId = this.getContractSettingByMtExtId();
//		System.debug('\n contrSettingByMtExtId.size() => ' + contrSettingByMtExtId.size() + '\n');
//		System.debug('\n contrSettingByMtExtId => ' + JSON.serializePretty(contrSettingByMtExtId) + '\n');

		Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> cliByMtExtIdByContrIdToCheckCai = this.getCliByMtExtIdByContrIdToCheckCais(contracts);
//		System.debug('\n cliByMtExtIdByContrIdToCheckCai.size() => ' + cliByMtExtIdByContrIdToCheckCai.size() + '\n');
//		System.debug('\n cliByMtExtIdByContrIdToCheckCai => ' + JSON.serializePretty(cliByMtExtIdByContrIdToCheckCai) + '\n');

		Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> cliByMtExtIdByContrIdToCreateCai = this.getCliByMtExtIdByContrIdToCreateCAIs(contracts, cliByMtExtIdByContrIdToCheckCai);
		System.debug('\n cliByMTtoCreateCAIs.size() => ' + cliByMtExtIdByContrIdToCreateCai.size() + '\n');
		System.debug('\n cliByMTtoCreateCAIs => ' + JSON.serializePretty(cliByMtExtIdByContrIdToCreateCai) + '\n');

		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtIdByContrIdToInsertFromCLIs = this.makeCaiByMtExtIdByContrIdToInsert(cliByMtExtIdByContrIdToCreateCai, contrSettingByMtExtId, caiRTid);
		System.debug('\n caiByMtIdByContrIdToInsertFromCLIs.size() => ' + caiByMtIdByContrIdToInsertFromCLIs.size() + '\n');
		System.debug('\n caiByMtIdByContrIdToInsertFromCLIs => ' + JSON.serializePretty(caiByMtIdByContrIdToInsertFromCLIs) + '\n');

		//Start Logic to create all missing CAIs for all Mechanic Types that have not CLIs
		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtExtIdByContrIdToCheckCai = this.getCaiByMtExtIdByContrIdToCheckCais(contracts);
		System.debug('\n caiByMtExtIdByContrIdToCheckCai.size() => ' + cliByMtExtIdByContrIdToCheckCai.size() + '\n');
		System.debug('\n caiByMtExtIdByContrIdToCheckCai => ' + JSON.serializePretty(cliByMtExtIdByContrIdToCheckCai) + '\n');

		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> missedCaiByMtExtIdByContrId = this.makeMissingCai(caiByMtExtIdByContrIdToCheckCai, caiByMtIdByContrIdToInsertFromCLIs, contrSettingByMtExtId, caiRTid);
		System.debug('\n missedCaiByMtExtIdByContrId.size() => ' + missedCaiByMtExtIdByContrId.size() + '\n');
		System.debug('\n missedCaiByMtExtIdByContrId => ' + JSON.serializePretty(missedCaiByMtExtIdByContrId) + '\n');

		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtIdByContrIdToInsertAll = this.putAll(caiByMtIdByContrIdToInsertFromCLIs, missedCaiByMtExtIdByContrId);
		System.debug('\n caiByMtIdByContrIdToInsertAll.size() => ' + caiByMtIdByContrIdToInsertAll.size() + '\n');
		System.debug('\n caiByMtIdByContrIdToInsertAll => ' + JSON.serializePretty(caiByMtIdByContrIdToInsertAll) + '\n');
		//End logic to create all missing CAIs for all Mechanic Types that have not CLIs

		List<EUR_CRM_Contract_Activity_Item__c> caiToInsert = this.getCaisToInsert(caiByMtIdByContrIdToInsertAll);
		System.debug('\n caiToInsert.size() => ' + caiToInsert.size() + '\n');
		System.debug('\n caiToInsert => ' + JSON.serializePretty(caiToInsert) + '\n');
		if ( ! caiToInsert.isEmpty()) {
			this.insertRecords(caiToInsert);
		}

		Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> clisByMtIdByContrId = this.getClisByMtExtIdByContrId(contracts);
		System.debug('\n cliByMtIdByContrId.size() => ' + clisByMtIdByContrId.size() + '\n');
		System.debug('\n cliByMtIdByContrId => ' + JSON.serializePretty(clisByMtIdByContrId) + '\n');

		Map<Id, Map<String, Set<Id>>> bBqBqsSkuIdByMtExtIdByContrId = this.getBBqBqsSkuIdByMtExtIdByContrId(clisByMtIdByContrId.keySet());
//		System.debug('\n bBqBqsSkuIdByMtExtIdByContrId.size() => ' + bBqBqsSkuIdByMtExtIdByContrId.size() + '\n');
//		System.debug('\n bBqBqsSkuIdByMtExtIdByContrId => ' + JSON.serializePretty(bBqBqsSkuIdByMtExtIdByContrId) + '\n');

		Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> clisByMtExtIdByContrIdToCreateCpis = this.getClisByMtExtIdByContrIdToCreateCpis(clisByMtIdByContrId, bBqBqsSkuIdByMtExtIdByContrId);
		System.debug('\n clisByMtExtIdByContrIdToCreateCpis.size() => ' + clisByMtExtIdByContrIdToCreateCpis.size() + '\n');
		System.debug('\n clisByMtExtIdByContrIdToCreateCpis => ' + JSON.serializePretty(clisByMtExtIdByContrIdToCreateCpis) + '\n');

		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = this.makeCPIsToInsert(clisByMtExtIdByContrIdToCreateCpis, cpiRTid, caiByMtIdByContrIdToInsertFromCLIs);
		System.debug('\n cpisToInsert.size() => ' + cpisToInsert.size() + '\n');
		System.debug('\n cpisToInsert => ' + JSON.serializePretty(cpisToInsert) + '\n');
		if ( ! cpisToInsert.isEmpty()) {
			this.insertRecords(cpisToInsert);
		}

		this.finish(bc);
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Contract__c> updateContractType(List<EUR_CRM_Contract__c> contracts) {
		List<EUR_CRM_Contract__c> updatedContracts = new List<EUR_CRM_Contract__c>();
		for (EUR_CRM_Contract__c contract : contracts) {
			if (String.isBlank(contract.EUR_CRM_Contract_Type__c) || contract.EUR_CRM_Nominated_Supplier__c != contract.EUR_CRM_Supplier_Account__c) {
				contract.EUR_CRM_Contract_Type__c = STANDARD_CONTRACT;
				contract.EUR_CRM_Supplier_Account__c = contract.EUR_CRM_Nominated_Supplier__c;
				updatedContracts.add(contract);
			}
		}
		return updatedContracts;
	}

	private Map<String, EUR_CRM_CTM_Contract_setting__mdt> getContractSettingByMtExtId() {
		List<EUR_CRM_CTM_Contract_setting__mdt> settings = selectContractSettings();
		if (settings.isEmpty()) { return new Map<String, EUR_CRM_CTM_Contract_setting__mdt>(); }

		Map<String, EUR_CRM_CTM_Contract_setting__mdt> contrSettingByMtExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();
		for (EUR_CRM_CTM_Contract_setting__mdt setting : settings) {
			contrSettingByMtExtId.put(setting.EUR_CRM_Mechanic_ExtID__c, setting);
		}
		return contrSettingByMtExtId;
	}

	private Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> getCliByMtExtIdByContrIdToCreateCAIs(List<EUR_CRM_Contract__c> contracts, Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> cliByMtExtIdByContrIdToCheckCAIs) {
		for (EUR_CRM_Contract__c contract : contracts) {
			for (EUR_CRM_Contract_Activity_Item__c cai : contract.EUR_CRM_Contract_Activity_Items__r) {
				String caiMtExtId = cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
				if (cliByMtExtIdByContrIdToCheckCAIs.containsKey(contract.Id) && cliByMtExtIdByContrIdToCheckCAIs.get(contract.Id).containsKey(caiMtExtId)) {
					cliByMtExtIdByContrIdToCheckCAIs.get(contract.Id).remove(caiMtExtId);
				}
			}
		}
		return cliByMtExtIdByContrIdToCheckCAIs;
	}

	private Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> getCliByMtExtIdByContrIdToCheckCais(List<EUR_CRM_Contract__c> contracts) {
		Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> cliByMtExtIdByContrIdToCheckCais = new  Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>>();
		for (EUR_CRM_Contract__c contract : contracts) {
			for (EUR_CRM_Contract_Line_Item__c cli : contract.Contract_Line_Items__r) {
				if ( ! this.isMTexist(cli)) { continue; }
				String mtExtId = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
				if (cliByMtExtIdByContrIdToCheckCais.containsKey(contract.Id)) {
					if ( ! this.isFieldBlank(cli.EUR_CRM_Cocktail_Percent__c)) {
						cliByMtExtIdByContrIdToCheckCais.get(contract.Id).put(mtExtId, cli);
					}
					if ( ! cliByMtExtIdByContrIdToCheckCais.get(contract.Id).containsKey(mtExtId)) {
						cliByMtExtIdByContrIdToCheckCais.get(contract.Id).put(mtExtId, cli);
					}
				} else {
					cliByMtExtIdByContrIdToCheckCais.put(contract.Id, new Map<String, EUR_CRM_Contract_Line_Item__c>{ mtExtId => cli });
				}
			}
		}
		return cliByMtExtIdByContrIdToCheckCais;
	}

	private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> getCaiByMtExtIdByContrIdToCheckCais(List<EUR_CRM_Contract__c> contracts) {
		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtExtIdByContrIdToCheckCais = new  Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();
		for (EUR_CRM_Contract__c contract : contracts) {
//			System.debug('\n contract => ' + JSON.serializePretty(contract) + '\n');
			if ( ! caiByMtExtIdByContrIdToCheckCais.containsKey(contract.Id)) {
				caiByMtExtIdByContrIdToCheckCais.put(contract.Id, new Map<String, EUR_CRM_Contract_Activity_Item__c>());
			}
			for (EUR_CRM_Contract_Activity_Item__c cai : contract.EUR_CRM_Contract_Activity_Items__r) {
				if ( ! this.isMTexist(cai)) { continue; }
				String mtExtId = cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
				if (caiByMtExtIdByContrIdToCheckCais.containsKey(contract.Id)) {
					caiByMtExtIdByContrIdToCheckCais.get(contract.Id).put(mtExtId, cai);
				} else {
					caiByMtExtIdByContrIdToCheckCais.put(contract.Id, new Map<String, EUR_CRM_Contract_Activity_Item__c>{ mtExtId => cai});
				}
			}
		}
		return caiByMtExtIdByContrIdToCheckCais;
	}

	private List<EUR_CRM_Contract_Line_Item__c> getCLIsWithContractCocktails(List<EUR_CRM_Contract__c> contracts) {
		List<EUR_CRM_Contract_Line_Item__c> clisToSelectCLIs = new List<EUR_CRM_Contract_Line_Item__c>();
		for (EUR_CRM_Contract__c contract : contracts) {
			for (EUR_CRM_Contract_Line_Item__c cli : contract.Contract_Line_Items__r) {
				if ( ! this.isCLIproductExists(cli)) { continue; }
				clisToSelectCLIs.add(cli);
			}
		}
		return this.selectCLIWhereIds(clisToSelectCLIs);
	}

	private Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> getClisByMtExtIdByContrId(List<EUR_CRM_Contract__c> contracts) {
		List<EUR_CRM_Contract_Line_Item__c> clis = this.getCLIsWithContractCocktails(contracts);
		Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> cliByMtIdByContrId = new Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>>();
		for (EUR_CRM_Contract_Line_Item__c cli : clis) {
			if ( ! this.isMTexist(cli)) { continue; }
			Id contrId = cli.EUR_CRM_Contract__c;
			String mtExtId = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			if (cliByMtIdByContrId.containsKey(contrId)) {
				if (cliByMtIdByContrId.get(contrId).containsKey(mtExtId)) {
					cliByMtIdByContrId.get(contrId).get(mtExtId).add(cli);
				} else {
					cliByMtIdByContrId.get(contrId).put(mtExtId, new List<EUR_CRM_Contract_Line_Item__c>{ cli });
				}
			} else {
				cliByMtIdByContrId.put(
					contrId, new Map<String, List<EUR_CRM_Contract_Line_Item__c>> { mtExtId => new List<EUR_CRM_Contract_Line_Item__c> { cli }}
				);
			}
		}
		return cliByMtIdByContrId;
	}

	private Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> getClisByMtExtIdByContrIdToCreateCpis(Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> clisByMtIdByContrId, Map<Id, Map<String, Set<Id>>> bBqBqsSkuIdByMtExtIdByContrId) {
		Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> clisByMtExtIdByContrIdToCreateCpis = new Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>>();

		for (Id contrId : clisByMtIdByContrId.keySet()) {
			Map<String, List<EUR_CRM_Contract_Line_Item__c>> clisByMtExtId = clisByMtIdByContrId.get(contrId);
			for (String mtExtId : clisByMtExtId.keySet()) {
				for (EUR_CRM_Contract_Line_Item__c cli : clisByMtExtId.get(mtExtId)) {
					if (bBqBqsSkuIdByMtExtIdByContrId.containsKey(contrId) && bBqBqsSkuIdByMtExtIdByContrId.get(contrId).containsKey(mtExtId)) {
						Set<Id> cpiParentIds = bBqBqsSkuIdByMtExtIdByContrId.get(contrId).get(mtExtId);
						Id cliParentProduct = this.getCliParentProduct(cli);
						if (cpiParentIds.contains(cliParentProduct)) { continue; }
						this.populateCliMap(clisByMtExtIdByContrIdToCreateCpis, contrId, mtExtId, cli);
					} else {
						this.populateCliMap(clisByMtExtIdByContrIdToCreateCpis, contrId, mtExtId, cli);
					}
				}
			}
		}
		return clisByMtExtIdByContrIdToCreateCpis;
	}

	private Map<Id, Map<String, Set<Id>>> getBBqBqsSkuIdByMtExtIdByContrId(Set<Id> contractIds) {
		List<EUR_CRM_Contract_Product_Item__c> cpis = this.selectCpisWhereContrIds(contractIds);
		if (cpis.isEmpty()) { return new Map<Id, Map<String, Set<Id>>>(); }
		Map<Id, Map<String, Set<Id>>> bBqBqsSkuIdByMtExtIdByContrId = new Map<Id, Map<String, Set<Id>>>();
		for (EUR_CRM_Contract_Product_Item__c cpi : cpis) {
			Id parentProductId = this.getCpiParentProduct(cpi);
			String mtExtId = cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			Id contrId = cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c;
			if (String.isBlank(mtExtId) || parentProductId == null) { continue; }

			if (bBqBqsSkuIdByMtExtIdByContrId.containsKey(contrId)) {
				if (bBqBqsSkuIdByMtExtIdByContrId.get(contrId).containsKey(mtExtId)) {
					bBqBqsSkuIdByMtExtIdByContrId.get(contrId).get(mtExtId).add(parentProductId);
				} else {
					bBqBqsSkuIdByMtExtIdByContrId.get(contrId)
						.put(mtExtId, new Set<Id>{ parentProductId });
				}
			} else {
				bBqBqsSkuIdByMtExtIdByContrId
					.put(contrId, new Map<String, Set<Id>>{ mtExtId => new Set<Id>{ parentProductId }});
			}
		}
		return bBqBqsSkuIdByMtExtIdByContrId;
	}

	private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> makeCaiByMtExtIdByContrIdToInsert(Map<Id, Map<String, EUR_CRM_Contract_Line_Item__c>> cliByMtExtIdByContrIdToCreateCai, Map<String, EUR_CRM_CTM_Contract_setting__mdt> contrSettingByMtExtId, Id caiRTid) {
		mechTypeByExtId = this.getMechanicTypeByExtId();
		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtExtIdByContrIdToInsert = new Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();
		for (Id contrId : cliByMtExtIdByContrIdToCreateCai.keySet()) {
			Map<String, EUR_CRM_Contract_Line_Item__c> cliByMtExtId = cliByMtExtIdByContrIdToCreateCai.get(contrId);
			for (EUR_CRM_Contract_Line_Item__c cli : cliByMtExtId.values()) {
				EUR_CRM_Mechanic_Type__c lumpSumMt;
				String mtExtId = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
				EUR_CRM_CTM_Contract_setting__mdt contrSetting = contrSettingByMtExtId.get(mtExtId);
				if (this.isNeedToCreateLumpSumMt(cliByMtExtId.get(mtExtId))) {
					lumpSumMt = mechTypeByExtId.containsKey(GB_LUMP_SUM_MT) ? mechTypeByExtId.get(GB_LUMP_SUM_MT) : null;
					mtExtId = mechTypeByExtId.containsKey(GB_LUMP_SUM_MT) ? mechTypeByExtId.get(GB_LUMP_SUM_MT).EUR_CRM_External_ID__c : '';
				}
				EUR_CRM_Contract_Activity_Item__c newCai = this.makeCAI(caiRTid, cli, lumpSumMt, contrSetting);
				if (caiByMtExtIdByContrIdToInsert.containsKey(cli.EUR_CRM_Contract__c)) {
					caiByMtExtIdByContrIdToInsert.get(cli.EUR_CRM_Contract__c).put(mtExtId, newCai);
				} else {
					caiByMtExtIdByContrIdToInsert.put(
						cli.EUR_CRM_Contract__c, new Map<String, EUR_CRM_Contract_Activity_Item__c>{mtExtId => newCai}
					);
				}
			}
		}
		return caiByMtExtIdByContrIdToInsert;
	}

	private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> makeMissingCai(Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtExtIdByContrIdToCheckCai, Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtIdByContrIdToInsert, Map<String, EUR_CRM_CTM_Contract_setting__mdt> contrSettingByMtExtId, Id caiRTid) {
		System.debug('\n mechTypeByExtId.size() => ' + mechTypeByExtId.size() + '\n');
		System.debug('\n mechTypeByExtId => ' + JSON.serializePretty(mechTypeByExtId) + '\n');
		Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> missedCaiByMtExtIdByContrId = new Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();
		for (Id contrId : caiByMtExtIdByContrIdToCheckCai.keySet()) {
			Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtIdToCheck = caiByMtExtIdByContrIdToCheckCai.get(contrId);
			System.debug('\n caiByMtExtIdToCheck.size() => ' + caiByMtExtIdToCheck.size() + '\n');
			System.debug('\n caiByMtExtIdToCheck => ' + JSON.serializePretty(caiByMtExtIdToCheck) + '\n');
			for (String mtExtId : mechTypeByExtId.keySet()) {
				if ( ! caiByMtExtIdToCheck.containsKey(mtExtId)) {
					if (caiByMtIdByContrIdToInsert.containsKey(contrId) && caiByMtIdByContrIdToInsert.get(contrId).containsKey(mtExtId)) { continue; }
					EUR_CRM_CTM_Contract_setting__mdt contrSetting = contrSettingByMtExtId.get(mtExtId);
					if (missedCaiByMtExtIdByContrId.containsKey(contrId)) {
						missedCaiByMtExtIdByContrId.get(contrId).put(mtExtId, this.makeCAI(caiRTid, contrId, contrSetting, mtExtId));
					} else {
						missedCaiByMtExtIdByContrId.put(contrId, new Map<String, EUR_CRM_Contract_Activity_Item__c>{ mtExtId => this.makeCAI(caiRTid, contrId, contrSetting, mtExtId)});
					}
				}
			}
		}
		return missedCaiByMtExtIdByContrId;
	}

	private List<EUR_CRM_Contract_Product_Item__c> makeCPIsToInsert(Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> cliByMtIdByContrIdToCreate, Id cpiRTid, Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtIdByContrId) {
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = new List<EUR_CRM_Contract_Product_Item__c>();
		List<EUR_CRM_Contract_Line_Item__c> allClis = this.getClis(cliByMtIdByContrIdToCreate);
		Map<EUR_CRM_Contract_Line_Item__c, String> ccNamesByCLItoCreateCPIs = this.getContrCocktailNamesByCLI(allClis);
		for (Id contrId : caiByMtIdByContrId.keySet()) {
			if ( ! cliByMtIdByContrIdToCreate.containsKey(contrId)) { continue; }
			Map<String, List<EUR_CRM_Contract_Line_Item__c>> cliByMtExtId = cliByMtIdByContrIdToCreate.get(contrId);
			Map<String, EUR_CRM_Contract_Activity_Item__c> caiByMtExtId = caiByMtIdByContrId.get(contrId);
			for (String mtExtId : caiByMtExtId.keySet()) {
				if (mtExtId == GB_LUMP_SUM_MT) { continue; }
				EUR_CRM_Contract_Activity_Item__c cai = caiByMtExtId.get(mtExtId);
				if ( ! cliByMtExtId.containsKey(mtExtId) || cai.Id == null) { continue; }
				List<EUR_CRM_Contract_Line_Item__c> clis = cliByMtExtId.get(mtExtId);
				for (EUR_CRM_Contract_Line_Item__c cli : clis) {
					if (this.isNeedToCreateLumpSumMt(cli)) { continue; }
					cpisToInsert.add(this.makeCPI(cpiRTid, cai, cli, ccNamesByCLItoCreateCPIs.get(cli)));
				}
			}
		}
		return cpisToInsert;
	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private Map<EUR_CRM_Contract_Line_Item__c, String> getContrCocktailNamesByCLI(List<EUR_CRM_Contract_Line_Item__c> clisWithCCs) {
		Map<EUR_CRM_Contract_Line_Item__c, String> ccNamesByCLI = new Map<EUR_CRM_Contract_Line_Item__c, String>();
		for (EUR_CRM_Contract_Line_Item__c cli : clisWithCCs) {
			Set<String> ccNames = new Set<String>();
			for (EUR_CRM_Contract_Cocktail__c cc : cli.Contract_Cocktails__r) {
				ccNames.add(cc.EUR_CRM_Cocktail_Menu__r.Name);
			}
			String contractCocktailNames = this.getStringFromSet(ccNames);
			ccNamesByCLI.put(cli, contractCocktailNames);
		}
		return ccNamesByCLI;
	}

	private Map<String, EUR_CRM_Mechanic_Type__c> getMechanicTypeByExtId() {
		Map<String, EUR_CRM_Mechanic_Type__c> mechTypeByExtId = new Map<String, EUR_CRM_Mechanic_Type__c>();
		List<EUR_CRM_Mechanic_Type__c> mts = this.selectMTs();
		for (EUR_CRM_Mechanic_Type__c mt : mts) {
			mechTypeByExtId.put(mt.EUR_CRM_External_ID__c, mt);
		}
		return mechTypeByExtId;
	}

	private List<EUR_CRM_Contract_Activity_Item__c> getCaisToInsert(Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> caiByMtIdByContrId) {
		List<EUR_CRM_Contract_Activity_Item__c> caiToInsert = new List<EUR_CRM_Contract_Activity_Item__c>();
		for (Id contrId : caiByMtIdByContrId.keySet()) {
			caiToInsert.addAll(caiByMtIdByContrId.get(contrId).values());
		}

		return caiToInsert;
	}

	private List<EUR_CRM_Contract_Line_Item__c> getClis(Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> cliByMtIdByContrId) {
		List<EUR_CRM_Contract_Line_Item__c> allClis = new List<EUR_CRM_Contract_Line_Item__c>();
		for (Id contrId : cliByMtIdByContrId.keySet()) {
			for (List<EUR_CRM_Contract_Line_Item__c> clis : cliByMtIdByContrId.get(contrId).values()) {
				allClis.addAll(clis);
			}
		}
		return allClis;
	}

	private void populateCliMap(Map<Id, Map<String, List<EUR_CRM_Contract_Line_Item__c>>> clisByMtExtIdByContrIdToCreateCpis, Id contrId, String mtExtId, EUR_CRM_Contract_Line_Item__c cli) {
		if (clisByMtExtIdByContrIdToCreateCpis.containsKey(contrId)) {
			if (clisByMtExtIdByContrIdToCreateCpis.get(contrId).containsKey(mtExtId)) {
				clisByMtExtIdByContrIdToCreateCpis.get(contrId).get(mtExtId).add(cli);
			} else {
				clisByMtExtIdByContrIdToCreateCpis.get(contrId)
					.put(mtExtId, new List<EUR_CRM_Contract_Line_Item__c>{cli});
			}
		} else {
			clisByMtExtIdByContrIdToCreateCpis
				.put(contrId, new Map<String, List<EUR_CRM_Contract_Line_Item__c>>{
				mtExtId => new List<EUR_CRM_Contract_Line_Item__c>{cli}
			});
		}
	}

	private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> putAll(Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> firstMap, Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> secondMap) {
		for (Id contrId : secondMap.keySet()) {
			Map<String, EUR_CRM_Contract_Activity_Item__c> secMapCaiByMtExtId = secondMap.get(contrId);
			for (String mtExtId : secMapCaiByMtExtId.keySet()) {
				if (firstMap.containsKey(contrId)) {
					firstMap.get(contrId).put(mtExtId, secMapCaiByMtExtId.get(mtExtId));
				} else {
					firstMap.put(contrId, new Map<String, EUR_CRM_Contract_Activity_Item__c>{
						mtExtId => secMapCaiByMtExtId.get(mtExtId)
					});
				}
			}
		}
		return firstMap;
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isFieldBlank(Decimal val) {
		return val == null || val == 0;
	}

	private Boolean isMTexist(EUR_CRM_Contract_Line_Item__c cli) {
		return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c != null;
	}

	private Boolean isMTexist(EUR_CRM_Contract_Activity_Item__c cai) {
		return cai.EUR_CRM_Mechanic_Type__c != null;
	}

	private Boolean isCLIproductExists(EUR_CRM_Contract_Line_Item__c cli) {
		return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c != null
			|| cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c != null
			|| cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c != null
			|| cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_SKU__c != null;
	}

	private Boolean isNeedToCreateLumpSumMt(EUR_CRM_Contract_Line_Item__c cli) {
		return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == GB_MARKETING_SUPPORT_MT
			&& cli.EUR_CRM_Process_Option_Lump_Sum__c;
	}

	private String getStringFromSet(Set<String> values) {
		List<String> strings = new List<String>(values);
		return String.join(strings, ';');
	}

	private Id getCpiParentProduct(EUR_CRM_Contract_Product_Item__c cpi) {
		if (cpi.EUR_CRM_Brand__c != null) { return cpi.EUR_CRM_Brand__c; }
		if (cpi.EUR_CRM_Brand_Quality__c != null) { return cpi.EUR_CRM_Brand_Quality__c; }
		if (cpi.EUR_CRM_Brand_Quality_Size__c != null) { return cpi.EUR_CRM_Brand_Quality_Size__c; }
		if (cpi.EUR_CRM_SKU__c != null) { return cpi.EUR_CRM_SKU__c; }
		return null;
	}

	private Id getCliParentProduct(EUR_CRM_Contract_Line_Item__c cli) {
		if (cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c != null) { return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c; }
		if (cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c != null) { return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c; }
		if (cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c != null) { return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c; }
		if (cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_SKU__c != null) { return cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_SKU__c; }
		return null;
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private EUR_CRM_Contract_Activity_Item__c makeCAI(Id rtId, EUR_CRM_Contract_Line_Item__c cli, EUR_CRM_Mechanic_Type__c mt, EUR_CRM_CTM_Contract_setting__mdt contrSetting) {
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Contract__c = cli.EUR_CRM_Contract__c
		,	EUR_CRM_Cocktail_Percent__c = cli.EUR_CRM_Cocktail_Percent__c
		,	EUR_CRM_Item_Type__c = contrSetting == null ? null : contrSetting.EUR_CRM_Setting_Type__c
		,	EUR_CRM_Product_level__c = contrSetting == null ? null : contrSetting.EUR_CRM_Product_level__c
		,	EUR_CRM_Mechanic_Type__c = mt == null ? cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c : mt.Id
		,	EUR_CRM_Amount__c = mt == null ? null : cli.EUR_CRM_Value__c
		);
	}

	private EUR_CRM_Contract_Activity_Item__c makeCAI(Id caiRTid, Id contrId, EUR_CRM_CTM_Contract_setting__mdt contrSetting, String mtExtId) {
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = caiRTid
		,	EUR_CRM_Contract__c = contrId
		,	EUR_CRM_Item_Type__c = contrSetting == null ? null : contrSetting.EUR_CRM_Setting_Type__c
		,	EUR_CRM_Product_level__c = contrSetting == null ? null : contrSetting.EUR_CRM_Product_level__c
		,	EUR_CRM_Mechanic_Type__c = mechTypeByExtId.get(mtExtId).Id
		);
	}

	private EUR_CRM_Contract_Product_Item__c makeCPI(Id cpiRTid, EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Line_Item__c cli, String ccNames) {
		return new EUR_CRM_Contract_Product_Item__c(
			RecordTypeId = cpiRTid
		,	EUR_CRM_Contract_Activity_Item__c = cai.Id
		,	EUR_CRM_Contract_Mechanic__c = cli.EUR_CRM_Contract_Mechanic__c
		,	EUR_CRM_Brand__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c
		,	EUR_CRM_Brand_Quality__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c
		,	EUR_CRM_Brand_Quality_Size__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c
		,	EUR_CRM_SKU__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_SKU__c
		,	EUR_Min_Qty_Per_Annum_9L__c = cli.EUR_Min_Qty_Per_Annum_9L__c
		,	EUR_CRM_Retro_Per_9L__c = cli.EUR_CRM_Retro_Per_9L__c
		,	EUR_CRM_No_of_Cocktails__c = cli.EUR_CRM_No_of_Cocktails__c
		,	EUR_CRM_Stock_Deal_Mechanic__c = cli.EUR_CRM_Stock_Deal__c
		,	EUR_CRM_Mechanic_Name__c = cli.EUR_CRM_Mechanic_Name__c
		,	EUR_CRM_No_of_People__c = cli.EUR_CRM_No_of_People__c
		,	EUR_CRM_Value__c = cli.EUR_CRM_Value__c
		,	EUR_CRM_Cocktail_Menu__c = String.isBlank(ccNames) ? null : ccNames
		,	EUR_CRM_Available_by_the_Glass__c = cli.EUR_CRM_Available_by_the_Glass__c
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_CTM_Contract_setting__mdt> selectContractSettings() {
		return [
			SELECT Id
			,	EUR_CRM_Setting_Type__c
			,	EUR_CRM_Product_level__c
			,	EUR_CRM_Mechanic_ExtID__c
			FROM EUR_CRM_CTM_Contract_setting__mdt
			WHERE EUR_CRM_Country_Code__c = 'GB'
		];
	}

	private List<EUR_CRM_Contract_Line_Item__c> selectCLIWhereIds(List<EUR_CRM_Contract_Line_Item__c> clis) {
		return [
			SELECT Id
			,	EUR_CRM_Contract_Mechanic__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.Name
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Size__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_SkU__c
			,	EUR_CRM_Cocktail_Percent__c
			,	EUR_Min_Qty_Per_Annum_9L__c
			,	EUR_CRM_Retro_Per_9L__c
			,	EUR_CRM_No_of_Cocktails__c
			,	EUR_CRM_Stock_Deal__c
			,	EUR_CRM_Mechanic_Name__c
			,	EUR_CRM_No_of_People__c
			,	EUR_CRM_Value__c
			,	EUR_CRM_Contract__c
			,	EUR_CRM_Process_Option_Lump_Sum__c
			,	EUR_CRM_Available_by_the_Glass__c
			,	(
				SELECT Id
				,	EUR_CRM_Cocktail_Menu__r.Name
				FROM Contract_Cocktails__r
			)
			FROM EUR_CRM_Contract_Line_Item__c
			WHERE Id IN :clis
		];
	}

	private List<EUR_CRM_Mechanic_Type__c> selectMTs() {
		return [
			SELECT Id
			,	EUR_CRM_External_ID__c
			FROM EUR_CRM_Mechanic_Type__c
			WHERE EUR_CRM_Country_Code__c = 'GB'
		];
	}

	private List<EUR_CRM_Contract_Product_Item__c> selectCpisWhereContrIds(Set<Id> contractIds) {
		return [
			SELECT Id
			,	EUR_CRM_Brand__c
			,	EUR_CRM_Brand_Quality__c
			,	EUR_CRM_Brand_Quality_Size__c
			,	EUR_CRM_SKU__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c
			FROM EUR_CRM_Contract_Product_Item__c
			WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c IN :contractIds
		];
	}

}