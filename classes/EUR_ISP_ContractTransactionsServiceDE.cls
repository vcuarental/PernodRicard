/**
 * Service class implements Contract Budget Transaction logic
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_ContractTransactionsServiceDE
{
	public static final Map<String, Id> RECORD_TYPES_MAP = null;

	public static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
	public static final String CONTRACT_STATUS_CANCELLED = 'Cancelled';
	public static final String CONTRACT_STATUS_APPROVED = 'Approved';
	public static final String CONTRACT_STATUS_REJECTED = 'Rejected';

	public static final String CONTRACT_REFUND = 'Contract Refund';
	public static final String DRAFT_TRANSACTION_CATEGORY = 'Draft Contract Transaction';
	public static final String TRANSACTION_CATEGORY = 'Contract Transaction';

	public static final Id DE_CONTRACT_RECORD_TYPE_ID = null;
	static
	{
		if (RECORD_TYPES_MAP == null)
		{
			RECORD_TYPES_MAP = EUR_ISP_Utils.getRecordTypesMap();
			DE_CONTRACT_RECORD_TYPE_ID = RECORD_TYPES_MAP.get(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME + EUR_ISP_Utils.DE_CONTRACT_RT_NAME);
		}
	}

	private static List<EUR_CRM_Budget_Transaction__c> transactionsToUpsert = new List<EUR_CRM_Budget_Transaction__c>();
	private static List<EUR_CRM_Budget_Transaction__c> transactionsToDelete = new List<EUR_CRM_Budget_Transaction__c>();
	private static List<EUR_CRM_Contract__c> contractsToUpdate = new List<EUR_CRM_Contract__c>();

	/**
	 * TODO: territory split logic commented
	 *
	 *  transfer budget transactions to the correct budget when Contract's Owner is changed
	 * incoming MAP: contract to OwnerId
	 */
	//public static void transferTransactionsToNewBudgets(List<EUR_CRM_Contract__c> contracts)
	//{
	//	Date prevFyDate = EUR_ISP_BudgetService.FY_START_PERIOD;
	//	Map<Id, EUR_CRM_Contract__c> contractsMap = new Map<Id, EUR_CRM_Contract__c>(contracts);
	//	Set<Id> newOwners = new Set<Id>();
	//	Set<String> fyStrings = new Set<String>();
	//	fyStrings.add(EUR_ISP_BudgetService.formatFiscalYear(prevFyDate));

	//	List<EUR_CRM_Budget_Transaction__c> transactions = EUR_ISP_ContractTransactionsServiceDE.getAllTransactions(contracts);
	//	for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
	//	{
	//		if (String.isNotBlank(transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c))
	//		{
	//			EUR_CRM_Contract__c theContract = contractsMap.get(transactionItem.EUR_CRM_Contract__c);
	//			// add start FY period of Contract
	//			fyStrings.add(EUR_ISP_BudgetService.formatFiscalYear(theContract.EUR_CRM_Start_Date__c));
	//			// add FY periods of transactions
	//			fyStrings.add(transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c);
	//			newOwners.add(transactionItem.EUR_CRM_Contract__r.CreatedById);
	//		}
	//	}

	//	//Key: owner ID => Budget FY => EUR_CRM_Budget__c
	//	Map<Id, Map<String, EUR_CRM_Budget__c>> currentOwnerIdToBudgetsMap = new Map<Id, Map<String, EUR_CRM_Budget__c>>();
	//	// get budgets and sort them by FY Key and OwnerId
	//	for (EUR_CRM_Budget__c budget : EUR_ISP_BudgetService.getBudgets(newOwners, fyStrings))
	//	{
	//		if (!currentOwnerIdToBudgetsMap.containsKey(budget.OwnerId))
	//		{
	//			currentOwnerIdToBudgetsMap.put(budget.OwnerId, new Map<String, EUR_CRM_Budget__c>());
	//		}
	//		currentOwnerIdToBudgetsMap.get(budget.OwnerId).put(budget.EUR_CRM_Fiscal_Year__c, budget);
	//	}
	//	System.debug('### newOwners ' + newOwners);
	//	System.debug('### transactions.size() ' + transactions.size());
	//	System.debug('### transactions.size() ' + transactions.size());

	//	// CREATE BUDGETS if needed
	//	List<EUR_CRM_Budget__c> budgetsToCreate = new List<EUR_CRM_Budget__c>();
	//	for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
	//	{
	//		String fyString = transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c;
	//		Id newOwnerId = transactionItem.EUR_CRM_Contract__r.CreatedById;
	//		// exceptional case: Owner does not have Budgets
	//		if (!currentOwnerIdToBudgetsMap.containsKey( newOwnerId ) || String.isBlank(fyString))
	//		{
	//			continue;
	//		}
	//		// budget already created
	//		if (currentOwnerIdToBudgetsMap.get( newOwnerId ).containsKey( fyString ))
	//		{
	//			continue;
	//		}

	//		// make sure that old budget exists
	//		// generate new Budget
	//		if (!currentOwnerIdToBudgetsMap.get( newOwnerId ).isEmpty())
	//		{
	//			EUR_CRM_Budget__c oldBudget = currentOwnerIdToBudgetsMap.get( newOwnerId ).values().get(0);
	//			EUR_CRM_Budget__c newBudget = EUR_ISP_BudgetService.cloneBudget( oldBudget, fyString );

	//			currentOwnerIdToBudgetsMap.get( newOwnerId ).put( fyString, newBudget );
	//			budgetsToCreate.add( newBudget );
	//		}
	//	}
	//	insert budgetsToCreate;

	//	// UPDATE BUDGET HEADER
	//	List<EUR_CRM_Budget_Transaction__c> transactionsToUpdate = new List<EUR_CRM_Budget_Transaction__c>();
	//	Map<Id, EUR_CRM_Contract__c> contractsToUpdateMap = new Map<Id, EUR_CRM_Contract__c>();
	//	for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
	//	{
	//		String fyString = transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c;
	//		Id newOwnerId = transactionItem.EUR_CRM_Contract__r.CreatedById;
	//		// exceptional case: Owner does not have Budgets
	//		if (String.isNotBlank(fyString) && currentOwnerIdToBudgetsMap.containsKey( newOwnerId ))
	//		{
	//			Map<String, EUR_CRM_Budget__c> budgetsMap = currentOwnerIdToBudgetsMap.get( newOwnerId );
	//			EUR_CRM_Budget__c budget = budgetsMap.get(fyString);
	//			if (budget != null)
	//			{
	//				transactionItem.EUR_CRM_Budget_Header__c = budget.Id;
	//				transactionsToUpdate.add(transactionItem);
	//			}

	//			// UPDATE CONTRACT BUDGET HEADER
	//			if (!contractsToUpdateMap.containsKey(transactionItem.EUR_CRM_Contract__c))
	//			{
	//				EUR_CRM_Contract__c theContract = contractsMap.get(transactionItem.EUR_CRM_Contract__c);
	//				String startFYString = EUR_ISP_BudgetService.formatFiscalYear(theContract.EUR_CRM_Start_Date__c);
	//				EUR_CRM_Budget__c startBudget = budgetsMap.get( startFYString );
	//				if (startBudget != null && theContract.EUR_CRM_Budget__c != startBudget.Id)
	//				{
	//					theContract.EUR_CRM_Budget__c = startBudget.Id;
	//					contractsToUpdateMap.put(theContract.Id, theContract);
	//				}
	//			}
	//		}
	//	}
	//	update transactionsToUpdate;
	//	update contractsToUpdateMap.values();
	//}

	public static void deleteWrongTransaction(List<EUR_CRM_Budget_Transaction__c> records) {
		List<EUR_CRM_Budget_Transaction__c> draftRecords = new List<EUR_CRM_Budget_Transaction__c>();
		Set<Id> contractIds = new Set<Id>();
		Id draftRecTypeId = RECORD_TYPES_MAP.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_DRAFT_RT_NAME_WKZ);
		for (EUR_CRM_Budget_Transaction__c record : records) {
			if(record.EUR_CRM_Transaction_Category__c == DRAFT_TRANSACTION_CATEGORY && record.RecordTypeId == draftRecTypeId && record.EUR_CRM_Contract__c != null) {
				draftRecords.add(record);
				contractIds.add(record.EUR_CRM_Contract__c);
			}
		}

		Set<Id> canceledContractIds = new Map<Id, EUR_CRM_Contract__c>([
			SELECT Id
			FROM EUR_CRM_Contract__c
			WHERE Id IN :contractIds AND EUR_CRM_Status__c = :CONTRACT_STATUS_CANCELLED
		]).keySet();

		Set<Id> wrongTransactionIds = new Set<Id>();
		for(EUR_CRM_Budget_Transaction__c record : draftRecords) {
			if(canceledContractIds.contains(record.EUR_CRM_Contract__c)) {
				wrongTransactionIds.add(record.Id);
			}
		}

		delete [SELECT Id FROM EUR_CRM_Budget_Transaction__c WHERE Id IN :wrongTransactionIds];
	}

	public static void closeTransactionsAfterApprove(List<EUR_CRM_Contract__c> contracts)
	{
		if (contracts != null && !contracts.isEmpty())
		{
			List<EUR_CRM_Budget_Transaction__c> refundTransactions = new List<EUR_CRM_Budget_Transaction__c>();
			for (EUR_CRM_Budget_Transaction__c transactionItem : [SELECT Id, EUR_CRM_Budget_Header__c, EUR_CRM_Contract__c, EUR_CRM_Amount__c, EUR_CRM_Transaction_Category__c,
			        EUR_CRM_Transaction_Type__c, EUR_CRM_Description__c, EUR_CRM_Transfer_From_Budget_Header__c, EUR_CRM_Transfer_From__c, EUR_CRM_Transfer_To__c
			        FROM EUR_CRM_Budget_Transaction__c
			        WHERE EUR_CRM_Contract__c IN: contracts])
			{
				EUR_CRM_Budget_Transaction__c newTransaction = transactionItem.clone(false);
				newTransaction.EUR_CRM_Transaction_Type__c = EUR_ISP_BudgetService.CREDIT;
				newTransaction.EUR_CRM_Transaction_Category__c = CONTRACT_REFUND;
				refundTransactions.add(newTransaction);
			}
			//insert refundTransactions;
			transactionsToUpsert.addAll(refundTransactions);
		}
	}

	public static void closeTransactions(List<EUR_CRM_Contract__c> contracts)
	{
		if (contracts != null && !contracts.isEmpty())
		{
			List<EUR_CRM_Budget_Transaction__c> draftTransactionsToDelete = EUR_ISP_ContractTransactionsServiceDE.getDraftTransactions(contracts);
			//delete EUR_ISP_ContractTransactionsServiceDE.getDraftTransactions(contracts);
			transactionsToDelete.addAll(draftTransactionsToDelete);
		}
	}

	public static void createApprovedTransactions(List<EUR_CRM_Contract__c> contracts)
	{
		if (contracts != null && !contracts.isEmpty())
		{
			Id approvedTransactionRecordTypeId = RECORD_TYPES_MAP.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_RT_NAME_WKZ);
			List<EUR_CRM_Budget_Transaction__c> debitTransactions = new List<EUR_CRM_Budget_Transaction__c>();
			for (EUR_CRM_Budget_Transaction__c transactionItem : EUR_ISP_ContractTransactionsServiceDE.getDraftTransactions(contracts))
			{
				transactionItem.EUR_CRM_Transaction_Category__c = TRANSACTION_CATEGORY;
				transactionItem.RecordTypeId = approvedTransactionRecordTypeId;
				debitTransactions.add(transactionItem);
			}
			//insert debitTransactions;
			transactionsToUpsert.addAll(debitTransactions);
		}
	}

	/**
	 * 1) => re-calculate transactions periods and amount
	 *		(old.EUR_CRM_DE_Deductible_Contract_Total__c != new.EUR_CRM_DE_Deductible_Contract_Total__c AND new.EUR_CRM_Contract_Approved_Date__c == NULL) OR (2)
	 *
	 * 2) => re-calculate transactions periods and amount / update budget header
	 * 		old.EUR_CRM_Start_Date__c != new.EUR_CRM_Start_Date__c OR old.EUR_CRM_End_Date__c != new.EUR_CRM_End_Date__c
	 *
	 * 3) => update budget header
	 * 		 old.EUR_CRM_Budget__c != new.EUR_CRM_Budget__c AND new.EUR_CRM_Contract_Approved_Date__c == NULL
	 *
	 * 4) => delete draft ?
	 * 		old.EUR_CRM_Contract_Approved_Date__c == NULL AND new.EUR_CRM_Contract_Approved_Date__c != NULL
	 */
	public static void createDraftTransactions(List<Id> contractIds)
	{
		transactionsToUpsert = new List<EUR_CRM_Budget_Transaction__c>();
		transactionsToDelete = new List<EUR_CRM_Budget_Transaction__c>();
		contractsToUpdate = new List<EUR_CRM_Contract__c>();

		if (contractIds != null && !contractIds.isEmpty())
		{
			List<EUR_CRM_Contract__c> contracts = EUR_ISP_ContractTransactionsServiceDE.getDraftContracts(contractIds);
			//Key: owner ID => Budget FY => EUR_CRM_Budget__c
			Map<Id, Map<String, EUR_CRM_Budget__c>> budgetsMap = EUR_ISP_ContractTransactionsServiceDE.getAllBudgetsForContracts(contracts);
			EUR_ISP_ContractTransactionsServiceDE.setUpdatedDraftTransactions(contracts, budgetsMap);
			EUR_ISP_ContractTransactionsServiceDE.contractBudgetUpdate(contracts, budgetsMap);
		}
	}

	public static void commitTransactions()
	{
		delete transactionsToDelete;
		transactionsToDelete.clear();
		upsert transactionsToUpsert;
		transactionsToUpsert.clear();
		update contractsToUpdate;
		contractsToUpdate.clear();
	}

	private static void contractBudgetUpdate(List<EUR_CRM_Contract__c> contracts, Map<Id, Map<String, EUR_CRM_Budget__c>> budgetsMap)
	{
		// make sure that we have correct budget header linked with contract
		for (EUR_CRM_Contract__c theContract : [SELECT Id, CreatedById, EUR_CRM_Account__r.OwnerId, EUR_CRM_Start_Date__c, EUR_CRM_Budget__c
		                                        FROM EUR_CRM_Contract__c
		                                        WHERE Id IN: contracts AND EUR_CRM_Account__c != null FOR UPDATE])
		{
			if (budgetsMap.containsKey(theContract.CreatedById))
			{
				String fyString = EUR_ISP_BudgetService.formatFiscalYear(theContract.EUR_CRM_Start_Date__c);
				EUR_CRM_Budget__c budget = budgetsMap.get(theContract.CreatedById).get(fyString);
				if (budget != null && theContract.EUR_CRM_Budget__c != budget.Id)
				{
					theContract.EUR_CRM_Budget__c = budget.Id;
					contractsToUpdate.add(theContract);
				}
			}
		}
	}

	private static void setUpdatedDraftTransactions(List<EUR_CRM_Contract__c> contracts, Map<Id, Map<String, EUR_CRM_Budget__c>> budgetsMap)
	{
		//Key: contract ID => Budget FY => EUR_CRM_Budget_Transaction__c
		Map<Id, Map<String, EUR_CRM_Budget_Transaction__c>> transactionsMap = new Map<Id, Map<String, EUR_CRM_Budget_Transaction__c>>();
		List<EUR_CRM_Budget_Transaction__c> transactions = EUR_ISP_ContractTransactionsServiceDE.getAllTransactions(contracts);
		for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
		{
			if (!transactionsMap.containsKey(transactionItem.EUR_CRM_Contract__c))
			{
				transactionsMap.put(transactionItem.EUR_CRM_Contract__c, new Map<String, EUR_CRM_Budget_Transaction__c>());
			}
			transactionsMap.get(transactionItem.EUR_CRM_Contract__c).put(transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c, transactionItem);
		}


		// adjust transactions or generate new
		Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> contractIdToActivities = EUR_ISP_ContractTransactionsServiceDE.getContractIdToActivities(contracts);
		for (EUR_CRM_Contract__c theContract : contracts)
		{
			Id ownerId = theContract.CreatedById;
			if (!budgetsMap.containsKey( ownerId ))
			{
				continue;
			}

			// DATA INIT
			// fyString => EUR_CRM_Budget__c
			Map<String, EUR_CRM_Budget__c> theBudgetMap = budgetsMap.get( ownerId );
			// fyString => EUR_CRM_Budget_Transaction__c
			Map<String, EUR_CRM_Budget_Transaction__c> contractTransactionsMap = new Map<String, EUR_CRM_Budget_Transaction__c>();
			if (transactionsMap.containsKey(theContract.Id))
			{
				contractTransactionsMap = transactionsMap.get(theContract.Id);
				for (EUR_CRM_Budget_Transaction__c transactionItem : contractTransactionsMap.values())
				{
					transactionItem.EUR_CRM_Amount__c = 0;
				}
			}

			// ACTIVITIES AMOUNTS
			// INIT ACTION FOR CONTRACT: activities is empty > create transactions with 0 amount
			List<EUR_CRM_Contract_Activity_Item__c> activities = new List<EUR_CRM_Contract_Activity_Item__c>();
			if (contractIdToActivities.containsKey(theContract.Id))
			{
				activities = contractIdToActivities.get(theContract.Id);
			}

			for (EUR_CRM_Contract_Activity_Item__c theActivity : activities)
			{
				if (theActivity.EUR_CRM_Contract_Activity_Total__c == null || theActivity.EUR_CRM_Contract_Activity_Total__c == 0)
				{
					continue;
				}

				// Activity Properties
				Date activityStartDate = theActivity.EUR_CRM_Start_Date__c != null ? theActivity.EUR_CRM_Start_Date__c : theContract.EUR_CRM_Start_Date__c;
				Date activityEndDate = theActivity.EUR_CRM_End_Date__c != null ? theActivity.EUR_CRM_End_Date__c : theContract.EUR_CRM_End_Date__c;
				Integer totalActivityMonths = activityStartDate.monthsBetween(activityEndDate) + 1;
				Decimal totalActivityAmount = theActivity.EUR_CRM_Contract_Activity_Total__c;
				System.debug('####\n' +
				             'activityStartDate: ' + activityStartDate + '\n' +
				             'activityEndDate: ' + activityEndDate + '\n' +
				             'totalActivityAmount: ' + totalActivityAmount + '\n' +
				             'totalActivityMonths: ' + totalActivityMonths + '\n' +
				             'Is_Pro_Rated_by_Month: ' + theActivity.EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Pro_Rated_by_Month__c
				            );

				// if activity is not prorated by Month > create transactions for the 1st FY
				if (!theActivity.EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Pro_Rated_by_Month__c)
				{
					EUR_CRM_Budget_Transaction__c transactionItem = new EUR_CRM_Budget_Transaction__c();
					String fyString = EUR_ISP_BudgetService.formatFiscalYear(activityStartDate);
					if (contractTransactionsMap.containsKey(fyString))
					{
						transactionItem = contractTransactionsMap.get(fyString);
						transactionItem.EUR_CRM_Amount__c += totalActivityAmount;
						contractTransactionsMap.put(fyString, transactionItem);
					}
					else
					{
						if (theBudgetMap.containsKey(fyString))
						{
							transactionItem = EUR_ISP_ContractTransactionsServiceDE.generateDraftTransactionRecord(theBudgetMap.get(fyString), theContract, totalActivityAmount);
							contractTransactionsMap.put(fyString, transactionItem);
						}
					}
					continue;
				}

				// activities prorated by month > split amount by periods
				Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(activityStartDate, activityEndDate);
				for (Date periodStartDate : periodsMap.keySet())
				{
					Date periodEndDate = periodsMap.get(periodStartDate);
					Integer periodMonths = periodStartDate.monthsBetween(periodEndDate) + 1;
					Decimal periodAmount = (periodMonths * totalActivityAmount / totalActivityMonths).setScale(2);
					System.debug('####\n' +
					             'periodStartDate: ' + periodStartDate + '\n' +
					             'periodEndDate: ' + periodEndDate + '\n' +
					             'periodAmount: ' + periodAmount + '\n' +
					             'periodMonths: ' + periodMonths
					            );
					EUR_CRM_Budget_Transaction__c transactionItem = new EUR_CRM_Budget_Transaction__c();
					String fyString = EUR_ISP_BudgetService.formatFiscalYear(periodStartDate);
					if (contractTransactionsMap.containsKey(fyString))
					{
						transactionItem = contractTransactionsMap.get(fyString);
						transactionItem.EUR_CRM_Amount__c += periodAmount;
						contractTransactionsMap.put(fyString, transactionItem);
					}
					else
					{
						if (theBudgetMap.containsKey(fyString))
						{
							transactionItem = EUR_ISP_ContractTransactionsServiceDE.generateDraftTransactionRecord(theBudgetMap.get(fyString), theContract, periodAmount);
							contractTransactionsMap.put(fyString, transactionItem);
						}
					}
				}
			}


			// create transactions with 0 amount for Contract Dates if Activity Dates do not include FY period
			Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(theContract.EUR_CRM_Start_Date__c, theContract.EUR_CRM_End_Date__c);
			Set<String> fullSetOfFyPeriods = new Set<String>();
			for (Date periodStartDate : periodsMap.keySet())
			{
				String fyString = EUR_ISP_BudgetService.formatFiscalYear(periodStartDate);
				fullSetOfFyPeriods.add(fyString);
				System.debug('#### fyString: ' + fyString);

				if (theBudgetMap.containsKey(fyString) && !contractTransactionsMap.containsKey(fyString))
				{
					EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_ContractTransactionsServiceDE.generateDraftTransactionRecord(theBudgetMap.get(fyString), theContract, 0);
					contractTransactionsMap.put(fyString, transactionItem);
				}
			}


			// TRANSACTIONS SORTING
			// put all current values to list for future updates
			for (String fyString : contractTransactionsMap.keySet())
			{
				EUR_CRM_Budget_Transaction__c transactionItem = contractTransactionsMap.get(fyString);

				if (transactionItem != null)
				{
					if (fullSetOfFyPeriods.contains(fyString))
					{
						transactionsToUpsert.add(transactionItem);
					}
					else if (transactionItem.Id != null)
					{
						transactionsToDelete.add(transactionItem);
					}
				}
			}
		}
		EUR_ISP_ContractTransactionsServiceDE.commitTransactions();
	}

	//Key: owner ID => Budget FY => EUR_CRM_Budget__c
	private static Map<Id, Map<String, EUR_CRM_Budget__c>> getAllBudgetsForContracts(List<EUR_CRM_Contract__c> contracts)
	{
		//Key: owner ID => Budget FY => EUR_CRM_Budget__c
		Map<Id, Map<String, EUR_CRM_Budget__c>> ownerIdToBudgetsMap = new Map<Id, Map<String, EUR_CRM_Budget__c>>();
		// get *FY periods + prev period* for all contracts and retrieve Budgets
		Set<String> contractFiscalYears = new Set<String>();
		Set<Id> ownerIds = new Set<Id>();
		for (EUR_CRM_Contract__c theContract : contracts)
		{
			ownerIds.add(theContract.CreatedById);

			Date startDate = theContract.EUR_CRM_Start_Date__c;
			Date prevFyDate = EUR_ISP_BudgetService.FY_START_PERIOD;
			prevFyDate = prevFyDate > startDate ? startDate : prevFyDate;

			Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(prevFyDate, theContract.EUR_CRM_End_Date__c);
			for (Date theStartDate : periodsMap.keySet())
			{
				//System.debug('#### pre-budget fyString: ' + EUR_ISP_BudgetService.formatFiscalYear(theStartDate));
				contractFiscalYears.add(EUR_ISP_BudgetService.formatFiscalYear(theStartDate));
			}
		}

		// get budgets and sort them by FY Key and OwnerId
		for (EUR_CRM_Budget__c budget : EUR_ISP_BudgetService.getBudgets(ownerIds, contractFiscalYears))
		{
			if (!ownerIdToBudgetsMap.containsKey(budget.OwnerId))
			{
				ownerIdToBudgetsMap.put(budget.OwnerId, new Map<String, EUR_CRM_Budget__c>());
			}
			ownerIdToBudgetsMap.get(budget.OwnerId).put(budget.EUR_CRM_Fiscal_Year__c, budget);
		}

		// check FY Budgets and create new one if does not exists for appropriate period
		List<EUR_CRM_Budget__c> budgetsToCreate = new List<EUR_CRM_Budget__c>();
		for (EUR_CRM_Contract__c theContract : contracts)
		{
			Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(theContract.EUR_CRM_Start_Date__c, theContract.EUR_CRM_End_Date__c);
			for (Date theStartDate : periodsMap.keySet())
			{
				Id ownerId = theContract.CreatedById;
				// exceptional case: Owner does not have Budgets
				if (!ownerIdToBudgetsMap.containsKey( ownerId ))
				{
					continue;
				}

				Map<String, EUR_CRM_Budget__c> budgetsMap = ownerIdToBudgetsMap.get( ownerId );
				String fyString = EUR_ISP_BudgetService.formatFiscalYear(theStartDate);
				// budget already created
				if (budgetsMap.containsKey(fyString))
				{
					continue;
				}

				// make sure that old budget exists
				// generate new Budget
				if (!budgetsMap.isEmpty())
				{
					EUR_CRM_Budget__c oldBudget = budgetsMap.values().get(0);
					EUR_CRM_Budget__c newBudget = EUR_ISP_BudgetService.cloneBudget(oldBudget, theStartDate);
					budgetsToCreate.add(newBudget);
					budgetsMap.put(fyString, newBudget);
				}
			}
		}
		insert budgetsToCreate;
		return ownerIdToBudgetsMap;
	}

	public static List<EUR_CRM_Contract__c> getDraftContracts(List<Id> contractIds)
	{
		return [SELECT Id, RecordTypeId, CreatedById, EUR_CRM_Budget__c, EUR_CRM_Status__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c,
		        EUR_CRM_DE_Deductible_Contract_Total__c, EUR_CRM_Contract_Approved_Date__c,
		        EUR_CRM_Account__c, EUR_CRM_Account__r.OwnerId
		        FROM EUR_CRM_Contract__c
		        WHERE Id IN: contractIds AND RecordTypeId = : DE_CONTRACT_RECORD_TYPE_ID
		                AND EUR_CRM_Start_Date__c != null
		                AND EUR_CRM_End_Date__c != null
		                AND EUR_CRM_Contract_Approved_Date__c = null];
	}

	private static Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> getContractIdToActivities(List<EUR_CRM_Contract__c> contracts)
	{
		Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> contractIdToActivities = new Map<Id, List<EUR_CRM_Contract_Activity_Item__c>>();
		for (EUR_CRM_Contract_Activity_Item__c contractActivity : [SELECT Id, EUR_CRM_Contract_Activity_Total__c, EUR_CRM_Contract__c,
		        EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c, EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Pro_Rated_by_Month__c
		        FROM EUR_CRM_Contract_Activity_Item__c
		        WHERE EUR_CRM_Contract__c IN: contracts AND EUR_CRM_Exclude_Budget_Deduction__c = false])
		{
			if (!contractIdToActivities.containsKey(contractActivity.EUR_CRM_Contract__c))
			{
				contractIdToActivities.put(contractActivity.EUR_CRM_Contract__c, new List<EUR_CRM_Contract_Activity_Item__c>());
			}
			contractIdToActivities.get(contractActivity.EUR_CRM_Contract__c).add(contractActivity);
		}
		return contractIdToActivities;
	}

	private static List<EUR_CRM_Budget_Transaction__c> getAllTransactions(List<EUR_CRM_Contract__c> contracts)
	{
		return [SELECT Id, EUR_CRM_Budget_Header__c, EUR_CRM_Budget_Header__r.OwnerId, EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c,
		        EUR_CRM_Amount__c, EUR_CRM_Transaction_Category__c, EUR_CRM_Transaction_Type__c, RecordTypeId,
		        EUR_CRM_Description__c, EUR_CRM_Transfer_From_Budget_Header__c, EUR_CRM_Transfer_From__c, EUR_CRM_Transfer_To__c,
		        EUR_CRM_Contract__c, EUR_CRM_Contract__r.EUR_CRM_Account__r.OwnerId
		        FROM EUR_CRM_Budget_Transaction__c
		        WHERE EUR_CRM_Contract__c IN: contracts];
	}

	private static List<EUR_CRM_Budget_Transaction__c> getDraftTransactions(List<EUR_CRM_Contract__c> contracts)
	{
		Id draftRecTypeId = RECORD_TYPES_MAP.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_DRAFT_RT_NAME_WKZ);
		return [SELECT Id, EUR_CRM_Budget_Header__c, EUR_CRM_Budget_Header__r.OwnerId, EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c,
		        EUR_CRM_Amount__c, EUR_CRM_Transaction_Category__c, EUR_CRM_Transaction_Type__c, RecordTypeId,
		        EUR_CRM_Description__c, EUR_CRM_Transfer_From_Budget_Header__c, EUR_CRM_Transfer_From__c, EUR_CRM_Transfer_To__c,
		        EUR_CRM_Contract__c, EUR_CRM_Contract__r.EUR_CRM_Account__r.OwnerId
		        FROM EUR_CRM_Budget_Transaction__c
		        WHERE EUR_CRM_Contract__c IN: contracts
		        AND EUR_CRM_Transaction_Category__c = : DRAFT_TRANSACTION_CATEGORY
		                AND RecordTypeId = : draftRecTypeId];
	}

	private static EUR_CRM_Budget_Transaction__c generateDraftTransactionRecord(EUR_CRM_Budget__c theBudget, EUR_CRM_Contract__c theContract, Decimal amount)
	{
		Id rtId = RECORD_TYPES_MAP.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_DRAFT_RT_NAME_WKZ);
		String transactionCategory = DRAFT_TRANSACTION_CATEGORY;
		if(theContract.EUR_CRM_Status__c == CONTRACT_STATUS_ACTIVATED) {
			rtId = RECORD_TYPES_MAP.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_RT_NAME_WKZ);
			transactionCategory = TRANSACTION_CATEGORY;
		}
		return new EUR_CRM_Budget_Transaction__c (
		           RecordTypeId = rtId,
		           EUR_CRM_Budget_Header__c =  theBudget.Id,
		           EUR_CRM_Contract__c = theContract.Id,
		           EUR_CRM_Amount__c = amount,
		           EUR_CRM_Transaction_Category__c = transactionCategory,
		           EUR_CRM_Transaction_Type__c = EUR_ISP_BudgetService.DEBIT
		       );
	}
}