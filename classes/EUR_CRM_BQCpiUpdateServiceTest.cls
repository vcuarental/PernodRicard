@IsTest(IsParallel = true)
private class EUR_CRM_BQCpiUpdateServiceTest {

	private static final String CPI_GB_RT = 'EUR_GB_Contract_Product_Item';
	private static final String BQ_GB_RT = 'EUR_GB_Quality';
	private static final String BQ_NL_RT = 'EUR_NL_Quality';

	private static final Set<String> BQ_RT_TO_UPDATE_CPI_TOTAL_SPENT_FREE_CASES = new Set<String>{
		'EUR_GB_Quality'
	};

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_BQCpiUpdateService', 'BQ_RT_TO_UPDATE_CPI_TOTAL_SPENT_FREE_CASES', BQ_RT_TO_UPDATE_CPI_TOTAL_SPENT_FREE_CASES));
	}

	@IsTest
	private static void afterUpdate_UpdateBq_UpdateCpiTotalSpend_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Status__c = 'Draft';
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Quality__c bq = makeBQ(b.Id, BQ_GB_RT);
		bq.EUR_CRM_OSG__c = 100;
		insert bq;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM(5, 6);
		sdm.EUR_CRM_Brand_Quality__c = bq.Id;
		insert sdm;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_GB_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Stock_Deal_Mechanic__c = sdm.Id;
		cpi.EUR_CRM_Brand_Quality__c = bq.Id;
		cpi.EUR_Min_Qty_Per_Annum_9L__c = 50;

		insert cpi;
		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPI()[0];
		System.assertEquals(6000, insertedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);

		List<EUR_CRM_Quality__c> bs = selectBs();
		System.assertEquals(1, bs.size());
		System.assertEquals(100, bs[0].EUR_CRM_OSG__c);

		Test.startTest();
		bs[0].EUR_CRM_OSG__c = 200;
		update bs;
		Test.stopTest();

		EUR_CRM_Contract_Product_Item__c updatedCPI = selectCPI()[0];
		System.assertEquals(12000, updatedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);
	}

	@IsTest
	private static void afterUpdate_UpdateBq_NotValidBqRt_NotUpdateCpiTotalSpend_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Status__c = 'Draft';
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Quality__c bq = makeBQ(b.Id, BQ_NL_RT);
		bq.EUR_CRM_OSG__c = 100;
		insert bq;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM(5, 6);
		sdm.EUR_CRM_Brand_Quality__c = bq.Id;
		insert sdm;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_GB_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Stock_Deal_Mechanic__c = sdm.Id;
		cpi.EUR_CRM_Brand_Quality__c = bq.Id;
		cpi.EUR_Min_Qty_Per_Annum_9L__c = 50;

		insert cpi;
		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPI()[0];
		System.assertEquals(6000, insertedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);

		List<EUR_CRM_Quality__c> bs = selectBs();
		System.assertEquals(1, bs.size());
		System.assertEquals(100, bs[0].EUR_CRM_OSG__c);

		Test.startTest();
		bs[0].EUR_CRM_OSG__c = 200;
		update bs;
		Test.stopTest();

		EUR_CRM_Contract_Product_Item__c updatedCPI = selectCPI()[0];
		System.assertEquals(6000, updatedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);
	}

	@IsTest
	private static void afterUpdate_UpdateBq_NotValidContractStatus_NotUpdateCpiTotalSpend_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Status__c = 'Activated';
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Quality__c bq = makeBQ(b.Id, BQ_GB_RT);
		bq.EUR_CRM_OSG__c = 100;
		insert bq;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM(5, 6);
		sdm.EUR_CRM_Brand_Quality__c = bq.Id;
		insert sdm;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_GB_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Stock_Deal_Mechanic__c = sdm.Id;
		cpi.EUR_CRM_Brand_Quality__c = bq.Id;
		cpi.EUR_Min_Qty_Per_Annum_9L__c = 50;

		insert cpi;
		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPI()[0];
		System.assertEquals(null, insertedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);

		List<EUR_CRM_Quality__c> bs = selectBs();
		System.assertEquals(1, bs.size());
		System.assertEquals(100, bs[0].EUR_CRM_OSG__c);

		Test.startTest();
		bs[0].EUR_CRM_OSG__c = 200;
		update bs;
		Test.stopTest();

		EUR_CRM_Contract_Product_Item__c updatedCPI = selectCPI()[0];
		System.assertEquals(null, updatedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '112233'
		);
	}

	private static EUR_CRM_Contract__c makeContract() {
		return new EUR_CRM_Contract__c();
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI() {
		return new EUR_CRM_Contract_Activity_Item__c();
	}

	private static EUR_CRM_Contract_Product_Item__c makeCPI(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Product_Item__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Stock_Deal_Mechanic__c makeSDM(Decimal qtyBuy, Decimal qtyFree) {
		return new EUR_CRM_Stock_Deal_Mechanic__c(
			EUR_CRM_Qty_Buy__c = qtyBuy
			,	EUR_CRM_Qty_Free__c = qtyFree
		);
	}

	private static EUR_CRM_Brand__c makeB() {
		return new EUR_CRM_Brand__c();
	}

	private static EUR_CRM_Quality__c makeBQ(Id bId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Quality__c(
			EUR_CRM_Brand__c = bId
		,	RecordTypeId = rtId
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Product_Item__c> selectCPI() {
		return [
			SELECT Id
				, EUR_CRM_Quantity__c
				, EUR_CRM_Volume_lt__c
				, EUR_CRM_Total_Spent_Free_cases_cur__c
				, EUR_CRM_Total_Spend_inc_free_cases__c
				, EUR_Min_Qty_Per_Annum_9L__c
			FROM EUR_CRM_Contract_Product_Item__c
		];
	}

	private static List<EUR_CRM_Quality__c> selectBs() {
		return [
			SELECT Id
			,	EUR_CRM_OSG__c
			FROM EUR_CRM_Quality__c
		];
	}
}