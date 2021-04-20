@IsTest
private class EUR_CRM_FI_ContractCaiUpdateBatchTest {

	/*
	Cases:
	- FI Contract and Draft Status
	1. 9 MTs and NO Cais -> 9 Cai create
	2. 9 MTs and all Cais -> no Cai create
	3. 9 MTs and 1 Cai -> 8 Cai create

	4. Contract Status != 'Draft' -> no Cai create
	*/

	private static final Set<String> FI_MT_EXT_IDS = new Set<String>{
		'EUR_FI_Mktg_Activity_Wines'
	,	'EUR_FI_Education'
	,	'EUR_FI_Free_Stock'
	,	'EUR_FI_Pouring_Refund_Wines'
	,	'EUR_FI_Selection_Brands_Wines'
	,	'EUR_FI_Mktg_Activity_Spirits'
	,	'EUR_FI_Selection_Brands_Spirits'
	,	'EUR_FI_Trips'
	,	'EUR_FI_Pouring_Refund_Spirits'
	};

	private static final String ACTIVATED_STATUS = 'Activated';
	private static final String DRAFT_STATUS = 'Draft';
	private static final String FI_MARKETING_ACTIVITY_SPIRITS = 'EUR_FI_Mktg_Activity_Spirits';
	private static final String FI_MARKETING_ACTIVITY_WINES = 'EUR_FI_Mktg_Activity_Wines';
	private static final String FI_CAI_RT = 'EUR_FI_Contract_Activity_Item';
	private static final String FI_MT_RT = 'EUR_FI_Mechanic_Type';
	private static final String FI_INDEPENDENT_CONTRACT_RT = 'EUR_FI_Independent_Contract';
	private static final String FI_ACC_DIRECT_ON_TRADE = 'EUR_FI_Direct_On_Trade';

	@IsTest
	private static void contractValid_NoCaiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, DRAFT_STATUS);
		insert contract;

		Map<String, EUR_CRM_Mechanic_Type__c> mtByExtId = getMtByExtId(makeMTs(FI_MT_EXT_IDS, FI_MT_RT));
		insert mtByExtId.values();

		List<EUR_CRM_Contract_Activity_Item__c> cais = makeCAIs(FI_CAI_RT, contract.Id, mtByExtId.values());
		insert cais;

		System.assertEquals(mtByExtId.size(), selectCais().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_ContractCaiUpdateBatch());
		Test.stopTest();

		System.assertEquals(9, mtByExtId.size());
		System.assertEquals(mtByExtId.size(), selectCais().size());
	}

	@IsTest
	private static void contractValid_SomeCaiCreated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, DRAFT_STATUS);
		insert contract;

		Map<String, EUR_CRM_Mechanic_Type__c> mtByExtId = getMtByExtId(makeMTs(FI_MT_EXT_IDS, FI_MT_RT));
		insert mtByExtId.values();

		List<EUR_CRM_Contract_Activity_Item__c> cais = new List<EUR_CRM_Contract_Activity_Item__c>();
		cais.add(makeCAI(FI_CAI_RT, contract.Id, mtByExtId.get(FI_MARKETING_ACTIVITY_WINES).Id));
		cais.add(makeCAI(FI_CAI_RT, contract.Id, mtByExtId.get(FI_MARKETING_ACTIVITY_SPIRITS).Id));
		insert cais;

		System.assertEquals(2, selectCais().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_ContractCaiUpdateBatch());
		Test.stopTest();

		System.assertEquals(9, mtByExtId.size());
		System.assertEquals(mtByExtId.size(), selectCais().size());
	}

	@IsTest
	private static void contractValid_AllCaiCreated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, DRAFT_STATUS);
		insert contract;

		Map<String, EUR_CRM_Mechanic_Type__c> mtByExtId = getMtByExtId(makeMTs(FI_MT_EXT_IDS, FI_MT_RT));
		insert mtByExtId.values();

		System.assertEquals(0, selectCais().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_ContractCaiUpdateBatch());
		Test.stopTest();

		System.assertEquals(9, mtByExtId.size());
		System.assertEquals(mtByExtId.size(), selectCais().size());
	}

	@IsTest
	private static void contractStatusNotValid_NoCaiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		Map<String, EUR_CRM_Mechanic_Type__c> mtByExtId = getMtByExtId(makeMTs(FI_MT_EXT_IDS, FI_MT_RT));
		insert mtByExtId.values();

		System.assertEquals(0, selectCais().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_ContractCaiUpdateBatch());
		Test.stopTest();

		System.assertEquals(9, mtByExtId.size());
		System.assertEquals(0, selectCais().size());
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private static Map<String, EUR_CRM_Mechanic_Type__c> getMtByExtId(List<EUR_CRM_Mechanic_Type__c> mts) {
		Map<String, EUR_CRM_Mechanic_Type__c> mtByExtId = new Map<String, EUR_CRM_Mechanic_Type__c>();
		for (EUR_CRM_Mechanic_Type__c mt : mts) {
			mtByExtId.put(mt.EUR_CRM_External_ID__c, mt);
		}
		return mtByExtId;
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			RecordTypeId = rtId
		,	EUR_CRM_Postal_Code__c = '112233'
		);
	}

	private static EUR_CRM_Contract__c makeContract(Id accId, String rt, String status) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract__c(
			RecordTypeId = rtId
		,	EUR_CRM_Account__c = accId
		,	EUR_CRM_Status__c = status
		);
	}

	private static List<EUR_CRM_Mechanic_Type__c> makeMTs(Set<String> mtExtIds, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		List<EUR_CRM_Mechanic_Type__c> mts = new List<EUR_CRM_Mechanic_Type__c>();
		for (String mtExtId : mtExtIds) {
			EUR_CRM_Mechanic_Type__c mt = makeMT(rtId);
			mt.EUR_CRM_External_ID__c = mtExtId;
			mts.add(mt);
		}
		return mts;
	}

	private static EUR_CRM_Mechanic_Type__c makeMT(Id rtId) {
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Stock_Deal_Mechanic__c makeSDM() {
		return new EUR_CRM_Stock_Deal_Mechanic__c(
			EUR_CRM_Litres_per_Case__c = 10
			,	EUR_CRM_Bottles_per_Case_BQ__c = 20
			,	EUR_CRM_Liquid_per_Bottle_litre__c = 30
			,	EUR_CRM_Qty_Buy__c = 40
			,	EUR_CRM_Qty_Free__c = 50
			,	EUR_CRM_RTM_Price__c = 60
		);
	}

	private static List<EUR_CRM_Contract_Activity_Item__c> makeCAIs(String rt, Id contrId, List<EUR_CRM_Mechanic_Type__c> mts) {
		List<EUR_CRM_Contract_Activity_Item__c> cais = new List<EUR_CRM_Contract_Activity_Item__c>();
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		for (EUR_CRM_Mechanic_Type__c mt : mts) {
			cais.add(makeCAI(rtId, contrId, mt.Id));
		}
		return cais;
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI(String rt, Id contrId, Id mtId) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Contract__c = contrId
		,	EUR_CRM_Mechanic_Type__c = mtId
		);
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id rtId, Id contrId, Id mtId) {
		return new EUR_CRM_Contract_Activity_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Contract__c = contrId
		,	EUR_CRM_Mechanic_Type__c = mtId
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Activity_Item__c> selectCais() {
		return [
			SELECT Id
			,	EUR_CRM_Mechanic_Type__c
			FROM EUR_CRM_Contract_Activity_Item__c
		];
	}
}