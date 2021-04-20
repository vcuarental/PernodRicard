@IsTest(IsParallel = true)
private class EUR_CRM_FI_LumpSumBatchTest {
	/*	Cai with filled cai.EUR_CRM_Lumpsum_Value__c field:

		1. Cai has cpi with needed brand name -> no cpi created
		2. Cai has not cpi with needed brand name and Brand EXIST in DB ->
						- create cpi and
						- assign existing corresponding brand from DB
						- fill cpi.EUR_CRM_Marketing_Amount__c from cai.EUR_CRM_Lumpsum_Value__c
		3. Cai has not cpi with needed brand name and Brand DOESN'T EXIST in DB ->
						- no cpi created

		Cai with EMPTY OR ==0 cai.EUR_CRM_Lumpsum_Value__c field:
		4. No cpi created
	*/


	private static final String ACTIVATED_STATUS = 'Activated';
	private static final String FI_MARKETING_ACTIVITY_SPIRITS = EUR_CRM_FI_LumpSumBatch.FI_MARKETING_ACTIVITY_SPIRITS;
	private static final String FI_MARKETING_ACTIVITY_WINES = EUR_CRM_FI_LumpSumBatch.FI_MARKETING_ACTIVITY_WINES;
	private static final String LUMPSUM_SPIRITS = EUR_CRM_FI_LumpSumBatch.LUMPSUM_SPIRITS;
	private static final String LUMPSUM_WINE = EUR_CRM_FI_LumpSumBatch.LUMPSUM_WINE;
	private static final String FI_CAI_RT = 'EUR_FI_Contract_Activity_Item';
	private static final String FI_CPI_RT = 'EUR_FI_Contract_Product_Item';
	private static final String FI_MT_RT = 'EUR_FI_Mechanic_Type';
	private static final String FI_ACC_DIRECT_ON_TRADE = 'EUR_FI_Direct_On_Trade';
	private static final String TEST_NAME = 'Test name';

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
	private static final String FI_INDEPENDENT_CONTRACT_RT = 'EUR_FI_Independent_Contract';
	private static final Integer CPI_MARKETING_AMOUNT_VALUE = 10;


	/* ========================================================= */
	/*      Marketing Activity Spirits Mt
	/* ========================================================= */
	@IsTest
	private static void spirits_caiHasCpiWithNeededNameAndAmount_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_SPIRITS;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = LUMPSUM_SPIRITS;
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		cpi.EUR_CRM_Marketing_Amount__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		System.assertEquals(1, selectCPIs().size());
	}

	@IsTest
	private static void spirits_caiHasCpiWithNeededNameAmountNotEquals_CpiUpdated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_SPIRITS;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = LUMPSUM_SPIRITS;
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		cpi.EUR_CRM_Marketing_Amount__c = 333;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		System.assertEquals(1, selectCPIs().size());

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			System.assertEquals(LUMPSUM_SPIRITS, cp.EUR_CRM_Brand__r.Name);
			System.assertEquals(cai.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
		}
	}

	@IsTest
	private static void spirits_caiHasNoCpiWithNeededName_NoMockedBrandExist_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_SPIRITS;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(1, cpis.size());
	}

	@IsTest
	private static void spirits_caiHasNoCpiWithNeededName_MockedBrandExist_CpiCreated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_SPIRITS;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedBrand = makeB();
		mockedBrand.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedBrand };

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(2, cpis.size());
		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
				System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
			} else {
				System.assertEquals(LUMPSUM_SPIRITS, cp.EUR_CRM_Brand__r.Name);
				System.assertEquals(cai.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
			}
		}
	}

	@IsTest
	private static void spirits_caiHasNoCpiWithNeededName_caiLumpsumValueIsZero_MockedBrandExist_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_SPIRITS;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = 0;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedBrand = makeB();
		mockedBrand.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedBrand };

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		System.assertEquals(1, selectCPIs().size());
	}

	@IsTest
	private static void spirits_caiHasNoCpiWithNeededName_MockedBrandWithWrongNameExist_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_SPIRITS;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedBrand = makeB();
		mockedBrand.Name = LUMPSUM_WINE;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedBrand };

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(1, cpis.size());
	}


	/* ========================================================= */
	/*      Marketing Activity Wines Mt
	/* ========================================================= */
	@IsTest
	private static void wines_caiHasCpiWithNeededNameAndAmount_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_WINES;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = LUMPSUM_WINE;
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		cpi.EUR_CRM_Marketing_Amount__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		System.assertEquals(1, selectCPIs().size());

	}

	@IsTest
	private static void wines_caiHasNoCpiWithNeededName_NoMockedBrandExist_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_WINES;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(1, cpis.size());
	}

	@IsTest
	private static void wines_caiHasNoCpiWithNeededName_MockedBrandExist_CpiCreated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_WINES;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedBrand = makeB();
		mockedBrand.Name = LUMPSUM_WINE;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedBrand };

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(2, cpis.size());
		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
				System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
			} else {
				System.assertEquals(LUMPSUM_WINE, cp.EUR_CRM_Brand__r.Name);
				System.assertEquals(cai.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
			}

		}
	}

	@IsTest
	private static void wine_caiHasNoCpiWithNeededName_caiLumpsumValueIsZero_MockedBrandExist_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_WINES;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = 0;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedBrand = makeB();
		mockedBrand.Name = LUMPSUM_WINE;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedBrand };

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		System.assertEquals(1, selectCPIs().size());
	}

	@IsTest
	private static void wines_caiHasCpiWithNeededNameAmountNotEquals_CpiUpdated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_WINES;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = LUMPSUM_WINE;
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		cpi.EUR_CRM_Marketing_Amount__c = 333;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		System.assertEquals(1, selectCPIs().size());

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			System.assertEquals(LUMPSUM_WINE, cp.EUR_CRM_Brand__r.Name);
			System.assertEquals(cai.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
		}
	}

	@IsTest
	private static void wines_caiHasNoCpiWithNeededName_MockedBrandWithWrongNameExist_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT(FI_MT_RT);
		mt.EUR_CRM_External_ID__c = FI_MARKETING_ACTIVITY_WINES;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contract.Id, mt.Id);
		cai.EUR_CRM_Lumpsum_Value__c = CPI_MARKETING_AMOUNT_VALUE;
		insert cai;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedBrand = makeB();
		mockedBrand.Name = 'Some brand';
		insert new List<EUR_CRM_Brand__c>{ brand, mockedBrand };

		EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
		cpi.EUR_CRM_Brand__c = brand.Id;
		insert cpi;

		System.assertEquals(1, selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(1, cpis.size());
	}


	/* ========================================================= */
	/*      Massive test
	/* ========================================================= */
	@IsTest
	private static void massive_caiHasNoCpiWithNeededName_MockedBrandsExist_CpiCreated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contr1 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr2 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr3 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr4 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr5 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>{contr1, contr2, contr3, contr4, contr5};
		insert contracts;

		List<EUR_CRM_Mechanic_Type__c> mts = makeMTs(FI_MT_EXT_IDS, FI_MT_RT);
		insert mts;

		List<EUR_CRM_Contract_Activity_Item__c> cais = makeCais(contracts, mts, CPI_MARKETING_AMOUNT_VALUE);
		insert cais;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedWine = makeB();
		mockedWine.Name = LUMPSUM_WINE;
		EUR_CRM_Brand__c mockedSpirits = makeB();
		mockedSpirits.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedWine, mockedSpirits };

		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = makeCpis(cais, brand);
		insert cpisToInsert;

		System.assertEquals(5, contracts.size());
		System.assertEquals(45, cais.size());
		System.assertEquals(cais.size(), selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(cais.size() + (contracts.size() * 2), cpis.size());

		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			String mtExtId = cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			if (mtExtId == FI_MARKETING_ACTIVITY_WINES) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_WINE, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
			if (mtExtId == FI_MARKETING_ACTIVITY_SPIRITS) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_SPIRITS, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
		}
	}

	@IsTest
	private static void massive_caiHasCpiWithNeededName_MockedBrandsExistAmountEquals_NoCpiCreated_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contr1 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr2 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr3 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr4 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr5 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>{contr1, contr2, contr3, contr4, contr5};
		insert contracts;

		List<EUR_CRM_Mechanic_Type__c> mts = makeMTs(FI_MT_EXT_IDS, FI_MT_RT);
		insert mts;

		List<EUR_CRM_Contract_Activity_Item__c> cais = makeCais(contracts, mts, CPI_MARKETING_AMOUNT_VALUE);
		insert cais;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedWine = makeB();
		mockedWine.Name = LUMPSUM_WINE;
		EUR_CRM_Brand__c mockedSpirits = makeB();
		mockedSpirits.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedWine, mockedSpirits };

		List<EUR_CRM_Contract_Activity_Item__c> insertedCais = selectCais();
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = makeCpis(insertedCais, brand, mockedSpirits, mockedWine, CPI_MARKETING_AMOUNT_VALUE);
		insert cpisToInsert;

		System.assertEquals(5, contracts.size());
		System.assertEquals(45, insertedCais.size());
		System.assertEquals(insertedCais.size(), selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(insertedCais.size(), cpis.size());

		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			String mtExtId = cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			if (mtExtId == FI_MARKETING_ACTIVITY_WINES) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_WINE, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
			if (mtExtId == FI_MARKETING_ACTIVITY_SPIRITS) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_SPIRITS, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
		}
	}

	@IsTest
	private static void massive_caiHasCpiWithNeededName_MockedBrandsExistAmountNotEquals_CpiUpdated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contr1 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr2 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr3 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr4 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr5 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>{contr1, contr2, contr3, contr4, contr5};
		insert contracts;

		List<EUR_CRM_Mechanic_Type__c> mts = makeMTs(FI_MT_EXT_IDS, FI_MT_RT);
		insert mts;

		List<EUR_CRM_Contract_Activity_Item__c> cais = makeCais(contracts, mts, CPI_MARKETING_AMOUNT_VALUE);
		insert cais;
		System.debug('\n cais.size() => ' + cais.size() + '\n');
		System.debug('\n cais => ' + JSON.serializePretty(cais) + '\n');

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedWine = makeB();
		mockedWine.Name = LUMPSUM_WINE;
		EUR_CRM_Brand__c mockedSpirits = makeB();
		mockedSpirits.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedWine, mockedSpirits };

		List<EUR_CRM_Contract_Activity_Item__c> insertedCais = selectCais();
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = makeCpis(insertedCais, brand, mockedSpirits, mockedWine, 333);
		insert cpisToInsert;

		System.assertEquals(5, contracts.size());
		System.assertEquals(45, insertedCais.size());
		System.assertEquals(insertedCais.size(), selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(insertedCais.size(), cpis.size());

		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			String mtExtId = cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			if (mtExtId == FI_MARKETING_ACTIVITY_WINES) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_WINE, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
			if (mtExtId == FI_MARKETING_ACTIVITY_SPIRITS) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_SPIRITS, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
		}
	}

	@IsTest
	private static void massive_caiHasCpiWithNeededName_MockedBrandsExistAmountNotEquals_CaiLumpsumIsZero_CpiUpdated_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contr1 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr2 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr3 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr4 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr5 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>{contr1, contr2, contr3, contr4, contr5};
		insert contracts;

		List<EUR_CRM_Mechanic_Type__c> mts = makeMTs(FI_MT_EXT_IDS, FI_MT_RT);
		insert mts;

		List<EUR_CRM_Contract_Activity_Item__c> cais = makeCais(contracts, mts, null);
		insert cais;
		System.debug('\n cais.size() => ' + cais.size() + '\n');
		System.debug('\n cais => ' + JSON.serializePretty(cais) + '\n');

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedWine = makeB();
		mockedWine.Name = LUMPSUM_WINE;
		EUR_CRM_Brand__c mockedSpirits = makeB();
		mockedSpirits.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedWine, mockedSpirits };

		List<EUR_CRM_Contract_Activity_Item__c> insertedCais = selectCais();
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = makeCpis(insertedCais, brand, mockedSpirits, mockedWine, 333);
		insert cpisToInsert;

		System.assertEquals(5, contracts.size());
		System.assertEquals(45, insertedCais.size());
		System.assertEquals(insertedCais.size(), selectCPIs().size());

		Test.startTest();
		Database.executeBatch(new EUR_CRM_FI_LumpSumBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Product_Item__c> cpis = selectCPIs();
		System.assertEquals(insertedCais.size(), cpis.size());

		for (EUR_CRM_Contract_Product_Item__c cp : cpis) {
			String mtExtId = cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c;
			if (mtExtId == FI_MARKETING_ACTIVITY_WINES) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_WINE, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(null, cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c);
					System.assertEquals(333, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
			if (mtExtId == FI_MARKETING_ACTIVITY_SPIRITS) {
				if (cp.EUR_CRM_Brand__r.Name == TEST_NAME) {
					System.assertEquals(null, cp.EUR_CRM_Marketing_Amount__c);
				} else {
					System.assertEquals(LUMPSUM_SPIRITS, cp.EUR_CRM_Brand__r.Name);
					System.assertEquals(null, cp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c);
					System.assertEquals(333, cp.EUR_CRM_Marketing_Amount__c);
				}
			}
		}
	}

	@IsTest
	private static void massive_clearCaisLumpsumValue_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount(FI_ACC_DIRECT_ON_TRADE);
		insert acc;

		EUR_CRM_Contract__c contr1 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr2 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr3 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr4 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		EUR_CRM_Contract__c contr5 = makeContract(acc.Id, FI_INDEPENDENT_CONTRACT_RT, ACTIVATED_STATUS);
		List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>{contr1, contr2, contr3, contr4, contr5};
		insert contracts;

		List<EUR_CRM_Mechanic_Type__c> mts = makeMTs(FI_MT_EXT_IDS, FI_MT_RT);
		insert mts;

		List<EUR_CRM_Contract_Activity_Item__c> cais = makeCais(contracts, mts, CPI_MARKETING_AMOUNT_VALUE);
		insert cais;

		EUR_CRM_Brand__c brand = makeB();
		brand.Name = TEST_NAME;
		EUR_CRM_Brand__c mockedWine = makeB();
		mockedWine.Name = LUMPSUM_WINE;
		EUR_CRM_Brand__c mockedSpirits = makeB();
		mockedSpirits.Name = LUMPSUM_SPIRITS;
		insert new List<EUR_CRM_Brand__c>{ brand, mockedWine, mockedSpirits };

		List<EUR_CRM_Contract_Activity_Item__c> insertedCais = selectCais();
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = makeCpis(insertedCais, brand, mockedSpirits, mockedWine, CPI_MARKETING_AMOUNT_VALUE);
		insert cpisToInsert;

		System.assertEquals(5, contracts.size());
		System.assertEquals(45, insertedCais.size());
		System.assertEquals(insertedCais.size(), selectCPIs().size());
		for (EUR_CRM_Contract_Activity_Item__c cai : insertedCais) {
			System.assertEquals(CPI_MARKETING_AMOUNT_VALUE, cai.EUR_CRM_Lumpsum_Value__c);
		}

		Test.startTest();
		new EUR_CRM_FI_LumpSumBatch().clearCaisLumpsumValue();
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> caisAfterClear = selectCais();
		for (EUR_CRM_Contract_Activity_Item__c cai : caisAfterClear) {
			if (EUR_CRM_FI_LumpSumBatch.CPI_BRAND_NAME_BY_MT_EXT_ID_TO_UPDATE_CAIS.containsKey(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c)) {
				System.assertEquals(null, cai.EUR_CRM_Lumpsum_Value__c);
			}
		}

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

	private static EUR_CRM_Mechanic_Type__c makeMT(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Mechanic_Type__c makeMT(Id rtId) {
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
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

	private static List<EUR_CRM_Contract_Product_Item__c> makeCpis(List<EUR_CRM_Contract_Activity_Item__c> cais, EUR_CRM_Brand__c brand) {
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = new List<EUR_CRM_Contract_Product_Item__c>();
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
			cpi.EUR_CRM_Brand__c = brand.Id;
			cpisToInsert.add(cpi);
		}
		return cpisToInsert;
	}

	private static List<EUR_CRM_Contract_Product_Item__c> makeCpis(List<EUR_CRM_Contract_Activity_Item__c> cais, EUR_CRM_Brand__c brand, EUR_CRM_Brand__c spiritBrand, EUR_CRM_Brand__c wineBrand, Decimal amountValue) {
		List<EUR_CRM_Contract_Product_Item__c> cpisToInsert = new List<EUR_CRM_Contract_Product_Item__c>();
		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
			EUR_CRM_Contract_Product_Item__c cpi = makeCPI(cai.Id, FI_CPI_RT);
			if (cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == FI_MARKETING_ACTIVITY_SPIRITS) {
				cpi.EUR_CRM_Brand__c = spiritBrand.Id;
				cpi.EUR_CRM_Marketing_Amount__c = amountValue;
			} else if (cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c == FI_MARKETING_ACTIVITY_WINES) {
				cpi.EUR_CRM_Brand__c = wineBrand.Id;
				cpi.EUR_CRM_Marketing_Amount__c = amountValue;
			}
			else {
				cpi.EUR_CRM_Brand__c = brand.Id;
			}
			cpisToInsert.add(cpi);
		}
		return cpisToInsert;
	}

	private static List<EUR_CRM_Contract_Activity_Item__c> makeCais(List<EUR_CRM_Contract__c> contracts, List<EUR_CRM_Mechanic_Type__c> mts, Decimal lumpsumVal) {
		List<EUR_CRM_Contract_Activity_Item__c> cais = new List<EUR_CRM_Contract_Activity_Item__c>();
		for (EUR_CRM_Contract__c contr : contracts) {
			for (EUR_CRM_Mechanic_Type__c mt : mts) {
				EUR_CRM_Contract_Activity_Item__c cai = makeCAI(FI_CAI_RT, contr.Id, mt.Id);
				cai.EUR_CRM_Lumpsum_Value__c = lumpsumVal;
				cais.add(cai);
			}
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


	private static EUR_CRM_Contract_Product_Item__c makeCPI(Id caiId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Product_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Contract_Activity_Item__c = caiId
		);
	}

	private static EUR_CRM_Brand__c makeB() {
		return new EUR_CRM_Brand__c();
	}

	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Activity_Item__c> selectCais() {
		return [
			SELECT Id
			,	EUR_CRM_Lumpsum_Value__c
			,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	(
			SELECT Id
				,	EUR_CRM_Brand__r.Name
			FROM Contract_Product_Items__r
		)
		FROM EUR_CRM_Contract_Activity_Item__c
		];
	}

	private static List<EUR_CRM_Contract_Product_Item__c> selectCPIs() {
		return [
			SELECT EUR_CRM_Marketing_Amount__c
				,   RecordType.DeveloperName
				,	EUR_CRM_Brand__r.Name
				,	EUR_CRM_Brand__c
				,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				,	EUR_CRM_Contract_Activity_Item__c
				,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Lumpsum_Value__c
			FROM EUR_CRM_Contract_Product_Item__c
		];
	}
}