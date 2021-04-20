@IsTest(IsParallel = true)
private class EUR_CRM_GB_ContractSummaryControllerTest {
	private static Set<String> mtNames = new Set<String>{
		'Cocktail'
	,	'Educations'
	,	'Free Stock'
	,	'House Pouring Champagne'
	,	'House Pouring Spirits'
	,	'Lump Sum'
	,	'Marketing Support'
	,	'May Stock Item'
	,	'Must Stock Item'
	,	'Point of Sales'
	,	'Premium Pouring Spirits'
	,	'Trips'
	};

	@IsTest
	private static void simpleContractId_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		insert contract;

		Test.startTest();
		PageReference pr = Page.EUR_CRM_GB_ContractSummaryPage;
		Test.setCurrentPage(pr);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractSummaryController contr = new EUR_CRM_GB_ContractSummaryController(stdContr);
		Test.stopTest();

		System.assertEquals(false, contr.getIsShowMarketingPackage());
		System.assertEquals(contract.Id, contr.contrId);
	}

	@IsTest
	private static void simpleContractId_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
//		insert contract;

		Test.startTest();
		PageReference pr = Page.EUR_CRM_GB_ContractSummaryPage;
		Test.setCurrentPage(pr);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractSummaryController contr = new EUR_CRM_GB_ContractSummaryController(stdContr);
		Test.stopTest();

		List<ApexPages.Message> messages = ApexPages.getMessages();
		System.assertEquals(ApexPages.Severity.ERROR, messages[0].getSeverity());
		System.assertEquals(Label.EUR_CRM_MissingIdMessage, messages[0].getDetail());
	}

	@IsTest
	private static void contractWithRelatives_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount('EUR_GB_FS_Indirect');
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, 'EUR_GB_Contract', 'Draft');
		contract.CurrencyIsoCode = 'USD';
		insert contract;

		EUR_CRM_Mechanic_Type__c mt = makeMT('EUR_GB_Mechanic_Type', 'Cocktail');
		insert mt;

		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, 'EUR_GB_Contract_Activity_Item');
		cai.EUR_CRM_Mechanic_Type__c = mt.Id;
		insert cai;

		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai.Id, 'EUR_GB_Contract_Product_Item');
		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3 };

		Test.startTest();
		PageReference pr = Page.EUR_CRM_GB_ContractSummaryPage;
		Test.setCurrentPage(pr);

		ApexPages.StandardController stdContr = new ApexPages.StandardController(contract);
		EUR_CRM_GB_ContractSummaryController contr = new EUR_CRM_GB_ContractSummaryController(stdContr);
		Test.stopTest();

		System.assertEquals(contract.Id, contr.contractObj.Id);
		System.assertEquals(1, contr.mtWrapByMtExtId.size());
		System.assertEquals(3, contr.mtWrapByMtExtId.values()[0].cpis.size());
		System.assertEquals('CPI_Table_', EUR_CRM_GB_ContractSummaryController.CPI_TABLE_PREFIX);
		System.assertEquals(contract.CurrencyIsoCode, contr.currencyCode);

		EUR_CRM_GB_ContractSummaryController.MechanicTypeWrapper mw = new EUR_CRM_GB_ContractSummaryController.MechanicTypeWrapper(cai);
		Boolean testBoolean = contr.isLumpSumOrBurSupport('GB_Lump_Sum');
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

}