/**
 * Apex Controller for Home Screen of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_HomeController
{
	private static User theUser = null;
	public static final Integer RECORDS_LIMIT = 10000;

	/**
	 * load App settings from the vairous places
	 */
	@AuraEnabled
	public static EUR_ISP_Utils.AppConfigurationSettings getAppConfiguration()
	{
		EUR_ISP_Utils.AppConfigurationSettings systemSettingsOut = new EUR_ISP_Utils.AppConfigurationSettings();
		systemSettingsOut.theUser = EUR_ISP_HomeController.getCurrentUserInfo();

		String countryCode = Test.isRunningTest() ? EUR_ISP_Utils.COUNTRY_CODE_DE : systemSettingsOut.theUser.EUR_CRM_Country_Code__c;
		systemSettingsOut.settings = getSystemSettings(countryCode);
		systemSettingsOut.objectPermissions = EUR_ISP_HomeController.getObjectPermissions();
		systemSettingsOut.projectName = '';
		//List<PermissionSetAssignment> pSets = [SELECT Id, PermissionSetId, PermissionSet.Name
		//                                       FROM PermissionSetAssignment
		//                                       WHERE AssigneeId = : systemSettingsOut.theUser.Id AND PermissionSet.Name = : EUR_ISP_Utils.DE_PERMISSION_SET_NAME];

		// detect project Name for Current User (don't have actual information how to detect this relation so just check for correct Permission Set)
		if (countryCode == EUR_ISP_Utils.COUNTRY_CODE_DE)
		{
			systemSettingsOut.projectName = EUR_ISP_Utils.DE_PROJECT_NAME_SETTING;
		}
		return systemSettingsOut;
	}

	@AuraEnabled
	public static User getCurrentUserInfo()
	{
		if (theUser == null)
		{
			theUser = [SELECT Id, Name, EUR_CRM_Country_Code__c FROM User WHERE Id = : UserInfo.getUserId()];
		}
		return theUser;
	}

	/**
	 * stops approval process within 3 statuses: Approve/Reject/Removed
	 */
	@AuraEnabled
	public static Boolean abortApprovalProcess(String ispendId, String workItemId, String comments, String status)
	{
		if (String.isBlank(workItemId))
		{
			List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem
			        WHERE ProcessInstance.TargetObjectId = : ispendId AND ProcessInstance.Status = : EUR_ISP_Utils.PENDING_APPROVAL_STATUS];
			if (workItems.isEmpty())
			{
				return false;
			}
			workItemId = workItems.get(0).Id;
		}
		comments = comments != null ? comments : '';

		Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
		approvalRequest.setComments(comments);
		approvalRequest.setAction(status);
		approvalRequest.setNextApproverIds(new List<Id> {UserInfo.getUserId()});
		approvalRequest.setWorkitemId(workItemId);
		Approval.ProcessResult approvalResult =  Approval.process(approvalRequest);
		return approvalResult.isSuccess();
	}

	@AuraEnabled
	public static EUR_ISP_Spend__c getSpendForApproval(String spendId)
	{
		EUR_ISP_Spend__c spendRecord = new EUR_ISP_Spend__c();
		if (String.isBlank(spendId))
		{
			return spendRecord;
		}

		spendId = String.escapeSingleQuotes(spendId);
		for (EUR_ISP_Spend__c spendItem : [SELECT Id, Name, CurrencyIsoCode, OwnerId, Owner.Name, EUR_ISP_Description__c, toLabel(EUR_ISP_Status__c),
		                                   EUR_ISP_Amount__c, EUR_ISP_Total_Spend_Activities_Amount__c, EUR_ISP_Awaiting_Approval_Amount__c, EUR_ISP_Available_Amount__c
		                                   FROM EUR_ISP_Spend__c
		                                   WHERE Id = : spendId])
		{
			spendRecord = spendItem;
		}
		return spendRecord;
	}

	@AuraEnabled
	public static TableData getActivitiesToAdjust(Decimal pageNumber)
	{
		TableData outputResults = new TableData();
		Integer currentPage = pageNumber != null && pageNumber > 0 ? pageNumber.intValue() : 1;
		ApexPages.StandardSetController stdSetCtrl = null;
		Id userId = UserInfo.getUserId();
		User currentUser = EUR_ISP_HomeController.getCurrentUserInfo();
		String plannedStatus = EUR_ISP_Utils.PLANNED_STATUS;
		List<String> statuses = new List<String> {EUR_ISP_Utils.INVOICED_STATUS, EUR_ISP_Utils.CANCELLED_STATUS};
		Date currentFY = EUR_ISP_BudgetService.getCurrentFiscalYear().addYears(-1);

		String queryString = 'SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Spend_Activity_Type__c, ' +
		                     'EUR_ISP_Total_Activity_Amount__c, EUR_ISP_Matched__c, EUR_ISP_Description__c, ' +
		                     'EUR_ISP_Activity_Start_Date__c, EUR_ISP_Activity_End_Date__c, ' +
		                     'EUR_ISP_Sales_In_Start_Date__c, EUR_ISP_Sales_In_End_Date__c, ' +
		                     'EUR_ISP_Sales_Out_Start_Date__c, EUR_ISP_Sales_Out_End_Date__c, ' +
		                     'EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c, ' +
		                     'EUR_ISP_Spend__c, EUR_ISP_Spend__r.EUR_ISP_Account__r.Name, EUR_ISP_Spend__r.EUR_ISP_Contract__r.Name ' +
		                     'FROM EUR_ISP_Spend_Activity__c ' +
		                     'WHERE EUR_ISP_Spend__r.OwnerId = : userId ';
		if (currentUser.EUR_CRM_Country_Code__c != EUR_ISP_Utils.COUNTRY_CODE_DE)
		{
			queryString += ' AND EUR_ISP_Status__c = : plannedStatus ';
		}
		else
		{
			queryString +=  ' AND EUR_ISP_Available_Amount__c > 0 AND EUR_ISP_Status__c NOT IN : statuses ';
		}
		queryString +=  ' AND ( ' +
		                '    (EUR_ISP_Activity_Start_Date__c != NULL AND EUR_ISP_Activity_Start_Date__c < :currentFY) OR ' +
		                '    (EUR_ISP_Sales_In_Start_Date__c != NULL AND EUR_ISP_Sales_In_Start_Date__c < :currentFY) OR ' +
		                '    (EUR_ISP_Sales_Out_Start_Date__c != NULL AND EUR_ISP_Sales_Out_Start_Date__c < :currentFY) OR ' +
		                '    (EUR_ISP_Activity_Start_Date__c = NULL AND ' +
		                '        EUR_ISP_Sales_In_Start_Date__c = NULL AND ' +
		                '        EUR_ISP_Sales_Out_Start_Date__c = NULL AND  ' +
		                '        EUR_ISP_Spend__r.EUR_ISP_Start_Date__c < :currentFY ' +
		                '    )' +
		                ') ' +
		                'ORDER BY CreatedDate DESC ';

		stdSetCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		stdSetCtrl.setPageSize(EUR_ISP_Utils.RECORDS_PER_PAGE_SIZE);
		stdSetCtrl.setPageNumber(currentPage);

		outputResults.sdata = (List<EUR_ISP_Spend_Activity__c>) stdSetCtrl.getRecords();
		outputResults.isCompleteResult = stdSetCtrl.getCompleteResult();
		outputResults.totalRows = stdSetCtrl.getResultSize();
		outputResults.pageNumber = currentPage;
		return outputResults;
	}

	@AuraEnabled
	public static TableData getSettlements(Decimal pageNumber)
	{
		TableData outputResults = new TableData();
		Integer currentPage = pageNumber != null && pageNumber > 0 ? pageNumber.intValue() : 1;

		ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([
		            SELECT Id, Name, OwnerId, CurrencyIsoCode, EUR_ISP_Amount_Excluding_Tax__c, EUR_ISP_Internal_Doc_Number__c,
		            EUR_ISP_Notes__c, EUR_ISP_Vendor_Invoice_Number__c, EUR_ISP_Vendor_Invoice_Date__c,
		            EUR_ISP_Account__c, EUR_ISP_Account__r.Name,
		            EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c,
		            (SELECT Id, Name
		             FROM Attachments
		             ORDER BY CreatedDate DESC
		             LIMIT 1)
		            FROM EUR_ISP_Settlement__c
		            WHERE OwnerId = : UserInfo.getUserId()
		                            AND EUR_ISP_Settlement_Status__c != : EUR_ISP_Utils.MATCHED_STATUS
		                            ORDER BY CreatedDate DESC
		        ]));
		stdSetCtrl.setPageSize(EUR_ISP_Utils.RECORDS_PER_PAGE_SIZE);
		stdSetCtrl.setPageNumber(currentPage);

		outputResults.sdata = (List<EUR_ISP_Settlement__c>) stdSetCtrl.getRecords();
		outputResults.isCompleteResult = stdSetCtrl.getCompleteResult();
		outputResults.totalRows = stdSetCtrl.getResultSize();
		outputResults.pageNumber = currentPage;
		return outputResults;
	}

	@AuraEnabled
	public static TableData getItemsToApprove(Decimal pageNumber)
	{
		TableData outputResults = new TableData();
		Integer currentPage = pageNumber != null && pageNumber > 0 ? pageNumber.intValue() : 1;
		List<ProcessInstance> instances = [SELECT Id, LastActorId, TargetObjectId,
		                                   (SELECT Id, ActorId, ProcessInstanceId
		                                    FROM Workitems
		                                    WHERE ActorId = : UserInfo.getUserId()
		                                            ORDER BY CreatedDate DESC
		                                            LIMIT 1),
		                                   (SELECT Id, ActorId, Actor.Name, CreatedDate
		                                    FROM Steps
		                                    ORDER BY CreatedDate DESC
		                                    LIMIT 1)
		                                   FROM ProcessInstance
		                                   WHERE Status = 'Pending' AND TargetObject.Type = 'EUR_ISP_Spend__c'
		                                           ORDER BY CreatedDate DESC];

		Map<Id, ProcessInstance> spendIdToProcess = new Map<Id, ProcessInstance>();
		for (ProcessInstance workItem : instances)
		{
			if (workItem.Workitems != null && !workItem.Workitems.isEmpty())
			{
				spendIdToProcess.put(workItem.TargetObjectId, workItem);
			}
		}

		ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([
		            SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Amount__c, EUR_ISP_Awaiting_Approval_Amount__c, EUR_ISP_Available_Amount__c,
		            EUR_ISP_Start_Date__c, EUR_ISP_End_Date__c, EUR_ISP_Description__c, EUR_ISP_Total_Spend_Activities_Amount__c,
		            EUR_ISP_Account__r.Name, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c
		            FROM EUR_ISP_Spend__c
		            WHERE Id IN : spendIdToProcess.keySet()
		            ORDER BY CreatedDate DESC]));
		stdSetCtrl.setPageSize(EUR_ISP_Utils.RECORDS_PER_PAGE_SIZE);
		stdSetCtrl.setPageNumber(currentPage);

		for (EUR_ISP_Spend__c spend : (List<EUR_ISP_Spend__c>) stdSetCtrl.getRecords())
		{
			outputResults.data.add(
			    new ItemToApprove(spend, spendIdToProcess.get(spend.Id))
			);
		}

		outputResults.isCompleteResult = stdSetCtrl.getCompleteResult();
		outputResults.totalRows = stdSetCtrl.getResultSize();
		outputResults.pageNumber = currentPage;
		return outputResults;
	}

	@AuraEnabled
	public static void createBudgetTransactionRecord(String activityId)
	{
		if (String.isBlank(activityId))
		{
			return;
		}
		activityId = String.escapeSingleQuotes(activityId);
		EUR_ISP_BudgetService.createBudgetTransactionRecord(activityId, EUR_ISP_BudgetService.CATEGORY_NAME_SPEND);
	}

	@AuraEnabled
	public static Map<String, EUR_ISP_Utils.ObjectPermission> getObjectPermissions()
	{
		List<String> objectApiNames = new List<String>
		{
			EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_TYPE_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SPEND_ITEM_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SETTLEMENT_API_NAME,
			EUR_ISP_Utils.EUR_ISP_SETTLEMENT_LINE_API_NAME,
			EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME,
			EUR_ISP_BudgetService.EUR_CRM_BUDGET_API_NAME
		};

		Map<String, EUR_ISP_Utils.ObjectPermission> permissions = new Map<String, EUR_ISP_Utils.ObjectPermission>();
		for (String objName : objectApiNames)
		{
			Schema.SObjectType objectType = EUR_ISP_Utils.GLOBAL_DESCRIBE.get(objName);
			permissions.put(objName, new EUR_ISP_Utils.ObjectPermission(objectType.getDescribe()));
		}
		return permissions;
	}

	public static List<EUR_ISP_SystemSettings__c> getSystemSettings(String countryCode)
	{
		return [SELECT Id, Name, EUR_ISP_Type__c, EUR_ISP_Value_SFDC__c, EUR_ISP_Country_Code__c
		        FROM EUR_ISP_SystemSettings__c
		        WHERE EUR_ISP_Country_Code__c = :countryCode AND EUR_ISP_Type__c = 'Tolerance'];
	}

	public class TableData
	{
		@AuraEnabled
		public List<ItemToApprove> data {get; set;}
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
			this.pageSize = EUR_ISP_Utils.RECORDS_PER_PAGE_SIZE;
			this.data = new List<ItemToApprove>();
			this.sdata = new List<sObject>();
		}
	}

	public class ItemToApprove
	{
		@AuraEnabled
		public EUR_ISP_Spend__c spend {get; set;}
		@AuraEnabled
		public ProcessInstanceWorkitem workItem {get; set;}
		@AuraEnabled
		public ProcessInstanceStep step {get; set;}

		public ItemToApprove() {}
		public ItemToApprove(EUR_ISP_Spend__c spend, ProcessInstance process)
		{
			this.spend = spend;
			if (!process.Steps.isEmpty())
			{
				this.step = process.Steps.get(0);
			}
			if (!process.WorkItems.isEmpty())
			{
				this.workItem = process.WorkItems.get(0);
			}
		}
	}
}