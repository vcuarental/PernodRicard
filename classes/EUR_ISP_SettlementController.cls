/**
 * Apex Controller for Match screen of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SettlementController
{
	@AuraEnabled
	public static EUR_ISP_Settlement__c getById(String settlementId)
	{
		EUR_ISP_Settlement__c output = new EUR_ISP_Settlement__c();
		if (String.isBlank(settlementId))
		{
			return output;
		}

		settlementId = String.escapeSingleQuotes(settlementId);
		for (EUR_ISP_Settlement__c settlement : [SELECT Id, Name, OwnerId, CurrencyIsoCode, EUR_ISP_Foreign_Amount_Including_Tax__c, EUR_ISP_Foreign_Amount_Excluding_Tax__c,
		        EUR_ISP_Amount_Including_Tax__c, EUR_ISP_Amount_Excluding_Tax__c, EUR_ISP_Spot_Rate__c, EUR_ISP_Tax_Rate__c, EUR_ISP_Matched__c,
		        EUR_ISP_Notes__c, EUR_ISP_Vendor_Invoice_Number__c, EUR_ISP_Settlement_Status__c, EUR_ISP_Approval_Status__c,
		        EUR_ISP_Vendor_Invoice_Date__c, EUR_ISP_Tax_Effective_Date__c, EUR_ISP_Internal_Doc_Number__c,
		        EUR_ISP_Account__c, EUR_ISP_Account__r.Name,
		        EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c
		        FROM EUR_ISP_Settlement__c
		        WHERE Id = : settlementId])
		{
			output = settlement;
		}
		return output;
	}

	@AuraEnabled
	public static EUR_ISP_Settlement__c closeSettlementRecord(String settlementId)
	{
		EUR_ISP_Settlement__c theSettlement = EUR_ISP_SettlementController.getById(settlementId);
		if (theSettlement.Id == null)
		{
			return theSettlement;
		}
		theSettlement.EUR_ISP_Settlement_Status__c = EUR_ISP_Utils.MATCHED_STATUS;
		update theSettlement;

		Set<Id> activityIds = new Set<Id>();
		for (EUR_ISP_Settlement_Line__c theItem : EUR_ISP_SettlementController.getSettlementLines(settlementId))
		{
			activityIds.add(theItem.EUR_ISP_Spend_Activity__c);
		}
		EUR_ISP_SpendActivityController.updateSpendActivitiesForInvoice(activityIds);

		return theSettlement;
	}

	@AuraEnabled
	public static void createBudgetTransactionRecord(String activityId, String itemId)
	{
		if (String.isBlank(activityId))
		{
			return;
		}

		//EUR_ISP_BudgetService.createBudgetTransactionRecord(activityId, EUR_ISP_BudgetService.CATEGORY_NAME_INVOICE);
		if (String.isBlank(itemId))
		{
			EUR_ISP_Spend_Activity__c spendActivity = EUR_ISP_SpendActivityController.releaseActivityAmount(activityId);
		}
		else
		{
			List<EUR_ISP_Spend_Item__c> spendItems = EUR_ISP_SpendActivityItemController.releaseSpendItemAmount(itemId);
		}
	}

	@AuraEnabled
	public static List<EUR_ISP_Settlement_Line__c> getSettlementLines(String settlementId)
	{
		if (String.isBlank(settlementId))
		{
			return new List<EUR_ISP_Settlement_Line__c>();
		}

		settlementId = String.escapeSingleQuotes(settlementId);
		return [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Amount__c,
		        EUR_ISP_Spend_Activity__c, EUR_ISP_Spend_Activity__r.Name,
		        EUR_ISP_Spend_Item__c, EUR_ISP_Spend_Item__r.Name,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type_Name__c
		        FROM EUR_ISP_Settlement_Line__c
		        WHERE EUR_ISP_Settlement__c = :settlementId
		                                      ORDER BY CreatedDate DESC];
	}

	@AuraEnabled
	public static List<EUR_ISP_Settlement_Line__c> createSettlementLineRecord(EUR_ISP_Settlement_Line__c settlementLine)
	{
		final Map<String, String> rTMapping = new Map<String, String>
		{
			'EUR_ISP_DE_Settlement' => 'EUR_ISP_DE_Settlement_Line',
			'EUR_ISP_iSpend_Settlement' => 'EUR_ISP_iSpend_Settlement_Line'
		};
		Map<String, Id> rtMap = EUR_ISP_Utils.getRecordTypesMap();
		for (EUR_ISP_Settlement__c theSettlement : [SELECT Id, RecordTypeId, RecordType.DeveloperName
		        FROM EUR_ISP_Settlement__c
		        WHERE Id = : settlementLine.EUR_ISP_Settlement__c])
		{
			if (theSettlement.RecordTypeId != null && rtMapping.containsKey(theSettlement.RecordType.DeveloperName))
			{
				settlementLine.RecordTypeId = rtMap.get(EUR_ISP_Utils.EUR_ISP_SETTLEMENT_LINE_API_NAME + rtMapping.get(theSettlement.RecordType.DeveloperName));
				break;
			}
		}

		insert settlementLine;
		EUR_ISP_SpendActivityController.updateSpendActivityStatus(settlementLine.EUR_ISP_Spend_Activity__c);
		return EUR_ISP_SettlementController.getSettlementLines(settlementLine.EUR_ISP_Settlement__c);
	}

	@AuraEnabled
	public static List<EUR_ISP_Settlement_Line__c> deleteSettlementLineRecord(String settlementLineId, String settlementId)
	{
		if (!String.isBlank(settlementLineId))
		{
			settlementLineId = String.escapeSingleQuotes(settlementLineId);
			EUR_ISP_Settlement_Line__c settlementLine = [SELECT Id, EUR_ISP_Spend_Activity__c
			        FROM EUR_ISP_Settlement_Line__c
			        WHERE Id = : settlementLineId];
			delete settlementLine;
			EUR_ISP_SpendActivityController.updateSpendActivityStatus(settlementLine.EUR_ISP_Spend_Activity__c);
		}
		return EUR_ISP_SettlementController.getSettlementLines(settlementId);
	}

	@AuraEnabled
	public static EUR_ISP_Spend__c getSpend(String spendId)
	{
		return EUR_ISP_SpendController.getISpend(spendId);
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Activity__c> getSpendActivities(String spendId)
	{
		if (String.isBlank(spendId))
		{
			return new List<EUR_ISP_Spend_Activity__c>();
		}
		spendId = String.escapeSingleQuotes(spendId);
		return EUR_ISP_SpendActivityController.getSpendActivitiesForSettlement(spendId);
	}
}