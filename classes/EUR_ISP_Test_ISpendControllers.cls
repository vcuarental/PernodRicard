/**
 * Apex Unit Test class for iSPend APP functionality
 *
 * @author afi
 * @copyright PARX
 */
@isTest
private class EUR_ISP_Test_ISpendControllers
{
	public static final String CURRENCY_CODE = 'EUR';

	@testSetup static void init()
	{
		insert new EUR_ISP_SystemSettings__c(
		    EUR_ISP_Type__c = 'Tolerance',
		    EUR_ISP_Country_Code__c = EUR_ISP_Utils.COUNTRY_CODE_DE,
		    EUR_ISP_Value_SFDC__c = '1000'
		);
	}

//	@isTest static void ContractPushServiceTest()
//	{
//		String rtIdKeyDe = EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME + EUR_ISP_Utils.DE_CONTRACT_RT_NAME;
//		Id contractIdNotDE = null;
//		Map<String, Id> rtMap = EUR_ISP_Utils.getRecordTypesMap();
//		for (String rtIdKey : rtMap.keySet())
//		{
//			if (rtIdKey != rtIdKeyDe && rtIdKey.startsWithIgnoreCase(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME))
//			{
//				contractIdNotDE = rtMap.get(rtIdKey);
//				break;
//			}
//		}
//
//		List<EUR_CRM_Contract__c> contracts = EUR_ISP_Test_ISpendControllers.generateContracts(5);
//		contracts.get(0).RecordTypeId = contractIdNotDE;
//		contracts.get(0).EUR_CRM_Status__c = EUR_ISP_ContractPushService.CONTRACT_STATUS_ACTIVATED;
//		EUR_ISP_ContractPushService.isServiceActive = false;
//		update contracts;
//
//		Test.startTest();
//		System.assertEquals(0, [SELECT COUNT() FROM EUR_ISP_Spend__c]);
//		EUR_ISP_ContractPushService.isServiceActive = true;
//		EUR_ISP_ContractPushService.pushContractData(new Set<Id> {contracts.get(0).Id});
//
//		System.assertEquals(1, [SELECT COUNT() FROM EUR_ISP_Spend__c]);
//		System.assertEquals(2, [SELECT COUNT() FROM EUR_ISP_Spend_Activity__c]);
//		System.assertEquals(4, [SELECT COUNT() FROM EUR_ISP_Spend_Item__c]);
//		System.assertEquals(2, [SELECT COUNT() FROM EUR_ISP_Error_Log__c]);
//
//		Set<Id> contractIds = new Map<Id, EUR_CRM_Contract__c>(contracts).keySet();
//		List<Id> contractIdslist = new List<Id>();
//		contractIdslist.addAll(contractIds);
//		EUR_ISP_ContractPushBatch.startBatch(contractIdslist);
//		Test.stopTest();
//	}

	@isTest static void ContractPushServiceDETest()
	{
		List<EUR_CRM_Contract__c> contracts = EUR_ISP_Test_ISpendControllers.generateContracts(1);
		Test.startTest();
		System.assertEquals(0, [SELECT COUNT() FROM EUR_ISP_Spend__c]);

		contracts.get(0).EUR_CRM_Status__c = EUR_ISP_ContractPushService.CONTRACT_STATUS_ACTIVATED;
		update contracts;
		System.assertEquals(1, [SELECT COUNT() FROM EUR_ISP_Spend__c]);
		System.assertEquals(4, [SELECT COUNT() FROM EUR_ISP_Spend_Activity__c]);
		System.assertEquals(8, [SELECT COUNT() FROM EUR_ISP_Spend_Item__c]);
		System.assertEquals(1, [SELECT COUNT() FROM EUR_ISP_Error_Log__c]);
		Test.stopTest();
	}

	@isTest static void ContractHistoryPDFControllerTest()
	{
		List<EUR_CRM_Contract__c> contracts = EUR_ISP_Test_ISpendControllers.generateContracts(5);
		Test.startTest();
		System.assertEquals(0, [SELECT COUNT() FROM EUR_ISP_Spend__c]);

		contracts.get(0).EUR_CRM_Status__c = EUR_ISP_ContractPushService.CONTRACT_STATUS_ACTIVATED;
		update contracts;

		List<EUR_ISP_Spend_Activity__c> activiites = [SELECT Id, EUR_ISP_Activity_Amount__c FROM EUR_ISP_Spend_Activity__c WHERE EUR_ISP_Spend__r.EUR_ISP_Contract__c = : contracts.get(0).Id];
		for (EUR_ISP_Spend_Activity__c act : activiites)
		{
			act.EUR_ISP_Activity_Amount__c = act.EUR_ISP_Activity_Amount__c != null ? act.EUR_ISP_Activity_Amount__c + 100 : 100;
		}
		update activiites;

		PageReference thePdfPage = new PageReference('/apex/EUR_ISP_ContractHistoryPDF');
		thePdfPage.getParameters().put(EUR_ISP_ContractHistoryPDFController.CONTRACT_ID_PARAM_NAME, contracts.get(0).Id);
		Test.setCurrentPage(thePdfPage);
		EUR_ISP_ContractHistoryPDFController ctrl = new EUR_ISP_ContractHistoryPDFController();
		ctrl.initAction();

		System.assertNotEquals(null, ctrl.theContract);
		System.assertEquals(false, ctrl.refundDataMap.isEmpty());
		System.assertNotEquals(null, ctrl.refundTotal);
		System.assertEquals(false, ctrl.marketingData.isEmpty());
		System.assertNotEquals(null, ctrl.marketingTotal);
		EUR_ISP_ContractPushBatch.startBatch();
		Test.stopTest();
	}

//	@isTest static void ContractPushBatchTest()
//	{
//		List<EUR_CRM_Contract__c> contracts = EUR_ISP_Test_ISpendControllers.generateContracts(10);
//		for (EUR_CRM_Contract__c contract : contracts)
//		{
//			contract.EUR_CRM_Status__c = EUR_ISP_ContractPushService.CONTRACT_STATUS_ACTIVATED;
//		}
//		EUR_ISP_ContractPushService.isServiceActive = false;
//		update contracts;
//
//		Test.startTest();
//		System.assertEquals(0, [SELECT COUNT() FROM EUR_ISP_Spend__c]);
//		EUR_ISP_ContractPushService.isServiceActive = true;
//
//		EUR_ISP_ContractPushBatch theBatchJob = new EUR_ISP_ContractPushBatch();
//		theBatchJob.runAll = true;
//		Database.executeBatch(new EUR_ISP_ContractPushBatch(), 200);
//		Test.stopTest();
//
//		//System.assertEquals(10, [SELECT COUNT() FROM EUR_ISP_Spend__c]);
//		//System.assertEquals(20, [SELECT COUNT() FROM EUR_ISP_Spend_Activity__c]);
//		//System.assertEquals(40, [SELECT COUNT() FROM EUR_ISP_Spend_Item__c]);
//		//System.assertEquals(20, [SELECT COUNT() FROM EUR_ISP_Error_Log__c]);
//	}

	@isTest static void BudgetServiceTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		Date currentFYStart = EUR_ISP_BudgetService.getCurrentFiscalYear();
		currentFYStart = EUR_ISP_BudgetService.FY_START_PERIOD;
		insert EUR_ISP_Test_ISpendControllers.generateBudgetRecord(EUR_ISP_BudgetService.formatFiscalYear(currentFYStart));

		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;
		// current FY
		EUR_ISP_Spend__c theSpend1 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend1.EUR_ISP_Start_Date__c = currentFYStart.addDays(-90);
		theSpend1.EUR_ISP_End_Date__c = currentFYStart.addDays(-10);
		// 2 FYs
		EUR_ISP_Spend__c theSpend2 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend2.EUR_ISP_Start_Date__c = currentFYStart.addDays(-30);
		theSpend2.EUR_ISP_End_Date__c = currentFYStart.addDays(30);
		// next FY
		EUR_ISP_Spend__c theSpend3 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend1.EUR_ISP_Start_Date__c = currentFYStart.addDays(10);
		theSpend1.EUR_ISP_End_Date__c = currentFYStart.addDays(90);
		insert new List<EUR_ISP_Spend__c> {theSpend1, theSpend2, theSpend3};

		EUR_ISP_Spend_Activity_Type__c theType1 = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType1');
		theType1.EUR_ISP_Budget_Phasing__c = EUR_ISP_SpendTransactionsService.PRORATA_PHASE;
		EUR_ISP_Spend_Activity_Type__c theType2 = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType2');
		theType2.EUR_ISP_Budget_Phasing__c = EUR_ISP_SpendTransactionsService.START_DATE_PHASE;
		EUR_ISP_Spend_Activity_Type__c theType3 = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType3');
		theType3.EUR_ISP_Budget_Phasing__c = EUR_ISP_SpendTransactionsService.END_DATE_PHASE;
		EUR_ISP_Spend_Activity_Type__c theType4 = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType4');
		theType4.EUR_ISP_Budget_Phasing__c = EUR_ISP_SpendTransactionsService.NO_DEDUCTION_PHASE;
		insert new List<EUR_ISP_Spend_Activity_Type__c> {theType1, theType2, theType3, theType4};

		// 1 transactions
		EUR_ISP_Spend_Activity__c theActivity1 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType1.Id, recordTypesSFAContract);
		//theActivity1.EUR_ISP_Status__c = EUR_ISP_Utils.PLANNED_STATUS;
		//theActivity1.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		theActivity1.EUR_ISP_Activity_Amount__c = 100;
		// 1 transaction
		EUR_ISP_Spend_Activity__c theActivity2 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType2.Id, recordTypesSFAContract);
		theActivity2.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		theActivity2.EUR_ISP_Activity_Amount__c = 100;
		// 1 transaction
		EUR_ISP_Spend_Activity__c theActivity3 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType3.Id, recordTypesSFAContract);
		//theActivity3.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		theActivity3.EUR_ISP_Activity_Amount__c = 100;
		// 0 amount => no transaction
		EUR_ISP_Spend_Activity__c theActivity4 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType1.Id, recordTypesSFAContract);
		// 1 transaction
		EUR_ISP_Spend_Activity__c theActivity5 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend2.Id, theType2.Id, recordTypesSFAContract);
		theActivity5.EUR_ISP_Activity_Amount__c = 100;
		// budget phasing => no transaction
		EUR_ISP_Spend_Activity__c theActivity6 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend2.Id, theType4.Id, recordTypesSFAContract);
		theActivity6.EUR_ISP_Activity_Amount__c = 100;
		// 1 transaction
		EUR_ISP_Spend_Activity__c theActivity7 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend3.Id, theType2.Id, recordTypesSFAContract);
		theActivity7.EUR_ISP_Activity_Amount__c = 100;

		Test.startTest();
		List<EUR_ISP_Spend_Activity__c> activities = new List<EUR_ISP_Spend_Activity__c> {theActivity1, theActivity2, theActivity3, theActivity4, theActivity5, theActivity6, theActivity7};
		insert activities;
		System.assertEquals(6, [SELECT COUNT() FROM EUR_CRM_Budget_Transaction__c]);

		// after Amount update the total number of transactions for each Budget phasing should be multiplied by 2
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			activity.EUR_ISP_Activity_Amount__c = 300;
		}
		// current FY
		activities.get(0).EUR_ISP_Activity_Start_Date__c = theSpend1.EUR_ISP_Start_Date__c.addDays(10);
		activities.get(0).EUR_ISP_Activity_End_Date__c = theSpend1.EUR_ISP_End_Date__c.addDays(-10);
		// both
		activities.get(4).EUR_ISP_Activity_Start_Date__c = theSpend2.EUR_ISP_Start_Date__c.addDays(10);
		activities.get(4).EUR_ISP_Activity_End_Date__c = theSpend2.EUR_ISP_End_Date__c.addDays(-10);
		// next FY
		activities.get(6).EUR_ISP_Activity_Start_Date__c = theSpend3.EUR_ISP_Start_Date__c.addDays(10);
		activities.get(6).EUR_ISP_Activity_End_Date__c = theSpend3.EUR_ISP_End_Date__c.addDays(-10);
		update activities;
		System.assertEquals(8, [SELECT COUNT() FROM EUR_CRM_Budget_Transaction__c]);

		activities.get(0).EUR_ISP_Status__c = EUR_ISP_Utils.CANCELLED_STATUS;
		activities.get(3).EUR_ISP_Status__c = EUR_ISP_Utils.CANCELLED_STATUS;
		update activities;
		System.assertEquals(8, [SELECT COUNT() FROM EUR_CRM_Budget_Transaction__c]);

		delete activities;
		System.assertEquals(8, [SELECT COUNT() FROM EUR_CRM_Budget_Transaction__c]);
		Test.stopTest();
	}

	@isTest static void SpendApprovalServiceTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		String currentFiscalYear = EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD);
		insert EUR_ISP_Test_ISpendControllers.generateBudgetRecord(currentFiscalYear);
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType');
		insert theType;
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;
		EUR_ISP_Spend__c theSpend1 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		EUR_ISP_Spend__c theSpend2 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		List<EUR_ISP_Spend__c> spends = new List<EUR_ISP_Spend__c> {theSpend1, theSpend2};
		insert spends;

		EUR_ISP_Spend_Activity__c theActivity1 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType.Id, recordTypesSFAContract);
		theActivity1.EUR_ISP_Status__c = EUR_ISP_Utils.PLANNED_STATUS;
		theActivity1.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		EUR_ISP_Spend_Activity__c theActivity2 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType.Id, recordTypesSFAContract);
		theActivity2.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		EUR_ISP_Spend_Activity__c theActivity3 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType.Id, recordTypesSFAContract);
		theActivity3.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		EUR_ISP_Spend_Activity__c theActivity4 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend1.Id, theType.Id, recordTypesSFAContract);
		EUR_ISP_Spend_Activity__c theActivity5 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(theSpend2.Id, theType.Id, recordTypesSFAContract);
		insert new List<EUR_ISP_Spend_Activity__c> {theActivity1, theActivity2, theActivity3, theActivity4, theActivity5};

		Test.startTest();
		EUR_ISP_SpendApprovalService.checkForOpenActivities(spends);
		System.assertEquals(EUR_ISP_Utils.PENDING_APPROVAL_STATUS, spends.get(0).EUR_ISP_Approval_Status__c);
		System.assertEquals(EUR_ISP_Utils.APPROVED_APPROVAL_STATUS, spends.get(1).EUR_ISP_Approval_Status__c);

		Map<Id, List<EUR_ISP_Spend_Activity__c>> activitiesMap = EUR_ISP_SpendApprovalService.getSpendActivitiesForApprovalStatusUpdate(spends);
		System.assertEquals(1, activitiesMap.size());
		List<EUR_ISP_Spend_Activity__c> activitiesList = EUR_ISP_SpendApprovalService.getSpendActivitiesForApprovalStatusUpdate(spends.get(0).Id, new Set<String> {EUR_ISP_Utils.APPROVED_APPROVAL_STATUS});
		System.assertEquals(2, activitiesList.size());

		Map<Id, String> recentProcesses = EUR_ISP_SpendApprovalService.getRecentProcessInstanceStatus(spends);
		System.assertEquals(true, recentProcesses.isEmpty());

        theSpend1.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.AWAITING_APPROVAL_STATUS;
		update theSpend1;
        theSpend1.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS;
		update theSpend1;
        Test.stopTest();
	}

	@isTest static void SettlementEditExtTest()
	{
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;

		PageReference thePage = new PageReference('/apex/EUR_ISP_SettlementEdit');
		thePage.getParameters().put('retURL', '/home.jsp');
		thePage.getParameters().put('RecordType', 'test');
		thePage.getParameters().put('ent', 'test2');

		Test.setCurrentPage(thePage);
		EUR_ISP_SettlementEditExtension ctrl = new EUR_ISP_SettlementEditExtension(new ApexPages.StandardController(new EUR_ISP_Settlement__c(
		            EUR_ISP_Account__c = theAccount.Id,
		            EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS,
		            EUR_ISP_Settlement_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS
		        )));
		PageReference createVeiw = ctrl.init();
		System.assertNotEquals(null, createVeiw);
		PageReference settlementView = ctrl.customSave();
		System.assertNotEquals(null, settlementView);

		EUR_ISP_Settlement__c settlement = [SELECT Id, EUR_ISP_Account__c FROM EUR_ISP_Settlement__c LIMIT 1];
		ctrl = new EUR_ISP_SettlementEditExtension(new ApexPages.StandardController(settlement));
		PageReference editView = ctrl.init();
		System.assertNotEquals(null, editView);

		EUR_ISP_CustomAccountLookupController searchCtrl = new EUR_ISP_CustomAccountLookupController();
		System.assertEquals(1, searchCtrl.results.size());

		searchCtrl.searchString = '123';
		searchCtrl.search();
		System.assertEquals(0, searchCtrl.results.size());

		System.assertEquals(null, searchCtrl.getFormTag());
		System.assertEquals(null, searchCtrl.getTextBox());
	}

	@isTest static void SettlementControllerTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		String currentFiscalYear = EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD);
		insert EUR_ISP_Test_ISpendControllers.generateBudgetRecord(currentFiscalYear);
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType');
		insert theType;
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;
		EUR_ISP_Settlement__c settlement = new EUR_ISP_Settlement__c(
		    EUR_ISP_Account__c = theAccount.Id,
		    EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS,
		    EUR_ISP_Settlement_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS
		);
		insert settlement;
		EUR_ISP_Spend__c theSpend1 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend1.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		EUR_ISP_Spend__c theSpend2 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend2.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		List<EUR_ISP_Spend__c> spends = new List<EUR_ISP_Spend__c> {theSpend1, theSpend2};
		insert spends;
		EUR_ISP_Spend_Activity__c theActivity1 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		            spends.get(0).Id,
		            theType.Id,
		            recordTypesSFAContract);
		theActivity1.EUR_ISP_Activity_Amount__c = 150;
		EUR_ISP_Spend_Activity__c theActivity2 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		            spends.get(1).Id,
		            theType.Id,
		            recordTypesSFAContract);
		theActivity2.EUR_ISP_Activity_Amount__c = 200;
		insert new List<EUR_ISP_Spend_Activity__c> {theActivity1, theActivity2};

		// select
		EUR_ISP_Settlement__c theSettlement = EUR_ISP_SettlementController.getById('');
		System.assertEquals(null, theSettlement.Id);
		theSettlement = EUR_ISP_SettlementController.getById(settlement.Id);
		System.assertEquals(settlement.Id, theSettlement.Id);

		EUR_ISP_Spend__c theSpend = EUR_ISP_SettlementController.getSpend(spends.get(0).Id);
		System.assertEquals(theSpend.Id, spends.get(0).Id);

		List<EUR_ISP_Spend_Activity__c> activities = EUR_ISP_SettlementController.getSpendActivities('');
		System.assertEquals(0, activities.size());
		activities = EUR_ISP_SettlementController.getSpendActivities(spends.get(0).Id);
		System.assertEquals(1, activities.size());

		List<EUR_ISP_Settlement_Line__c> lineItems = EUR_ISP_SettlementController.getSettlementLines('');
		System.assertEquals(0, lineItems.size());

		//create line items
		EUR_ISP_Settlement_Line__c lineItem = new EUR_ISP_Settlement_Line__c(
		    EUR_ISP_Amount__c = 100,
		    EUR_ISP_Spend_Activity__c = theActivity1.Id,
		    EUR_ISP_Settlement__c = theSettlement.Id
		);
		lineItems = EUR_ISP_SettlementController.createSettlementLineRecord(lineItem);
		System.assertEquals(1, lineItems.size());
		lineItem = new EUR_ISP_Settlement_Line__c(
		    EUR_ISP_Amount__c = 150 - 100,
		    EUR_ISP_Spend_Activity__c = theActivity1.Id,
		    EUR_ISP_Settlement__c = theSettlement.Id
		);
		lineItems = EUR_ISP_SettlementController.createSettlementLineRecord(lineItem);
		System.assertEquals(2, lineItems.size());

		// Invoice Settlement
		EUR_ISP_Settlement__c theSettlement2 = EUR_ISP_SettlementController.closeSettlementRecord('');
		theSettlement2 = EUR_ISP_SettlementController.closeSettlementRecord(theSettlement.Id);
		System.assertEquals(theSettlement.Id, theSettlement2.Id);
		System.assertEquals(EUR_ISP_Utils.MATCHED_STATUS, theSettlement2.EUR_ISP_Settlement_Status__c);

		Test.startTest();
		// creaet Transaction
		EUR_ISP_SettlementController.createBudgetTransactionRecord('', lineItem.id);
		EUR_ISP_SettlementController.createBudgetTransactionRecord(theActivity2.Id, '');
		EUR_ISP_SettlementController.createBudgetTransactionRecord(theActivity1.Id, '');
		Test.stopTest();

		// delete line items
		lineItems = EUR_ISP_SettlementController.deleteSettlementLineRecord('', theSettlement.Id);
		System.assertEquals(2, lineItems.size());
		lineItems = EUR_ISP_SettlementController.deleteSettlementLineRecord(lineItems.get(0).Id, theSettlement.Id);
		System.assertEquals(1, lineItems.size());

		EUR_ISP_Spend_Item__c spendItem = EUR_ISP_Test_ISpendControllers.generateSpendItem(theActivity1.Id);
		insert spendItem;
		lineItems = EUR_ISP_SettlementController.createSettlementLineRecord( new EUR_ISP_Settlement_Line__c(
		                EUR_ISP_Amount__c = 10,
		                EUR_ISP_Spend_Activity__c = theActivity1.Id,
		                EUR_ISP_Settlement__c = theSettlement.Id,
		                EUR_ISP_Spend_Item__c = spendItem.Id
		            ));
		delete lineItems;
	}

	@isTest static void HomeControllerTest()
	{
		String currentFiscalYear = EUR_ISP_BudgetService.formatFiscalYear(EUR_ISP_BudgetService.FY_START_PERIOD);
		insert EUR_ISP_Test_ISpendControllers.generateBudgetRecord(currentFiscalYear);
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType');
		insert theType;
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;
		EUR_ISP_Vendor__c vendor = EUR_ISP_Test_ISpendControllers.generateVendor('TestVendor');
		insert vendor;
		EUR_ISP_Spend__c theSpend1 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend1.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		EUR_ISP_Spend__c theSpend2 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend2.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		EUR_ISP_Spend__c theSpend3 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend2.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.COMMITTED_STATUS;
		List<EUR_ISP_Spend__c> spends = new List<EUR_ISP_Spend__c> {theSpend1, theSpend2, theSpend3};
		insert spends;
		EUR_ISP_Spend_Activity__c theActivity1 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
					spends.get(0).Id,
					theType.Id,
					recordTypesSFAContract);
		theActivity1.EUR_ISP_Activity_Amount__c = 200000;
		EUR_ISP_Spend_Activity__c theActivity2 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
					spends.get(1).Id,
					theType.Id,
					recordTypesSFAContract);
		theActivity2.EUR_ISP_Activity_Amount__c = 300000;
		EUR_ISP_Spend_Activity__c theActivity3 = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
			spends.get(2).Id,
			theType.Id,
			recordTypesSFAContract);
		theActivity3.EUR_ISP_Status__c = EUR_ISP_Utils.COMMITTED_STATUS;
		theActivity3.EUR_ISP_Activity_Start_Date__c = Date.today().addYears(-2);
		theActivity3.EUR_ISP_Activity_End_Date__c = theActivity3.EUR_ISP_Activity_Start_Date__c.addMonths(5);
		insert new List<EUR_ISP_Spend_Activity__c> {theActivity1, theActivity2, theActivity3};

		theActivity3.EUR_ISP_Activity_Amount__c = 400000;
		update theActivity3;

		List<EUR_CRM_Budget__c> dummyBudgets = [SElECT Id FROM EUR_CRM_Budget__c WHERE EUR_CRM_External_ID__c LIKE 'DUMMY_%'];
		System.assert(!dummyBudgets.isEmpty(), 'There is no dummy budgets');

		Approval.ProcessSubmitRequest processRequest = new Approval.ProcessSubmitRequest();
		processRequest.setComments('Test submit0');
		processRequest.setObjectId(spends.get(0).Id);
		processRequest.setSubmitterId(UserInfo.getUserId());
		Approval.ProcessResult result = Approval.process(processRequest);
		System.assert(result.isSuccess());

		EUR_ISP_HomeController.createBudgetTransactionRecord(theActivity1.Id);
		EUR_ISP_HomeController.createBudgetTransactionRecord('');
		EUR_ISP_HomeController.TableData spendsToApprove = EUR_ISP_HomeController.getItemsToApprove(1);
		System.assertEquals(true, spendsToApprove.data.isEmpty());
		EUR_ISP_HomeController.TableData settlements = EUR_ISP_HomeController.getSettlements(1);
		System.assertEquals(true, settlements.sdata.isEmpty());
		EUR_ISP_HomeController.TableData activitiesToAdjust = EUR_ISP_HomeController.getActivitiesToAdjust(1);
		System.assertNotEquals(null, activitiesToAdjust.sdata.isEmpty());
		EUR_ISP_Spend__c spendRecord = EUR_ISP_HomeController.getSpendForApproval(spends.get(0).Id);
		spendRecord = EUR_ISP_HomeController.getSpendForApproval('');
		System.assertNotEquals(null, spendRecord);
		List<EUR_ISP_SystemSettings__c> settings = EUR_ISP_HomeController.getSystemSettings(EUR_ISP_Utils.COUNTRY_CODE_DE);
		System.assertNotEquals(true, settings.isEmpty());
		EUR_ISP_Utils.AppConfigurationSettings permissions = EUR_ISP_HomeController.getAppConfiguration();
		System.assertNotEquals(true, permissions.objectPermissions.isEmpty());
		User theUser = EUR_ISP_HomeController.getCurrentUserInfo();
		System.assertNotEquals(null, theUser);
		EUR_ISP_HomeController.abortApprovalProcess(spends.get(0).Id, '', 'String comments', EUR_ISP_Utils.RECALL_APPROVAL);
		EUR_ISP_HomeController.ItemToApprove item = new EUR_ISP_HomeController.ItemToApprove();
		EUR_ISP_Spend__c spendItem = item.spend;
		ProcessInstanceWorkitem workItem = item.workItem;
		ProcessInstanceStep step = item.step;
		ProcessInstance pInstance = new ProcessInstance();
		item = new EUR_ISP_HomeController.ItemToApprove(spends.get(0), pInstance);
	}

	@isTest static void SpendTableControllerTest()
	{
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType');
		insert theType;
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount(
		                                    'TestAccount',
		                                    UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;
		EUR_ISP_Vendor__c vendor = EUR_ISP_Test_ISpendControllers.generateVendor('TestVendor');
		insert vendor;
		List<EUR_ISP_Spend__c> spends = new List<EUR_ISP_Spend__c>();
		spends.add(EUR_ISP_Test_ISpendControllers.generateSpend(
		               theAccount.Id,
		               recordTypesSFAContract));
		spends.add(EUR_ISP_Test_ISpendControllers.generateSpend(
		               theAccount.Id,
		               recordTypesSFAContract));
		insert spends;

		EUR_ISP_SpendTableController.SpendTableSearchSettings settings = new EUR_ISP_SpendTableController.SpendTableSearchSettings();
		settings.spendName = '';
		settings.contractName = '';
		settings.startDate = Datetime.now().addDays(-180).format('yyyy-MM-dd');
		settings.endDate = Datetime.now().addDays(360).format('yyyy-MM-dd');
		settings.vendorId = '';
		settings.accountId = theAccount.Id;
		settings.recordTypeId = recordTypesSFAContract.get(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME);
		settings.approvalStatus = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS;
		settings.pageNumber = 1;
		EUR_ISP_SpendTableController.SpendTableData tableData = EUR_ISP_SpendTableController.getISpendsSearch(JSON.serialize(settings));
		System.assertEquals(1, tableData.pageNumber);
		System.assertEquals(2, tableData.totalRows);

		settings.accountId = '';
		settings.vendorId = vendor.Id;
		settings.sortOrder = 'Name ASC';
		tableData = EUR_ISP_SpendTableController.getISpendsSearch(JSON.serialize(settings));
		System.assertEquals(1, tableData.pageNumber);
		System.assertEquals(0, tableData.totalRows);

		List<EUR_ISP_Spend_Activity_Type__c> types = EUR_ISP_SpendTableController.getActivityTypesBySpendRecType('');
		System.assertEquals(true, types.isEmpty());
		types = EUR_ISP_SpendTableController.getActivityTypesBySpendRecType(spends.get(0).Id);
		System.assertEquals(true, types.isEmpty());

		EUR_ISP_Spend_Activity__c theActivity = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		        spends.get(0).Id,
		        theType.Id,
		        recordTypesSFAContract);
		theActivity.EUR_ISP_Vendor__c = vendor.Id;
		insert theActivity;

		List<EUR_ISP_Spend_Activity__c> activities = EUR_ISP_SpendTableController.getSpendActivities(spends.get(0).Id, null);
		System.assertEquals(false, activities.isEmpty());
		activities = EUR_ISP_SpendTableController.getSpendActivities(spends.get(0).Id, vendor.Id);
		System.assertEquals(true, activities.isEmpty());

		EUR_ISP_SpendTableController.getISPendActivitiesByIdAndType(spends.get(0).Id, new List<String>());
		Map<String, List<EUR_ISP_Utils.PicklistValue>> picklists = EUR_ISP_SpendTableController.getPicklistValues();
		System.assertEquals(false, picklists.isEmpty());
	}

	@isTest static void SpendControllerTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType');
		insert theType;
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount(
		                                    'TestAccount',
		                                    UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_Spend__c theSpend = EUR_ISP_Test_ISpendControllers.generateSpend(
		                                theAccount.Id,
		                                recordTypesSFAContract);

		// create
		theSpend = EUR_ISP_SpendController.createSpendRecord(theSpend);
		System.assertNotEquals(null, theSpend.Id);
		// select
		theSpend = EUR_ISP_SpendController.getISpend(theSpend.Id);
		System.assertEquals(null, EUR_ISP_SpendController.getISpend('').Id);
		// update
		theSpend = EUR_ISP_SpendController.updateSpendRecord(theSpend);
		// check for Lock status
		Boolean isLocked = EUR_ISP_SpendController.isRecordLocked('');
		System.assertEquals(false, isLocked);
		isLocked = EUR_ISP_SpendController.isRecordLocked(theSpend.Id);
		System.assertEquals(false, isLocked);
		// approval
		EUR_ISP_SpendApprovalService.ApprovalUpdateResult approvalResults = null;
		approvalResults = EUR_ISP_SpendController.submitSpendForApproval('');
		System.assertEquals(false, approvalResults.isLocked);
		approvalResults = EUR_ISP_SpendController.submitSpendForApproval(theSpend.Id);

		List<EUR_ISP_Spend_Activity__c> activities = new List<EUR_ISP_Spend_Activity__c>();
		activities.add(EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		                   theSpend.Id,
		                   theType.Id,
		                   recordTypesSFAContract));
		activities.add(EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		                   theSpend.Id,
		                   theType.Id,
		                   recordTypesSFAContract));
		activities.get(0).EUR_ISP_Activity_Amount__c = 20000;
		activities.get(1).EUR_ISP_Activity_Amount__c = 10000;
		activities.get(1).EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		insert activities;
		approvalResults = EUR_ISP_SpendController.submitSpendForApproval(theSpend.Id);
		// update
		theSpend = EUR_ISP_SpendController.updateSpendRecord(theSpend);
		// other
		Map<String, List<EUR_ISP_Utils.PicklistValue>> picklists = EUR_ISP_SpendController.getPicklistValues();
		System.assertNotEquals(0, picklists.size());
		EUR_ISP_Spend_Activity_Type__c selectedType = EUR_ISP_SpendController.getActivityTypeById('');
		System.assertEquals(null, selectedType.Id);
		selectedType = EUR_ISP_SpendController.getActivityTypeById(theType.Id);
		System.assertNotEquals(null, selectedType.Id);
		List<EUR_ISP_Spend_Activity__c> spenActivities = EUR_ISP_SpendApprovalService.getSpendActivitiesForApprovalStatusUpdate('', new Set<String>());
		System.assertEquals(true, spenActivities.isEmpty());
		// approval history table
		EUR_ISP_SpendController.TableData tableData = EUR_ISP_SpendController.getApprovalHistory(1, theSpend.Id);
		System.assertEquals(2, tableData.totalRows);
		System.assertEquals(1, tableData.pageNumber);
	}

	@isTest static void SpendActivityControllerTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount(
		                                    'TestAccount',
		                                    UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_Spend__c theSpend = EUR_ISP_Test_ISpendControllers.generateSpend(
		                                theAccount.Id,
		                                recordTypesSFAContract);
		insert theSpend;
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('Pouring Refund');
		insert theType;
		EUR_ISP_Spend_Activity__c theActivity = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		        theSpend.Id,
		        theType.Id,
		        recordTypesSFAContract);
		insert theActivity;

		// select
		EUR_ISP_Spend_Activity__c result = EUR_ISP_SpendActivityController.getById('');
		System.assertEquals(null, result.Id);
		result = EUR_ISP_SpendActivityController.getById(theActivity.Id);
		System.assertNotEquals(null, result.Id);

		List<EUR_ISP_Spend_Activity__c> results = EUR_ISP_SpendActivityController.getBySpendId('');
		System.assertEquals(true, results.isEmpty());
		results = EUR_ISP_SpendActivityController.getBySpendId(theSpend.Id);
		System.assertEquals(false, results.isEmpty());

		Map<String, List<EUR_ISP_Spend_Activity__c>> resultsMap = null;
		resultsMap = EUR_ISP_SpendActivityController.getBySpendIdAndType('', new List<String> {theType.Id});
		System.assertEquals(0, resultsMap.size());
		resultsMap = EUR_ISP_SpendActivityController.getBySpendIdAndType(theSpend.Id, new List<String> {theType.Id});
		System.assertEquals(1, resultsMap.size());

		List<EUR_ISP_Spend_Activity__c> settlements = EUR_ISP_SpendActivityController.getSpendActivitiesForSettlement(theSpend.Id);
		System.assertEquals(1, settlements.size());
		Test.startTest();
		// create
		EUR_ISP_Spend_Activity__c itemToCreate = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		            theSpend.Id,
		            theType.Id,
		            recordTypesSFAContract);
		EUR_ISP_Spend_Activity__c itemToUpdate = EUR_ISP_SpendActivityController.createSpendActivityRecord(itemToCreate);

		List<EUR_ISP_Spend_Item__c> itemsToCreate = new List<EUR_ISP_Spend_Item__c>();
		itemsToCreate.add(EUR_ISP_Test_ISpendControllers.generateSpendItem(itemToUpdate.Id));
		itemsToCreate.add(EUR_ISP_Test_ISpendControllers.generateSpendItem(itemToUpdate.Id));
		insert itemsToCreate;

		// update
		result = EUR_ISP_SpendActivityController.updateSpendActivityRecord(itemToUpdate);
		itemToUpdate.EUR_ISP_Activity_Amount__c = 20000;
		result = EUR_ISP_SpendActivityController.updateSpendActivityRecord(itemToUpdate);
		System.assertEquals(itemToUpdate.EUR_ISP_Activity_Amount__c, result.EUR_ISP_Activity_Amount__c);
		result.EUR_ISP_Status__c = EUR_ISP_Utils.CANCELLED_STATUS;
		result.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		result = EUR_ISP_SpendActivityController.updateSpendActivityRecord(result);
		result = EUR_ISP_SpendActivityController.releaseActivityAmount(result.Id);

		// delete
		EUR_ISP_SpendActivityController.deleteSpendActivity('');
		EUR_ISP_SpendActivityController.deleteSpendActivity(result.Id);
        Test.stopTest();
	}

	@isTest static void SpendItemControllerTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount(
		                                    'TestAccount',
		                                    UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_Spend__c theSpend = EUR_ISP_Test_ISpendControllers.generateSpend(
		                                theAccount.Id,
		                                recordTypesSFAContract);
		insert theSpend;
		EUR_ISP_Spend_Activity_Type__c theType = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType');
		insert theType;
		EUR_ISP_Spend_Activity__c theActivity = EUR_ISP_Test_ISpendControllers.generateSpendActivity(
		        theSpend.Id,
		        theType.Id,
		        recordTypesSFAContract);
		insert theActivity;

		// select
		List<EUR_ISP_Spend_Item__c> results = EUR_ISP_SpendActivityItemController.getSpendActivityItems('');
		System.assertEquals(true, results.isEmpty());

		// create
		List<EUR_ISP_Spend_Item__c> itemsToCreate = new List<EUR_ISP_Spend_Item__c>();
		results = EUR_ISP_SpendActivityItemController.createSpendItems(itemsToCreate);
		System.assertEquals(true, results.isEmpty());

		itemsToCreate.add(EUR_ISP_Test_ISpendControllers.generateSpendItem(theActivity.Id));
		itemsToCreate.add(EUR_ISP_Test_ISpendControllers.generateSpendItem(theActivity.Id));
		itemsToCreate.add(EUR_ISP_Test_ISpendControllers.generateSpendItem(theActivity.Id));
		results = EUR_ISP_SpendActivityItemController.createSpendItems(itemsToCreate);
		System.assertEquals(false, results.isEmpty());

		// update
		List<EUR_ISP_Spend_Item__c> itemsToUpdate = new List<EUR_ISP_Spend_Item__c>();
		results = EUR_ISP_SpendActivityItemController.updateSpendItems(itemsToUpdate);
		System.assertEquals(true, results.isEmpty());

		itemsToUpdate = EUR_ISP_SpendActivityItemController.getSpendActivityItems(theActivity.Id);
		System.assertEquals(false, itemsToUpdate.isEmpty());

		itemsToUpdate.get(0).EUR_ISP_Per_Unit_Amount__c = 6;
		itemsToUpdate.get(0).EUR_ISP_Volume__c = 11;
		itemsToUpdate.get(1).EUR_ISP_Per_Unit_Amount__c = 10;
		itemsToUpdate.get(1).EUR_ISP_Volume__c = 10;
		itemsToUpdate.get(1).EUR_ISP_Lump_Sum_2__c = 100;
		itemsToUpdate.get(1).EUR_ISP_Lump_Sum_1__c = 100;

		results = EUR_ISP_SpendActivityItemController.updateSpendItems(itemsToUpdate);
		System.assertEquals(false, results.isEmpty());

		List<EUR_ISP_Spend_Item__c> results0 = EUR_ISP_SpendActivityItemController.releaseSpendItemAmount(results.get(0).Id);
		System.assertEquals(false, results0.isEmpty());
		List<EUR_ISP_Spend_Item__c> results1 = EUR_ISP_SpendActivityItemController.releaseSpendItemAmount(results.get(1).Id);
		System.assertEquals(false, results1.isEmpty());
		List<EUR_ISP_Spend_Item__c> results2 = EUR_ISP_SpendActivityItemController.releaseSpendItemAmount(results.get(2).Id);
		System.assertEquals(false, results2.isEmpty());

		// other
		Map<String, List<EUR_ISP_Utils.PicklistValue>> picklists = EUR_ISP_SpendActivityItemController.getPicklistValues();
		System.assertEquals(false, picklists.isEmpty());
		EUR_ISP_SpendActivityItemController.getActivityTypeById('');
		EUR_ISP_Spend_Item__c spendItem = EUR_ISP_SpendActivityItemController.getById('');
		spendItem = EUR_ISP_SpendActivityItemController.getById(itemsToUpdate.get(1).Id);

		// delete
		EUR_ISP_SpendActivityItemController.deleteSpendActivityItem('');
		EUR_ISP_SpendActivityItemController.deleteSpendActivityItem(spendItem.Id);
		EUR_ISP_SpendActivityItemController.deleteSpendItems(new List<EUR_ISP_Spend_Item__c> {itemsToUpdate.get(0)});
		System.assertEquals(1, EUR_ISP_SpendActivityItemController.getSpendActivityItems(theActivity.Id).size());
	}

	@isTest static void BudgetsControllerTest()
	{
		EUR_CRM_Budget__c currentBudget = EUR_ISP_BudgetsController.getCurrentBudget();
		System.assertEquals(null, currentBudget.Id);

		String currentFiscalYear = EUR_ISP_BudgetService.formatFiscalYear(Date.today());
		insert EUR_ISP_Test_ISpendControllers.generateBudgetRecord(currentFiscalYear);
		currentBudget = EUR_ISP_BudgetsController.getCurrentBudget();
		System.assertNotEquals(null, currentBudget.Id);
	}

	@isTest static void LookupSObjectControllerTest()
	{
		String sObjectAPIName = 'EUR_CRM_Account__c';
		EUR_ISP_LookupSObjectController.SelectionData result = null;
		List<EUR_ISP_LookupSObjectController.SelectionData> results = null;

		List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
		accounts.add( EUR_ISP_Test_ISpendControllers.generateAccount('Test Account 1', UserInfo.getUserId()) );
		accounts.add( EUR_ISP_Test_ISpendControllers.generateAccount('Unique Account 2', UserInfo.getUserId()) );
		accounts.add( EUR_ISP_Test_ISpendControllers.generateAccount('Account 3', UserInfo.getUserId()) );
		insert accounts;

		insert new EUR_ISP_UserAccount__c(
		    EUR_ISP_User__c = UserInfo.getUserId(),
		    EUR_ISP_Account__c = accounts.get(0).Id
		);

		result = EUR_ISP_LookupSObjectController.getSelectedData('', sObjectAPIName);
		System.assertEquals(null, result);
		result = EUR_ISP_LookupSObjectController.getSelectedData(accounts.get(0).Id, sObjectAPIName);
		System.assertEquals(accounts.get(0).Id, result.id);

		results = EUR_ISP_LookupSObjectController.getInitSelectionData(sObjectAPIName);
		System.assertNotEquals(null, results);
		System.assertEquals(3, results.size());

		results = EUR_ISP_LookupSObjectController.getSelectionData('', sObjectAPIName);
		System.assertEquals(0, results.size());
		results = EUR_ISP_LookupSObjectController.getSelectionData('Unique', sObjectAPIName);
		System.assertNotEquals(1, results.size());

		results = EUR_ISP_LookupSObjectController.getAccounts('Unique');
		System.assertEquals(0, results.size());
		results = EUR_ISP_LookupSObjectController.getAccounts('Test');
		System.assertEquals(1, results.size());

		List<sObject> accountResuls = EUR_ISP_LookupSObjectController.searchAccounts(new Set<Id>(), 'Test', 100);
		System.assertEquals(1, accountResuls.size());

		sObjectAPIName = 'EUR_ISP_Vendor__c';
		EUR_ISP_Vendor__c vendor = EUR_ISP_Test_ISpendControllers.generateVendor('TestVendor');
		insert vendor;
		result = EUR_ISP_LookupSObjectController.getSelectedData(vendor.Id, sObjectAPIName);
		System.assertEquals(vendor.Id, result.Id);

		results = EUR_ISP_LookupSObjectController.getVendors('Test',  '');
		System.assertEquals(true, results.isEmpty());
		results = EUR_ISP_LookupSObjectController.getVendors('Test',  accounts.get(0).Id);
		System.assertEquals(true, results.isEmpty());
		insert new EUR_ISP_AccountVendor__c(
		    EUR_ISP_Vendor__c = vendor.Id,
		    EUR_ISP_Account__c = accounts.get(0).Id,
		    EUR_ISP_Active__c = true
		);
		results = EUR_ISP_LookupSObjectController.getVendors('Test',  accounts.get(0).Id);
		System.assertEquals(false, results.isEmpty());
	}

	@isTest static void BrandsControllerTest()
	{
		Map<String, Id> recordTypesSFAContract = EUR_ISP_Utils.getRecordTypesMap();
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert theAccount;
		EUR_ISP_UserAccount__c userAccount = EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount.Id);
		insert userAccount;

		EUR_ISP_Spend__c theSpend1 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		EUR_ISP_Spend__c theSpend2 = EUR_ISP_Test_ISpendControllers.generateSpend(theAccount.Id, recordTypesSFAContract);
		theSpend2.RecordTypeId = recordTypesSFAContract.get(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME + EUR_ISP_Utils.EUR_ISP_SPEND_COMMERCIAL_RT_NAME);
		insert new List<EUR_ISP_Spend__c> {theSpend1, theSpend2};


		List<EUR_CRM_Brand__c> brands = EUR_ISP_BrandsController.getBrands(theSpend1.Id);
		List<EUR_CRM_Quality__c> brandsQuality = EUR_ISP_BrandsController.getBrandsQuality(theSpend1.Id);
		List<EUR_CRM_Size__c> brandsQualitySize = EUR_ISP_BrandsController.getBrandsQualitySizes(theSpend1.Id);
		List<EUR_CRM_Wine_Spirits__c> brandsFamlity = EUR_ISP_BrandsController.getBrandFamily(theSpend1.Id);
		List<EUR_CRM_SKU__c> brandsSKU = EUR_ISP_BrandsController.getBrandSKU(theSpend1.Id);
		System.assertEquals(true, brands.isEmpty());

		Test.startTest();
		brands = EUR_ISP_BrandsController.getBrands(theSpend2.Id);
		brandsQuality = EUR_ISP_BrandsController.getBrandsQuality(theSpend2.Id);
		brandsQualitySize = EUR_ISP_BrandsController.getBrandsQualitySizes(theSpend2.Id);
		brandsFamlity = EUR_ISP_BrandsController.getBrandFamily(theSpend2.Id);
		brandsSKU = EUR_ISP_BrandsController.getBrandSKU(theSpend2.Id);
		System.assertEquals(true, brands.isEmpty());

		EUR_CRM_Wine_Spirits__c family = new EUR_CRM_Wine_Spirits__c(Name = 'Family1');
		insert family;
		EUR_CRM_Category__c category = new EUR_CRM_Category__c(EUR_CRM_Active__c = true, EUR_CRM_Wine_Spirits__c = family.Id);
		insert category;
		EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c(Name = 'Brand1', EUR_CRM_Active__c = true, EUR_CRM_Is_Competitor__c = false, EUR_CRM_Category__c = category.Id);
		insert brand;
		insert new EUR_ISP_UserBrand__c(EUR_ISP_Brand__c = brand.Id, EUR_ISP_User__c = UserInfo.getUserId());
		EUR_CRM_Quality__c quality = new EUR_CRM_Quality__c(Name = 'Quality1', EUR_CRM_Active__c = true, EUR_CRM_Brand__c = brand.Id);
		insert quality;
		EUR_CRM_Size__c size = new EUR_CRM_Size__c(Name = 'Size1', EUR_CRM_Active__c = true, EUR_CRM_Brand_Quality__c = quality.Id);
		insert size;
		EUR_CRM_SKU__c sku = new EUR_CRM_SKU__c(Name = 'SKU1', EUR_CRM_Active__c = true, EUR_CRM_Brand_Quality_Size__c = size.Id);
		insert sku;
		insert new EUR_ISP_AccountSku__c(EUR_ISP_Active__c = true, EUR_ISP_Account__c = theAccount.Id, EUR_ISP_SKU__c = sku.Id);

		brands = EUR_ISP_BrandsController.getBrands(theSpend1.Id);
		brandsQuality = EUR_ISP_BrandsController.getBrandsQuality(theSpend1.Id);
		brandsQualitySize = EUR_ISP_BrandsController.getBrandsQualitySizes(theSpend1.Id);
		brandsFamlity = EUR_ISP_BrandsController.getBrandFamily(theSpend1.Id);
		brandsSKU = EUR_ISP_BrandsController.getBrandSKU(theSpend1.Id);
		System.assertEquals(false, brands.isEmpty());

		brands = EUR_ISP_BrandsController.getBrands(theSpend2.Id);
		brandsQuality = EUR_ISP_BrandsController.getBrandsQuality(theSpend2.Id);
		brandsQualitySize = EUR_ISP_BrandsController.getBrandsQualitySizes(theSpend2.Id);
		brandsFamlity = EUR_ISP_BrandsController.getBrandFamily(theSpend2.Id);
		brandsSKU = EUR_ISP_BrandsController.getBrandSKU(theSpend2.Id);
		System.assertEquals(false, brands.isEmpty());
		Test.stopTest();
	}

	/**
	 * HLPRs
	 */
	private static List<EUR_CRM_Contract__c> generateContracts(Integer contractNumber)
	{
		EUR_CRM_Account__c theAccount = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		EUR_CRM_Account__c theAccount1 = EUR_ISP_Test_ISpendControllers.generateAccount('TestAccount', UserInfo.getUserId());
		insert new List<EUR_CRM_Account__c> {theAccount, theAccount1};

		insert EUR_ISP_Test_ISpendControllers.genereateUserAccount(theAccount1.Id);
		EUR_ISP_Spend_Activity_Type__c spendType1 = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType1');
		EUR_ISP_Spend_Activity_Type__c spendType2 = EUR_ISP_Test_ISpendControllers.generateSpendType('MyType2');
		insert new List<EUR_ISP_Spend_Activity_Type__c> { spendType1, spendType2 };

		EUR_CRM_Mechanic_Type__c mechanic1 = new EUR_CRM_Mechanic_Type__c(
		    EUR_CRM_External_ID__c = 'DE_MyType1',
		    RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Mechanic_Type__c' + 'EUR_DE_Pouring_RV_Mechanic_Type')
		);
		EUR_CRM_Mechanic_Type__c mechanic2 = new EUR_CRM_Mechanic_Type__c(
		    EUR_CRM_External_ID__c = 'DE_MyType2'
		);
		EUR_CRM_Mechanic_Type__c mechanic3 = new EUR_CRM_Mechanic_Type__c(
		    EUR_CRM_External_ID__c = 'MyType2',
		    RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Mechanic_Type__c' + 'EUR_DE_Pouring_RV_Mechanic_Type')
		);
		insert new List<EUR_CRM_Mechanic_Type__c> {mechanic1, mechanic2, mechanic3};


		final Date theStartDate = EUR_ISP_BudgetService.FY_START_PERIOD;

		List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>();
		for (Integer i = 0; i < contractNumber; i++)
		{
			EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
			    EUR_CRM_Account__c = theAccount.Id,
			    EUR_CRM_Start_Date__c = theStartDate,
			    EUR_CRM_End_Date__c = theStartDate.addDays(600),
			    CurrencyIsoCode = CURRENCY_CODE,
			    EUR_CRM_Status__c = 'test',
			    RecordTypeId = EUR_ISP_Utils.getRecordTypesMap().get(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME + EUR_ISP_Utils.DE_CONTRACT_RT_NAME)
			);
			contracts.add(contract);
		}
		insert contracts;


		Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> contractItemsMap = new Map<Id, List<EUR_CRM_Contract_Activity_Item__c>>();
		List<EUR_CRM_Contract_Activity_Item__c> contractItems = new List<EUR_CRM_Contract_Activity_Item__c>();
		Id caiRTId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Activity_Item').getRecordTypeId();
		for (Integer i = 0; i < contractNumber; i++)
		{
			EUR_CRM_Contract__c contract = contracts.get(i);

			// correct activity item
			EUR_CRM_Contract_Activity_Item__c item1 = EUR_ISP_Test_ISpendControllers.generateContractActivity(contract.Id, mechanic1.Id, i);
			item1.EUR_CRM_Start_Date__c = theStartDate.addDays(60);
			item1.EUR_CRM_End_Date__c = theStartDate.addDays(400);
			item1.RecordTypeId = caiRTId;

			// this item will trigger validation rule ERR
			EUR_CRM_Contract_Activity_Item__c item2 = EUR_ISP_Test_ISpendControllers.generateContractActivity(contract.Id, mechanic1.Id, i + 1);
			item2.EUR_CRM_Start_Date__c = theStartDate.addDays(1);
			item2.EUR_CRM_End_Date__c = theStartDate.addDays(270);
			item2.RecordTypeId = caiRTId;

			EUR_CRM_Contract_Activity_Item__c item3 = EUR_ISP_Test_ISpendControllers.generateContractActivity(contract.Id, mechanic3.Id, i + 2);
			item3.EUR_CRM_Start_Date__c = theStartDate.addDays(90);
			item3.EUR_CRM_End_Date__c = theStartDate.addDays(360);
			item3.RecordTypeId = caiRTId;

			// this item will trigger ERR for the incorrect Spend Type detection
			EUR_CRM_Contract_Activity_Item__c item4 = EUR_ISP_Test_ISpendControllers.generateContractActivity(contract.Id, mechanic2.Id, i + 3);
			item4.EUR_CRM_Start_Date__c = theStartDate.addDays(15);
			item4.EUR_CRM_End_Date__c = theStartDate.addDays(400);
			item4.RecordTypeId = caiRTId;


			List<EUR_CRM_Contract_Activity_Item__c> itemsList = new List<EUR_CRM_Contract_Activity_Item__c> {item1, item2, item3, item4};
			contractItems.addAll(itemsList);
			contractItemsMap.put(contract.Id, itemsList);
		}
		insert contractItems;

		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAIs();
		System.debug('\n cais.size() => ' + cais.size() + '\n');
		System.debug('\n cais => ' + JSON.serializePretty(cais) + '\n');
		List<EUR_CRM_Contract_Payment_Plan__c> cpPlans = new List<EUR_CRM_Contract_Payment_Plan__c>();

//		for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
//			EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
//			cpPlan.EUR_CRM_Contract__c = cai.EUR_CRM_Contract__c;
//			cpPlans.add(cpPlan);
//		}
//		insert cpPlans;
//
//		List<EUR_CRM_Contract_Payment_Plan__c> cpps = selectCPP();
//		List<EUR_CRM_Contract_Payment_Plan_Period__c> cppps = new List<EUR_CRM_Contract_Payment_Plan_Period__c>();
//		for (Integer i = 0; i < cpps.size(); i++) {
//			cppps.add(makeCPPperiod(cpps.get(i).Id, cais.get(i).Id));
//		}
//		insert cppps;

		List<EUR_CRM_Contract_Product_Item__c> contractProducts = new List<EUR_CRM_Contract_Product_Item__c>();
		for (Integer i = 0; i < contractNumber; i++)
		{
			List<EUR_CRM_Contract_Activity_Item__c> itemsList = contractItemsMap.get(contracts.get(i).Id);

			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(0).Id, i) );
			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(0).Id, i + 1) );
			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(0).Id, i + 2) );
			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(1).Id, i + 3) );
			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(1).Id, i + 4) );
			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(2).Id, i + 5) );
			contractProducts.add( EUR_ISP_Test_ISpendControllers.generateContractProduct( itemsList.get(3).Id, i + 6) );
		}
		insert contractProducts;

		EUR_CRM_Contract_Payment_Plan__c cpPlan = makeCPplan('EUR_DE_Contract_Payment_Plan');
		cpPlan.EUR_CRM_Contract__c = contracts[0].Id;
		insert cpPlan;

		EUR_CRM_Contract_Payment_Plan_Period__c cppp = makeCPPperiod(cpPlan.Id);
		cppp.EUR_CRM_Contract_Product_Item__c = contractProducts[0].Id;
		cppp.EUR_CRM_Contract_Activity_Item__c = contractItems[0].Id;
		insert cppp;

		List<EUR_CRM_Contract_Activity_Item__c> caisWithProducts = selectCAIs();
		System.debug('\n caisWithProducts.size() => ' + caisWithProducts.size() + '\n');
		System.debug('\n caisWithProducts => ' + JSON.serializePretty(caisWithProducts) + '\n');
		return contracts;
	}

	private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
		return [
			SELECT Id
				, EUR_CRM_Contract__c
				, EUR_CRM_Mechanic_Type_Name__c
				, EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
				, (
				SELECT Id
					, EUR_CRM_Contract_Payment_Plan__c
				FROM Contract_Payment_Plan_Periods__r
			)
			FROM EUR_CRM_Contract_Activity_Item__c
		];
	}

	private static List<EUR_CRM_Contract_Payment_Plan__c> selectCPP() {
		return [
			SELECT Id
				, EUR_CRM_Contract__c
			FROM EUR_CRM_Contract_Payment_Plan__c
		];
	}

	private static EUR_ISP_Spend__c generateSpend(Id accountId, Map<String, Id> recTypes)
	{
		Date startDate = Date.today();
		return new EUR_ISP_Spend__c(
		           RecordTypeId = recTypes.get(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME),
		           EUR_ISP_Account__c = accountId,
		           EUR_ISP_Start_Date__c = startDate,
		           EUR_ISP_End_Date__c = startDate.addDays(180),
		           EUR_ISP_Status__c = EUR_ISP_Utils.COMMITTED_STATUS,
		           EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS,
		           EUR_ISP_Amount__c = 1500,
		           OwnerId = UserInfo.getUserId()
		       );
	}

	public static EUR_ISP_Spend_Activity_Type__c generateSpendType(String name)
	{
		return new EUR_ISP_Spend_Activity_Type__c(
		           EUR_ISP_Spend_Activity_Type_Name__c = name,
		           EUR_ISP_Spend_Activity_Type_Name_English__c = name,
		           EUR_ISP_Spend_Type__c = 'SFA Contract',
		           EUR_ISP_Country_Code__c = EUR_ISP_Utils.COUNTRY_CODE_DE,
		           EUR_ISP_External_ID__c = 'DE_' + name
		       );
	}

	private static EUR_ISP_Spend_Activity__c generateSpendActivity(Id spendId, Id typeId, Map<String, Id> recTypes)
	{
		return new EUR_ISP_Spend_Activity__c(
		           RecordTypeId = recTypes.get(EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME),
		           EUR_ISP_Spend__c = spendId,
		           EUR_ISP_Spend_Activity_Type__c = typeId,
		           EUR_ISP_Status__c = EUR_ISP_Utils.COMMITTED_STATUS,
		           EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS
		       );
	}

	private static EUR_ISP_Spend_Item__c generateSpendItem(Id activityId)
	{
		return new EUR_ISP_Spend_Item__c(
		           EUR_ISP_Spend_Activity__c = activityId
		       );
	}

	private static EUR_CRM_Account__c generateAccount(String name, Id ownerId)
	{
		return new EUR_CRM_Account__c(
		           Name = name,
		           EUR_CRM_Postal_Code__c = '11111',
		           OwnerId = ownerId
		       );
	}

	private static EUR_ISP_Vendor__c generateVendor(String name)
	{
		return new EUR_ISP_Vendor__c(
		           EUR_ISP_Country_Code__c = EUR_ISP_Utils.COUNTRY_CODE_DE,
		           EUR_ISP_Enabled_For_selection__c = true,
		           EUR_ISP_ERP_ID__c = 'test',
		           EUR_ISP_Vendor_Name__c = name
		       );
	}

	private static EUR_CRM_Budget__c generateBudgetRecord(String fiscalYear)
	{
		return new EUR_CRM_Budget__c(
		           OwnerId = UserInfo.getUserId(),
		           CurrencyIsoCode = CURRENCY_CODE,
		           EUR_CRM_Fiscal_Year__c = fiscalYear,
		           EUR_CRM_External_ID__c = 'TEST_' + UserInfo.getUserEmail() + '_' + fiscalYear,
		           EUR_CRM_Allocated_Budget__c = 0,
		           EUR_CRM_Carry_Forward__c = 0
		       );
	}

	private static EUR_ISP_UserAccount__c genereateUserAccount(Id accountId)
	{
		return new EUR_ISP_UserAccount__c(
		           EUR_ISP_Account__c = accountId,
		           EUR_ISP_User__c = UserInfo.getUserId()
		       );
	}
	/**
	 * pls see @EUR_CRM_ContractPaymentPlanPeriodHandler to understand why the Value in DE
	 */
	private static EUR_CRM_Contract_Activity_Item__c generateContractActivity(Id contractId, Id mechanicId, Integer iNumber)
	{
		return new EUR_CRM_Contract_Activity_Item__c(
		           EUR_CRM_Contract__c = contractId,
		           EUR_CRM_Mechanic_Type__c = mechanicId,
		           EUR_CRM_Amount__c = 100 * (iNumber > 0 ? iNumber : 1),
		           CurrencyIsoCode = CURRENCY_CODE,
		           EUR_CRM_Payment_Term__c = 'Pro rata p.a.' + String.valueOf(iNumber),
		           EUR_CRM_Vendor__c = 'my new vendor' + String.valueOf(iNumber),
		           EUR_CRM_Payment_Term_By_SR__c = 'Nach Umsetzung'
		                   //EUR_CRM_Payment_Term_By_SR__c = 'After implementation'
		       );
	}

	private static EUR_CRM_Contract_Product_Item__c generateContractProduct(Id activityId, Integer iNumber)
	{
		return new EUR_CRM_Contract_Product_Item__c(
		           //RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract_Product_Item__c' + 'EUR_DE_Contract_Product_Item'),
		           EUR_CRM_Contract_Activity_Item__c = activityId,
		           EUR_CRM_Amount__c = 10,
		           EUR_CRM_Quantity__c = 10,
		           EUR_CRM_Unit__c = 'Test' + String.valueOf(iNumber)
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

	private static EUR_CRM_Contract_Payment_Plan_Period__c makeCPPperiod(Id cpPlanId) {
		return new EUR_CRM_Contract_Payment_Plan_Period__c(
			EUR_CRM_Contract_Payment_Plan__c = cpPlanId
		);
	}
}