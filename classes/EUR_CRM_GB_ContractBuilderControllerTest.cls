@IsTest(IsParallel = true)
private class EUR_CRM_GB_ContractBuilderControllerTest {
	private static final Map<String, String> DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID = new Map<String, String> {
		'GB_Must_Stock_Item' => 'GB_Cocktail'
	};

	private static final Map<String, String> DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID = new Map<String, String>{
		'GB_Must_Stock_Item' => 'GB_May_Stock_Item'
	,	'GB_May_Stock_Item' => 'GB_Must_Stock_Item'
	};

//	private static final Set<String> EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST = new Set<String>{
//		'GB_House_Pouring_Champagne'
//	,	'GB_House_Pouring_Spirits'
//	};
//
//	private static final Set<String> EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST = new Set<String>{
//		'GB_Educations'
//	,	'GB_Trips'
//	};

	private static final Map<String, String> MT_NAME_BY_MT_EXT_ID = new Map<String, String>{
		'GB_House_Pouring_Champagne'	=>		'House Pouring Champagne'
	,	'GB_Cocktail'			        =>	    'Cocktail'
	,	'GB_Bar_support'			    =>	    'Bar support'
	,	'GB_Educations'			        =>	    'Educations'
	,	'GB_Free_Stock'			        =>	    'Free Stock'
	,	'GB_House_Pouring_Spirits'		=>		'House Pouring Spirits'
	,	'GB_Lump_Sum'			        =>	    'Lump Sum'
	,	'GB_Marketing_Support'			=>	    'Marketing Support'
	,	'GB_May_Stock_Item'			    =>	    'May Stock Item'
	,	'GB_Must_Stock_Item'			=>	    'Must Stock Item'
	,	'GB_Point_of_Sales'			    =>	    'Point of Sales'
	,	'GB_Premium_Pouring_Spirits'	=>		'Premium Pouring Spirits'
	,	'GB_Trips'			            =>	    'Trips'
	};

	private static final String CLASS_NAME = 'EUR_CRM_GB_ContractBuilderController';

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(CLASS_NAME, 'DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID', DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID));
		EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest(CLASS_NAME, 'DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID', DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_LIST_BY_CONTROLLED_MT_EXT_ID));
	}

	@IsTest
	private static void getBQsByMtExtId_OneMt_Test() {
		initCMT();
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_GB_Mechanic_Type', 'Cocktail');
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(new List<EUR_CRM_Mechanic__c>{m}, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(1, contr.allMtById.size());
		Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> bQsByMt = contr.getBQsByMt(contr.allMtById);
		Test.stopTest();

		System.assertEquals(1, bQsByMt.size());
		System.assertEquals(50, bQsByMt.values()[0].size());
	}

	@IsTest
	private static void getBQsByMtExtId_ManyMts_Test() {
		initCMT();
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.allMtById.size());
		Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> bQsByMt = contr.getBQsByMt(contr.allMtById);
		Test.stopTest();

		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), bQsByMt.size());
		for (EUR_CRM_Mechanic_Type__c mt : bQsByMt.keySet()) {
			System.assertEquals(50, bQsByMt.get(mt).size());
			for (EUR_CRM_Quality__c bQ : bQsByMt.get(mt)) {
				System.assertEquals(2, bQ.Stock_Deal_Mechanics__r.size());
			}
		}
	}

	@IsTest
	private static void getBQsByMtExtId_NoMTs_Test() {
		initCMT();
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(0, contr.allMtById.size());
		Map<EUR_CRM_Mechanic_Type__c, Set<EUR_CRM_Quality__c>> bQsByMt = contr.getBQsByMt(contr.allMtById);
		Test.stopTest();

		System.assertEquals(0, bQsByMt.size());
	}

	@IsTest
	private static void getMtWrapperByMtExtIdWithProducts_ManyMts_NoDependentMts_notEmptyStockDealName_Test() {
		initCMT();

		for (String mtExtId : DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.keySet()) {
			MT_NAME_BY_MT_EXT_ID.remove(mtExtId);
		}

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.allMtById.size());
		Map<String, EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper> mtwByMtExtId = contr.getMtWrapperByMtExtIdWithBQs(contr.allMtById);
		Test.stopTest();

		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), mtwByMtExtId.size());
		for (String mtExtId : mtwByMtExtId.keySet()) {
			System.assertEquals(50, mtwByMtExtId.get(mtExtId).bqWrapperByBqIdAvailable.size());
			System.assertEquals(0, mtwByMtExtId.get(mtExtId).bqWrapperByBqIdInCPIs.size());
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtwByMtExtId.get(mtExtId).bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
		}
	}

	@IsTest
	private static void populateMtWrapperByMtExtIdMap_ManyMts_CPIsWithoutBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id; // GB_House_Pouring_Champagne
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };


		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.allMtById.size());
		Map<String, EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper> mtwByMtExtId = contr.populateMtWrapperByMtExtIdMap(contr.allMtById);
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), mtwByMtExtId.size());
		for (String mtExtId : mtwByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = mtwByMtExtId.get(mtExtId);
			System.assertEquals(50, mtWrapper.bqWrapperByBqIdAvailable.size());
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			if (mtExtId.contains('GB_House_Pouring_Champagne')) {
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);
				System.assertEquals(insertedCAIs[0].Contract_Product_Items__r.size(), mtWrapper.cpis.size());
			} else {
				System.assertEquals(null, mtWrapper.cai.Id);
				System.assertEquals(0, mtWrapper.cpis.size());
			}
		}
	}

	@IsTest
	private static void populateMtWrapperByMtExtIdMap_ManyMts_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };


		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.allMtById.size());
		Map<String, EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper> mtwByMtExtId = contr.populateMtWrapperByMtExtIdMap(contr.allMtById);
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), mtwByMtExtId.size());
		for (String mtExtId : mtwByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = mtwByMtExtId.get(mtExtId);
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			if (mtExtId.contains('GB_House_Pouring_Champagne')) {
				System.assertEquals(48, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);
				System.assertEquals(insertedCAIs[0].Contract_Product_Items__r.size(), mtWrapper.cpis.size());
			} else {
				System.assertEquals(50, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(null, mtWrapper.cai.Id);
				System.assertEquals(0, mtWrapper.cpis.size());
			}
		}
	}

	@IsTest
	private static void populateMtWrapperByMtExtIdMap_WithProducts_ManyMts_ForDependentMts_notEmptyStockDealName_Test() {
		initCMT();

		Map<String, String> allMtNameByExtId = MT_NAME_BY_MT_EXT_ID;
		Map<String, String> mtExtIdByNameToCreateMts = new Map<String, String>();
		for (String mtExtId : DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.keySet()) {
			mtExtIdByNameToCreateMts.put(mtExtId, allMtNameByExtId.get(mtExtId));
			mtExtIdByNameToCreateMts.put(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId), allMtNameByExtId.get(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId)));
		}

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', mtExtIdByNameToCreateMts);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		System.assertEquals(mtExtIdByNameToCreateMts.size(), contr.allMtById.size());
		Map<String, EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper> mtwByMtExtId = contr.populateMtWrapperByMtExtIdMap(contr.allMtById);
		Test.stopTest();

		System.assertEquals(mtExtIdByNameToCreateMts.size(), mtwByMtExtId.size());
		for (String mtExtId : mtwByMtExtId.keySet()) {
			if (DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) {
				System.assertEquals(50, mtwByMtExtId.get(mtExtId).bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, mtwByMtExtId.get(mtExtId).bqWrapperByBqIdInCPIs.size());

				String dependMtExtId = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
				System.assertEquals(0, mtwByMtExtId.get(dependMtExtId).bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, mtwByMtExtId.get(dependMtExtId).bqWrapperByBqIdInCPIs.size());
			}
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtwByMtExtId.get(mtExtId).bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
		}
	}

	@IsTest
	private static void addProduct_ManyMts_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mts[0].EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mts[0].EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdAvailable.values()[0].bq.Id));

		Test.startTest();
		contr.addProduct();
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.mtWrapByMtExtId.size());
		for (String mtExtId : contr.mtWrapByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = contr.mtWrapByMtExtId.get(mtExtId);
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			System.debug('\n mtExtId => ' + mtExtId + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdAvailable.size() => ' + mtWrapper.bqWrapperByBqIdAvailable.size() + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdInCPis.size() => ' + mtWrapper.bqWrapperByBqIdInCPis.size() + '\n');
			System.debug('\n mtWrapper.cpis.size() => ' + mtWrapper.cpis.size() + '\n');
			System.debug('\n mtWrapper.cpis => ' + JSON.serializePretty(mtWrapper.cpis) + '\n');
			if (mtExtId.contains('GB_House_Pouring_Champagne')) {
				System.assertEquals(47, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(3, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);
				System.assertEquals(2, mtWrapper.cpis.size());
			} else {
				System.assertEquals(50, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(null, mtWrapper.cai.Id);
				System.assertEquals(0, mtWrapper.cpis.size());
			}
		}
	}

	@IsTest
	private static void addProduct_ForMechanicTypesWithDependentAvailableBqLists_CPIsWithBQs_Test() {
		initCMT();
		Map<String, String> MT_NAME_BY_MT_EXT_ID = new Map<String, String>{
			'GB_May_Stock_Item'			    =>	    'May Stock Item'
		,	'GB_Must_Stock_Item'			=>	    'Must Stock Item'
		};

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, 'GB_May_Stock_Item');
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get('GB_May_Stock_Item');
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdAvailable.values()[0].bq.Id));

		Test.startTest();
		contr.addProduct();
		Test.stopTest();

		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.mtWrapByMtExtId.size());
		System.assertEquals(49, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdAvailable.size());
		System.assertEquals(1, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdInCPIs.size());
		System.assertEquals(0, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdBuffered.size());

		System.assertEquals(49, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdAvailable.size());
		System.assertEquals(0, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdInCPIs.size());
		System.assertEquals(1, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdBuffered.size());
	}

	@IsTest
	private static void removeProduct_ForMechanicTypesWithDependentAvailableBqLists_CPIsWithBQs_Test() {
		initCMT();
		Map<String, String> MT_NAME_BY_MT_EXT_ID = new Map<String, String>{
			'GB_May_Stock_Item'			    =>	    'May Stock Item'
		,	'GB_Must_Stock_Item'			=>	    'Must Stock Item'
		};

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, 'GB_May_Stock_Item');
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get('GB_May_Stock_Item');
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));

		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.mtWrapByMtExtId.size());
		System.assertEquals(48, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdAvailable.size());
		System.assertEquals(2, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdInCPIs.size());
		System.assertEquals(0, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdBuffered.size());

		System.assertEquals(48, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdAvailable.size());
		System.assertEquals(0, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdInCPIs.size());
		System.assertEquals(2, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdBuffered.size());

		Test.startTest();
		contr.removeProduct();
		Test.stopTest();

		System.assertEquals(49, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdAvailable.size());
		System.assertEquals(1, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdInCPIs.size());
		System.assertEquals(0, contr.mtWrapByMtExtId.get('GB_May_Stock_Item').bqWrapperByBqIdBuffered.size());

		System.assertEquals(49, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdAvailable.size());
		System.assertEquals(0, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdInCPIs.size());
		System.assertEquals(1, contr.mtWrapByMtExtId.get('GB_Must_Stock_Item').bqWrapperByBqIdBuffered.size());
	}

	@IsTest
	private static void removeProduct_ManyMts_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mts[0].EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mts[0].EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));

		Test.startTest();
		contr.removeProduct();
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(MT_NAME_BY_MT_EXT_ID.size(), contr.mtWrapByMtExtId.size());
		for (String mtExtId : contr.mtWrapByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = contr.mtWrapByMtExtId.get(mtExtId);
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			System.debug('\n mtExtId => ' + mtExtId + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdAvailable.size() => ' + mtWrapper.bqWrapperByBqIdAvailable.size() + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdInCPis.size() => ' + mtWrapper.bqWrapperByBqIdInCPis.size() + '\n');
			System.debug('\n mtWrapper.cpis.size() => ' + mtWrapper.cpis.size() + '\n');
			System.debug('\n mtWrapper.cpis => ' + JSON.serializePretty(mtWrapper.cpis) + '\n');
			if (mtExtId.contains('GB_House_Pouring_Champagne')) {
				System.assertEquals(49, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(1, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);
				System.assertEquals(2, mtWrapper.cpis.size());
			} else {
				System.assertEquals(50, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(null, mtWrapper.cai.Id);
				System.assertEquals(0, mtWrapper.cpis.size());
			}
		}
	}

	@IsTest
	private static void addProduct_ForDependentMTs_ManyMts_CPIsWithBQs_Test() {
		initCMT();
		Map<String, String> allMtNameByExtId = MT_NAME_BY_MT_EXT_ID;
		Map<String, String> mtExtIdByNameToCreateMts = new Map<String, String>();
		for (String mtExtId : DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.keySet()) {
			mtExtIdByNameToCreateMts.put(mtExtId, allMtNameByExtId.get(mtExtId));
			mtExtIdByNameToCreateMts.put(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId), allMtNameByExtId.get(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId)));
		}

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', mtExtIdByNameToCreateMts);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mts[0].EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mts[0].EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdAvailable.values()[0].bq.Id));

		Test.startTest();
		contr.addProduct();
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(mtExtIdByNameToCreateMts.size(), contr.mtWrapByMtExtId.size());
		for (String mtExtId : contr.mtWrapByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = contr.mtWrapByMtExtId.get(mtExtId);
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			System.debug('\n mtExtId => ' + mtExtId + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdAvailable.size() => ' + mtWrapper.bqWrapperByBqIdAvailable.size() + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdInCPis.size() => ' + mtWrapper.bqWrapperByBqIdInCPis.size() + '\n');
			System.debug('\n mtWrapper.cpis.size() => ' + mtWrapper.cpis.size() + '\n');
			System.debug('\n mtWrapper.cpis => ' + JSON.serializePretty(mtWrapper.cpis) + '\n');
			if (DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) {
				String dependMtExtId = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
				EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper dependMtWrap = contr.mtWrapByMtExtId.get(dependMtExtId);
				System.assertEquals(47, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(3, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);

				System.assertEquals(3, dependMtWrap.bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, dependMtWrap.bqWrapperByBqIdInCPis.size());
			}
		}
	}

	@IsTest
	private static void removeProduct_ForDependentMTs_ManyMts_CPIsWithBQs_Test() {
		initCMT();
		Map<String, String> allMtNameByExtId = MT_NAME_BY_MT_EXT_ID;
		Map<String, String> mtExtIdByNameToCreateMts = new Map<String, String>();
		for (String mtExtId : DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.keySet()) {
			mtExtIdByNameToCreateMts.put(mtExtId, allMtNameByExtId.get(mtExtId));
			mtExtIdByNameToCreateMts.put(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId), allMtNameByExtId.get(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId)));
		}

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', mtExtIdByNameToCreateMts);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mts[0].EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mts[0].EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));

		Test.startTest();
		contr.removeProduct();
		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(mtExtIdByNameToCreateMts.size(), contr.mtWrapByMtExtId.size());
		for (String mtExtId : contr.mtWrapByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = contr.mtWrapByMtExtId.get(mtExtId);
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			System.debug('\n mtExtId => ' + mtExtId + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdAvailable.size() => ' + mtWrapper.bqWrapperByBqIdAvailable.size() + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdInCPis.size() => ' + mtWrapper.bqWrapperByBqIdInCPis.size() + '\n');
			System.debug('\n mtWrapper.cpis.size() => ' + mtWrapper.cpis.size() + '\n');
			System.debug('\n mtWrapper.cpis => ' + JSON.serializePretty(mtWrapper.cpis) + '\n');
			if (DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) {
				String dependMtExtId = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
				EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper dependMtWrap = contr.mtWrapByMtExtId.get(dependMtExtId);
				System.assertEquals(49, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(1, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);

				System.assertEquals(1, dependMtWrap.bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, dependMtWrap.bqWrapperByBqIdInCPis.size());
			}
		}
	}

	@IsTest
	private static void initializeMtWrapDuringLoading_ForDependentMTs_ManyMts_CPIsWithBQs_Test() {
		initCMT();
		Map<String, String> allMtNameByExtId = MT_NAME_BY_MT_EXT_ID;
		Map<String, String> mtExtIdByNameToCreateMts = new Map<String, String>();
		for (String mtExtId : DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.keySet()) {
			mtExtIdByNameToCreateMts.put(mtExtId, allMtNameByExtId.get(mtExtId));
			mtExtIdByNameToCreateMts.put(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId), allMtNameByExtId.get(DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId)));
		}

		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', mtExtIdByNameToCreateMts);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		Test.startTest();
		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.stopTest();

		List<EUR_CRM_Contract_Activity_Item__c> insertedCAIs = selectCAIs();
		System.assertEquals(mtExtIdByNameToCreateMts.size(), contr.mtWrapByMtExtId.size());
		for (String mtExtId : contr.mtWrapByMtExtId.keySet()) {
			EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrapper = contr.mtWrapByMtExtId.get(mtExtId);
			for (EUR_CRM_GB_ContractBuilderController.BrandQualityWrapper bqw : mtWrapper.bqWrapperByBqIdAvailable.values()) {
				if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_STOCK_DEAL_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(3, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				} else if (EUR_CRM_GB_ContractBuilderController.MT_EXT_IDS_TO_CUSTOMIZE_CONTRACT_MECHANIC_PICKLIST.contains(mtExtId)) {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(1, bqw.cmSelectOptions.size());
				} else {
					System.assertEquals(0, bqw.sdmSelectOptions.size());
					System.assertEquals(0, bqw.cmSelectOptions.size());
				}
			}
			System.debug('\n mtExtId => ' + mtExtId + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdAvailable.size() => ' + mtWrapper.bqWrapperByBqIdAvailable.size() + '\n');
			System.debug('\n mtWrapper.bqWrapperByBqIdInCPis.size() => ' + mtWrapper.bqWrapperByBqIdInCPis.size() + '\n');
			System.debug('\n mtWrapper.cpis.size() => ' + mtWrapper.cpis.size() + '\n');
			System.debug('\n mtWrapper.cpis => ' + JSON.serializePretty(mtWrapper.cpis) + '\n');
			if (DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.containsKey(mtExtId)) {
				String dependMtExtId = DEPENDENT_MT_EXT_ID_TO_SET_AVAILABLE_BQ_AND_CPI_LIST_BY_CONTROLLED_MT_EXT_ID.get(mtExtId);
				EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper dependMtWrap = contr.mtWrapByMtExtId.get(dependMtExtId);
				System.assertEquals(48, mtWrapper.bqWrapperByBqIdAvailable.size());
				System.assertEquals(2, mtWrapper.bqWrapperByBqIdInCPis.size());
				System.assertEquals(insertedCAIs[0].Id, mtWrapper.cai.Id);

				System.assertEquals(2, dependMtWrap.bqWrapperByBqIdAvailable.size());
				System.assertEquals(0, dependMtWrap.bqWrapperByBqIdInCPis.size());
			}
		}
	}

	@IsTest
	private static void save_ForDependentMTs_ManyMts_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		List<EUR_CRM_Mechanic_Type__c> mTs = makeMTs('EUR_GB_Mechanic_Type', MT_NAME_BY_MT_EXT_ID);
		insert mTs;

		List<EUR_CRM_Mechanic__c> ms = makeMs(mTs);
		insert ms;

		List<EUR_CRM_Quality__c> bQs = makeBQs(50);
		insert bQs;

		List<EUR_CRM_Contract_Mechanic__c> cMs = makeCMs(ms, bQs);
		insert cMs;

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mts[0].Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		Test.startTest();
		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mts[0].EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mts[0].EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));
		contr.removeProduct();

		pageParams.put(EUR_CRM_GB_ContractBuilderController.IS_QUICK_SAVE, 'false');
		contr.saveContract();
		Test.stopTest();
	}

	@IsTest
	private static void setCaiAndCpiListsForSave_OneCaiToInsert_OneMt_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_GB_Mechanic_Type', 'House Pouring Champagne');
		mt.EUR_CRM_External_ID__c = 'GB_House_Pouring_Champagne';
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		List<EUR_CRM_Quality__c> bQs = makeBQs(2);
		insert bQs;

		EUR_CRM_Contract_Mechanic__c cm1 = makeCM(m.Id, bQs[0].Id);
		EUR_CRM_Contract_Mechanic__c cm2 = makeCM(m.Id, bQs[1].Id);
		insert new List<EUR_CRM_Contract_Mechanic__c>{ cm1, cm2 };

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mt.EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mt.EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));

		contr.removeProduct();
		contr.setCaiListsForSave();
		contr.setCpiListsForSave();
		Test.stopTest();

		System.debug('\n contr.cpiToUpsert.size() => ' + contr.cpiToUpsert.size() + '\n');
		System.debug('\n contr.cpiToUpsert => ' + JSON.serializePretty(contr.cpiToUpsert) + '\n');
		System.debug('\n contr.cpiToDelete.size() => ' + contr.cpiToDelete.size() + '\n');
		System.debug('\n contr.cpiToDelete => ' + JSON.serializePretty(contr.cpiToDelete) + '\n');
		System.assertEquals(0, contr.caiToUpsert.size());
//		System.assertEquals(0, contr.caiToDelete.size());
		System.assertEquals(1, contr.cpiToUpsert.size());
		System.assertEquals(1, contr.cpiToDelete.size());
	}

	@IsTest
	private static void setCaiAndCpiListsForSave_OneCaiToDelete_OneMt_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_GB_Mechanic_Type', 'House Pouring Champagne');
		mt.EUR_CRM_External_ID__c = 'GB_House_Pouring_Champagne';
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		List<EUR_CRM_Quality__c> bQs = makeBQs(2);
		insert bQs;

		EUR_CRM_Contract_Mechanic__c cm1 = makeCM(m.Id, bQs[0].Id);
		EUR_CRM_Contract_Mechanic__c cm2 = makeCM(m.Id, bQs[1].Id);
		insert new List<EUR_CRM_Contract_Mechanic__c>{ cm1, cm2 };

		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (EUR_CRM_Quality__c bq : bQs) {
			sdms.addAll(makeSDMs(bq.Id, 2));
		}
		insert sdms;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi1.EUR_CRM_Brand_Quality__c = bQs[0].Id;
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		cpi2.EUR_CRM_Brand_Quality__c = bQs[1].Id;
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2 };

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);

		Test.startTest();
		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.MT_EXT_ID, mt.EUR_CRM_External_ID__c);
		EUR_CRM_GB_ContractBuilderController.MechanicTypeWrapper mtWrap = contr.mtWrapByMtExtId.get(mt.EUR_CRM_External_ID__c);
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));

		contr.removeProduct();
		pageParams.put(EUR_CRM_GB_ContractBuilderController.BQ_ID, String.valueOf(mtWrap.bqWrapperByBqIdInCPIs.values()[0].bq.Id));
		contr.removeProduct();
		contr.setCaiListsForSave();
		contr.setCpiListsForSave();
		Test.stopTest();

		System.debug('\n contr.cpiToUpsert.size() => ' + contr.cpiToUpsert.size() + '\n');
		System.debug('\n contr.cpiToUpsert => ' + JSON.serializePretty(contr.cpiToUpsert) + '\n');
		System.debug('\n contr.cpiToDelete.size() => ' + contr.cpiToDelete.size() + '\n');
		System.debug('\n contr.cpiToDelete => ' + JSON.serializePretty(contr.cpiToDelete) + '\n');
		System.assertEquals(0, contr.caiToUpsert.size());
//		System.assertEquals(0, contr.caiToDelete.size());
		System.assertEquals(0, contr.cpiToUpsert.size());
		System.assertEquals(2, contr.cpiToDelete.size());
	}

	@IsTest
	private static void setCaiAndCpiListsForSave_OneCaiToUpdate_ManyMts_CPIsWithBQs_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_GB_Mechanic_Type', 'Bar Support');
		mt.EUR_CRM_External_ID__c = 'GB_Bar_support';
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		cai.EUR_CRM_Amount__c = 10;
		insert cai;

		PageReference pageRef = Page.EUR_CRM_GB_ContractBuilderPage;
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractBuilderController contr = new EUR_CRM_GB_ContractBuilderController(stdContr);
		System.debug('\n contr.mtWrapByMtExtId.size() => ' + contr.mtWrapByMtExtId.size() + '\n');
		System.debug('\n contr.mtWrapByMtExtId => ' + contr.mtWrapByMtExtId + '\n');

		Test.startTest();
		contr.setCaiListsForSave();
		contr.setCpiListsForSave();
		Test.stopTest();

		System.debug('\n contr.caiToUpsert.size() => ' + contr.caiToUpsert.size() + '\n');
		System.debug('\n contr.caiToUpsert => ' + JSON.serializePretty(contr.caiToUpsert) + '\n');
		System.assertEquals(0, contr.caiToUpsert.size());
//		System.assertEquals(0, contr.caiToDelete.size());
	}

	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			EUR_CRM_Postal_Code__c = '112233'
			,	RecordTypeId = rtId
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

	private static EUR_CRM_Mechanic_Type__c makeMT(String rt, String mtName) {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
		,	Name = mtName
		);
	}

	private static List<EUR_CRM_Mechanic_Type__c> makeMTs(String rt, Set<String> mtNames) {
		List<EUR_CRM_Mechanic_Type__c> mts = new List<EUR_CRM_Mechanic_Type__c>();
		for (String mtName : mtNames) {
			EUR_CRM_Mechanic_Type__c mt = makeMT(rt, mtName);
			mt.EUR_CRM_External_ID__c = mtName + '_EXT_ID';
			mts.add(mt);
		}
		return mts;
	}

	private static List<EUR_CRM_Mechanic_Type__c> makeMTs(String rt, Map<String, String> mtNameByExtId) {
		List<EUR_CRM_Mechanic_Type__c> mts = new List<EUR_CRM_Mechanic_Type__c>();
		for (String mtExtId : mtNameByExtId.keySet()) {
			EUR_CRM_Mechanic_Type__c mt = makeMT(rt, mtNameByExtId.get(mtExtId));
			mt.EUR_CRM_External_ID__c = mtExtId;
			mts.add(mt);
		}
		return mts;
	}

	private static EUR_CRM_Mechanic__c makeM(Id mtId) {
		return new EUR_CRM_Mechanic__c(
			EUR_CRM_Mechanic_Type__c = mtId
		);
	}

	private static List<EUR_CRM_Mechanic__c> makeMs(List<EUR_CRM_Mechanic_Type__c> mts) {
		List<EUR_CRM_Mechanic__c> ms = new List<EUR_CRM_Mechanic__c>();
		for (EUR_CRM_Mechanic_Type__c mt : mts) {
			ms.add(makeM(mt.Id));
		}
		return ms;
	}

	private static EUR_CRM_Contract_Mechanic__c makeCM(Id mId, Id bqId) {
		return new EUR_CRM_Contract_Mechanic__c(
			EUR_CRM_Mechanic__c = mId
		,	EUR_CRM_Brand_Quality__c = bqId
		);
	}

	private static List<EUR_CRM_Contract_Mechanic__c> makeCMs(List<EUR_CRM_Mechanic__c> ms, List<EUR_CRM_Quality__c> bQs) {
		List<EUR_CRM_Contract_Mechanic__c> cMs = new List<EUR_CRM_Contract_Mechanic__c>();
		for (EUR_CRM_Mechanic__c m : ms) {
			for (EUR_CRM_Quality__c bq : bQs) {
				cMs.add(makeCM(m.Id, bq.Id));
			}

		}
		return cMs;
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contrId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Activity_Item__c(
			EUR_CRM_Contract__c = contrId
			,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Product_Item__c makeCPI(Id caiId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Product_Item__c(
			RecordTypeId = rtId
			,	EUR_CRM_Contract_Activity_Item__c = caiId
		);
	}

	private static EUR_CRM_Stock_Deal_Mechanic__c makeSDM(Id bqId, String sdName) {
		return new EUR_CRM_Stock_Deal_Mechanic__c(
			EUR_CRM_Brand_Quality__c = bqId
		,	EUR_CRM_Stock_Deal_Name__c = sdName
		);
	}

	private static List<EUR_CRM_Stock_Deal_Mechanic__c> makeSDMs(Id bqId, Integer sdmNumber) {
		List<EUR_CRM_Stock_Deal_Mechanic__c> sdms = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
		for (Integer i = 0; i < sdmNumber; i++) {
			sdms.add(makeSDM(bqId, 'name_' + i));
		}
		return sdms;
	}

	private static EUR_CRM_Quality__c makeBQ() {
		return new EUR_CRM_Quality__c();
	}

	private static List<EUR_CRM_Quality__c> makeBQs(Integer bqNumber) {
		List<EUR_CRM_Quality__c> bQualities = new List<EUR_CRM_Quality__c>();
		for (Integer i = 0; i < bqNumber; i++) {
			bQualities.add(makeBQ());
		}
		return bQualities;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
		return [
			SELECT Id
				,	EUR_CRM_Mechanic_Type_Name__c
				,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				,	EUR_CRM_Contract__c
				,	EUR_CRM_Total_Value__c
				,	EUR_CRM_Amount__c
				,	(
				SELECT Id
					,	EUR_CRM_Total_Spend__c
					,	EUR_Min_Qty_Per_Annum_9L__c
					,	EUR_CRM_Retro_Per_9L__c
					,	EUR_CRM_Stock_Deal_Mechanic__r.EUR_CRM_Stock_Deal_Name__c
					,	EUR_CRM_No_of_People__c
					,	EUR_CRM_No_of_Cocktails__c
					,	EUR_CRM_Brand_Quality__r.Name
					,	EUR_CRM_Brand_Quality_Name__c
					,	EUR_CRM_Available_by_the_Glass__c
					,	EUR_CRM_Cocktail_Menu__c
					,	EUR_CRM_Value__c
					,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c
				FROM Contract_Product_Items__r
			)
			FROM EUR_CRM_Contract_Activity_Item__c
		];
	}
}