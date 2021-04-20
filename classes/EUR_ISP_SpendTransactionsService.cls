/**
 * Budget Service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendTransactionsService
{
	public static final Set<String> acceptableDraftStatuses = new Set<String> {EUR_ISP_Utils.RINGFENCE_STATUS, EUR_ISP_Utils.PLANNED_STATUS};
	public static final Set<String> acceptableStatuses = new Set<String> {EUR_ISP_Utils.COMMITTED_STATUS};
	public static final String PRORATA_PHASE = 'Pro-Rata';
	public static final String START_DATE_PHASE = 'Start of activity';
	public static final String END_DATE_PHASE = 'End of activity';
	public static final String NO_DEDUCTION_PHASE = 'No deduction';
	private static Id spendActivitySFARecordTypeId = null;
	private static Id budgetSpendRecordTypeId = null;
	static
	{
		spendActivitySFARecordTypeId = EUR_ISP_Utils.getRecordTypesMap().get(EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME);
		budgetSpendRecordTypeId = EUR_ISP_Utils.getRecordTypesMap().get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_API_NAME + EUR_ISP_BudgetService.BUDGET_RT_NAME_ISPEND);
	}

	public static Boolean skipProcessing = false;
	public static Boolean isUpdateAction = false;

	private static Map<Id, List<EUR_ISP_Spend_Activity__c>> ownerIdToActivities = new Map<Id, List<EUR_ISP_Spend_Activity__c>>();
	//Key: owner ID => Budget FY => EUR_CRM_Budget__c
	private static Map<Id, Map<String, EUR_CRM_Budget__c>> ownerIdToBudgets = new Map<Id, Map<String, EUR_CRM_Budget__c>>();
	private static Map<Id, List<EUR_CRM_Budget_Transaction__c>> spendIdToTransactionsList = new Map<Id, List<EUR_CRM_Budget_Transaction__c>>();
	private static Map<Id, Map<Id, List<EUR_CRM_Budget_Transaction__c>>> spendIdToTransactionsMap = new Map<Id, Map<Id, List<EUR_CRM_Budget_Transaction__c>>>();
	private static Map<Id, Map<Id, EUR_ISP_Spend_Activity__c>> spendIdToActivitiesMap = new Map<Id, Map<Id, EUR_ISP_Spend_Activity__c>>();
	private static List<EUR_CRM_Budget_Transaction__c> transactionsToUsert = new List<EUR_CRM_Budget_Transaction__c>();

	private static void resetMaps()
	{
		ownerIdToActivities.clear();
		//Key: owner ID => Budget FY => EUR_CRM_Budget__c
		ownerIdToBudgets.clear();
		spendIdToTransactionsList.clear();
		spendIdToTransactionsMap.clear();
		spendIdToActivitiesMap.clear();
		transactionsToUsert.clear();
	}

	/**
	 * TODO: territory split logic commented
	 *
	 * transfer budget transactions to the correct budget when Spend's Owner is changed
	 */
	//public static void transferTransactionsToNewBudgets(Set<Id> spendIds)
	//{
	//	Date prevFyDate = EUR_ISP_BudgetService.FY_START_PERIOD;
	//	List<EUR_CRM_Budget_Transaction__c> transactions = EUR_ISP_SpendTransactionsService.getAllTransactions(spendIds);
	//	Set<Id> newOwners = new Set<Id>();
	//	Set<String> fyStrings = new Set<String>();
	//	fyStrings.add(EUR_ISP_BudgetService.formatFiscalYear(prevFyDate));

	//	for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
	//	{
	//		if (String.isNotBlank(transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c))
	//		{
	//			fyStrings.add(transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c);
	//			newOwners.add(transactionItem.EUR_CRM_Spend__r.OwnerId);
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

	//	// create budgets if needed
	//	List<EUR_CRM_Budget__c> budgetsToCreate = new List<EUR_CRM_Budget__c>();
	//	for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
	//	{
	//		String fyString = transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c;
	//		Id newOwnerId = transactionItem.EUR_CRM_Spend__r.OwnerId;
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
	//	for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
	//	{
	//		String fyString = transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c;
	//		Id newOwnerId = transactionItem.EUR_CRM_Spend__r.OwnerId;
	//		// exceptional case: Owner does not have Budgets
	//		if (String.isNotBlank(fyString) && currentOwnerIdToBudgetsMap.containsKey( newOwnerId ))
	//		{
	//			EUR_CRM_Budget__c budget = currentOwnerIdToBudgetsMap.get( newOwnerId ).get(fyString);
	//			if (budget != null && transactionItem.EUR_CRM_Budget_Header__c != budget.Id)
	//			{
	//				transactionItem.EUR_CRM_Budget_Header__c = budget.Id;
	//				transactionsToUpdate.add(transactionItem);
	//			}
	//		}
	//	}
	//	update transactionsToUpdate;
	//}

	/**
	 * create Transactions for updated activities
	 */
	public static void createTransactionsForUpdated(List<EUR_ISP_Spend_Activity__c> activities)
	{
		if (EUR_ISP_SpendTransactionsService.skipProcessing)
		{
			return;
		}
		EUR_ISP_SpendTransactionsService.isUpdateAction = true;
		EUR_ISP_SpendTransactionsService.dataInit(activities);
		EUR_ISP_SpendTransactionsService.processTransactionsCreate();
	}

	/**
	 * create Transactions for closed Spends
	 */
	public static void createTransactionsForCancelled(List<EUR_ISP_Spend_Activity__c> activities)
	{
		EUR_ISP_SpendTransactionsService.isUpdateAction = true;
		EUR_ISP_SpendTransactionsService.dataInit(activities);
		EUR_ISP_SpendTransactionsService.processTransactionsClose();
	}

	/**
	 * start and end dates updated from the last save, so we need to adjust Transactions to correct Budget
	 */
	public static void updateTransactions(List<EUR_ISP_Spend_Activity__c> activities)
	{
		if (EUR_ISP_SpendTransactionsService.skipProcessing)
		{
			return;
		}

		EUR_ISP_SpendTransactionsService.dataInit(activities);
		EUR_ISP_SpendTransactionsService.processTransactionsUpdate();
	}

	/**
	 * Total Amount updated => create new transactions
	 */
	public static void createTransactions(List<EUR_ISP_Spend_Activity__c> activities)
	{
		if (EUR_ISP_SpendTransactionsService.skipProcessing)
		{
			return;
		}

		EUR_ISP_SpendTransactionsService.dataInit(activities);
		EUR_ISP_SpendTransactionsService.processTransactionsCreate();
	}

	private static void dataInit(List<EUR_ISP_Spend_Activity__c> activities)
	{
		EUR_ISP_SpendTransactionsService.resetMaps();
		if (activities.isEmpty())
		{
			return;
		}
		Set<Id> currentActivities = new Map<Id, EUR_ISP_Spend_Activity__c>(activities).keySet();
		activities = EUR_ISP_SpendTransactionsService.getSpendActivities(activities);


		Set<Id> spendIds = new Set<Id>();
		for (EUR_ISP_Spend_Activity__c theSpendActivity : activities)
		{
			Id spendId = theSpendActivity.EUR_ISP_Spend__c;
			Id ownerId = theSpendActivity.EUR_ISP_Spend__r.OwnerId;
			spendIds.add(spendId);

			if (currentActivities.contains(theSpendActivity.Id))
			{
				if (!ownerIdToActivities.containsKey(ownerId))
				{
					ownerIdToActivities.put(ownerId, new List<EUR_ISP_Spend_Activity__c>());
				}
				ownerIdToActivities.get(ownerId).add(theSpendActivity);
			}

			// get all activities for SFA Contract RTs
			if (!spendIdToActivitiesMap.containsKey(spendId))
			{
				spendIdToActivitiesMap.put(spendId, new Map<Id, EUR_ISP_Spend_Activity__c>());
			}
			if (!spendIdToActivitiesMap.get(spendId).containsKey(theSpendActivity.Id))
			{
				spendIdToActivitiesMap.get(spendId).put(theSpendActivity.Id, theSpendActivity);
			}
		}

		EUR_ISP_SpendTransactionsService.setFYBudgets();
		EUR_ISP_SpendTransactionsService.setAllTransactions(spendIds);
	}

	private static void processTransactionsClose()
	{
		for (Id ownerId : ownerIdToActivities.keySet())
		{
			for (EUR_ISP_Spend_Activity__c activity : ownerIdToActivities.get(ownerId))
			{
				Map<String, EUR_CRM_Budget__c> budgets = ownerIdToBudgets.get(ownerId);
				// expected that  current FY budget already created at least, but double check it
				if (budgets == null || budgets.isEmpty())
				{
					continue;
				}

				List<EUR_CRM_Budget_Transaction__c> transactions =  spendIdToTransactionsMap.containsKey(activity.EUR_ISP_Spend__c) &&
				        spendIdToTransactionsMap.get(activity.EUR_ISP_Spend__c).containsKey(activity.Id) ?
				        spendIdToTransactionsMap.get(activity.EUR_ISP_Spend__c).get(activity.Id) :
				        new List<EUR_CRM_Budget_Transaction__c>();

				// can't detect by Status so - check all transactions and decide which type should be used for new Transaction
				Boolean isDraft = EUR_ISP_BudgetService.isDraftTransactions(transactions);

				Map<String, List<EUR_CRM_Budget_Transaction__c>> fyToTransactions = new Map<String, List<EUR_CRM_Budget_Transaction__c>>();
				fyToTransactions = EUR_ISP_SpendTransactionsService.getTransactionsToProcess(activity, new List<EUR_CRM_Budget_Transaction__c>(), budgets, isDraft);
				for (List<EUR_CRM_Budget_Transaction__c> transactionItems : fyToTransactions.values())
				{
					for (EUR_CRM_Budget_Transaction__c transactionItem : transactionItems)
					{
						transactionItem.EUR_CRM_Transaction_Type__c = EUR_ISP_BudgetService.CREDIT;
					}
				}

				EUR_ISP_SpendTransactionsService.addTransactionsToList(fyToTransactions);
			}
		}
		// UPSERT records: transactions
		EUR_ISP_SpendTransactionsService.upsertTransactions();
	}

	private static void processTransactionsCreate()
	{
		for (Id ownerId : ownerIdToActivities.keySet())
		{
			for (EUR_ISP_Spend_Activity__c activity : ownerIdToActivities.get(ownerId))
			{
				Map<String, EUR_CRM_Budget__c> budgets = ownerIdToBudgets.get(ownerId);
				// expected that  current FY budget already created at least, but double check it
				if (budgets == null || budgets.isEmpty())
				{
					continue;
				}

				List<EUR_CRM_Budget_Transaction__c> transactions =  spendIdToTransactionsMap.containsKey(activity.EUR_ISP_Spend__c) &&
				        spendIdToTransactionsMap.get(activity.EUR_ISP_Spend__c).containsKey(activity.Id) ?
				        spendIdToTransactionsMap.get(activity.EUR_ISP_Spend__c).get(activity.Id) :
				        new List<EUR_CRM_Budget_Transaction__c>();
				System.debug('#### transactions.size(): ' + transactions.size());
				// FyString => Transactions
				Map<String, List<EUR_CRM_Budget_Transaction__c>> fyToTransactions = new Map<String, List<EUR_CRM_Budget_Transaction__c>>();

				// when status changed from the New to Ringfence or Planned
				if (acceptableDraftStatuses.contains(activity.EUR_ISP_Status__c))
				{
					fyToTransactions = EUR_ISP_SpendTransactionsService.getTransactionsToProcess(activity, transactions, budgets, true);
				}
				// when status changed from the Ringfence or Planned to Committed
				if (acceptableStatuses.contains(activity.EUR_ISP_Status__c))
				{
					fyToTransactions = EUR_ISP_SpendTransactionsService.getTransactionsToProcess(activity, transactions, budgets, false);
				}

				// when status is Cancelled
				if (activity.EUR_ISP_Status__c == EUR_ISP_Utils.CANCELLED_STATUS)
				{
					// can't detect by Status so - check all transactions and decide which type should be used for new Transaction
					Boolean isDraft = EUR_ISP_BudgetService.isDraftTransactions(transactions);
					fyToTransactions = EUR_ISP_SpendTransactionsService.getTransactionsToProcess(activity, new List<EUR_CRM_Budget_Transaction__c>(), budgets, isDraft);
					for (List<EUR_CRM_Budget_Transaction__c> transactionItems : fyToTransactions.values())
					{
						for (EUR_CRM_Budget_Transaction__c transactionItem : transactionItems)
						{
							transactionItem.EUR_CRM_Transaction_Type__c = EUR_ISP_BudgetService.CREDIT;
						}
					}
				}

				EUR_ISP_SpendTransactionsService.addTransactionsToList(fyToTransactions);
			}
		}

		// UPSERT records: transactions
		EUR_ISP_SpendTransactionsService.upsertTransactions();
	}

	private static void processTransactionsUpdate()
	{
		for (Id ownerId : ownerIdToActivities.keySet())
		{
			for (EUR_ISP_Spend_Activity__c activity : ownerIdToActivities.get(ownerId))
			{
				if (activity.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Budget_Phasing__c == NO_DEDUCTION_PHASE)
				{
					continue;
				}

				Map<String, EUR_CRM_Budget__c> budgets = ownerIdToBudgets.get(ownerId);
				// expected that  current FY budget already created at least, but double check it
				if (budgets == null || budgets.isEmpty())
				{
					continue;
				}

				List<EUR_CRM_Budget_Transaction__c> transactions = spendIdToTransactionsMap.containsKey(activity.EUR_ISP_Spend__c) &&
				        spendIdToTransactionsMap.get(activity.EUR_ISP_Spend__c).containsKey(activity.Id) ?
				        spendIdToTransactionsMap.get(activity.EUR_ISP_Spend__c).get(activity.Id) :
				        new List<EUR_CRM_Budget_Transaction__c>();
				if (transactions.isEmpty())
				{
					continue;
				}

				Boolean isDraft = EUR_ISP_BudgetService.isDraftTransactions(transactions);
				Map<String, List<EUR_CRM_Budget_Transaction__c>> fyToTransactions = new Map<String, List<EUR_CRM_Budget_Transaction__c>>();
				fyToTransactions = EUR_ISP_SpendTransactionsService.getAdjsutedTransactions(activity, transactions, budgets);

				EUR_ISP_SpendTransactionsService.adjustTransactionType(fyToTransactions, budgets, isDraft);
				EUR_ISP_SpendTransactionsService.addTransactionsToList(fyToTransactions);
			}
		}
		// UPSERT records: transactions
		EUR_ISP_SpendTransactionsService.upsertTransactions();
	}

	private static Map<String, List<EUR_CRM_Budget_Transaction__c>> getAdjsutedTransactions(EUR_ISP_Spend_Activity__c activity, List<EUR_CRM_Budget_Transaction__c> transactions, Map<String, EUR_CRM_Budget__c> budgets)
	{
		Map<String, List<EUR_CRM_Budget_Transaction__c>> draftTransactionsMap = new Map<String, List<EUR_CRM_Budget_Transaction__c>>();
		// Activity Properties
		Date startDate = EUR_ISP_SpendTransactionsService.getActivityStartDate(activity);
		Date endDate = EUR_ISP_SpendTransactionsService.getActivityEndDate(activity);
		// dates are NULL - error!
		if (startDate == null || endDate == null)
		{
			return draftTransactionsMap;
		}

		// Activity Properties
		Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(startDate, endDate);
		String activityTypeBudgetPhasing = activity.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Budget_Phasing__c;
		Integer totalActivityMonths = startDate.monthsBetween(endDate) + 1;
		Set<String> currentFYPeriods = new Set<String>();
		for (Date periodStartDate : periodsMap.keySet())
		{
			String fyString = EUR_ISP_BudgetService.formatFiscalYear(periodStartDate);
			currentFYPeriods.add(fyString);
		}

		// sort transactions by FY and calculate amounts per FY
		Map<String, Decimal> fyStringToAmount = new Map<String, Decimal>();
		for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
		{
			Decimal transactionAmount = -1 * Decimal.valueOf(transactionItem.EUR_CRM_Ind__c + (transactionItem.EUR_CRM_Amount__c != null ? transactionItem.EUR_CRM_Amount__c : 0));
			if (transactionAmount != 0)
			{
				String fyString = transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c;
				Decimal fyAmount = fyStringToAmount.get(fyString) != null ? fyStringToAmount.get(fyString) : 0;
				fyAmount += transactionAmount;
				fyStringToAmount.put(fyString, fyAmount);
			}
		}

		// check if FY periods has been changed
		// Dates has been updated and new FY period has been added. need recalculation
		if (currentFYPeriods.equals(fyStringToAmount.keySet()))
		{
			return draftTransactionsMap;
		}

		// adjust amountsMap with current FYs (add 0 amounts to FYs which are not been added to the Map)
		for (Date periodStartDate : periodsMap.keySet())
		{
			String fyString = EUR_ISP_BudgetService.formatFiscalYear(periodStartDate);
			if (!fyStringToAmount.containsKey(fyString))
			{
				fyStringToAmount.put(fyString, 0);
			}
		}

		if (activityTypeBudgetPhasing == PRORATA_PHASE)
		{
			Decimal amountToTransfer = 0;
			// clear differences for FY budgets
			for (String fyString : fyStringToAmount.keySet())
			{
				Decimal amountToCredit = fyStringToAmount.get(fyString);
				if (amountToCredit != 0 && budgets.containsKey(fyString))
				{
					amountToTransfer += amountToCredit;
					EUR_CRM_Budget_Transaction__c transactionItemCredit = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(fyString), activity, -amountToCredit);
					if (!draftTransactionsMap.containsKey(fyString))
					{
						draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> ());
					}
					draftTransactionsMap.get(fyString).add(transactionItemCredit);
				}
			}

			// genereate new transactions with adjusted amounts
			for (Date periodStartDate : periodsMap.keySet())
			{
				Date periodEndDate = periodsMap.get(periodStartDate);
				Integer periodMonths = periodStartDate.monthsBetween(periodEndDate) + 1;
				Decimal periodAmount = (periodMonths * amountToTransfer / totalActivityMonths).setScale(2);
				if (periodAmount != 0)
				{
					String fyString = EUR_ISP_BudgetService.formatFiscalYear(periodStartDate);
					if (budgets.containsKey(fyString))
					{
						EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(fyString), activity, periodAmount);
						if (!draftTransactionsMap.containsKey(fyString))
						{
							draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c>());
						}
						draftTransactionsMap.get(fyString).add(transactionItem);
					}
				}
			}
		}
		else if (activityTypeBudgetPhasing == START_DATE_PHASE)
		{
			String startFyString = EUR_ISP_BudgetService.formatFiscalYear(startDate);
			String prevStartFYString = '';
			Decimal amountToTransfer = 0;
			// find out the prev FY start (it will be FY with amount > 0)
			for (String fyString : fyStringToAmount.keySet())
			{
				if (fyStringToAmount.get(fyString) != 0)
				{
					prevStartFYString = fyString;
					amountToTransfer = fyStringToAmount.get(fyString);
				}
			}

			if (amountToTransfer != 0 && String.isNotBlank(prevStartFYString) && startFyString != prevStartFYString)
			{
				if (budgets.containsKey(prevStartFYString) && budgets.containsKey(startFyString))
				{
					EUR_CRM_Budget_Transaction__c transactionItemDebit = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(startFyString), activity, amountToTransfer);
					EUR_CRM_Budget_Transaction__c transactionItemCredit = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(prevStartFYString), activity, -amountToTransfer);

					draftTransactionsMap.put(startFyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItemDebit});
					draftTransactionsMap.put(prevStartFYString, new List<EUR_CRM_Budget_Transaction__c> {transactionItemCredit});
				}
			}
		}
		else if (activityTypeBudgetPhasing == END_DATE_PHASE)
		{
			String endFyString = EUR_ISP_BudgetService.formatFiscalYear(endDate);
			String prevEndFYString = '';
			Decimal amountToTransfer = 0;
			// find out the prev FY start (it will be FY with amount > 0)
			for (String fyString : fyStringToAmount.keySet())
			{
				if (fyStringToAmount.containsKey(fyString) && fyStringToAmount.get(fyString) != 0)
				{
					prevEndFYString = fyString;
					amountToTransfer = fyStringToAmount.get(fyString);
				}
			}

			if (amountToTransfer != 0 && String.isNotBlank(prevEndFYString) && endFyString != prevEndFYString)
			{
				if (budgets.containsKey(prevEndFYString) && budgets.containsKey(endFyString))
				{
					EUR_CRM_Budget_Transaction__c transactionItemDebit = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(endFyString), activity, amountToTransfer);
					EUR_CRM_Budget_Transaction__c transactionItemCredit = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(prevEndFYString), activity, -amountToTransfer);

					draftTransactionsMap.put(endFyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItemDebit});
					draftTransactionsMap.put(prevEndFYString, new List<EUR_CRM_Budget_Transaction__c> {transactionItemCredit});
				}
			}
		}//if (activityTypeBudgetPhasing == NO_DEDUCTION_PHASE){}
		return draftTransactionsMap;
	}

	private static Map<String, List<EUR_CRM_Budget_Transaction__c>> getTransactionsToProcess(EUR_ISP_Spend_Activity__c activity, List<EUR_CRM_Budget_Transaction__c> transactions, Map<String, EUR_CRM_Budget__c> budgets, Boolean isDraft)
	{
		Map<String, List<EUR_CRM_Budget_Transaction__c>> transactionsToProcess = new Map<String, List<EUR_CRM_Budget_Transaction__c>>();
		//and Budget Phasing != 'no deduction'
		if (activity.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Budget_Phasing__c == NO_DEDUCTION_PHASE)
		{
			return transactionsToProcess;
		}

		/**
		 * we have transactions:
		 * 1) find out difference between transactions amount and activity amount
		 * 2) generate new transactions
		 */
		for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
		{
			String fyString = transactionItem.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c;
			if (String.isNotBlank(fyString) && budgets.containsKey(fyString))
			{
				if (!transactionsToProcess.containsKey(fyString))
				{
					transactionsToProcess.put(fyString, new List<EUR_CRM_Budget_Transaction__c>());
				}
				transactionsToProcess.get(fyString).add(transactionItem);
			}
		}

		// generate new Transactions if Amount is updated
		Decimal calculatedAmount = EUR_ISP_SpendTransactionsService.getActivityAmountFromTransactions(activity, transactions);
		if (calculatedAmount != 0)
		{
			Map<String, List<EUR_CRM_Budget_Transaction__c>> newDrafts = EUR_ISP_SpendTransactionsService.generateNewDraftTransactions(activity, budgets, calculatedAmount);

			for (String fyString : newDrafts.keySet())
			{
				if (!transactionsToProcess.containsKey(fyString))
				{
					transactionsToProcess.put(fyString, new List<EUR_CRM_Budget_Transaction__c>());
				}
				transactionsToProcess.get(fyString).addAll(newDrafts.get(fyString));
			}
		}

		EUR_ISP_SpendTransactionsService.adjustTransactionType(transactionsToProcess, budgets, isDraft);
		return transactionsToProcess;
	}

	// Expected: 1 draft transaction per 1 budget
	private static Map<String, List<EUR_CRM_Budget_Transaction__c>> generateNewDraftTransactions(EUR_ISP_Spend_Activity__c activity, Map<String, EUR_CRM_Budget__c> budgets, Decimal calculatedAmount)
	{
		EUR_CRM_Budget__c dummyBudget;

		Boolean isUpdatedAndInPast = false;
		Boolean isStartDateAndEndDateInPast = false;

		Map<String, List<EUR_CRM_Budget_Transaction__c>> draftTransactionsMap = new Map<String, List<EUR_CRM_Budget_Transaction__c>>();
		// Activity Properties
		String activityTypeBudgetPhasing = activity.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Budget_Phasing__c;
		Date startDate = EUR_ISP_SpendTransactionsService.getActivityStartDate(activity);
		Date endDate = EUR_ISP_SpendTransactionsService.getActivityEndDate(activity);

		// dates are NULL - error!
		if (startDate == null || endDate == null || calculatedAmount == 0)
		{
			return draftTransactionsMap;
		}

		// If Activities updated and Start Date in the Past or current FY => Transaction should be created for current FY
		// otherwise split between FYs
		if (EUR_ISP_SpendTransactionsService.isUpdateAction)
		{
			Date currentDate = Date.today();
			Integer currentFY = Integer.valueOf( EUR_ISP_BudgetService.formatFiscalYear(currentDate).replace('FY', ''));
			Integer activityStartFY = Integer.valueOf( EUR_ISP_BudgetService.formatFiscalYear(startDate).replace('FY', ''));
			Integer activityEndFY = Integer.valueOf( EUR_ISP_BudgetService.formatFiscalYear(endDate).replace('FY', ''));

			if (activityStartFY < currentFY)
			{
				isUpdatedAndInPast = true;
				
				if (activityEndFY < currentFY) isStartDateAndEndDateInPast = true;
				dummyBudget = EUR_ISP_BudgetService.createDummyBudget(activity);
				//startDate = Date.today();
				//endDate = Date.today();
			}
		}

		if (activityTypeBudgetPhasing == PRORATA_PHASE)
		{
			calculatedAmount = calculateAmountFoeMathedActivity(calculatedAmount, activity);
			
			if (isStartDateAndEndDateInPast)
			{
				String fyString = EUR_ISP_BudgetService.formatFiscalYear(startDate);
				/*if (budgets.containsKey(fyString))
				{*/
				EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(dummyBudget, activity, calculatedAmount);
				draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
				//}
			}
			else
			{
				Integer totalActivityMonths = startDate.monthsBetween(endDate) + 1;
				Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(startDate, endDate);

				Integer currentFY = Integer.valueOf( EUR_ISP_BudgetService.formatFiscalYear(Date.today()).replace('FY', ''));

				for (Date periodStartDate : periodsMap.keySet())
				{
					Date periodEndDate = periodsMap.get(periodStartDate);
					Integer periodMonths = periodStartDate.monthsBetween(periodEndDate) + 1;
					Decimal periodAmount = (periodMonths * calculatedAmount / totalActivityMonths).setScale(2);

					periodAmount = calculateAmountFoeMathedActivity(periodAmount, activity);

					Integer periodStartFY = Integer.valueOf( EUR_ISP_BudgetService.formatFiscalYear(periodStartDate).replace('FY', ''));
					Integer periodEndFY = Integer.valueOf( EUR_ISP_BudgetService.formatFiscalYear(periodEndDate).replace('FY', ''));

					if (periodAmount != 0)
					{
						String fyString = EUR_ISP_BudgetService.formatFiscalYear(periodStartDate);
						if (periodStartFY < currentFY && periodEndFY < currentFY) 
						{
							System.debug('All in past');
							EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(dummyBudget, activity, periodAmount);
							draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
						}
						else 
						{
							if (budgets.containsKey(fyString))
							{
								EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(fyString), activity, periodAmount);
								draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
							}
						}
					}
				}
			}
		}
		else if (activityTypeBudgetPhasing == START_DATE_PHASE)
		{
			String fyString = EUR_ISP_BudgetService.formatFiscalYear(startDate);

			if (isUpdatedAndInPast)
			{
				EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(dummyBudget, activity, calculatedAmount);
				draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
			}
			else {
				if (budgets.containsKey(fyString))
				{
					EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(fyString), activity, calculatedAmount);
					draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
				}
			}
		}
		else if (activityTypeBudgetPhasing == END_DATE_PHASE)
		{
			String fyString = EUR_ISP_BudgetService.formatFiscalYear(endDate);

			if (isUpdatedAndInPast)
			{
				EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(dummyBudget, activity, calculatedAmount);
				draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
			}
			else 
			{
				if (budgets.containsKey(fyString))
				{
					EUR_CRM_Budget_Transaction__c transactionItem = EUR_ISP_SpendTransactionsService.generateDraftTransactionRecord(budgets.get(fyString), activity, calculatedAmount);
					draftTransactionsMap.put(fyString, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
				}
			}

		}//if (activityTypeBudgetPhasing == NO_DEDUCTION_PHASE){}
		return draftTransactionsMap;
	}

	private static Decimal calculateAmountFoeMathedActivity(Decimal amount, EUR_ISP_Spend_Activity__c activity) 
	{
		if (activity.EUR_ISP_Matched__c != 0 && activity.EUR_ISP_Matched__c != null) 
		{
			Decimal spendActivityTotalAmount = activity.EUR_ISP_Total_Activity_Amount__c;
			Decimal amountWithoutMatched = spendActivityTotalAmount - activity.EUR_ISP_Matched__c;

			return (amount/spendActivityTotalAmount) * amountWithoutMatched;
		}
		else return amount;
	}

	private static Decimal getActivityAmountFromTransactions(EUR_ISP_Spend_Activity__c activity, List<EUR_CRM_Budget_Transaction__c> transactions)
	{
		if (activity.RecordTypeId != spendActivitySFARecordTypeId)
		{
			Decimal totalAmount = 0;
			for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
			{
				Decimal transactionAmount = -1 * Decimal.valueOf(transactionItem.EUR_CRM_Ind__c + (transactionItem.EUR_CRM_Amount__c != null ? transactionItem.EUR_CRM_Amount__c : 0));
				totalAmount += transactionAmount;
			}
			System.debug('EUR_ISP_Total_Activity_Amount__c: ' + activity.EUR_ISP_Total_Activity_Amount__c);
			System.debug('totalAmount: ' + totalAmount);
			System.debug('calculatedAmount: ' + (activity.EUR_ISP_Total_Activity_Amount__c - totalAmount));
			return activity.EUR_ISP_Total_Activity_Amount__c - totalAmount;
		}

		List<EUR_CRM_Budget_Transaction__c> spendTransactions = new List<EUR_CRM_Budget_Transaction__c>();
		Decimal totalAmount = 0;
		Id theSpendId = activity.EUR_ISP_Spend__c;

		// get Spend Transactions inculding the contract transactions
		if (spendIdToTransactionsList.containsKey(theSpendId) && spendIdToTransactionsList.containsKey(theSpendId))
		{
			spendTransactions.addAll(spendIdToTransactionsList.get(theSpendId));
		}

		for (EUR_CRM_Budget_Transaction__c transactionItem : spendTransactions)
		{
			Decimal transactionAmount = -1 * Decimal.valueOf(transactionItem.EUR_CRM_Ind__c + (transactionItem.EUR_CRM_Amount__c != null ? transactionItem.EUR_CRM_Amount__c : 0));
			totalAmount += transactionAmount;
		}

		Decimal totalSpendAmount = 0;
		Map<Id, EUR_ISP_Spend_Activity__c> activitiesMap = spendIdToActivitiesMap.containsKey(theSpendId) ? spendIdToActivitiesMap.get(theSpendId) : new Map<Id, EUR_ISP_Spend_Activity__c>();
		for (EUR_ISP_Spend_Activity__c theSpendActivity : activitiesMap.values())
		{
			totalSpendAmount += theSpendActivity.EUR_ISP_Total_Activity_Amount__c;
		}
		System.debug('totalSpendAmount: ' + totalSpendAmount);
		System.debug('totalAmount: ' + totalAmount);
		System.debug('calculatedAmount: ' + (totalSpendAmount - totalAmount));
		return totalSpendAmount - totalAmount;
	}

	private static void addTransactionsToList(Map<String, List<EUR_CRM_Budget_Transaction__c>> transactionsToProcess)
	{
		for (String fyString : transactionsToProcess.keySet())
		{
			List<EUR_CRM_Budget_Transaction__c> tmpTransactions = transactionsToProcess.get(fyString);
			if (tmpTransactions != null && !tmpTransactions.isEmpty())
			{
				transactionsToUsert.addAll(tmpTransactions);
			}
		}
	}

	/**
	 * Upset transactions
	 */
	private static void upsertTransactions()
	{
		if (!transactionsToUsert.isEmpty())
		{
			upsert transactionsToUsert;
		}
	}

	/**
	 * setup Budget's Map for the given Activities
	 * Key: owner ID => Budget FY => EUR_CRM_Budget__c
	 */
	private static void setFYBudgets()
	{
		// get *FY periods + prev period* for all activities and retrieve Budgets
		Set<String> fyYearsString = new Set<String>();
		fyYearsString.add(EUR_ISP_BudgetService.formatFiscalYear( Date.today() ));

		Set<Id> ownerIds = ownerIdToActivities.keySet();
		for (List<EUR_ISP_Spend_Activity__c> activities : ownerIdToActivities.values())
		{
			for (EUR_ISP_Spend_Activity__c theSpendActivity : activities)
			{
				Date startDate = theSpendActivity.EUR_ISP_Spend__r.EUR_ISP_Start_Date__c;
				Date endDate = theSpendActivity.EUR_ISP_Spend__r.EUR_ISP_End_Date__c;
				if (startDate == null || endDate == null)
				{
					continue;
				}

				Date prevFyDate = EUR_ISP_BudgetService.FY_START_PERIOD;
				prevFyDate = prevFyDate > startDate ? startDate : prevFyDate;

				Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(prevFyDate, endDate);
				for (Date theStartDate : periodsMap.keySet())
				{
					System.debug('#### pre-budget fyString: ' + EUR_ISP_BudgetService.formatFiscalYear( theStartDate ));
					fyYearsString.add(EUR_ISP_BudgetService.formatFiscalYear( theStartDate ));
				}
			}
		}

		System.debug('#### fyYearsString: ' + fyYearsString);
		// get budgets and sort them by FY Key and OwnerId
		for (EUR_CRM_Budget__c budget : EUR_ISP_BudgetService.getBudgets(ownerIds, fyYearsString))
		{
			//System.debug('#### budget: ' + budget.EUR_CRM_Fiscal_Year__c);
			if (!ownerIdToBudgets.containsKey(budget.OwnerId))
			{
				ownerIdToBudgets.put(budget.OwnerId, new Map<String, EUR_CRM_Budget__c>());
			}
			ownerIdToBudgets.get(budget.OwnerId).put(budget.EUR_CRM_Fiscal_Year__c, budget);
		}

		System.debug('#### fyYearsString: ' + ownerIdToBudgets);
		// check FY Budgets and create new one if does not exists for appropriate period
		List<EUR_CRM_Budget__c> budgetsToCreate = new List<EUR_CRM_Budget__c>();
		for (List<EUR_ISP_Spend_Activity__c> activities : ownerIdToActivities.values())
		{
			for (EUR_ISP_Spend_Activity__c theSpendActivity : activities)
			{
				Date startDate = theSpendActivity.EUR_ISP_Spend__r.EUR_ISP_Start_Date__c;
				Date endDate = theSpendActivity.EUR_ISP_Spend__r.EUR_ISP_End_Date__c;
				Id spendOwnerId = theSpendActivity.EUR_ISP_Spend__r.OwnerId;
				if (startDate == null || endDate == null)
				{
					continue;
				}

				Map<Date, Date> periodsMap = EUR_ISP_BudgetService.getPeriodsMap(startDate, endDate);
				for (Date theStartDate : periodsMap.keySet())
				{
					// exceptional case: Owner does not have Budgets
					if (!ownerIdToBudgets.containsKey( spendOwnerId ))
					{
						continue;
					}

					String fyString = EUR_ISP_BudgetService.formatFiscalYear(theStartDate);
					System.debug('#### budget fyString: ' + fyString);
					// budget already created
					if (ownerIdToBudgets.get( spendOwnerId ).containsKey( fyString ))
					{
						continue;
					}

					// make sure that old budget exists
					// generate new Budget
					if (!ownerIdToBudgets.get( spendOwnerId ).isEmpty())
					{
						EUR_CRM_Budget__c oldBudget = ownerIdToBudgets.get( spendOwnerId ).values().get(0);
						EUR_CRM_Budget__c newBudget = EUR_ISP_BudgetService.cloneBudget( oldBudget, theStartDate );

						ownerIdToBudgets.get( spendOwnerId ).put( fyString, newBudget );
						budgetsToCreate.add( newBudget );
					}
				}
			}
		}
		insert budgetsToCreate;
	}

	/**
	 * setup Map with Transactions for the given Spend IDs Set and Spend Activities List
	 */
	public static void setAllTransactions(Set<Id> spendIds)
	{
		for (EUR_CRM_Budget_Transaction__c transactionItem : EUR_ISP_SpendTransactionsService.getAllTransactions(spendIds))
		{
			Id activityId = transactionItem.EUR_CRM_Spend_Activity__c;
			Id spendId = transactionItem.EUR_CRM_Spend__c;
			System.debug('### transactionItem: ' + transactionItem.Id + '  ' + activityId + '  ' + spendId + '  ' + transactionItem.EUR_CRM_Amount__c);
			//if (activityId == null || )
			//{
			if (!spendIdToTransactionsList.containsKey(spendId))
			{
				spendIdToTransactionsList.put(spendId, new List<EUR_CRM_Budget_Transaction__c>());
			}
			spendIdToTransactionsList.get(spendId).add(transactionItem);
			//	continue;
			//}

			if (!spendIdToTransactionsMap.containsKey(spendId))
			{
				spendIdToTransactionsMap.put(spendId, new Map<Id, List<EUR_CRM_Budget_Transaction__c>>());
			}
			if (!spendIdToTransactionsMap.get(spendId).containsKey(activityId))
			{
				spendIdToTransactionsMap.get(spendId).put(activityId, new List<EUR_CRM_Budget_Transaction__c>());
			}
			spendIdToTransactionsMap.get(spendId).get(activityId).add(transactionItem);
		}
	}

	/**
	 * returns spend transactions
	 */
	public static List<EUR_CRM_Budget_Transaction__c> getAllTransactions(Set<Id> spendIds)
	{
		return [SELECT Id, RecordTypeId, EUR_CRM_Description__c, EUR_CRM_Transfer_From_Budget_Header__c,
		        EUR_CRM_Contract__c, EUR_CRM_Amount__c, EUR_CRM_Transaction_Category__c, EUR_CRM_Transaction_Type__c, EUR_CRM_Ind__c, EUR_CRM_Transfer_From__c, EUR_CRM_Transfer_To__c,
		        EUR_CRM_Budget_Header__c, EUR_CRM_Budget_Header__r.OwnerId, EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c,
		        EUR_CRM_Spend_Activity__c, EUR_CRM_Spend_Activity__r.EUR_ISP_Total_Activity_Amount__c, EUR_CRM_Spend_Activity__r.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Budget_Phasing__c,
		        EUR_CRM_Spend__c, EUR_CRM_Spend__r.OwnerId
		        FROM EUR_CRM_Budget_Transaction__c
		        WHERE EUR_CRM_Spend__c IN : spendIds];
	}

	/**
	 * returns spend activities
	 */
	public static List<EUR_ISP_Spend_Activity__c> getSpendActivities(List<EUR_ISP_Spend_Activity__c> activities)
	{
		Set<Id> spendIds = new Set<Id>();
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			spendIds.add(activity.EUR_ISP_Spend__c);
		}
		return [SELECT Id, EUR_ISP_Total_Activity_Amount__c, EUR_ISP_Activity_Start_Date__c, EUR_ISP_Activity_End_Date__c, EUR_ISP_Status__c,
		        EUR_ISP_Sales_In_Start_Date__c, EUR_ISP_Sales_In_End_Date__c, EUR_ISP_Sales_Out_Start_Date__c, EUR_ISP_Sales_Out_End_Date__c,
		        EUR_ISP_Spend__c, EUR_ISP_Spend__r.OwnerId, EUR_ISP_Spend__r.EUR_ISP_Start_Date__c, EUR_ISP_Spend__r.EUR_ISP_End_Date__c,
		        EUR_ISP_Spend__r.EUR_ISP_Amount__c, EUR_ISP_Matched__c,
		        EUR_ISP_Spend_Activity_Type__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Budget_Phasing__c, RecordTypeId
		        FROM EUR_ISP_Spend_Activity__c WHERE EUR_ISP_Spend__c IN : spendIds];
	}


	/**
	 * generates new Budget Transaction Record
	 */
	private static EUR_CRM_Budget_Transaction__c generateDraftTransactionRecord(EUR_CRM_Budget__c budget, EUR_ISP_Spend_Activity__c activity, Decimal amount)
	{
		final Boolean isLessThanNull = amount < 0;
		final Id tRecordTypeId = EUR_ISP_Utils.getRecordTypesMap().get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_DRAFT_RT_NAME_WKZ);

		return new EUR_CRM_Budget_Transaction__c(
		           EUR_CRM_Budget_Header__c =  budget.Id,
		           EUR_CRM_Spend_Activity__c = activity.Id,
		           EUR_CRM_Spend__c = activity.EUR_ISP_Spend__c,
		           EUR_CRM_Amount__c = Math.abs(amount),
		           EUR_CRM_Transaction_Category__c = EUR_ISP_BudgetService.CATEGORY_NAME_DRAFT,
		           EUR_CRM_Transaction_Type__c = isLessThanNull ? EUR_ISP_BudgetService.CREDIT : EUR_ISP_BudgetService.DEBIT,
		           RecordTypeId = tRecordTypeId
		       );
	}

	/**
	 * Update Transaction Category|RecordType based on Budget RT and Activity Status
	 */
	private static void adjustTransactionType(Map<String, List<EUR_CRM_Budget_Transaction__c>> transactionsToProcess, Map<String, EUR_CRM_Budget__c> budgets, Boolean isDraft)
	{
		final String categoryName = isDraft ? EUR_ISP_BudgetService.CATEGORY_NAME_DRAFT : EUR_ISP_BudgetService.CATEGORY_NAME_SPEND;
		final Map<String, Id> rtMaps = EUR_ISP_Utils.getRecordTypesMap();

		for (String fyString : transactionsToProcess.keySet())
		{
			Id draftRecordTypeId = rtMaps.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_DRAFT_RT_NAME_WKZ);
			Id recordTypeId = rtMaps.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_RT_NAME_WKZ);
			EUR_CRM_Budget__c budget = budgets.get(fyString);

			//System.debug('###### budgetSpendRecordTypeId: ' + budget);
			if (budget != null && budget.RecordTypeId == budgetSpendRecordTypeId)
			{
				draftRecordTypeId = rtMaps.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_DRAFT_RT_NAME_ISPEND);
				recordTypeId = rtMaps.get(EUR_ISP_BudgetService.EUR_CRM_BUDGET_TRANSACTION_API_NAME + EUR_ISP_BudgetService.TRANSACTION_RT_NAME_ISPEND);
			}

			//Id rectTypeIdToCheck = isDraft ? recordTypeId : draftRecordTypeId;
			List<EUR_CRM_Budget_Transaction__c> transactionsTmp = transactionsToProcess.get(fyString);
			for (EUR_CRM_Budget_Transaction__c transactionItem : transactionsTmp)
			{
				if (transactionItem.EUR_CRM_Transaction_Category__c != EUR_ISP_BudgetService.CATEGORY_NAME_DRAFT &&
				        transactionItem.EUR_CRM_Transaction_Category__c != EUR_ISP_BudgetService.CATEGORY_NAME_SPEND)
				{
					continue;
				}

				transactionItem.RecordTypeId = isDraft ? draftRecordTypeId : recordTypeId;
				transactionItem.EUR_CRM_Transaction_Category__c = categoryName;
			}
		}
	}

	/**
	 * check if the Spend Activity Status acceptable for Budget transaction logic
	 */
	public static Boolean isAcceptableStatus(String status)
	{
		return String.isNotBlank(status) &&
		       (acceptableDraftStatuses.contains(status) ||
		        acceptableStatuses.contains(status)) || status == EUR_ISP_Utils.CANCELLED_STATUS;
	}

	/**
	 * get Activity Start Date
	 */
	public static Date getActivityStartDate(EUR_ISP_Spend_Activity__c activity)
	{
		Date startDate = activity.EUR_ISP_Activity_Start_Date__c == null ? (
		                     activity.EUR_ISP_Sales_In_Start_Date__c == null ?
		                     activity.EUR_ISP_Sales_Out_Start_Date__c :
		                     activity.EUR_ISP_Sales_In_Start_Date__c
		                 ) :
		                 activity.EUR_ISP_Activity_Start_Date__c;
		// if these dates are still NULL => get dates from the Spend record (they should not be equal NULL)
		if (startDate == null)
		{
			startDate = activity.EUR_ISP_Spend__r.EUR_ISP_Start_Date__c;
		}
		return startDate;
	}

	/**
	 * get Activity End Date
	 */
	public static Date getActivityEndDate(EUR_ISP_Spend_Activity__c activity)
	{
		Date endDate = activity.EUR_ISP_Activity_End_Date__c == null ? (
		                   activity.EUR_ISP_Sales_In_End_Date__c == null ?
		                   activity.EUR_ISP_Sales_Out_End_Date__c :
		                   activity.EUR_ISP_Sales_In_End_Date__c
		               ) : activity.EUR_ISP_Activity_End_Date__c;
		// if these dates are still NULL => get dates from the Spend record (they should not be equal NULL)
		if (endDate == null)
		{
			endDate = activity.EUR_ISP_Spend__r.EUR_ISP_End_Date__c;
		}
		return endDate;
	}
}