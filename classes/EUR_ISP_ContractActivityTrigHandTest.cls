@IsTest
private class EUR_ISP_ContractActivityTrigHandTest {

	@IsTest
	static void doUpdateCPPPs_WKZ_Fix_Amount_PositiveTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(1).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'WKZ Fix Amount';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = 'EUR_DE_WKZ_Fix_Amount';
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id, 'EUR_DE_Contract_Activity_Item');
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = 'Beginning of contract';
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		cpItem.EUR_CRM_Volume_lt__c= 5;

		insert cpItem;

		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPIs()[0];
		EUR_CRM_Contract_Activity_Item__c insertedCAI = selectCAIs()[0];
		Test.startTest();
		insertedCPI.EUR_CRM_Volume_lt__c = 10;
		update insertedCPI;

		insertedCAI.EUR_CRM_Amount__c = 2500;
		insertedCAI.EUR_CRM_Payment_Term__c = 'After implementation';
		update insertedCAI;
		Test.stopTest();
		System.debug('\n selectCAIs() => ' + JSON.serializePretty(selectCAIs()) + '\n');

		List<EUR_CRM_Contract_Payment_Plan_Period__c> insertedCPPPs = selectCPPperiods();
		System.debug('\n insertedCPPPs.size() => ' + insertedCPPPs.size() + '\n');
		System.debug('\n insertedCPPPs => ' + JSON.serializePretty(insertedCPPPs) + '\n');
		System.assertEquals(1, insertedCPPPs.size());
		System.assertEquals(2500, insertedCPPPs[0].EUR_CRM_CPPP_Amount__c);
		System.assertEquals('After implementation', insertedCPPPs[0].EUR_CRM_CPPP_Payment_Term__c);
	}

	@IsTest
	static void doUpdateCPPPs_WKZ_Fix_Amount_NegativeTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(1).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'WKZ Fix Amount';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = 'EUR_DE_WKZ_Fix_Amount';
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id, 'EUR_FI_Contract_Activity_Item');
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = 'Beginning of contract';
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		cpItem.EUR_CRM_Volume_lt__c= 5;

		insert cpItem;

		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPIs()[0];
		EUR_CRM_Contract_Activity_Item__c insertedCAI = selectCAIs()[0];
		Test.startTest();
		insertedCPI.EUR_CRM_Volume_lt__c = 10;
		update insertedCPI;

		insertedCAI.EUR_CRM_Amount__c = 2500;
		insertedCAI.EUR_CRM_Payment_Term__c = 'After implementation';
		update insertedCAI;
		Test.stopTest();

		List<EUR_CRM_Contract_Payment_Plan_Period__c> insertedCPPPs = selectCPPperiods();
		System.debug('\n insertedCPPPs.size() => ' + insertedCPPPs.size() + '\n');
		System.debug('\n insertedCPPPs => ' + JSON.serializePretty(insertedCPPPs) + '\n');
		System.assertEquals(1, insertedCPPPs.size());
		System.assertEquals(5000, insertedCPPPs[0].EUR_CRM_CPPP_Amount__c);
		System.assertEquals('Beginning of contract', insertedCPPPs[0].EUR_CRM_CPPP_Payment_Term__c);
	}

	@IsTest
	static void doUpdateCPPPs_Pouring_Refund_PositiveTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(1).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'WKZ Fix Amount';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = 'EUR_DE_Pouring_Refund';
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id, 'EUR_DE_Contract_Activity_Item');
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = 'After Implementation';
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 60.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		cpItem.EUR_CRM_Volume_lt__c= 5;
		insert cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> insertedCPPPs = selectCPPperiods();
		System.debug('\n insertedCPPPs.size() => ' + insertedCPPPs.size() + '\n');
		System.debug('\n insertedCPPPs => ' + JSON.serializePretty(insertedCPPPs) + '\n');
		System.assertEquals(1, insertedCPPPs.size());
		System.assertEquals(3600, insertedCPPPs[0].EUR_CRM_CPPP_Amount__c);
		System.assertEquals('Nach Umsetzung', insertedCPPPs[0].EUR_CRM_CPPP_Payment_Term__c);


		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPIs()[0];
		EUR_CRM_Contract_Activity_Item__c insertedCAI = selectCAIs()[0];
		Test.startTest();
		caItem.EUR_CRM_Amount__c = 2500;
		caItem.EUR_CRM_Payment_Term__c = 'Beginning of contract';
		update caItem;
		Test.stopTest();

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppps = selectCPPperiods();
		System.debug('\n insertedCPPPs.size() => ' + cppps.size() + '\n');
		System.debug('\n insertedCPPPs => ' + JSON.serializePretty(cppps) + '\n');
		System.assertEquals(1, cppps.size());
		System.assertEquals(3600, cppps[0].EUR_CRM_CPPP_Amount__c);
		System.assertEquals('Nach Umsetzung', cppps[0].EUR_CRM_CPPP_Payment_Term__c);
	}

	@IsTest
	static void doUpdateCPPPs_Pouring_Refund_NegativeTest() {

		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(1).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'Pouring Refund';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = 'EUR_DE_Pouring_Refund';
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id, 'EUR_FI_Contract_Activity_Item');
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = 'After Implementation';
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 60.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		cpItem.EUR_CRM_Volume_lt__c= 5;
		insert cpItem;


		EUR_CRM_Contract_Product_Item__c insertedCPI = selectCPIs()[0];
		EUR_CRM_Contract_Activity_Item__c insertedCAI = selectCAIs()[0];
		Test.startTest();
		caItem.EUR_CRM_Amount__c = 2500;
		caItem.EUR_CRM_Payment_Term__c = 'Beginning of contract';
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 7, 1);
		update caItem;
		Test.stopTest();

		List<EUR_CRM_Contract_Payment_Plan_Period__c> insertedCPPPs = selectCPPperiods();
		System.debug('\n insertedCPPPs.size() => ' + insertedCPPPs.size() + '\n');
		System.debug('\n insertedCPPPs => ' + JSON.serializePretty(insertedCPPPs) + '\n');
		System.assertEquals(1, insertedCPPPs.size());
		System.assertEquals(3600, insertedCPPPs[0].EUR_CRM_CPPP_Amount__c);

		// Nach Umsetzung = Beginning of contract (in german language)
		// it's because of EUR_CRM_ContractPaymentPlanPeriodHandler.cls logic
		System.assertEquals('Nach Umsetzung', insertedCPPPs[0].EUR_CRM_CPPP_Payment_Term__c);
		System.assertEquals(Date.newInstance(Date.today().year(), 5, 1), insertedCPPPs[0].EUR_CRM_Payment_Period_End_Date__c);
	}

	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			RecordTypeId = rtId
			,   EUR_CRM_Postal_Code__c = '112233'
		);
	}

	private static EUR_CRM_Contract__c makeContract(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Payment_Plan__c makeCPplan(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Payment_Plan__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Payment_Plan__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Payment_Plan_Period__c makeCPPperiod(Id cpPlanId, Id caItemId) {
		return new EUR_CRM_Contract_Payment_Plan_Period__c(
			EUR_CRM_Contract_Payment_Plan__c= cpPlanId
			,	EUR_CRM_Contract_Activity_Item__c = caItemId
		);
	}

	private static EUR_CRM_Contract_Activity_Item__c makeCAitem(Id contractId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract_Activity_Item__c(
			EUR_CRM_Contract__c = contractId
		,	RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Mechanic_Type__c makeMechanicType(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Mechanic_Type__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Brand__c makeBrand(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Brand__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Brand__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract_Product_Item__c makeCPitem(Id caItemId) {
		return new EUR_CRM_Contract_Product_Item__c(
			EUR_CRM_Contract_Activity_Item__c = caItemId
		);
	}

	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_Contract_Product_Item__c> selectCPIs() {
		return [
			SELECT Id
			,	EUR_CRM_Brand__c
			,	EUR_CRM_Unit__c
			,	EUR_CRM_Amount__c
			,	EUR_CRM_Quantity__c
			,	EUR_CRM_Volume_lt__c
			FROM EUR_CRM_Contract_Product_Item__c
		];
	}

	private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
		return [
			SELECT Id
			,	EUR_CRM_Amount__c
			,	EUR_CRM_Payment_Term__c
			,	EUR_CRM_Start_Date__c
			,	EUR_CRM_End_Date__c
			FROM EUR_CRM_Contract_Activity_Item__c
		];
	}

	private static List<EUR_CRM_Contract_Payment_Plan_Period__c> selectCPPperiods() {
		return [
			SELECT Id
			,	EUR_CRM_Contract_Payment_Plan__c
			,	EUR_CRM_Contract_Activity_Item__c
			,	EUR_CRM_CPPP_Amount__c
			,	EUR_CRM_Payment_Period_Start_Date__c
			,	EUR_CRM_Payment_Period_End_Date__c
			,	EUR_CRM_CPPP_Payment_Term__c
			FROM EUR_CRM_Contract_Payment_Plan_Period__c
		];
	}
}