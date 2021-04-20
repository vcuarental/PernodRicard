/**
 * Apex Unit Test class for iSPend APP functionality
 *
 * @author afi
 * @copyright PARX
 */
@isTest
private class EUR_ISP_Test_ContractTransactionsService
{
	private static String MECHANIC_TYPE_1 = 'Drinks Menu';
	private static String MECHANIC_TYPE_2 = 'Events';
	private static String EXTERNAL_ID = 'TEST_FY15';
	private static Decimal ALLOCATED_BUDGET = 10000;
	private static Decimal CARRY_FWD = 0;
	private static String TEST_POSTAL = '12345';

	private static EUR_CRM_Contract__c dataInit()
	{
		EUR_CRM_Account__c accountEU = new EUR_CRM_Account__c(
		    Name = 'testname',
		    EUR_CRM_Postal_Code__c = TEST_POSTAL,
		    OwnerId = UserInfo.getUserId()
		);
		insert accountEU;

		//Create Budget
		insert new EUR_CRM_Budget__c(
		    OwnerId = UserInfo.getUserId(),
		    CurrencyIsoCode = 'EUR',
		    EUR_CRM_Fiscal_Year__c = EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD),
		    EUR_CRM_External_ID__c = 'TEST_test_external_Id_' + EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD),
		    EUR_CRM_Allocated_Budget__c = 100000,
		    EUR_CRM_Carry_Forward__c = 0
		);

		//Create Contract
		EUR_CRM_Contract__c contract = EUR_CRM_TestClassUtilityHelper.createContracts(1,
		                               EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE,
		                               accountEU.Id,
		                               EUR_ISP_BudgetService.FY_START_PERIOD.addDays(10),
		                               EUR_ISP_BudgetService.FY_START_PERIOD.addDays(500))[0];
		contract.EUR_CRM_Contract_Approved_Date__c = null;
		return contract;
	}

	private static EUR_CRM_Contract__c dataInit(Id adminId)
	{
		EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1',
		                           EUR_CRM_DE_TestClassUtilityHelper.regionalUser.Id,
		                           EUR_CRM_DE_TestClassUtilityHelper.DE_REGION_RECORD_TYPE);
		EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1',
		                                 EUR_CRM_DE_TestClassUtilityHelper.salesRepUser.Id,
		                                 region.Id,
		                                 EUR_CRM_DE_TestClassUtilityHelper.DE_TERRITORY_RECORD_TYPE);
		EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap',
		        TEST_POSTAL,
		        territory.Id,
		        EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
		EUR_CRM_Account__c accountEU = new EUR_CRM_Account__c(
		    Name = 'testname',
		    OwnerId = EUR_CRM_DE_TestClassUtilityHelper.regionalUser.Id,
		    EUR_CRM_Postal_Code__c = TEST_POSTAL,
		    RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', EUR_CRM_DE_TestClassUtilityHelper.DE_EUACCOUNT_RECORD_TYPE)
		);
		insert accountEU;
		// create budget
		//insert new List<EUR_CRM_Budget__c> { new EUR_CRM_Budget__c(
		//	    OwnerId = EUR_CRM_DE_TestClassUtilityHelper.regionalUser.Id,
		//	    CurrencyIsoCode = 'EUR',
		//	    EUR_CRM_Fiscal_Year__c = EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD),
		//	    EUR_CRM_External_ID__c = 'TEST_test_external_Id_' + EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD),
		//	    EUR_CRM_Allocated_Budget__c = 100000,
		//	    EUR_CRM_Carry_Forward__c = 0
		//	),
		//	new EUR_CRM_Budget__c(
		//	    OwnerId = adminId,
		//	    CurrencyIsoCode = 'EUR',
		//	    EUR_CRM_Fiscal_Year__c = EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD),
		//	    EUR_CRM_External_ID__c = 'TEST_external_Id_' + EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD),
		//	    EUR_CRM_Allocated_Budget__c = 100000,
		//	    EUR_CRM_Carry_Forward__c = 0
		//	)
		//};

		//Create Contract
		EUR_CRM_Contract__c contract = EUR_CRM_TestClassUtilityHelper.createContracts(1,
		                               EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE,
		                               accountEU.Id,
		                               EUR_ISP_BudgetService.FY_START_PERIOD.addDays(10),
		                               EUR_ISP_BudgetService.FY_START_PERIOD.addDays(500))[0];
		contract.EUR_CRM_Contract_Approved_Date__c = null;
		return contract;
	}

	@isTest static void testContractTransactionsOnInsertEmptyContract()
	{
		EUR_CRM_Contract__c contract = dataInit();
		Test.startTest();
		insert contract;
		Test.stopTest();
	}

//	@isTest static void testOwnerChange()
//	{
//		Id adminId = UserInfo.getUserId();
//		EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
//		System.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser)
//		{
//			EUR_CRM_Contract__c contract = dataInit(adminId);
//			//insert contract;
//			Test.startTest();
//			EUR_CRM_Account__c accountEU2 = [SELECT Id, OwnerId FROM EUR_CRM_Account__c WHERE Name = 'testname'];
//			accountEU2.OwnerId = adminId;
//			update accountEU2;
//		}
//		Test.stopTest();
//	}

	@isTest static void testContractReassign()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;
		EUR_CRM_Account__c accountEU2 = [SELECT Id, OwnerId FROM EUR_CRM_Account__c WHERE Name = 'testname'];

		Test.startTest();
		EUR_ISP_AccountEUTriggerHandler.filterContractsForOwnerUpdate(new List<Id> {accountEU2.Id});
		Test.stopTest();
	}
	@isTest static void testContractTransactionsOnCreateActivities()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_1)[0];
		mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType1.EUR_CRM_Has_Lump_Sum__c = false;
		mechType1.EUR_CRM_Has_Per_BQ__c = true;
		mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
		mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
		insert mechType1;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_2)[0];
		mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType2.EUR_CRM_Has_Lump_Sum__c = true;
		mechType2.EUR_CRM_Has_Per_BQ__c = true;
		mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
		mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
		insert mechType2;

		Test.startTest();
		//Create Contract Activity1
		EUR_CRM_Contract_Activity_Item__c contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
		contractActivity1.EUR_CRM_Amount__c = 100;
		//Create Contract Activity 2
		EUR_CRM_Contract_Activity_Item__c contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
		contractActivity2.EUR_CRM_Amount__c = 200;
		contractActivity2.EUR_CRM_Name__c = 'Test';

		insert new List<EUR_CRM_Contract_Activity_Item__c> {contractActivity1, contractActivity2};
		Test.stopTest();
	}

	@isTest static void testApprovedContractTransactionsOnCancel()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		Integer draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertNotEquals(0,draftTransactionSize);

		Test.startTest();
		contract.EUR_CRM_Contract_Approved_Date__c = Date.today().addDays(10);
		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_APPROVED;
		contract.EUR_CRM_Total_Pro_Rated_Amount__c = 10;
		update contract;

		Integer transactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c	WHERE EUR_CRM_Transaction_Category__c = 'Contract Transaction'].size();
		System.assertNotEquals(0,transactionSize);

		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_CANCELLED;
		update contract;
		Test.stopTest();

		Integer refundTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c	WHERE EUR_CRM_Transaction_Category__c = 'Contract Refund'].size();
		System.assertEquals(transactionSize,refundTransactionSize);
	}

	@isTest static void testActivatedContractTransactionsOnCancel()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		Integer draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertNotEquals(0,draftTransactionSize);

		Test.startTest();
		contract.EUR_CRM_Contract_Approved_Date__c = Date.today().addDays(10);
		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_ACTIVATED;
		contract.EUR_CRM_Total_Pro_Rated_Amount__c = 10;
		update contract;

		Integer transactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c	WHERE EUR_CRM_Transaction_Category__c = 'Contract Transaction'].size();
		System.assertNotEquals(0,transactionSize);

		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_CANCELLED;
		update contract;
		Test.stopTest();

		Integer refundTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c	WHERE EUR_CRM_Transaction_Category__c = 'Contract Refund'].size();
		System.assertEquals(transactionSize,refundTransactionSize);
	}

	@isTest static void testDraftContractTransactionsOnCancel()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		Integer draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertNotEquals(0,draftTransactionSize);

		Test.startTest();

		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_CANCELLED;
		update contract;
		Test.stopTest();

		draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertEquals(0, draftTransactionSize);
	}

	@isTest static void testDraftContractTransactionsOnReject()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		Integer draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertNotEquals(0,draftTransactionSize);

		Test.startTest();

		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_REJECTED;
		update contract;
		Test.stopTest();

		draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertNotEquals(0, draftTransactionSize);
	}

	@isTest static void testDeleteWrongTransaction()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		List<EUR_CRM_Budget_Transaction__c> draftTransactions = [
				SELECT Id,
						EUR_CRM_Budget_Header__c,
						EUR_CRM_Transaction_Category__c,
						RecordTypeId,
						EUR_CRM_Contract__c,
						EUR_CRM_Amount__c,
						EUR_CRM_Transaction_Type__c,
						EUR_CRM_Description__c,
						EUR_CRM_Transfer_From_Budget_Header__c,
						EUR_CRM_Transfer_From__c,
						EUR_CRM_Transfer_To__c
				FROM EUR_CRM_Budget_Transaction__c
				WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'];
		System.assertNotEquals(0,draftTransactions.size());

		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_CANCELLED;
		update contract;

		Integer draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertEquals(0, draftTransactionSize);

		Test.startTest();
		draftTransactions[0].Id = null;
		insert draftTransactions[0];
		Test.stopTest();

		draftTransactionSize = [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction'].size();
		System.assertEquals(0, draftTransactionSize);
	}

//	@isTest static void testContractTransactionsOnCancell2()
//	{
//		EUR_CRM_Contract__c contract = dataInit();
//		insert contract;
//
//		Test.startTest();
//		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_CANCELLED;
//		update contract;
//		Test.stopTest();
//	}

	@isTest static void testContractTransactionsOnActivityUpdate()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_1)[0];
		mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType1.EUR_CRM_Has_Lump_Sum__c = false;
		mechType1.EUR_CRM_Has_Per_BQ__c = true;
		mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
		mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
		insert mechType1;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_2)[0];
		mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType2.EUR_CRM_Has_Lump_Sum__c = true;
		mechType2.EUR_CRM_Has_Per_BQ__c = true;
		mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
		mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
		insert mechType2;

		//Create Contract Activity1
		EUR_CRM_Contract_Activity_Item__c contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
		contractActivity1.EUR_CRM_Amount__c = 100;
		//Create Contract Activity 2
		EUR_CRM_Contract_Activity_Item__c contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
		contractActivity2.EUR_CRM_Amount__c = 200;
		contractActivity2.EUR_CRM_Name__c = 'Test';
		Test.startTest();
		insert new List<EUR_CRM_Contract_Activity_Item__c> {contractActivity1, contractActivity2};

		//update Contract Activity1
		contractActivity1.EUR_CRM_Start_Date__c = Date.today().addDays(-10);
		update contractActivity1;
		Test.stopTest();
	}
	
	@IsTest
	static void createActivatedTransactions_Test() {
		EUR_CRM_Contract__c contract = dataInit();
		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_ACTIVATED;
		Test.startTest();
		insert contract;

		System.assertEquals(true, [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction' LIMIT 1].isEmpty());
		System.assertEquals(false, [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Contract Transaction' LIMIT 1].isEmpty());

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_1)[0];
		mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType1.EUR_CRM_Has_Lump_Sum__c = false;
		mechType1.EUR_CRM_Has_Per_BQ__c = true;
		mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
		mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
		insert mechType1;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_2)[0];
		mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType2.EUR_CRM_Has_Lump_Sum__c = true;
		mechType2.EUR_CRM_Has_Per_BQ__c = true;
		mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
		mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
		insert mechType2;

		//Create Contract Activity1
		EUR_CRM_Contract_Activity_Item__c contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
		contractActivity1.EUR_CRM_Amount__c = 100;
		//Create Contract Activity 2
		EUR_CRM_Contract_Activity_Item__c contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
		contractActivity2.EUR_CRM_Amount__c = 200;
		contractActivity2.EUR_CRM_Name__c = 'Test';

		insert new List<EUR_CRM_Contract_Activity_Item__c> {contractActivity1, contractActivity2};
		Test.stopTest();

		System.assertEquals(true, [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction' LIMIT 1].isEmpty());
		System.assertEquals(false, [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Contract Transaction' LIMIT 1].isEmpty());

		System.assertEquals(true, [SELECT Id, EUR_CRM_Amount__c FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Contract Transaction' LIMIT 1].EUR_CRM_Amount__c > 0);
	}

	@isTest static void testOnActivationWithDateChanging()
	{
		EUR_CRM_Contract__c contract = dataInit();
		insert contract;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType1 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_1)[0];
		mechType1.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType1.EUR_CRM_Has_Lump_Sum__c = false;
		mechType1.EUR_CRM_Has_Per_BQ__c = true;
		mechType1.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType1.EUR_CRM_Is_Pro_Rated_by_Month__c = true;
		mechType1.EUR_CRM_Has_Multiple_Activity_Item__c = false;
		insert mechType1;

		//Create Mechanic Type
		EUR_CRM_Mechanic_Type__c mechType2 = EUR_CRM_TestClassUtilityHelper.createMechType(1, EUR_CRM_DE_TestClassUtilityHelper.DE_MECHANIC_TYPE_RECORD_TYPE, MECHANIC_TYPE_2)[0];
		mechType2.EUR_CRM_Grouping_Name__c = 'Germany';
		mechType2.EUR_CRM_Has_Lump_Sum__c = true;
		mechType2.EUR_CRM_Has_Per_BQ__c = true;
		mechType2.EUR_CRM_Lump_Sum_Or_Per_BQ__c  = false;
		mechType2.EUR_CRM_Is_Pro_Rated_by_Month__c = false;
		mechType2.EUR_CRM_Has_Multiple_Activity_Item__c = true;
		insert mechType2;

		//Create Contract Activity1
		EUR_CRM_Contract_Activity_Item__c contractActivity1 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType1.Id);
		contractActivity1.EUR_CRM_Amount__c = 100;
		//Create Contract Activity 2
		EUR_CRM_Contract_Activity_Item__c contractActivity2 = EUR_CRM_DE_TestClassUtilityHelper.createContractActivityItem(null, contract.Id, mechType2.Id);
		contractActivity2.EUR_CRM_Amount__c = 200;
		contractActivity2.EUR_CRM_Name__c = 'Test';
		Test.startTest();
		insert new List<EUR_CRM_Contract_Activity_Item__c> {contractActivity1, contractActivity2};

		contract.EUR_CRM_Status__c = EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_ACTIVATED;
		contract.EUR_CRM_Start_Date__c = EUR_ISP_BudgetService.FY_START_PERIOD.addDays(11);
		contract.EUR_CRM_End_Date__c = EUR_ISP_BudgetService.FY_START_PERIOD.addDays(501);
		update contract;
		Test.stopTest();

		System.assertEquals(true, [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Draft Contract Transaction' LIMIT 1].isEmpty());
		System.assertEquals(false, [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE EUR_CRM_Transaction_Category__c = 'Contract Transaction' LIMIT 1].isEmpty());
	}

}