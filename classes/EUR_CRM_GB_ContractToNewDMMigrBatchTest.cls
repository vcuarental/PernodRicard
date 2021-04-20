/*
	C - Contract
	CAI - Contract Activity Item
	CPI - Contract Product Item
	CLI - Contract Line Item
	M - Mechanic
	MT - Mechanic Type
	CM - Contract Mechanic
	B - Brand
	BQ - Brand-Quality
	BQS - Brand-Quality-Size
	SKU - SKU
	SDM - Stock Deal Mechanic
* */
@IsTest(IsParallel = true)
private class EUR_CRM_GB_ContractToNewDMMigrBatchTest {

	private static final String ACTIVATED_STATUS = 'Activated';
	private static final String WAITING_FOR_SYNC_STATUS = 'Waiting for sync';
	private static final String GB_HOUSE_POURING_SPIRIT = 'GB_House_Pouring_Spirits';
	private static final String GB_TRIPS = 'GB_Trips';
	private static final String GB_MARKETING_SUPPORT = 'GB_Marketing_Support';
	private static final String GB_LUMP_SUM = 'GB_Lump_Sum';
	private static final String GB_COCKTAIL = 'GB_Cocktail';
	private static final String GB_HOUSE_POURING_CHAMPAGNE = 'GB_House_Pouring_Champagne';
	private static final String STANDARD_CONTRACT = 'Standard Contract';

	@IsTest
	private static void contractWithContractMechanicAndBrand_expectedCreateCaiWithCpi_positiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT();
		mt.EUR_CRM_External_ID__c = GB_HOUSE_POURING_SPIRIT;
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		EUR_CRM_Cocktail_Menu__c cMenu1 = makeCocktailMenu('Aviation');
		EUR_CRM_Cocktail_Menu__c cMenu2 = makeCocktailMenu('Bellini');
		insert new List<EUR_CRM_Cocktail_Menu__c>{ cMenu1, cMenu2 };

		EUR_CRM_Contract_Cocktail__c cc1 = makeCC(cli.Id, cMenu1.Id);
		EUR_CRM_Contract_Cocktail__c cc2 = makeCC(cli.Id, cMenu2.Id);
		insert new List<EUR_CRM_Contract_Cocktail__c>{ cc1, cc2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(1, createdCAIs.size());
		System.assertEquals(1, createdCPIs.size());
		System.assertEquals(1, contracts.size());

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);

		System.assertEquals(mt.Id, createdCAIs[0].EUR_CRM_Mechanic_Type__c);
		System.assertEquals(66.6, createdCAIs[0].EUR_CRM_Cocktail_Percent__c);

		System.assertEquals(cm.Id, createdCPIs[0].EUR_CRM_Contract_Mechanic__c);
		System.assertEquals(sdm.Id, createdCPIs[0].EUR_CRM_Stock_Deal_Mechanic__c);
		System.assertEquals(b.Id, createdCPIs[0].EUR_CRM_Brand__c);
		System.assertEquals('Test Mech Name', createdCPIs[0].EUR_CRM_Mechanic_Name__c);
		System.assertEquals('Aviation;Bellini', createdCPIs[0].EUR_CRM_Cocktail_Menu__c);
		System.assertEquals(150, createdCPIs[0].EUR_Min_Qty_Per_Annum_9L__c);
		System.assertEquals(151, createdCPIs[0].EUR_CRM_Retro_Per_9L__c);
		System.assertEquals(152, createdCPIs[0].EUR_CRM_No_of_Cocktails__c);
		System.assertEquals(155, createdCPIs[0].EUR_CRM_No_of_People__c);
		System.assertEquals(156, createdCPIs[0].EUR_CRM_Value__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Brand_Quality__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Brand_Quality_Size__c);
	}

	@IsTest
	private static void contractWithContractMechanicAndBrand_MarketingSupport_expectedCreateCaiWithCpi_positiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT();
		mt.EUR_CRM_External_ID__c = GB_MARKETING_SUPPORT;
		EUR_CRM_Mechanic_Type__c mtLumpSum = makeMT();
		mtLumpSum.EUR_CRM_External_ID__c = GB_LUMP_SUM;
		insert new List<EUR_CRM_Mechanic_Type__c>{ mt, mtLumpSum };

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_CRM_Process_Option_Lump_Sum__c = true;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		EUR_CRM_Cocktail_Menu__c cMenu1 = makeCocktailMenu('Aviation');
		EUR_CRM_Cocktail_Menu__c cMenu2 = makeCocktailMenu('Bellini');
		insert new List<EUR_CRM_Cocktail_Menu__c>{ cMenu1, cMenu2 };

		EUR_CRM_Contract_Cocktail__c cc1 = makeCC(cli.Id, cMenu1.Id);
		EUR_CRM_Contract_Cocktail__c cc2 = makeCC(cli.Id, cMenu2.Id);
		insert new List<EUR_CRM_Contract_Cocktail__c>{ cc1, cc2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();
		System.debug('\n createdCAIs.size() => ' + createdCAIs.size() + '\n');
		System.debug('\n createdCAIs => ' + JSON.serializePretty(createdCAIs) + '\n');
		System.debug('\n createdCPIs.size() => ' + createdCPIs.size() + '\n');
		System.debug('\n createdCPIs => ' + JSON.serializePretty(createdCPIs) + '\n');

		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(2, createdCAIs.size());
		System.assertEquals(0, createdCPIs.size());
		System.assertEquals(1, contracts.size());

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);
		List<String> mts = new List<String>();
		for (EUR_CRM_Contract_Activity_Item__c cai : createdCAIs) {
			mts.add(cai.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
		}
		System.assert(mts.contains(GB_LUMP_SUM));
		System.assert(mts.contains(GB_MARKETING_SUPPORT));
//		System.assertEquals(mtLumpSum.Id, createdCAIs[0].EUR_CRM_Mechanic_Type__c);
	}

	@IsTest
	private static void contractNoValidRt_expectedNothing_negativeTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_SE_Contract', WAITING_FOR_SYNC_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT();
		mt.EUR_CRM_External_ID__c = 'EUR_SE_Marketing_AP';
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		EUR_CRM_Cocktail_Menu__c cMenu1 = makeCocktailMenu('Aviation');
		EUR_CRM_Cocktail_Menu__c cMenu2 = makeCocktailMenu('Bellini');
		insert new List<EUR_CRM_Cocktail_Menu__c>{ cMenu1, cMenu2 };

		EUR_CRM_Contract_Cocktail__c cc1 = makeCC(cli.Id, cMenu1.Id);
		EUR_CRM_Contract_Cocktail__c cc2 = makeCC(cli.Id, cMenu2.Id);
		insert new List<EUR_CRM_Contract_Cocktail__c>{ cc1, cc2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();


		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(0, createdCAIs.size());
		System.assertEquals(0, createdCPIs.size());
		System.assertEquals(1, contracts.size());
		System.assertEquals(null, contracts[0].EUR_CRM_Contract_Type__c);
	}

	@IsTest
	private static void contractWithContractMechanicAndBrand_incorrectCCname_expectedCreateCaiWithoutCpi_negativeTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT();
		mt.EUR_CRM_External_ID__c = GB_TRIPS;
		insert mt;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		EUR_CRM_Cocktail_Menu__c cMenu1 = makeCocktailMenu('AviationTest');
		EUR_CRM_Cocktail_Menu__c cMenu2 = makeCocktailMenu('BelliniTest');
		insert new List<EUR_CRM_Cocktail_Menu__c>{ cMenu1, cMenu2 };

		EUR_CRM_Contract_Cocktail__c cc1 = makeCC(cli.Id, cMenu1.Id);
		EUR_CRM_Contract_Cocktail__c cc2 = makeCC(cli.Id, cMenu2.Id);
		insert new List<EUR_CRM_Contract_Cocktail__c>{ cc1, cc2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);
		System.assertEquals(1, contracts.size());
		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(1, createdCAIs.size());
		System.assertEquals(0, createdCPIs.size());
	}

	@IsTest
	private static void contractWithContractMechanicAndBrandAndCAI_expectedNothing_negativeTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT();
		mt.EUR_CRM_External_ID__c = GB_HOUSE_POURING_SPIRIT;
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id);
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		insert cai;

		EUR_CRM_Mechanic__c m = makeM(mt.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);

		System.assertEquals(1, contracts.size());
		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(1, createdCAIs.size());
		System.assertEquals(0, createdCPIs.size());
	}

	@IsTest
	private static void contractWithContractMechanicAndBrandAndCAI_expectedCreateCAIandCPI_positiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt1 = makeMT();
		mt1.EUR_CRM_External_ID__c = GB_HOUSE_POURING_SPIRIT;
		EUR_CRM_Mechanic_Type__c mt2 = makeMT();
		mt2.EUR_CRM_External_ID__c = GB_TRIPS;
		insert new List<EUR_CRM_Mechanic_Type__c>{ mt1, mt2 };

		EUR_CRM_Contract_Activity_Item__c cai1 = makeCAI(contract.Id);
		cai1.EUR_CRM_Mechanic_Type__c = mt2.Id;
		insert cai1;

		EUR_CRM_Mechanic__c m = makeM(mt1.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);

		System.assertEquals(1, contracts.size());
		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(2, createdCAIs.size());
		System.assertEquals(1, createdCPIs.size());
		System.assertEquals(mt1.Id, createdCAIs[1].EUR_CRM_Mechanic_Type__c);
		System.assertEquals(66.6, createdCAIs[1].EUR_CRM_Cocktail_Percent__c);

		System.assertEquals(cm.Id, createdCPIs[0].EUR_CRM_Contract_Mechanic__c);
		System.assertEquals(sdm.Id, createdCPIs[0].EUR_CRM_Stock_Deal_Mechanic__c);
		System.assertEquals(b.Id, createdCPIs[0].EUR_CRM_Brand__c);
		System.assertEquals('Test Mech Name', createdCPIs[0].EUR_CRM_Mechanic_Name__c);
		System.assertEquals(150, createdCPIs[0].EUR_Min_Qty_Per_Annum_9L__c);
		System.assertEquals(151, createdCPIs[0].EUR_CRM_Retro_Per_9L__c);
		System.assertEquals(152, createdCPIs[0].EUR_CRM_No_of_Cocktails__c);
		System.assertEquals(155, createdCPIs[0].EUR_CRM_No_of_People__c);
		System.assertEquals(156, createdCPIs[0].EUR_CRM_Value__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Brand_Quality__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Brand_Quality_Size__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Cocktail_Menu__c);
	}

	@IsTest
	private static void contractWithSeveralCLI_expectedCreateCAIandCPI_positiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt1 = makeMT();
		mt1.Name = 'First';
		mt1.EUR_CRM_External_ID__c = GB_HOUSE_POURING_SPIRIT;
		EUR_CRM_Mechanic_Type__c mt2 = makeMT();
		mt2.Name = 'Second';
		mt2.EUR_CRM_External_ID__c = GB_TRIPS;
		EUR_CRM_Mechanic_Type__c mt3 = makeMT();
		mt3.Name = 'Third';
		mt3.EUR_CRM_External_ID__c = GB_COCKTAIL;
		EUR_CRM_Mechanic_Type__c mt4 = makeMT();
		mt4.Name = 'Fourth';
		mt4.EUR_CRM_External_ID__c = GB_HOUSE_POURING_CHAMPAGNE;
		insert new List<EUR_CRM_Mechanic_Type__c>{ mt1, mt2, mt3, mt4 };

		EUR_CRM_Mechanic__c m1 = makeM(mt1.Id);
		EUR_CRM_Mechanic__c m2 = makeM(mt2.Id);
		EUR_CRM_Mechanic__c m3 = makeM(mt3.Id);
		EUR_CRM_Mechanic__c m4 = makeM(mt4.Id);
		insert new List<EUR_CRM_Mechanic__c>{ m1, m2, m3, m4 };

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Quality__c bq = makeBQ();
		insert bq;

		EUR_CRM_Size__c bqs = makeBQS();
		insert bqs;

		EUR_CRM_SKU__c sku = makeSKU();
		insert sku;

		EUR_CRM_Contract_Mechanic__c cm1 = makeCM(m1.Id);
		EUR_CRM_Contract_Mechanic__c cm2 = makeCM(m1.Id);
		cm2.EUR_CRM_Brand__c = b.Id;
		EUR_CRM_Contract_Mechanic__c cm3 = makeCM(m2.Id);
		EUR_CRM_Contract_Mechanic__c cm4 = makeCM(m2.Id);
		cm4.EUR_CRM_Brand_Quality__c = bq.Id;
		EUR_CRM_Contract_Mechanic__c cm5 = makeCM(m3.Id);
		EUR_CRM_Contract_Mechanic__c cm6 = makeCM(m3.Id);
		cm6.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
		EUR_CRM_Contract_Mechanic__c cm7 = makeCM(m4.Id);
		EUR_CRM_Contract_Mechanic__c cm8 = makeCM(m4.Id);
		cm8.EUR_CRM_SKU__c = sku.Id;
		insert new List<EUR_CRM_Contract_Mechanic__c>{ cm1, cm3, cm5, cm7, cm2, cm4, cm6, cm8 };

		EUR_CRM_Stock_Deal_Mechanic__c sdm1 = makeSDM();
		EUR_CRM_Stock_Deal_Mechanic__c sdm2 = makeSDM();
		sdm2.EUR_CRM_Brand_Quality__c = bq.Id;
		EUR_CRM_Stock_Deal_Mechanic__c sdm3 = makeSDM();
		EUR_CRM_Stock_Deal_Mechanic__c sdm4 = makeSDM();
		insert new List<EUR_CRM_Stock_Deal_Mechanic__c>{ sdm1, sdm2, sdm3, sdm4 };

		EUR_CRM_Contract_Line_Item__c cli1 = makeCLI(contract.Id);
		cli1.EUR_CRM_Contract_Mechanic__c = cm1.Id;
		cli1.EUR_CRM_Cocktail_Percent__c = 60;

		EUR_CRM_Contract_Line_Item__c cli2 = makeCLI(contract.Id);
		cli2.EUR_CRM_Contract_Mechanic__c = cm2.Id;
		cli2.EUR_Min_Qty_Per_Annum_9L__c = 250;
		cli2.EUR_CRM_Retro_Per_9L__c = 251;
		cli2.EUR_CRM_No_of_Cocktails__c = 252;
		cli2.EUR_CRM_Stock_Deal__c = sdm1.Id;
		cli2.EUR_CRM_Mechanic_Name__c = 'Test Mech Name 2';
		cli2.EUR_CRM_No_of_People__c = 255;
		cli2.EUR_CRM_Value__c = 256.0;

		EUR_CRM_Contract_Line_Item__c cli3 = makeCLI(contract.Id);
		cli3.EUR_CRM_Contract_Mechanic__c = cm3.Id;
		cli3.EUR_CRM_Cocktail_Percent__c = 61;

		EUR_CRM_Contract_Line_Item__c cli4 = makeCLI(contract.Id);
		cli4.EUR_CRM_Contract_Mechanic__c = cm4.Id;
		cli4.EUR_Min_Qty_Per_Annum_9L__c = 450;
		cli4.EUR_CRM_Retro_Per_9L__c = 451;
		cli4.EUR_CRM_No_of_Cocktails__c = 452;
		cli4.EUR_CRM_Stock_Deal__c = sdm2.Id;
		cli4.EUR_CRM_Mechanic_Name__c = 'Test Mech Name 4';
		cli4.EUR_CRM_No_of_People__c = 455;
		cli4.EUR_CRM_Value__c = 456.0;

		EUR_CRM_Contract_Line_Item__c cli5 = makeCLI(contract.Id);
		cli5.EUR_CRM_Contract_Mechanic__c = cm5.Id;
		cli5.EUR_CRM_Cocktail_Percent__c = 62;

		EUR_CRM_Contract_Line_Item__c cli6 = makeCLI(contract.Id);
		cli6.EUR_CRM_Contract_Mechanic__c = cm6.Id;
		cli6.EUR_Min_Qty_Per_Annum_9L__c = 650;
		cli6.EUR_CRM_Retro_Per_9L__c = 651;
		cli6.EUR_CRM_No_of_Cocktails__c = 652;
		cli6.EUR_CRM_Stock_Deal__c = sdm3.Id;
		cli6.EUR_CRM_Mechanic_Name__c = 'Test Mech Name 6';
		cli6.EUR_CRM_No_of_People__c = 655;
		cli6.EUR_CRM_Value__c = 656.0;

		EUR_CRM_Contract_Line_Item__c cli7 = makeCLI(contract.Id);
		cli7.EUR_CRM_Contract_Mechanic__c = cm7.Id;
		cli7.EUR_CRM_Cocktail_Percent__c = 63;

		EUR_CRM_Contract_Line_Item__c cli8 = makeCLI(contract.Id);
		cli8.EUR_CRM_Contract_Mechanic__c = cm8.Id;
		cli8.EUR_Min_Qty_Per_Annum_9L__c = 850;
		cli8.EUR_CRM_Retro_Per_9L__c = 851;
		cli8.EUR_CRM_No_of_Cocktails__c = 852;
		cli8.EUR_CRM_Stock_Deal__c = sdm4.Id;
		cli8.EUR_CRM_Mechanic_Name__c = 'Test Mech Name 8';
		cli8.EUR_CRM_No_of_People__c = 855;
		cli8.EUR_CRM_Value__c = 856.0;
		insert new List<EUR_CRM_Contract_Line_Item__c>{ cli1, cli2, cli3, cli4, cli5, cli6, cli7, cli8 };

		EUR_CRM_Cocktail_Menu__c cMenu1 = makeCocktailMenu('Aviation');
		EUR_CRM_Cocktail_Menu__c cMenu2 = makeCocktailMenu('Bellini');
		EUR_CRM_Cocktail_Menu__c cMenu3 = makeCocktailMenu('Cosmopolitan');
		EUR_CRM_Cocktail_Menu__c cMenu4 = makeCocktailMenu('Daiquiri');
		EUR_CRM_Cocktail_Menu__c cMenu5 = makeCocktailMenu('Gimlet');
		EUR_CRM_Cocktail_Menu__c cMenu6 = makeCocktailMenu('Hibiscus Margarita');
		EUR_CRM_Cocktail_Menu__c cMenu7 = makeCocktailMenu('Irish Coffee');
		EUR_CRM_Cocktail_Menu__c cMenu8 = makeCocktailMenu('Mai Tai');
		insert new List<EUR_CRM_Cocktail_Menu__c>{ cMenu1, cMenu2, cMenu3, cMenu4, cMenu5, cMenu6, cMenu7, cMenu8 };

		EUR_CRM_Contract_Cocktail__c cc1 = makeCC(cli2.Id, cMenu1.Id);
		EUR_CRM_Contract_Cocktail__c cc2 = makeCC(cli2.Id, cMenu2.Id);
		EUR_CRM_Contract_Cocktail__c cc3 = makeCC(cli4.Id, cMenu3.Id);
		EUR_CRM_Contract_Cocktail__c cc4 = makeCC(cli4.Id, cMenu4.Id);
		EUR_CRM_Contract_Cocktail__c cc5 = makeCC(cli6.Id, cMenu5.Id);
		EUR_CRM_Contract_Cocktail__c cc6 = makeCC(cli6.Id, cMenu6.Id);
		EUR_CRM_Contract_Cocktail__c cc7 = makeCC(cli8.Id, cMenu7.Id);
		EUR_CRM_Contract_Cocktail__c cc8 = makeCC(cli8.Id, cMenu8.Id);
		insert new List<EUR_CRM_Contract_Cocktail__c>{ cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);

		System.assertEquals(1, contracts.size());
		System.debug('\n createdCAIs.size() => ' + createdCAIs.size() + '\n');
		System.debug('\n createdCAIs => ' + JSON.serializePretty(createdCAIs) + '\n');
		System.debug('\n createdCPIs.size() => ' + createdCPIs.size() + '\n');
		System.debug('\n createdCPIs => ' + JSON.serializePretty(createdCPIs) + '\n');

		System.assertEquals(8, insertedCLIs.size());
		System.assertEquals(4, createdCAIs.size());
		System.assertEquals(4, createdCPIs.size());
		System.assertEquals(mt1.Id, createdCAIs[0].EUR_CRM_Mechanic_Type__c);
		System.assertEquals(mt2.Id, createdCAIs[1].EUR_CRM_Mechanic_Type__c);
		System.assertEquals(mt3.Id, createdCAIs[2].EUR_CRM_Mechanic_Type__c);
		System.assertEquals(mt4.Id, createdCAIs[3].EUR_CRM_Mechanic_Type__c);
		System.assertEquals(60, createdCAIs[0].EUR_CRM_Cocktail_Percent__c);
		System.assertEquals(61, createdCAIs[1].EUR_CRM_Cocktail_Percent__c);
		System.assertEquals(62, createdCAIs[2].EUR_CRM_Cocktail_Percent__c);
		System.assertEquals(63, createdCAIs[3].EUR_CRM_Cocktail_Percent__c);
//
		System.assertEquals(cm2.Id, createdCPIs[0].EUR_CRM_Contract_Mechanic__c);
		System.assertEquals(cm4.Id, createdCPIs[1].EUR_CRM_Contract_Mechanic__c);
		System.assertEquals(cm6.Id, createdCPIs[2].EUR_CRM_Contract_Mechanic__c);
		System.assertEquals(cm8.Id, createdCPIs[3].EUR_CRM_Contract_Mechanic__c);
		System.assertEquals(sdm1.Id, createdCPIs[0].EUR_CRM_Stock_Deal_Mechanic__c);
		System.assertEquals(sdm2.Id, createdCPIs[1].EUR_CRM_Stock_Deal_Mechanic__c);
		System.assertEquals(sdm3.Id, createdCPIs[2].EUR_CRM_Stock_Deal_Mechanic__c);
		System.assertEquals(sdm4.Id, createdCPIs[3].EUR_CRM_Stock_Deal_Mechanic__c);
		System.assertEquals(b.Id, createdCPIs[0].EUR_CRM_Brand__c);
		System.assertEquals(null, createdCPIs[1].EUR_CRM_Brand__c);
		System.assertEquals(null, createdCPIs[2].EUR_CRM_Brand__c);
		System.assertEquals(null, createdCPIs[3].EUR_CRM_Brand__c);
		System.assertEquals('Test Mech Name 2', createdCPIs[0].EUR_CRM_Mechanic_Name__c);
		System.assertEquals('Test Mech Name 4', createdCPIs[1].EUR_CRM_Mechanic_Name__c);
		System.assertEquals('Test Mech Name 6', createdCPIs[2].EUR_CRM_Mechanic_Name__c);
		System.assertEquals('Test Mech Name 8', createdCPIs[3].EUR_CRM_Mechanic_Name__c);
		System.assertEquals(250, createdCPIs[0].EUR_Min_Qty_Per_Annum_9L__c);
		System.assertEquals(450, createdCPIs[1].EUR_Min_Qty_Per_Annum_9L__c);
		System.assertEquals(650, createdCPIs[2].EUR_Min_Qty_Per_Annum_9L__c);
		System.assertEquals(850, createdCPIs[3].EUR_Min_Qty_Per_Annum_9L__c);
		System.assertEquals(251, createdCPIs[0].EUR_CRM_Retro_Per_9L__c);
		System.assertEquals(451, createdCPIs[1].EUR_CRM_Retro_Per_9L__c);
		System.assertEquals(651, createdCPIs[2].EUR_CRM_Retro_Per_9L__c);
		System.assertEquals(851, createdCPIs[3].EUR_CRM_Retro_Per_9L__c);
		System.assertEquals(252, createdCPIs[0].EUR_CRM_No_of_Cocktails__c);
		System.assertEquals(452, createdCPIs[1].EUR_CRM_No_of_Cocktails__c);
		System.assertEquals(652, createdCPIs[2].EUR_CRM_No_of_Cocktails__c);
		System.assertEquals(852, createdCPIs[3].EUR_CRM_No_of_Cocktails__c);
		System.assertEquals(255, createdCPIs[0].EUR_CRM_No_of_People__c);
		System.assertEquals(455, createdCPIs[1].EUR_CRM_No_of_People__c);
		System.assertEquals(655, createdCPIs[2].EUR_CRM_No_of_People__c);
		System.assertEquals(855, createdCPIs[3].EUR_CRM_No_of_People__c);
		System.assertEquals(256, createdCPIs[0].EUR_CRM_Value__c);
		System.assertEquals(456, createdCPIs[1].EUR_CRM_Value__c);
		System.assertEquals(656, createdCPIs[2].EUR_CRM_Value__c);
		System.assertEquals(856, createdCPIs[3].EUR_CRM_Value__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Brand_Quality__c);
		System.assertEquals(bq.Id, createdCPIs[1].EUR_CRM_Brand_Quality__c);
		System.assertEquals(null, createdCPIs[2].EUR_CRM_Brand_Quality__c);
		System.assertEquals(null, createdCPIs[3].EUR_CRM_Brand_Quality__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_Brand_Quality_Size__c);
		System.assertEquals(null, createdCPIs[1].EUR_CRM_Brand_Quality_Size__c);
		System.assertEquals(bqs.Id, createdCPIs[2].EUR_CRM_Brand_Quality_Size__c);
		System.assertEquals(null, createdCPIs[3].EUR_CRM_Brand_Quality_Size__c);
		System.assertEquals(null, createdCPIs[0].EUR_CRM_SKU__c);
		System.assertEquals(null, createdCPIs[1].EUR_CRM_SKU__c);
		System.assertEquals(null, createdCPIs[2].EUR_CRM_SKU__c);
		System.assertEquals(sku.Id, createdCPIs[3].EUR_CRM_SKU__c);
		System.assertEquals('Aviation;Bellini', createdCPIs[0].EUR_CRM_Cocktail_Menu__c);
		System.assertEquals('Cosmopolitan;Daiquiri', createdCPIs[1].EUR_CRM_Cocktail_Menu__c);
		System.assertEquals('Gimlet;Hibiscus Margarita', createdCPIs[2].EUR_CRM_Cocktail_Menu__c);
		System.assertEquals('Irish Coffee;Mai Tai', createdCPIs[3].EUR_CRM_Cocktail_Menu__c);
	}

	@IsTest
	private static void contractWithContractMechanicAndBrandAndCAIWithCPI_expectedNoCreateCAIandCPI_negativeTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt1 = makeMT();
		mt1.EUR_CRM_External_ID__c = GB_HOUSE_POURING_SPIRIT;
		EUR_CRM_Mechanic_Type__c mt2 = makeMT();
		mt2.EUR_CRM_External_ID__c = GB_TRIPS;
		insert new List<EUR_CRM_Mechanic_Type__c>{ mt1, mt2 };

		EUR_CRM_Mechanic__c m = makeM(mt1.Id);
		insert m;

		EUR_CRM_Brand__c b = makeB();
		insert b;

		EUR_CRM_Contract_Activity_Item__c cai1 = makeCAI(contract.Id);
		cai1.EUR_CRM_Mechanic_Type__c = mt1.Id;
		insert cai1;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai1.Id);
		cpi1.EUR_CRM_Brand__c = b.Id;
		insert cpi1;

		EUR_CRM_Contract_Mechanic__c cm = makeCM(m.Id);
		cm.EUR_CRM_Brand__c = b.Id;
		insert cm;

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli = makeCLI(contract.Id);
		cli.EUR_CRM_Contract_Mechanic__c = cm.Id;
		cli.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli.EUR_CRM_Retro_Per_9L__c = 151;
		cli.EUR_CRM_No_of_Cocktails__c = 152;
		cli.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli.EUR_CRM_No_of_People__c = 155;
		cli.EUR_CRM_Value__c = 156.0;
		insert cli;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);

		System.assertEquals(1, contracts.size());
		System.assertEquals(1, insertedCLIs.size());
		System.assertEquals(2, createdCAIs.size());
		System.assertEquals(1, createdCPIs.size());
	}

	@IsTest
	private static void contractWithContractMechanicAndBrandAndCAIWithCPI_expectedCreateCAIandCPI_positiveTest() {
		EUR_CRM_Account__c acc = makeAccount();
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', ACTIVATED_STATUS);
		insert contract;

		EUR_CRM_Mechanic_Type__c mt1 = makeMT();
		mt1.EUR_CRM_External_ID__c = GB_HOUSE_POURING_SPIRIT;
		EUR_CRM_Mechanic_Type__c mt2 = makeMT();
		mt2.EUR_CRM_External_ID__c = GB_TRIPS;
		insert new List<EUR_CRM_Mechanic_Type__c>{ mt1, mt2 };

		EUR_CRM_Mechanic__c m1 = makeM(mt1.Id);
		EUR_CRM_Mechanic__c m2 = makeM(mt2.Id);
		insert new List<EUR_CRM_Mechanic__c>{ m1, m2 };

		EUR_CRM_Brand__c b1 = makeB();
		EUR_CRM_Brand__c b2 = makeB();
		insert new List<EUR_CRM_Brand__c>{ b1, b2 };

		EUR_CRM_Contract_Activity_Item__c cai1 = makeCAI(contract.Id);
		cai1.EUR_CRM_Mechanic_Type__c = mt1.Id;
		insert cai1;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai1.Id);
		cpi1.EUR_CRM_Brand__c = b1.Id;
		insert cpi1;

		EUR_CRM_Contract_Mechanic__c cm1 = makeCM(m1.Id);
		cm1.EUR_CRM_Brand__c = b1.Id;
		EUR_CRM_Contract_Mechanic__c cm2 = makeCM(m2.Id);
		cm2.EUR_CRM_Brand__c = b2.Id;
		insert new List<EUR_CRM_Contract_Mechanic__c>{ cm1, cm2 };

		EUR_CRM_Stock_Deal_Mechanic__c sdm = makeSDM();
		insert sdm;

		EUR_CRM_Contract_Line_Item__c cli1 = makeCLI(contract.Id);
		cli1.EUR_CRM_Contract_Mechanic__c = cm1.Id;
		cli1.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli1.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli1.EUR_CRM_Retro_Per_9L__c = 151;
		cli1.EUR_CRM_No_of_Cocktails__c = 152;
		cli1.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli1.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli1.EUR_CRM_No_of_People__c = 155;
		cli1.EUR_CRM_Value__c = 156.0;

		EUR_CRM_Contract_Line_Item__c cli2 = makeCLI(contract.Id);
		cli2.EUR_CRM_Contract_Mechanic__c = cm2.Id;
		cli2.EUR_CRM_Cocktail_Percent__c = 66.6;
		cli2.EUR_Min_Qty_Per_Annum_9L__c = 150;
		cli2.EUR_CRM_Retro_Per_9L__c = 151;
		cli2.EUR_CRM_No_of_Cocktails__c = 152;
		cli2.EUR_CRM_Stock_Deal__c = sdm.Id;
		cli2.EUR_CRM_Mechanic_Name__c = 'Test Mech Name';
		cli2.EUR_CRM_No_of_People__c = 155;
		cli2.EUR_CRM_Value__c = 156.0;
		insert new List<EUR_CRM_Contract_Line_Item__c>{ cli1, cli2 };



		Test.startTest();
		Database.executeBatch(new EUR_CRM_GB_ContractToNewDMMigrBatch());
		Test.stopTest();

		List<EUR_CRM_Contract_Line_Item__c> insertedCLIs = selectCLIs();
		List<EUR_CRM_Contract_Activity_Item__c> createdCAIs = selectCAIs();
		List<EUR_CRM_Contract_Product_Item__c> createdCPIs = selectCPIs();
		List<EUR_CRM_Contract__c> contracts = selectContracts();

		System.assertEquals(STANDARD_CONTRACT, contracts[0].EUR_CRM_Contract_Type__c);

		System.debug('\n insertedCLIs.size() => ' + insertedCLIs.size() + '\n');
		System.debug('\n insertedCLIs => ' + JSON.serializePretty(insertedCLIs) + '\n');
		System.debug('\n createdCAIs.size() => ' + createdCAIs.size() + '\n');
		System.debug('\n createdCAIs => ' + JSON.serializePretty(createdCAIs) + '\n');
		System.debug('\n createdCPIs.size() => ' + createdCPIs.size() + '\n');
		System.debug('\n createdCPIs => ' + JSON.serializePretty(createdCPIs) + '\n');
		System.assertEquals(1, contracts.size());
		System.assertEquals(2, insertedCLIs.size());
		System.assertEquals(2, createdCAIs.size());
		System.assertEquals(2, createdCPIs.size());
	}



	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount() {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_FS_Indirect').getRecordTypeId();
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

	private static EUR_CRM_Contract_Line_Item__c makeCLI(Id contrId) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Line_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Contract_Line_Item').getRecordTypeId();
		return new EUR_CRM_Contract_Line_Item__c(
			EUR_CRM_Contract__c = contrId
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Mechanic__c makeCM(Id mechId) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Mechanic__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Contract_Mechanic').getRecordTypeId();
		return new EUR_CRM_Contract_Mechanic__c(
			EUR_CRM_Mechanic__c = mechId
		,	RecordTypeId = rtId

		);
	}

	private static EUR_CRM_Mechanic__c makeM(Id mtId) {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Mechanic').getRecordTypeId();
		return new EUR_CRM_Mechanic__c(
			EUR_CRM_Mechanic_Type__c = mtId
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Mechanic_Type__c makeMT() {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Mechanic_Type').getRecordTypeId();
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Stock_Deal_Mechanic__c makeSDM() {
		Id rtId = Schema.SObjectType.EUR_CRM_Stock_Deal_Mechanic__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Stock_Deal_Mechanic').getRecordTypeId();
		return new EUR_CRM_Stock_Deal_Mechanic__c(
			EUR_CRM_Litres_per_Case__c = 10
		,	EUR_CRM_Bottles_per_Case_BQ__c = 20
		,	EUR_CRM_Liquid_per_Bottle_litre__c = 30
		,	EUR_CRM_Qty_Buy__c = 40
		,	EUR_CRM_Qty_Free__c = 50
		,	EUR_CRM_RTM_Price__c = 60
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contrId) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Contract_Activity_Item').getRecordTypeId();
		return new EUR_CRM_Contract_Activity_Item__c(
			EUR_CRM_Contract__c = contrId
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Product_Item__c makeCPI(Id caiId) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Contract_Product_Item').getRecordTypeId();
		return new EUR_CRM_Contract_Product_Item__c(
			EUR_CRM_Contract_Activity_Item__c = caiId
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Cocktail__c makeCC(Id cliId, Id cocktailMenuId) {
		return new EUR_CRM_Contract_Cocktail__c(
			EUR_CRM_Cocktail_Menu__c = cocktailMenuId
		,	EUR_CRM_Contract_Line_Item__c = cliId
		);
	}

	private static EUR_CRM_Cocktail_Menu__c makeCocktailMenu(String cName) {
		Id rtId = Schema.SObjectType.EUR_CRM_Cocktail_Menu__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Cocktail_Menu').getRecordTypeId();
		return new EUR_CRM_Cocktail_Menu__c(
			Name = cName
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Brand__c makeB() {
		Id rtId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Brand').getRecordTypeId();
		return new EUR_CRM_Brand__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Quality__c makeBQ() {
		Id rtId = Schema.SObjectType.EUR_CRM_Quality__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Quality').getRecordTypeId();
		return new EUR_CRM_Quality__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Size__c makeBQS() {
		Id rtId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_Size').getRecordTypeId();
		return new EUR_CRM_Size__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_SKU__c makeSKU() {
		Id rtId = Schema.SObjectType.EUR_CRM_SKU__c.getRecordTypeInfosByDeveloperName().get('EUR_GB_SKU').getRecordTypeId();
		return new EUR_CRM_SKU__c(
			RecordTypeId = rtId
		);
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
		return [
			SELECT Id
			,	EUR_CRM_Mechanic_Type__c
			,	EUR_CRM_Mechanic_Type_Name__c
			,	EUR_CRM_Mechanic_Type__r.Name
			,	EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Name__c
			,	EUR_CRM_Cocktail_Percent__c
			,	EUR_CRM_Amount__c
			FROM EUR_CRM_Contract_Activity_Item__c
			ORDER BY EUR_CRM_Cocktail_Percent__c
		];
	}

	private static List<EUR_CRM_Contract_Line_Item__c> selectCLIs() {
		return [
			SELECT Id
			,	EUR_CRM_Contract_Mechanic__c
			,	EUR_CRM_Contract__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.Name
			FROM EUR_CRM_Contract_Line_Item__c
		];
	}

	private static List<EUR_CRM_Contract_Product_Item__c> selectCPIs() {
		return [
			SELECT Id
			,	EUR_CRM_Contract_Activity_Item__c
			,	EUR_CRM_Contract_Mechanic__c
			,	EUR_CRM_Brand__c
			,	EUR_CRM_Brand_Quality__c
			,	EUR_CRM_Brand_Quality_Size__c
			,	EUR_CRM_SKU__c
			,	EUR_Min_Qty_Per_Annum_9L__c
			,	EUR_CRM_Retro_Per_9L__c
			,	EUR_CRM_No_of_Cocktails__c
			,	EUR_CRM_Stock_Deal_Mechanic__c
			,	EUR_CRM_Stock_Deal_Mechanic__r.EUR_CRM_Brand_Quality__c
			,	EUR_CRM_Mechanic_Name__c
			,	EUR_CRM_No_of_People__c
			,	EUR_CRM_Value__c
			,	EUR_CRM_Cocktail_Menu__c
			FROM EUR_CRM_Contract_Product_Item__c
			ORDER BY EUR_CRM_Mechanic_Name__c
		];
	}

	private static List<EUR_CRM_Contract__c> selectContracts() {
		return [
			SELECT Id
			,	EUR_CRM_Contract_Type__c
			FROM EUR_CRM_Contract__c
		];
	}
}