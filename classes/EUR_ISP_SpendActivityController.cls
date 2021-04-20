/**
 * Apex Controller for SpendActivity components of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendActivityController
{
	@AuraEnabled
	public static EUR_ISP_Spend_Activity__c getById(String activityId)
	{
		EUR_ISP_Spend_Activity__c activityItem = new EUR_ISP_Spend_Activity__c();
		if (String.isBlank(activityId))
		{
			return activityItem;
		}

		activityId = String.escapeSingleQuotes(activityId);
		for (EUR_ISP_Spend_Activity__c activity : [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Description__c,
		        EUR_ISP_Activity_Start_Date__c, EUR_ISP_Activity_End_Date__c, EUR_ISP_Sales_In_Start_Date__c, EUR_ISP_Sales_In_End_Date__c,
		        EUR_ISP_Sales_Out_Start_Date__c, EUR_ISP_Sales_Out_End_Date__c, EUR_ISP_Conditional__c, EUR_ISP_Visible__c,
		        EUR_ISP_Approval_Status__c, EUR_ISP_Status__c, EUR_ISP_Settlement_Method__c, EUR_ISP_Matched__c, EUR_ISP_Total_Matched__c,
		        EUR_ISP_Activity_Amount__c, EUR_ISP_Total_Activity_Amount__c, EUR_ISP_Total_Spend_Items_Amount__c, EUR_ISP_Payment_Terms__c,
		        EUR_ISP_Spend_Activity_Type__c, EUR_ISP_Spend_Activity_Type__r.Name, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Product_Level_Of_Input__c,
		        EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c,
		        EUR_ISP_Spend__c, EUR_ISP_Spend__r.Name, EUR_ISP_Spend__r.OwnerId,
		        EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c,
		        RecordTypeId, RecordType.Name,
		        (SELECT Id, EUR_ISP_Amount__c, EUR_ISP_Settlement__r.EUR_ISP_Internal_Doc_Number__c, EUR_ISP_Settlement__r.EUR_ISP_Vendor_Invoice_Number__c, EUR_ISP_Settlement__c,
		         EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity__r.Name
		         FROM Settlement_Lines_EU__r)
		        // ,
		        //(SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Lump_Sum_1__c, EUR_ISP_Lump_Sum_2__c, EUR_ISP_Percentage__c,
		        // EUR_ISP_Per_Unit_Amount__c, EUR_ISP_Total_Spend_Item__c, EUR_ISP_Matched__c, EUR_ISP_Available_Amount__c, EUR_ISP_Unit_Of_Measure__c, EUR_ISP_Volume__c,
		        // EUR_ISP_Brand__r.Name,
		        // EUR_ISP_Brand_Quality__r.Name,
		        // EUR_ISP_Brand_Quality_Size__r.Name,
		        // EUR_ISP_Family__r.Name,
		        // EUR_ISP_SKU_EU__r.Name
		        // FROM Spend_Items_EU__r)
		        FROM EUR_ISP_Spend_Activity__c WHERE Id = :activityId])
		{
			activityItem = activity;
		}
		return activityItem;
	}

	@AuraEnabled
	public static EUR_ISP_Spend_Activity__c releaseActivityAmount(String activityId)
	{
		if (String.isBlank(activityId))
		{
			return null;
		}

		activityId = String.escapeSingleQuotes(activityId);
		List<EUR_ISP_Spend_Activity__c> spendActivities = [SELECT Id, EUR_ISP_Matched__c, EUR_ISP_Activity_Amount__c FROM EUR_ISP_Spend_Activity__c WHERE Id = :activityId];
		if (!spendActivities.isEmpty() && spendActivities.get(0).EUR_ISP_Activity_Amount__c != null)
		{
			EUR_ISP_Spend_Activity__c theSpendActivity = spendActivities.get(0);
			if (theSpendActivity.EUR_ISP_Activity_Amount__c != null )
			{
				Decimal amountToTheBudget = theSpendActivity.EUR_ISP_Activity_Amount__c - theSpendActivity.EUR_ISP_Matched__c;
				if (amountToTheBudget >= 0)
				{
					theSpendActivity.EUR_ISP_Activity_Amount__c = theSpendActivity.EUR_ISP_Activity_Amount__c - amountToTheBudget;
					update theSpendActivity;
				}
			}
			return EUR_ISP_SpendActivityController.getById(activityId);
		}
		return null;
	}

	@AuraEnabled
	public static void deleteSpendActivity(String activityId)
	{
		if (String.isBlank(activityId))
		{
			return;
		}

		activityId = String.escapeSingleQuotes(activityId);
		delete [SELECT Id FROM EUR_ISP_Spend_Activity__c WHERE Id = : activityId];
	}

	@AuraEnabled
	public static EUR_ISP_Spend_Activity__c updateSpendActivityRecord(EUR_ISP_Spend_Activity__c activityItem)
	{
		EUR_ISP_Utils.AppConfigurationSettings AppConfig = EUR_ISP_HomeController.getAppConfiguration();
		EUR_ISP_Spend_Activity__c oldActivity = EUR_ISP_SpendActivityController.getById(activityItem.Id);
		Boolean isDeProject = String.isNotBlank(AppConfig.projectName) && AppConfig.projectName.equals(EUR_ISP_Utils.DE_PROJECT_NAME_SETTING);
		String activityType = isDeProject ? oldActivity.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c : oldActivity.EUR_ISP_Spend_Activity_Type_Name__c;
		Boolean isPouringType = String.isNotBlank(activityType) && activityType.contains('Pouring Refund');

		EUR_CRM_Budget__c oldBudget = EUR_ISP_BudgetService.getUserBudget(oldActivity.EUR_ISP_Spend__r.OwnerId);
		System.Savepoint dbSavePoint = Database.setSavepoint();

		if (EUR_ISP_Utils.isActivityAmountsMoreThenToleranceValue(activityItem, oldActivity, AppConfig.settings))
		{
			if (isDeProject && !isPouringType)
			{
				Decimal toleranceValue = 0;
				if (!AppConfig.settings.isEmpty() && AppConfig.settings.get(0).EUR_ISP_Value_SFDC__c != null)
				{
					toleranceValue = Decimal.valueOf(AppConfig.settings.get(0).EUR_ISP_Value_SFDC__c);
				}
				String errMsg = Label.EUR_ISP_EXCEEDS_TOLERANCE1_TEXT + toleranceValue + ' ' + activityItem.CurrencyIsoCode + Label.EUR_ISP_EXCEEDS_TOLERANCE2_TEXT;
				//'This change exceeds the tolerance level (€300, please do create a new contract in SFDC'
				throw new AuraHandledException(errMsg);
			}

			if (!isDeProject)
			{
				activityItem.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
				EUR_ISP_Spend__c spend = EUR_ISP_SpendController.getISpend(activityItem.EUR_ISP_Spend__c);
				spend.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
				update spend;
			}
		}
		update activityItem;

		// Insufficient Balance – Please contact your Sales Manager
		if (isDeProject && isPouringType)
		{
			EUR_CRM_Budget__c budget = EUR_ISP_BudgetService.getUserBudget(oldActivity.EUR_ISP_Spend__r.OwnerId);
			if (budget != null && oldBudget != null && oldBudget.EUR_CRM_Current_Balance__c != budget.EUR_CRM_Current_Balance__c && budget.EUR_CRM_Current_Balance__c < 0)
			{
				Database.rollback(dbSavePoint);
				throw new AuraHandledException(Label.EUR_ISP_INSUFFIENT_BALANCE);
			}
		}
		return EUR_ISP_SpendActivityController.getById(activityItem.Id);
	}

	@AuraEnabled
	public static EUR_ISP_Spend_Activity__c createSpendActivityRecord(EUR_ISP_Spend_Activity__c activityItem)
	{
		insert activityItem;
		return EUR_ISP_SpendActivityController.getById(activityItem.Id);
	}

	public static List<EUR_ISP_Spend_Activity__c> getBySpendId(String spendId)
	{

		if (String.isBlank(spendId))
		{
			return new List<EUR_ISP_Spend_Activity__c>();
		}

		spendId = String.escapeSingleQuotes(spendId);
		User theUser = EUR_ISP_HomeController.getCurrentUserInfo();
		final String countryCode = Test.isRunningTest() ? EUR_ISP_Utils.COUNTRY_CODE_DE : theUser.EUR_CRM_Country_Code__c;

		return [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Activity_Amount__c, EUR_ISP_Total_Activity_Amount__c,
		        EUR_ISP_Activity_Start_Date__c, EUR_ISP_Activity_End_Date__c, EUR_ISP_Sales_In_Start_Date__c, EUR_ISP_Sales_In_End_Date__c,
		        EUR_ISP_Sales_Out_Start_Date__c, EUR_ISP_Sales_Out_End_Date__c, EUR_ISP_Total_Spend_Items_Amount__c, EUR_ISP_Matched__c, EUR_ISP_Total_Matched__c,
		        toLabel(EUR_ISP_Approval_Status__c), EUR_ISP_Description__c, toLabel(EUR_ISP_Settlement_Method__c), toLabel(EUR_ISP_Payment_Terms__c),
		        EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Product_Level_Of_Input__c, toLabel(EUR_ISP_Status__c),  EUR_ISP_Conditional__c, EUR_ISP_Visible__c,
		        EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c,
		        EUR_ISP_Spend__c, EUR_ISP_Spend__r.Name,
		        EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c,
		        RecordTypeId, RecordType.Name,
		        (SELECT Id, EUR_ISP_Amount__c, EUR_ISP_Settlement__r.EUR_ISP_Internal_Doc_Number__c, EUR_ISP_Settlement__r.EUR_ISP_Vendor_Invoice_Number__c, EUR_ISP_Settlement__c,
		         EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity__r.Name
		         FROM Settlement_Lines_EU__r)
		        // ,
		        //(SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Lump_Sum_1__c, EUR_ISP_Lump_Sum_2__c, EUR_ISP_Percentage__c,
		        // EUR_ISP_Per_Unit_Amount__c, EUR_ISP_Total_Spend_Item__c, EUR_ISP_Matched__c, EUR_ISP_Available_Amount__c, EUR_ISP_Unit_Of_Measure__c, EUR_ISP_Volume__c,
		        // EUR_ISP_Brand__r.Name,
		        // EUR_ISP_Brand_Quality__r.Name,
		        // EUR_ISP_Brand_Quality_Size__r.Name,
		        // EUR_ISP_Family__r.Name,
		        // EUR_ISP_SKU_EU__r.Name
		        // FROM Spend_Items_EU__r)
		        FROM EUR_ISP_Spend_Activity__c
		        WHERE EUR_ISP_Spend__c = :spendId AND EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Country_Code__c = : countryCode
		                                 ORDER BY CreatedDate DESC];
	}

	@AuraEnabled
	public static Map<String, List<EUR_ISP_Spend_Activity__c>> getBySpendIdAndType(String spendId, List<String> activityTypeIds)
	{
		Map<String, List<EUR_ISP_Spend_Activity__c>> outputResults = new Map<String, List<EUR_ISP_Spend_Activity__c>>();
		if (String.isBlank(spendId) || activityTypeIds == null)
		{
			return outputResults;
		}

		spendId = String.escapeSingleQuotes(spendId);
		for (EUR_ISP_Spend_Activity__c activity : [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Activity_Amount__c, EUR_ISP_Total_Activity_Amount__c,
		        EUR_ISP_Activity_Start_Date__c, EUR_ISP_Activity_End_Date__c, EUR_ISP_Sales_In_Start_Date__c, EUR_ISP_Sales_In_End_Date__c,
		        EUR_ISP_Sales_Out_Start_Date__c, EUR_ISP_Sales_Out_End_Date__c, EUR_ISP_Total_Spend_Items_Amount__c, EUR_ISP_Matched__c, EUR_ISP_Total_Matched__c,
		        EUR_ISP_Approval_Status__c, EUR_ISP_Description__c, EUR_ISP_Settlement_Method__c, EUR_ISP_Payment_Terms__c,
		        EUR_ISP_Spend_Activity_Type__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Product_Level_Of_Input__c, EUR_ISP_Status__c,  EUR_ISP_Conditional__c, EUR_ISP_Visible__c,
		        EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c,
		        EUR_ISP_Spend__c, EUR_ISP_Spend__r.Name,
		        EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c,
		        RecordTypeId, RecordType.Name,
		        (SELECT Id, EUR_ISP_Amount__c, EUR_ISP_Settlement__r.EUR_ISP_Internal_Doc_Number__c, EUR_ISP_Settlement__r.EUR_ISP_Vendor_Invoice_Number__c, EUR_ISP_Settlement__c,
		         EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity__r.Name
		         FROM Settlement_Lines_EU__r)
		        // ,
		        //(SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Lump_Sum_1__c, EUR_ISP_Lump_Sum_2__c, EUR_ISP_Percentage__c,
		        // EUR_ISP_Per_Unit_Amount__c, EUR_ISP_Total_Spend_Item__c, EUR_ISP_Matched__c, EUR_ISP_Available_Amount__c, EUR_ISP_Unit_Of_Measure__c, EUR_ISP_Volume__c,
		        // EUR_ISP_Brand__r.Name,
		        // EUR_ISP_Brand_Quality__r.Name,
		        // EUR_ISP_Brand_Quality_Size__r.Name,
		        // EUR_ISP_Family__r.Name,
		        // EUR_ISP_SKU_EU__r.Name
		        // FROM Spend_Items_EU__r)
		        FROM EUR_ISP_Spend_Activity__c
		        WHERE EUR_ISP_Spend__c = :spendId AND EUR_ISP_Spend_Activity_Type__c IN : activityTypeIds
		                                 ORDER BY CreatedDate DESC] )
		{
			if (outputResults.containsKey(activity.EUR_ISP_Spend_Activity_Type__c))
			{
				outputResults.get(activity.EUR_ISP_Spend_Activity_Type__c).add(activity);
			}
			else
			{
				outputResults.put(activity.EUR_ISP_Spend_Activity_Type__c, new List<EUR_ISP_Spend_Activity__c> {activity});
			}
		}
		return outputResults;
	}

	public static List<EUR_ISP_Spend_Activity__c> getSpendActivitiesForSettlement(String spendId)
	{
		EUR_ISP_Utils.AppConfigurationSettings userSettings = EUR_ISP_HomeController.getAppConfiguration();
		String countryCode = Test.isRunningTest() ? EUR_ISP_Utils.COUNTRY_CODE_DE : userSettings.theUser.EUR_CRM_Country_Code__c;
		return [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Status__c, EUR_ISP_Approval_Status__c,
		        EUR_ISP_Activity_Start_Date__c, EUR_ISP_Activity_End_Date__c, EUR_ISP_Matched__c, EUR_ISP_Total_Activity_Amount__c, EUR_ISP_Activity_Amount__c,
		        EUR_ISP_Spend_Activity_Type__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Product_Level_Of_Input__c,
		        EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c,
		        (SELECT Id, Name,
		         EUR_ISP_Matched__c,
		         EUR_ISP_Lump_Sum_1__c,
		         EUR_ISP_Lump_Sum_2__c,
		         EUR_ISP_Per_Unit_Amount__c,
		         EUR_ISP_Volume__c,
		         EUR_ISP_Total_Spend_Item__c,
		         EUR_ISP_Brand__r.Name,
		         EUR_ISP_Brand_Quality__r.Name,
		         EUR_ISP_Brand_Quality_Size__r.Name,
		         EUR_ISP_Family__r.Name,
		         EUR_ISP_SKU_EU__r.Name
		         FROM Spend_Items_EU__r ORDER BY CreatedDate DESC)
		        FROM EUR_ISP_Spend_Activity__c
		        WHERE EUR_ISP_Spend__c = : spendId AND EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Country_Code__c = : countryCode ORDER BY CreatedDate DESC];
	}

	/**
	 * If an Activity is fully matched, then the Activity Status has to change to “Invoiced”,
	 * if not - then the Activity Status will have to change back to “Committed”
	 */
	public static void updateSpendActivityStatus(String activityId)
	{
		EUR_ISP_Spend_Activity__c activityItem = EUR_ISP_SpendActivityController.getById(activityId);
		if (activityItem.Id != null)
		{
			if (activityItem.EUR_ISP_Total_Activity_Amount__c - activityItem.EUR_ISP_Total_Matched__c == 0)
			{
				activityItem.EUR_ISP_Status__c = EUR_ISP_Utils.INVOICED_STATUS;
				update activityItem;
			}
			else if (activityItem.EUR_ISP_Total_Activity_Amount__c - activityItem.EUR_ISP_Total_Matched__c > 0)
			{
				activityItem.EUR_ISP_Status__c = EUR_ISP_Utils.COMMITTED_STATUS;
				update activityItem;
			}
		}
	}

	/**
	 * Close all activities related to the Settlement
	 */
	public static void updateSpendActivitiesForInvoice(Set<Id> activityIds)
	{
		List<EUR_ISP_Spend_Activity__c> spendActivities = new List<EUR_ISP_Spend_Activity__c>();
		for (EUR_ISP_Spend_Activity__c activity : [SELECT Id, EUR_ISP_Status__c, EUR_ISP_Total_Activity_Amount__c, EUR_ISP_Total_Matched__c
		        FROM EUR_ISP_Spend_Activity__c
		        WHERE Id IN :activityIds])
		{
			if (activity.EUR_ISP_Total_Activity_Amount__c - activity.EUR_ISP_Total_Matched__c == 0 )
			{
				activity.EUR_ISP_Status__c = EUR_ISP_Utils.INVOICED_STATUS;
				spendActivities.add(activity);
			}
		}
		update spendActivities;
	}
}