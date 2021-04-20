/**
 * Apex Controller for Spend components of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendController
{
	@AuraEnabled
	public static Boolean isRecordLocked(String spendId)
	{
		if (String.isBlank(spendId))
		{
			return false;
		}
		return EUR_ISP_SpendApprovalService.isRecordLocked(String.escapeSingleQuotes(spendId));
	}

	@AuraEnabled
	public static EUR_ISP_SpendApprovalService.ApprovalUpdateResult submitSpendForApproval(String spendId)
	{
		if (String.isBlank(spendId))
		{
			return new EUR_ISP_SpendApprovalService.ApprovalUpdateResult();
		}
		return EUR_ISP_SpendApprovalService.submitSpendForApproval(String.escapeSingleQuotes(spendId));
	}

	@AuraEnabled
	public static TableData getApprovalHistory(Decimal pageNumber, String spendId)
	{
		spendId = String.escapeSingleQuotes(spendId);

		TableData outputResults = new TableData();
		Integer currentPage = pageNumber != null && pageNumber > 0 ? pageNumber.intValue() : 1;
		Integer currentOffest = 5 * (currentPage - 1);
		Integer totalRows = [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :spendId];

		outputResults.sdata = [SELECT Id, Status, (SELECT ProcessNode.Name, Actor.Name, OriginalActor.Name, StepStatus, Comments, CreatedDate
		                       FROM StepsAndWorkitems
		                       ORDER BY CreatedDate DESC)
		                       FROM ProcessInstance
		                       WHERE TargetObjectId = :String.escapeSingleQuotes(spendId)
		                               ORDER BY CreatedDate DESC
		                               LIMIT 5
		                               OFFSET :currentOffest];

		outputResults.totalRows = totalRows;
		outputResults.pageNumber = currentPage;
		return outputResults;
	}

	@AuraEnabled
	public static EUR_ISP_Spend__c getISpend(String spendId)
	{
		EUR_ISP_Spend__c spendRecord = new EUR_ISP_Spend__c();
		if (String.isBlank(spendId))
		{
			return spendRecord;
		}

		spendId = String.escapeSingleQuotes(spendId);
		for (EUR_ISP_Spend__c spendItem : [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Amount__c, EUR_ISP_Total_Spend_Activities_Amount__c, EUR_ISP_Deductible_Value__c,
		                                   EUR_ISP_Start_Date__c, EUR_ISP_End_Date__c,  EUR_ISP_Objective__c, EUR_ISP_Status__c, EUR_ISP_Matched__c,
		                                   EUR_ISP_Approval_Status__c, EUR_ISP_Allocation_Method__c, EUR_ISP_Phasing_Method__c,
		                                   EUR_ISP_Settlement_Method__c, EUR_ISP_Funding_Based__c, EUR_ISP_Description__c, EUR_ISP_Available_Amount__c,
		                                   RecordType.Name, EUR_ISP_Account__r.Name, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c,
		                                   EUR_ISP_Contract__c, EUR_ISP_Contract__r.Name,
		                                   OwnerId, Owner.Name
		                                   FROM EUR_ISP_Spend__c
		                                   WHERE Id = : spendId])
		{
			spendRecord = spendItem;
		}
		return spendRecord;
	}

	@AuraEnabled
	public static EUR_ISP_Spend__c updateSpendRecord(EUR_ISP_Spend__c spendItem)
	{
		update spendItem;
		return EUR_ISP_SpendController.getISpend(spendItem.Id);
	}

	@AuraEnabled
	public static EUR_ISP_Spend__c createSpendRecord(EUR_ISP_Spend__c spendItem)
	{
		insert spendItem;
		return EUR_ISP_SpendController.getISpend(spendItem.Id);
	}

	@AuraEnabled
	public static EUR_ISP_Spend_Activity_Type__c getActivityTypeById(String spendActivityTypeId)
	{
		EUR_ISP_Spend_Activity_Type__c spendType = new EUR_ISP_Spend_Activity_Type__c();
		if (String.isBlank(spendActivityTypeId))
		{
			return spendType;
		}

		spendActivityTypeId = String.escapeSingleQuotes(spendActivityTypeId);
		for (EUR_ISP_Spend_Activity_Type__c spendActivityType : [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Display_Conditional_Flag__c,
		        EUR_ISP_Display_Lump_Sum_1__c, EUR_ISP_Display_Lump_Sum_2__c, EUR_ISP_Display_Percentage__c, EUR_ISP_Display_Variable_Fields__c,
		        EUR_ISP_Display_Vendor__c, EUR_ISP_Display_Visible_Flag__c, EUR_ISP_Product_Level_Of_Input__c,
		        EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Country_Code__c, EUR_ISP_Category__c, EUR_ISP_Spend_Activity_Type_Name_English__c
		        FROM EUR_ISP_Spend_Activity_Type__c WHERE Id = : spendActivityTypeId])
		{
			spendType = spendActivityType;
		}
		return spendType;
	}

	@AuraEnabled
	public static Map<String, List<EUR_ISP_Utils.PicklistValue>> getPicklistValues()
	{
		return EUR_ISP_Utils.getPicklistValuesForObject(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME);
	}

	public class TableData
	{
		@AuraEnabled
		public List<sObject> sdata {get; set;}
		@AuraEnabled
		public Integer pageNumber {get; set;}
		@AuraEnabled
		public Integer pageSize {get; set;}
		@AuraEnabled
		public Boolean isCompleteResult {get; set;}
		@AuraEnabled
		public Integer totalRows {get; set;}

		public TableData()
		{
			this.pageNumber = 1;
			this.totalRows = 0;
			this.isCompleteResult = false;
			this.pageSize = 5;
			this.sdata = new List<sObject>();
		}
	}
}