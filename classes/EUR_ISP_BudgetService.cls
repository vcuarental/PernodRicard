/**
 * Budget Service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_BudgetService
{
	public static final String EUR_CRM_BUDGET_API_NAME = 'EUR_CRM_Budget__c';
	public static final String BUDGET_RT_NAME_ISPEND = 'EUR_ISP_iSpend';
	public static final String BUDGET_RT_NAME_CONTRACT = 'EUR_DE_On_Trade_WKZ';

	public static final String EUR_CRM_BUDGET_TRANSACTION_API_NAME = 'EUR_CRM_Budget_Transaction__c';
	public static final String TRANSACTION_DRAFT_RT_NAME_WKZ = 'EUR_DE_On_Trade_WKZ_Draft_Transaction';
	public static final String TRANSACTION_RT_NAME_WKZ = 'EUR_DE_On_Trade_WKZ';
	public static final String TRANSACTION_RT_NAME_ISPEND = 'EUR_ISP_iSpend';
	public static final String TRANSACTION_DRAFT_RT_NAME_ISPEND = 'EUR_ISP_iSpend_Draft_Transaction';

	public static final String CATEGORY_NAME_DRAFT = 'Draft Spend Transaction';
	public static final String CATEGORY_NAME_SPEND = 'Spend Transaction';
	public static final String CATEGORY_NAME_INVOICE = 'Invoice Tracker Adjustment';
	public static final String CREDIT = 'Credit';
	public static final String DEBIT = 'Debit';

	public static final Organization FY_ORG_DETAILS = null;
	public static final Date CURRENT_FY_START = null;
	public static final Date FY_START_PERIOD = null;
	static
	{
		if (FY_ORG_DETAILS == null)
		{
			FY_ORG_DETAILS = EUR_CRM_BudgetUtil.retrieveFiscalYearOrg();
			CURRENT_FY_START = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
			FY_START_PERIOD = CURRENT_FY_START.addYears(-1);
		}
	}

	private static final Id DUMMY_BUDGET_OWNER_ID 
    {
        get
        {
            if (DUMMY_BUDGET_OWNER_ID == null)
            {
				ISP_Setting__mdt ispSetting = [SELECT Value__c FROM ISP_Setting__mdt WHERE DeveloperName = 'DummyBudgetOwnerName'];
				List<User> userList = [SELECT Id FROM User WHERE Name = :ispSetting.Value__c];
				DUMMY_BUDGET_OWNER_ID = !userList.isEmpty() ? userList[0].Id : UserInfo.getUserId();
            }
            return DUMMY_BUDGET_OWNER_ID;
        }
        set;
    }


	public static List<EUR_CRM_Budget__c> getBudgets(Set<Id> ownerIds, Set<String> contracFYs)
	{
		return [SELECT Id, OwnerId, EUR_CRM_Fiscal_Year__c, EUR_CRM_External_ID__c,
		        EUR_CRM_User_Role_Type__c, EUR_CRM_Allocated_Budget__c, EUR_CRM_Carry_Forward__c,
		        RecordTypeId, RecordType.DeveloperName
		        FROM EUR_CRM_Budget__c
		        WHERE OwnerId IN: ownerIds AND EUR_CRM_Fiscal_Year__c IN: contracFYs];
	}

	/**
	 * check if Current transactions has Draft RTs
	 */
	public static Boolean isDraftTransactions(List<EUR_CRM_Budget_Transaction__c> transactions)
	{
		final Map<String, Id> rtMaps = EUR_ISP_Utils.getRecordTypesMap();
		Set<Id> draftRecordTypeIds = new Set<Id>();
		draftRecordTypeIds.add(rtMaps.get(EUR_CRM_BUDGET_TRANSACTION_API_NAME + TRANSACTION_DRAFT_RT_NAME_WKZ));
		draftRecordTypeIds.add(rtMaps.get(EUR_CRM_BUDGET_TRANSACTION_API_NAME + TRANSACTION_DRAFT_RT_NAME_ISPEND));

		Boolean isDraft = true;
		for (EUR_CRM_Budget_Transaction__c transactionItem : transactions)
		{
			if ((transactionItem.EUR_CRM_Transaction_Category__c != CATEGORY_NAME_DRAFT &&
			        transactionItem.EUR_CRM_Transaction_Category__c != CATEGORY_NAME_SPEND) || !isDraft)
			{
				continue;
			}
			if (isDraft && draftRecordTypeIds.contains(transactionItem.RecordTypeId))
			{
				isDraft = true;
			}
			else
			{
				isDraft = false;
			}
		}
		return isDraft;
	}

	/**
	 * Create Invoice Budget for the given Activity
	 */
	public static void createBudgetTransactionRecord(String activityId, String categoryName)
	{
		List<EUR_ISP_Spend_Activity__c> spendActivities = [SELECT Id, EUR_ISP_Spend__r.OwnerId, EUR_ISP_Matched__c, EUR_ISP_Status__c,
										EUR_ISP_Total_Activity_Amount__c, EUR_ISP_Activity_Amount__c
										FROM EUR_ISP_Spend_Activity__c
										WHERE Id = :activityId];
		if (spendActivities.isEmpty())
		{
		return;
		}

		EUR_ISP_Spend_Activity__c theSpendActivity = spendActivities.get(0);
		Decimal amountToTheBudget = theSpendActivity.EUR_ISP_Total_Activity_Amount__c - theSpendActivity.EUR_ISP_Matched__c;
		EUR_CRM_Budget__c theBudget = EUR_ISP_BudgetService.getUserBudget(theSpendActivity.EUR_ISP_Spend__r.OwnerId);
		if (theBudget != null)
		{
		EUR_CRM_Budget_Transaction__c theTransaction = new EUR_CRM_Budget_Transaction__c();
		theTransaction.EUR_CRM_Budget_Header__c = theBudget.Id;
		theTransaction.EUR_CRM_Spend_Activity__c = activityId;
		theTransaction.EUR_CRM_Transaction_Category__c = categoryName;
		theTransaction.EUR_CRM_Transaction_Type__c = CREDIT;
		theTransaction.EUR_CRM_Amount__c = amountToTheBudget;
		theTransaction.RecordTypeId = EUR_ISP_Utils.getRecordTypesMap().get(EUR_CRM_BUDGET_TRANSACTION_API_NAME + TRANSACTION_RT_NAME_WKZ);

		if (theSpendActivity.EUR_ISP_Matched__c == 0)
		{
			theSpendActivity.EUR_ISP_Status__c = EUR_ISP_Utils.CANCELLED_STATUS;
		}
		else
		{
			theSpendActivity.EUR_ISP_Activity_Amount__c = (theSpendActivity.EUR_ISP_Activity_Amount__c != null ? theSpendActivity.EUR_ISP_Activity_Amount__c : 0) - amountToTheBudget;
			theSpendActivity.EUR_ISP_Status__c = EUR_ISP_Utils.INVOICED_STATUS;
		}
		insert theTransaction;
		update theSpendActivity;
		}
	}

	//create get a dummy budget
	public static EUR_CRM_Budget__c createDummyBudget(EUR_ISP_Spend_Activity__c theSpendActivity) 
	{
		Date spendActStartDate = theSpendActivity.EUR_ISP_Activity_Start_Date__c;
		String spendActivityFY = EUR_ISP_BudgetService.formatFiscalYear(spendActStartDate);

		String budgetExternalUd = 'DUMMY_' + spendActivityFY;

		//check if there in existing dummy budget for the Spend Activity 
		List<EUR_CRM_Budget__c> dummyBudgetList = [SElECT EUR_CRM_Fiscal_Year__c, OwnerId, EUR_CRM_External_ID__c, EUR_CRM_Carry_Forward__c 
			FROM EUR_CRM_Budget__c WHERE EUR_CRM_External_ID__c = :budgetExternalUd];

		if (!dummyBudgetList.isEmpty()) 
		{
			return dummyBudgetList.get(0);
		}

		//create a new dummy budget if there is no dummy budget for the Spend Activity 
		EUR_CRM_Budget__c newDummmyBudget = new EUR_CRM_Budget__c(
			OwnerId = DUMMY_BUDGET_OWNER_ID,
			EUR_CRM_Fiscal_Year__c = spendActivityFY,
			EUR_CRM_External_ID__c = budgetExternalUd,
			EUR_CRM_Allocated_Budget__c = 0,
			EUR_CRM_Carry_Forward__c = 0
		);

		insert newDummmyBudget;
		return newDummmyBudget;
	}

	/**
	 * returns Current FY's Budget for the given User ID
	 */
	public static EUR_CRM_Budget__c getUserBudget(Id ownerId)
	{
		String currentFiscalYearString = EUR_ISP_BudgetService.formatFiscalYear(Date.today());
		EUR_CRM_Budget__c output = null;

		for (EUR_CRM_Budget__c budget : [SELECT Id, OwnerId, CurrencyIsoCode, EUR_CRM_Allocated_Budget__c, EUR_CRM_Carry_Forward__c, EUR_CRM_Current_Balance__c,
		                                 EUR_CRM_Fiscal_Year__c, EUR_CRM_Remaining_Balance__c, EUR_CRM_Actual_Budget__c,
		                                 RecordTypeId, RecordType.DeveloperName
		                                 FROM EUR_CRM_Budget__c
		                                 WHERE EUR_CRM_Fiscal_Year__c = : currentFiscalYearString AND OwnerId = : ownerId])
		{
			output = budget;
			break;
		}
		return output;
	}

	/**
	 * returns Current FY's Budget for Current User
	 */
	public static EUR_CRM_Budget__c getCurrentBudget()
	{
		return EUR_ISP_BudgetService.getUserBudget(UserInfo.getUserId());
	}

	/**
	 * clone budget from existing and update FY information for the given FY date
	 */
	public static EUR_CRM_Budget__c cloneBudget(EUR_CRM_Budget__c budget, Date fiscalYear)
	{
		String fiscalYearString = EUR_ISP_BudgetService.formatFiscalYear(fiscalYear);
		return EUR_ISP_BudgetService.cloneBudget(budget, fiscalYearString);
	}

	/**
	 * clone budget from existing and update FY information for the given FY date
	 */
	public static EUR_CRM_Budget__c cloneBudget(EUR_CRM_Budget__c budget, String fiscalYearString)
	{
		//Create external Id
		String externalId = budget.EUR_CRM_External_ID__c != null ? budget.EUR_CRM_External_ID__c.replace(budget.EUR_CRM_Fiscal_Year__c, fiscalYearString) : null;
		EUR_CRM_Budget__c newBudget = budget.clone(false, true);
		newBudget.EUR_CRM_Fiscal_Year__c = fiscalYearString;
		newBudget.EUR_CRM_External_ID__c = externalId;
		newBudget.EUR_CRM_Allocated_Budget__c = 0;
		newBudget.EUR_CRM_Carry_Forward__c = 0;
		return newBudget;
	}

	/**
	 * check if  the date in current Date range
	 */
	public static Boolean isDateBetween(Date curDate, Date startDate, Date endDate)
	{
		return startDate <= curDate && curDate < endDate;
	}

	/**
	 * covert FY date to the String
	 */
	public static String formatFiscalYear(Date theDate)
	{
		String outputStr = '';
		if (theDate != null)
		{
			Integer yearFullNumber = theDate.month() >= FY_ORG_DETAILS.FiscalYearStartMonth ? (theDate.year() + 1) : theDate.year();
			outputStr = 'FY' + String.valueOf(yearFullNumber).substring(2);
		}
		return outputStr;
	}

	/**
	 * returns the Current FY date
	 */
	public static Date getCurrentFiscalYear()
	{
		return CURRENT_FY_START;
	}

	public static Map<Date, Date> getPeriodsMap(Date startDate, Date endDate)
	{
		Map<Date, Date> periods = new Map<Date, Date>();
		if (endDate == null || startDate == null )
		{
			return periods;
		}

		Date startFYPeriod = FY_START_PERIOD;
		if (startDate < startFYPeriod)
		{
			startFYPeriod = startFYPeriod.addYears(startFYPeriod.year() - startDate.year() - 2);
		}

		while (startDate <= endDate)
		{
			if (startDate == startFYPeriod)
			{
				startFYPeriod = startFYPeriod.addYears(1);
				continue;
			}
			if (startDate == endDate)
			{
				periods.put(startDate, endDate);
				break;
			}

			if (startDate > endDate)
			{
				periods.put(startFYPeriod, endDate);
				break;
			}

			if (startDate <= startFYPeriod && endDate > startFYPeriod)
			{
				periods.put(startDate, startFYPeriod.addMonths(-1));

				startDate = startFYPeriod;
				startFYPeriod = startFYPeriod.addYears(1);
				continue;
			}

			if (startDate <= startFYPeriod && endDate <= startFYPeriod)
			{
				periods.put(startDate, endDate);

				startDate = startFYPeriod;
				startFYPeriod = startFYPeriod.addYears(1);
				continue;
			}
			startFYPeriod = startFYPeriod.addYears(1);
		}
		return periods;
	}
}