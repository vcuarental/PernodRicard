@IsTest(IsParallel=true)
private class EUR_CRM_CPIbeforeInsertServiceTest {

	private static final String CPI_DE_RT = 'EUR_DE_Contract_Product_Item';
	private static final String CPI_NL_RT = 'EUR_NL_Contract_Product_Item';
	private static final String CPI_GB_RT = 'EUR_GB_Contract_Product_Item';
	private static final Integer COUNT_OF_RECORDS = 5;

	private static final Set<String> CPI_RT_TO_UPDATE_QUANTITY = new Set<String> {
		'EUR_DE_Contract_Product_Item'
	};

	private static final Set<String> CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES = new Set<String> {
		'EUR_GB_Contract_Product_Item'
	};

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_CPIbeforeInsertService', 'CPI_RT_TO_UPDATE_QUANTITY', CPI_RT_TO_UPDATE_QUANTITY));
		EUR_CRM_RecordTypeHelper_v2.rtListsForTest.add(EUR_CRM_RecordTypeHelper_v2.makeRtListForTest('EUR_CRM_CPIbeforeInsertService', 'CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES', CPI_RT_TO_UPDATE_TOTAL_SPENT_FREE_CASES));
	}

	@IsTest
	static void beforeInsert_updateQuantity_Test() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_DE_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Quantity__c = 0;
		cpi.EUR_CRM_Volume_lt__c = 666;

		Test.startTest();
		insert cpi;

		List<EUR_CRM_Contract_Product_Item__c> insertedCPIs = selectCPI();
		System.assertEquals(666, insertedCPIs[0].EUR_CRM_Quantity__c);
		Test.stopTest();
	}

	@IsTest
	static void beforeUpdate_updateQuantity_Test() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_DE_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Quantity__c = 0;
		cpi.EUR_CRM_Volume_lt__c = 666;

		Test.startTest();
		insert cpi;

		cpi.EUR_CRM_Quantity__c = 333;
		update cpi;

		List<EUR_CRM_Contract_Product_Item__c> insertedCPIs = selectCPI();
		System.assertEquals(1, insertedCPIs.size());
		Test.stopTest();
	}

	@IsTest
	static void beforeInsert_Negative_QuantityNotBlank_Test() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_DE_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Quantity__c = 3;
		cpi.EUR_CRM_Volume_lt__c = 666;

		Test.startTest();
		insert cpi;

		List<EUR_CRM_Contract_Product_Item__c> insertedCPIs = selectCPI();
		System.assertEquals(3, insertedCPIs[0].EUR_CRM_Quantity__c);
		Test.stopTest();
	}

	@IsTest
	static void beforeInsert_Negative_InvalidRecordType_Test() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_NL_RT);
		cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
		cpi.EUR_CRM_Quantity__c = 3;
		cpi.EUR_CRM_Volume_lt__c = 666;

		Test.startTest();
		insert cpi;

		List<EUR_CRM_Contract_Product_Item__c> insertedCPIs = selectCPI();
		System.assertEquals(3, insertedCPIs[0].EUR_CRM_Quantity__c);
		Test.stopTest();
	}

	@IsTest
	static void beforeInsert_MassUpdate_Quantity_Positive_Test() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract();
		contract.EUR_CRM_Account__c = acc.Id;
		insert contract;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI();
		cai.EUR_CRM_Contract__c = contract.Id;
		insert cai;

		List<EUR_CRM_Contract_Product_Item__c> cpis = makeCPIs(cai);

		Test.startTest();
		insert cpis;

		List<EUR_CRM_Contract_Product_Item__c> insertedCPIs = selectCPI();
		for (EUR_CRM_Contract_Product_Item__c cpi : insertedCPIs) {
			System.assertEquals(666, cpi.EUR_CRM_Quantity__c);
		}
		Test.stopTest();
	}

	@IsTest
	private static void afterInsert_UpdateTotalSpend_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
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

		EUR_CRM_Quality__c bq = makeBQ(b.Id);
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

		Test.startTest();
		insert cpi;
		Test.stopTest();

		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPI()[0];
		System.assertEquals(insertedCPI.EUR_CRM_Total_Spend_inc_free_cases__c, insertedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);
	}

	@IsTest
	private static void afterInsert_UpdateTotalSpend_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
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

		EUR_CRM_Quality__c bq = makeBQ(b.Id);
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

		Test.startTest();
		insert cpi;
		Test.stopTest();

		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPI()[0];
		System.assertEquals(null, insertedCPI.EUR_CRM_Total_Spent_Free_cases_cur__c);
	}

	@IsTest
	private static void beforeUpdate_UpdateTotalSpend_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount();
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

		EUR_CRM_Quality__c bq = makeBQ(b.Id);
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

		Test.startTest();
		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPI()[0];
		insertedCPI.EUR_Min_Qty_Per_Annum_9L__c = 60;
		update insertedCPI;
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> updatedCPIs = selectCPI();
		System.debug('\n updatedCPIs.size() => ' + updatedCPIs.size() + '\n');
		System.debug('\n updatedCPIs => ' + JSON.serializePretty(updatedCPIs) + '\n');
		System.assertEquals(1, updatedCPIs.size());
		System.assertEquals(updatedCPIs[0].EUR_CRM_Total_Spend_inc_free_cases__c, updatedCPIs[0].EUR_CRM_Total_Spent_Free_cases_cur__c);
	}


	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount() {
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

	private static EUR_CRM_Quality__c makeBQ(Id bId) {
		return new EUR_CRM_Quality__c(
			EUR_CRM_Brand__c = bId
		);
	}

	private static List<EUR_CRM_Contract_Product_Item__c> makeCPIs(EUR_CRM_Contract_Activity_Item__c cai) {
		List<EUR_CRM_Contract_Product_Item__c> cpis = new List<EUR_CRM_Contract_Product_Item__c>();
		for (Integer i; i < COUNT_OF_RECORDS; i++) {
			EUR_CRM_Contract_Product_Item__c cpi = makeCPI(CPI_NL_RT);
			cpi.EUR_CRM_Contract_Activity_Item__c = cai.Id;
			cpi.EUR_CRM_Quantity__c = null;
			cpi.EUR_CRM_Volume_lt__c = 666;
			cpis.add(cpi);
		}
		return cpis;
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
}