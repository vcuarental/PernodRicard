@IsTest(IsParallel = true)
private class EUR_CRM_ContractPaymentPlanPeriodHndlTst {

	private static final String LISTING_MT_EXT_ID = 'EUR_DE_Listing';
	private static final String HOUSE_POURING_MT_EXT_ID = 'EUR_DE_House_Pouring';
	private static final String POURING_REFUND_MT_EXT_ID = 'EUR_DE_Pouring_Refund';

	/* ========================================================= */
	/*      After insert tests
	/* ========================================================= */

	@IsTest
	private static void LISTING_MechanicType_NoCreatedCPPP_Test() {
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
		mechType.Name = 'Listing';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = LISTING_MT_EXT_ID;
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.BEGINNING_CONTRACT;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		Test.startTest();
		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;
		Test.stopTest();


		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppPeriods = selectCPPperiods();
		System.assert(cppPeriods.isEmpty());
	}

	@IsTest
	private static void HOUSE_POURING_MechanicType_NoCreatedCPPP_Test() {
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
		mechType.Name = 'House Pouring';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = HOUSE_POURING_MT_EXT_ID;
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.BEGINNING_CONTRACT;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		Test.startTest();
		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;
		Test.stopTest();


		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppPeriods = selectCPPperiods();
		System.assert(cppPeriods.isEmpty());
	}

	@IsTest
	private static void BEGINNING_CONTRACT_PaymentTerm_CAitemWithMT_Test() {
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
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.BEGINNING_CONTRACT;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		Test.startTest();
		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void BEGINNING_CONTRACT_PaymentTerm_CAitemWithoutMT_Test() {
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

//		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
//		mechType.Name = 'Napkins';
//		mechType.EUR_CRM_Has_Start_Date__c = true;
//		mechType.EUR_CRM_Has_End_Date__c = true;
//		mechType.EUR_CRM_Has_Payment_Term__c = true;
//		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.BEGINNING_CONTRACT;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void BEGINNING_CONTRACT_PERIOD_PaymentTerm_CAitemWithMT_Test() {
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
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.BEGINNING_CONTRACT_PERIOD;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void BEGINNING_CONTRACT_PERIOD_PaymentTerm_CAitemWithoutMT_Test() {
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

//		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
//		mechType.Name = 'Napkins';
//		mechType.EUR_CRM_Has_Start_Date__c = true;
//		mechType.EUR_CRM_Has_End_Date__c = true;
//		mechType.EUR_CRM_Has_Payment_Term__c = true;
//		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.BEGINNING_CONTRACT_PERIOD;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
    private static void AFTER_IMPLEMENTATION_PaymentTerm_CAitemWithMT_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'Pouring Refund';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.AFTER_IMPLEMENTATION;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void AFTER_IMPLEMENTATION_PaymentTerm_CAitemWithoutMT_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

//		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
//		mechType.Name = 'Napkins';
//		mechType.EUR_CRM_Has_Start_Date__c = true;
//		mechType.EUR_CRM_Has_End_Date__c = true;
//		mechType.EUR_CRM_Has_Payment_Term__c = true;
//		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.AFTER_IMPLEMENTATION;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void THIRD_PARTY_VENDOR_PaymentTerm_CAitemWithMT_Test() {
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
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.THIRD_PARTY_VENDOR;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void THIRD_PARTY_VENDOR_PaymentTerm_CAitemWithoutMT_Test() {
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

//		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
//		mechType.Name = 'Pouring Refund';
//		mechType.EUR_CRM_Has_Start_Date__c = true;
//		mechType.EUR_CRM_Has_End_Date__c = true;
//		mechType.EUR_CRM_Has_Payment_Term__c = true;
//		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.THIRD_PARTY_VENDOR;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void HALF_YEARLY_PaymentTerm_CAitemWithMT_Test() {
		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 1, 1);
		insert contr;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contr.Id;
		insert cpPlan;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'Pouring Refund';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.HALF_YEARLY;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	@IsTest
	private static void HALF_YEARLY_PaymentTerm_CAitemWithoutMT_Test() {
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

//		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
//		mechType.Name = 'Pouring Refund';
//		mechType.EUR_CRM_Has_Start_Date__c = true;
//		mechType.EUR_CRM_Has_End_Date__c = true;
//		mechType.EUR_CRM_Has_Payment_Term__c = true;
//		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.HALF_YEARLY;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(1).year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Quantity__c= 60.0;
		insert cpItem;

		EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod = makeCPPperiod(cpPlan.Id, caItem.Id);
		insert cppPeriod;
		Test.stopTest();
	}

	/* ========================================================= */
	/*      After Update tests
	/* ========================================================= */
	@IsTest
	private static void PouringRefund_WithOneCPPP_AfterUpdateCPI_UpdateCPPP_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 1, 1);
		insert contr;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'Pouring Refund';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.AFTER_IMPLEMENTATION;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
		cpItem.RecordTypeId = rtId;
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Volume_lt__c = 60.0;
		insert cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppps = selectCPPperiods();
		System.assert( ! cppps.isEmpty());
		System.debug('\n cppps.size() => ' + cppps.size() + '\n');
		System.debug('\n cppps => ' + JSON.serializePretty(cppps) + '\n');
		System.assertEquals(1, cppps.size());
		System.assertEquals(3000, cppps[0].EUR_CRM_CPPP_Amount__c);

		cpItem.EUR_CRM_Amount__c = 60;
		cpItem.EUR_CRM_Volume_lt__c = 70;
		update cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsUpdated = selectCPPperiods();
		System.assert( ! cpppsUpdated.isEmpty());
		System.debug('\n cppps.size() => ' + cpppsUpdated.size() + '\n');
		System.debug('\n cppps => ' + JSON.serializePretty(cpppsUpdated) + '\n');
		System.assertEquals(1, cpppsUpdated.size());
		System.assertEquals(4200, cpppsUpdated[0].EUR_CRM_CPPP_Amount__c);

		Test.stopTest();
	}

	@IsTest
	private static void NotPouringRefund_WithOneCPPP_AfterUpdateCPI_UpdateCPPP_NegativeTest() {
		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 1, 1);
		insert contr;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'Pouring Refund';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = 'EUR_DE_WKZ_Fix_Amount';
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.AFTER_IMPLEMENTATION;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().year(), 5, 1);
		insert caItem;

		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
		cpItem.RecordTypeId = rtId;
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Volume_lt__c = 60.0;
		insert cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppps = selectCPPperiods();
		System.assert( ! cppps.isEmpty());
		System.debug('\n cppps.size() => ' + cppps.size() + '\n');
		System.debug('\n cppps => ' + JSON.serializePretty(cppps) + '\n');
		System.assertEquals(1, cppps.size());
		System.assertEquals(5000, cppps[0].EUR_CRM_CPPP_Amount__c);

		cpItem.EUR_CRM_Amount__c = 60;
		cpItem.EUR_CRM_Volume_lt__c = 70;
		update cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsUpdated = selectCPPperiods();
		System.assert( ! cpppsUpdated.isEmpty());
		System.debug('\n cppps.size() => ' + cpppsUpdated.size() + '\n');
		System.debug('\n cppps => ' + JSON.serializePretty(cpppsUpdated) + '\n');
		System.assertEquals(1, cpppsUpdated.size());
		System.assertEquals(5000, cpppsUpdated[0].EUR_CRM_CPPP_Amount__c);

		Test.stopTest();
	}

	@IsTest
	private static void PouringRefund_WithSeveralCPPP_AfterUpdateCPI_UpdateCPPP_PositiveTest() {
		EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
		insert acc;

		EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
		contr.EUR_CRM_Account__c = acc.Id;
		contr.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 1, 1);
		contr.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 1, 1);
		insert contr;

		EUR_CRM_Mechanic_Type__c mechType = makeMechanicType('EUR_DE_Mechanic_Type');
		mechType.Name = 'Pouring Refund';
		mechType.EUR_CRM_Has_Start_Date__c = true;
		mechType.EUR_CRM_Has_End_Date__c = true;
		mechType.EUR_CRM_Has_Payment_Term__c = true;
		mechType.EUR_CRM_External_ID__c = POURING_REFUND_MT_EXT_ID;
		insert mechType;

		Test.startTest();
		EUR_CRM_Contract_Activity_Item__c caItem = makeCAitem(contr.Id);
		caItem.EUR_CRM_Mechanic_Type__c = mechType.Id;
		caItem.EUR_CRM_Amount__c = 5000;
		caItem.EUR_CRM_Payment_Term__c = EUR_CRM_ContractPaymentPlanPeriodHandler.AFTER_IMPLEMENTATION;
		caItem.EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), 2, 1);
		caItem.EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(2).year(), 5, 1);
		insert caItem;


		EUR_CRM_Brand__c brand = makeBrand('EUR_DE_Brand');
		brand.Name = 'Test brand name';
		insert brand;

		EUR_CRM_Contract_Product_Item__c cpItem = makeCPitem(caItem.Id);
		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
		cpItem.RecordTypeId = rtId;
		cpItem.EUR_CRM_Brand__c = brand.Id;
		cpItem.EUR_CRM_Description__c= 'CPitem description';
		cpItem.EUR_CRM_Unit__c= 'Liter';
		cpItem.EUR_CRM_Amount__c= 50.0;
		cpItem.EUR_CRM_Volume_lt__c = 60.0;
		insert cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppps = selectCPPperiods();
		System.assert( ! cppps.isEmpty());
		System.debug('\n cppps.size() => ' + cppps.size() + '\n');
		System.debug('\n cppps => ' + JSON.serializePretty(cppps) + '\n');
		System.assertEquals(3, cppps.size());

		System.assertEquals(1300, cppps[0].EUR_CRM_CPPP_Amount__c);
		System.assertEquals(1350, cppps[1].EUR_CRM_CPPP_Amount__c);
		System.assertEquals(350, cppps[2].EUR_CRM_CPPP_Amount__c);

		cpItem.EUR_CRM_Amount__c = 60;
		cpItem.EUR_CRM_Volume_lt__c = 70;
		update cpItem;

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsUpdated = selectCPPperiods();
		System.assert( ! cpppsUpdated.isEmpty());
		System.debug('\n cppps.size() => ' + cpppsUpdated.size() + '\n');
		System.debug('\n cppps => ' + JSON.serializePretty(cpppsUpdated) + '\n');
		System.assertEquals(3, cpppsUpdated.size());
		System.assertEquals(1860, cpppsUpdated[0].EUR_CRM_CPPP_Amount__c);
		System.assertEquals(60, cpppsUpdated[0].EUR_CRM_CPPP_Rate__c);
		System.assertEquals(31, cpppsUpdated[0].EUR_CRM_CPPP_Volume__c);
		System.assertEquals(1860, cpppsUpdated[1].EUR_CRM_CPPP_Amount__c);
		System.assertEquals(60, cpppsUpdated[1].EUR_CRM_CPPP_Rate__c);
		System.assertEquals(31, cpppsUpdated[1].EUR_CRM_CPPP_Volume__c);
		System.assertEquals(480, cpppsUpdated[2].EUR_CRM_CPPP_Amount__c);
		System.assertEquals(60, cpppsUpdated[2].EUR_CRM_CPPP_Rate__c);
		System.assertEquals(8, cpppsUpdated[2].EUR_CRM_CPPP_Volume__c);

		Test.stopTest();

		delete caItem;

		undelete caItem;
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

    private static EUR_CRM_Contract_Activity_Item__c makeCAitem(Id contractId) {
        return new EUR_CRM_Contract_Activity_Item__c(
            EUR_CRM_Contract__c = contractId
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
	private static List<EUR_CRM_Contract_Payment_Plan_Period__c> selectCPPperiods() {
		return [
			SELECT Id
				,	EUR_CRM_Contract_Payment_Plan__c
				,	EUR_CRM_Contract_Activity_Item__c
				,	EUR_CRM_CPPP_Amount__c
				,	EUR_CRM_CPPP_Rate__c
				,	EUR_CRM_CPPP_Volume__c
				,	EUR_CRM_Payment_Period_Start_Date__c
				,	EUR_CRM_Payment_Period_End_Date__c
				,	EUR_CRM_CPPP_Payment_Term__c
			FROM EUR_CRM_Contract_Payment_Plan_Period__c
		];
	}
}