/**
 * Apex Controller for Spend Activity Items component of iSpend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendActivityItemController
{
	@AuraEnabled
	public static EUR_ISP_Spend_Item__c getById(String spendItemId)
	{
		EUR_ISP_Spend_Item__c spendItem = new EUR_ISP_Spend_Item__c();
		if (String.isBlank(spendItemId))
		{
			return spendItem;
		}

		spendItemId = String.escapeSingleQuotes(spendItemId);
		for (EUR_ISP_Spend_Item__c item : [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Lump_Sum_1__c, EUR_ISP_Lump_Sum_2__c, EUR_ISP_Percentage__c,
		                                   EUR_ISP_Per_Unit_Amount__c, EUR_ISP_Matched__c, EUR_ISP_Available_Amount__c, EUR_ISP_Total_Spend_Item__c, EUR_ISP_Unit_Of_Measure__c, EUR_ISP_Volume__c,
		                                   EUR_ISP_Brand__r.Name,
		                                   EUR_ISP_Brand_Quality__r.Name,
		                                   EUR_ISP_Brand_Quality_Size__r.Name,
		                                   EUR_ISP_Family__r.Name,
		                                   EUR_ISP_SKU_EU__r.Name
		                                   FROM EUR_ISP_Spend_Item__c
		                                   WHERE Id = : spendItemId])
		{
			spendItem = item;
			break;
		}
		return spendItem;
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Item__c> createSpendItems(List<EUR_ISP_Spend_Item__c> spendItems)
	{
		if (spendItems != null && !spendItems.isEmpty())
		{
			EUR_ISP_Utils.AppConfigurationSettings AppConfig = EUR_ISP_HomeController.getAppConfiguration();
			Boolean isDeProject = String.isNotBlank(AppConfig.projectName) && AppConfig.projectName.equals(EUR_ISP_Utils.DE_PROJECT_NAME_SETTING);
			EUR_ISP_Spend_Activity__c theActivity = EUR_ISP_SpendActivityController.getById(spendItems.get(0).EUR_ISP_Spend_Activity__c);
			EUR_CRM_Budget__c oldBudget = EUR_ISP_BudgetService.getUserBudget(theActivity.EUR_ISP_Spend__r.OwnerId);

			System.Savepoint dbSavePoint = Database.setSavepoint();
			insert spendItems;

			EUR_CRM_Budget__c budget = EUR_ISP_BudgetService.getUserBudget(theActivity.EUR_ISP_Spend__r.OwnerId);
			// Insufficient Balance – Please contact your Sales Manager
			if (isDeProject && budget != null && oldBudget != null &&
			        oldBudget.EUR_CRM_Current_Balance__c != budget.EUR_CRM_Current_Balance__c &&
			        oldBudget.EUR_CRM_Current_Balance__c > 0 &&	budget.EUR_CRM_Current_Balance__c < 0)
			{
				Database.rollback(dbSavePoint);
				throw new AuraHandledException(Label.EUR_ISP_INSUFFIENT_BALANCE);
			}
		}
		return spendItems;
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Item__c> updateSpendItems(List<EUR_ISP_Spend_Item__c> spendItems)
	{
		if (spendItems != null && !spendItems.isEmpty())
		{
			EUR_ISP_Utils.AppConfigurationSettings AppConfig = EUR_ISP_HomeController.getAppConfiguration();
			Boolean isDeProject = String.isNotBlank(AppConfig.projectName) && AppConfig.projectName.equals(EUR_ISP_Utils.DE_PROJECT_NAME_SETTING);
			EUR_ISP_Spend_Activity__c theActivity = EUR_ISP_SpendActivityController.getById(spendItems.get(0).EUR_ISP_Spend_Activity__c);
			EUR_CRM_Budget__c oldBudget = EUR_ISP_BudgetService.getUserBudget(theActivity.EUR_ISP_Spend__r.OwnerId);

			System.Savepoint dbSavePoint = Database.setSavepoint();
			update spendItems;

			EUR_CRM_Budget__c budget = EUR_ISP_BudgetService.getUserBudget(theActivity.EUR_ISP_Spend__r.OwnerId);
			// Insufficient Balance – Please contact your Sales Manager
			if (isDeProject && budget != null && oldBudget != null &&
			        oldBudget.EUR_CRM_Current_Balance__c != budget.EUR_CRM_Current_Balance__c &&
			        oldBudget.EUR_CRM_Current_Balance__c > 0 &&	budget.EUR_CRM_Current_Balance__c < 0)
			{
				Database.rollback(dbSavePoint);
				throw new AuraHandledException(Label.EUR_ISP_INSUFFIENT_BALANCE);
			}
		}
		return spendItems;
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Item__c> releaseSpendItemAmount(String spendItemId)
	{
		if (String.isBlank(spendItemId))
		{
			return null;
		}

		spendItemId = String.escapeSingleQuotes(spendItemId);
		List<EUR_ISP_Spend_Item__c> spendItems = [SELECT Id, EUR_ISP_Spend_Activity__c,
		                            EUR_ISP_Matched__c, EUR_ISP_Available_Amount__c, EUR_ISP_Volume__c, EUR_ISP_Total_Spend_Item__c,
		                            EUR_ISP_Lump_Sum_2__c, EUR_ISP_Lump_Sum_1__c, EUR_ISP_Per_Unit_Amount__c
		                            FROM EUR_ISP_Spend_Item__c
		                            WHERE Id = :spendItemId];

		EUR_ISP_Spend_Item__c spendItem = spendItems.get(0);
		Decimal amountToTheBudget = spendItem.EUR_ISP_Available_Amount__c;
		if (amountToTheBudget <= 0)
		{
			return EUR_ISP_SpendActivityItemController.getSpendActivityItems(spendItem.EUR_ISP_Spend_Activity__c);
		}

		if (spendItem.EUR_ISP_Lump_Sum_2__c != null && spendItem.EUR_ISP_Lump_Sum_2__c > 0)
		{
			if (amountToTheBudget >= spendItem.EUR_ISP_Lump_Sum_2__c)
			{
				amountToTheBudget -= spendItem.EUR_ISP_Lump_Sum_2__c;
				spendItem.EUR_ISP_Lump_Sum_2__c = 0;
			}
			else
			{
				spendItem.EUR_ISP_Lump_Sum_2__c -= amountToTheBudget;
				amountToTheBudget = 0;
			}
		}

		if (spendItem.EUR_ISP_Lump_Sum_1__c != null && spendItem.EUR_ISP_Lump_Sum_1__c > 0 && amountToTheBudget > 0)
		{
			if (amountToTheBudget >= spendItem.EUR_ISP_Lump_Sum_1__c)
			{
				amountToTheBudget -= spendItem.EUR_ISP_Lump_Sum_1__c;
				spendItem.EUR_ISP_Lump_Sum_1__c = 0;
			}
			else
			{
				spendItem.EUR_ISP_Lump_Sum_1__c -= amountToTheBudget;
				amountToTheBudget = 0;
			}
		}

		if (spendItem.EUR_ISP_Volume__c != null && spendItem.EUR_ISP_Per_Unit_Amount__c != null
		        && spendItem.EUR_ISP_Volume__c > 0 && spendItem.EUR_ISP_Per_Unit_Amount__c > 0 && amountToTheBudget > 0)
		{
			spendItem.EUR_ISP_Volume__c -= (amountToTheBudget / spendItem.EUR_ISP_Per_Unit_Amount__c);
		}
		update spendItem;

		return EUR_ISP_SpendActivityItemController.getSpendActivityItems(spendItem.EUR_ISP_Spend_Activity__c);
	}

	@AuraEnabled
	public static void deleteSpendItems(List<EUR_ISP_Spend_Item__c> spendItems)
	{
		if (spendItems != null && !spendItems.isEmpty())
		{
			delete spendItems;
		}
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Item__c> getSpendActivityItems(String spendActivityId)
	{
		if (String.isBlank(spendActivityId))
		{
			return new List<EUR_ISP_Spend_Item__c>();
		}

		spendActivityId = String.escapeSingleQuotes(spendActivityId);
		return [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Lump_Sum_1__c, EUR_ISP_Lump_Sum_2__c, EUR_ISP_Percentage__c,
		        EUR_ISP_Per_Unit_Amount__c, EUR_ISP_Total_Spend_Item__c, EUR_ISP_Matched__c, EUR_ISP_Available_Amount__c, EUR_ISP_Unit_Of_Measure__c, EUR_ISP_Volume__c,
		        EUR_ISP_Brand__r.Name,
		        EUR_ISP_Brand_Quality__r.Name,
		        EUR_ISP_Brand_Quality_Size__r.Name,
		        EUR_ISP_Family__r.Name,
		        EUR_ISP_SKU_EU__r.Name
		        FROM EUR_ISP_Spend_Item__c
		        WHERE EUR_ISP_Spend_Activity__c = : spendActivityId];
	}

	@AuraEnabled
	public static void deleteSpendActivityItem(String spendItemId)
	{
		if (String.isBlank(spendItemId))
		{
			return;
		}

		spendItemId = String.escapeSingleQuotes(spendItemId);
		delete [SELECT Id FROM EUR_ISP_Spend_Item__c WHERE Id = : spendItemId];
	}

	@AuraEnabled
	public static EUR_ISP_Spend_Activity_Type__c getActivityTypeById(String spendActivityTypeId)
	{
		return EUR_ISP_SpendController.getActivityTypeById(spendActivityTypeId);
	}

	@AuraEnabled
	public static Map<String, List<EUR_ISP_Utils.PicklistValue>> getPicklistValues()
	{
		return EUR_ISP_Utils.getPicklistValuesForObject(EUR_ISP_Utils.EUR_ISP_SPEND_ITEM_API_NAME);
	}
}