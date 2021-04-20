/**
 * Apex Controller for Spend Search screen of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendTableController
{
	public static final Integer SPEND_RECORDS_LIMIT = 10000;

	@AuraEnabled
	public static SpendTableData getISpendsSearch(String settingsJson)
	{
		EUR_ISP_Utils.AppConfigurationSettings AppConfig = EUR_ISP_HomeController.getAppConfiguration();

		SpendTableData outputResults = new SpendTableData();
		SpendTableSearchSettings settings = new SpendTableSearchSettings();
		if (String.isNotBlank(settingsJson))
		{
			settings = (SpendTableSearchSettings)JSON.deserialize(settingsJson, SpendTableSearchSettings.class);
		}

		String queryString = 'SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Amount__c, EUR_ISP_Total_Spend_Activities_Amount__c, ' +
		                     'EUR_ISP_Start_Date__c, EUR_ISP_End_Date__c, EUR_ISP_Available_Amount__c, toLabel(EUR_ISP_Status__c), ' +
		                     'toLabel(EUR_ISP_Approval_Status__c), RecordType.Name, EUR_ISP_Account__r.Name, EUR_ISP_Contract__r.Name ' +
		                     'FROM EUR_ISP_Spend__c ';
		String whereClause = 'WHERE ';
		if (String.isNotBlank(AppConfig.projectName) && AppConfig.projectName.equals(EUR_ISP_Utils.DE_PROJECT_NAME_SETTING))
		{
			Map<String, Id> recordTypes = EUR_ISP_Utils.getRecordTypesMap();
			Id sfaContractRTId = recordTypes.get(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME);
			whereClause += 'RecordTypeId = :sfaContractRTId AND ';
		}
		if (String.isNotBlank(settings.startDate))
		{
			Date startDateValue = Date.valueOf(String.escapeSingleQuotes(settings.startDate));
			whereClause += 'EUR_ISP_Start_Date__c >= :startDateValue AND ';
		}
		if (String.isNotBlank(settings.endDate))
		{
			Date endDateValue = Date.valueOf(String.escapeSingleQuotes(settings.endDate));
			whereClause += 'EUR_ISP_End_Date__c <= :endDateValue AND ';
		}
		if (String.isNotBlank(settings.accountId))
		{
			whereClause += 'EUR_ISP_Account__c = \'' + String.escapeSingleQuotes(settings.accountId) + '\' AND ';
		}
		else
		{
			Set<Id> ids = EUR_ISP_SpendTableController.getAvailableAccountIds();
			whereClause += 'EUR_ISP_Account__c IN :ids AND ';
		}
		if (String.isNotBlank(settings.vendorId))
		{
			whereClause += 'EUR_ISP_Vendor__c = \'' + String.escapeSingleQuotes(settings.vendorId) + '\' AND ';
		}
		if (String.isNotBlank(settings.recordTypeId))
		{
			whereClause += 'RecordTypeId = \'' + String.escapeSingleQuotes(settings.recordTypeId) + '\' AND ';
		}
		if (String.isNotBlank(settings.approvalStatus))
		{
			whereClause += 'EUR_ISP_Approval_Status__c = \'' + String.escapeSingleQuotes(settings.approvalStatus) + '\' AND ';
		}
		if (String.isNotBlank(settings.spendName))
		{
			whereClause += 'Name LIKE \'%' + String.escapeSingleQuotes(settings.spendName) + '%\' AND ';
		}
		if (String.isNotBlank(settings.contractName))
		{
			whereClause += 'EUR_ISP_Contract__r.Name LIKE \'%' + String.escapeSingleQuotes(settings.contractName) + '%\' AND ';
		}

		if (whereClause.endsWith('AND '))
		{
			whereClause = whereClause.removeEnd('AND ');
			queryString += whereClause;
		}
		if (String.isNotBlank(settings.sortOrder))
		{
			queryString += ' ORDER BY ' + String.escapeSingleQuotes(settings.sortOrder) + ' LIMIT ' + SPEND_RECORDS_LIMIT;
		}
		else
		{
			queryString += ' ORDER BY EUR_ISP_Start_Date__c ASC LIMIT ' + SPEND_RECORDS_LIMIT;
		}

		Integer currentPageNumber = settings.pageNumber != null && settings.pageNumber > 0 ? settings.pageNumber : 1;
		ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		stdSetCtrl.setPageSize(EUR_ISP_Utils.RECORDS_PER_PAGE_SIZE);
		stdSetCtrl.setPageNumber(currentPageNumber);
		outputResults.data = (List<EUR_ISP_Spend__c>) stdSetCtrl.getRecords();
		outputResults.isCompleteResult = stdSetCtrl.getCompleteResult();
		outputResults.totalRows = stdSetCtrl.getResultSize();
		outputResults.pageNumber = currentPageNumber;
		return outputResults;
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Activity_Type__c> getActivityTypesBySpendRecType(String spendId)
	{
		List<EUR_ISP_Spend_Activity_Type__c> outputResults = new List<EUR_ISP_Spend_Activity_Type__c>();
		if (String.isBlank(spendId))
		{
			return outputResults;
		}

		User theUser = EUR_ISP_HomeController.getCurrentUserInfo();
		// EUR_ISP_Spend__c.RecordType MATCHES the EUR_ISP_Spend_Activity_Type__c.EUR_ISP_Spend_Type__c
		spendId = String.escapeSingleQuotes(spendId);
		for (EUR_ISP_Spend__c spendRecord : [SELECT Id, RecordType.Name FROM EUR_ISP_Spend__c WHERE Id = : spendId])
		{
			String typeOfSpendRec = spendRecord.RecordType.Name;
			outputResults = [SELECT Id, Name, CurrencyIsoCode, EUR_ISP_Display_Conditional_Flag__c,
			                 EUR_ISP_Display_Lump_Sum_1__c, EUR_ISP_Display_Lump_Sum_2__c, EUR_ISP_Display_Percentage__c, EUR_ISP_Display_Variable_Fields__c,
			                 EUR_ISP_Display_Vendor__c, EUR_ISP_Display_Visible_Flag__c, EUR_ISP_Product_Level_Of_Input__c,
			                 EUR_ISP_Spend_Activity_Type_Name__c, EUR_ISP_Country_Code__c, EUR_ISP_Category__c
			                 FROM EUR_ISP_Spend_Activity_Type__c
			                 WHERE EUR_ISP_Spend_Activity_Type_Name__c != null AND EUR_ISP_Spend_Type__c INCLUDES (:typeOfSpendRec) AND
			                 EUR_ISP_Country_Code__c = : theUser.EUR_CRM_Country_Code__c
			                         ORDER BY EUR_ISP_Spend_Activity_Type_Name__c ASC];
			break;
		}
		return outputResults;
	}

	private static Set<Id> getAvailableAccountIds()
	{
		Set<Id> ids = new Set<Id>();
		for (EUR_ISP_UserAccount__c userToAccount : [SELECT Id, EUR_ISP_Account__c
		        FROM EUR_ISP_UserAccount__c
		        WHERE EUR_ISP_User__c = : UserInfo.getUserId()
		                                LIMIT : EUR_ISP_SpendTableController.SPEND_RECORDS_LIMIT])
		{
			ids.add(userToAccount.EUR_ISP_Account__c);
		}
		return ids;
	}

	@AuraEnabled
	public static List<EUR_ISP_Spend_Activity__c> getSpendActivities(String spendId, String vendorId)
	{
		List<EUR_ISP_Spend_Activity__c> outputActivities = new List<EUR_ISP_Spend_Activity__c>();
		List<EUR_ISP_Spend_Activity__c> spendAcitivities = EUR_ISP_SpendActivityController.getBySpendId(spendId);

		vendorId = String.isNotBlank(vendorId) ? String.escapeSingleQuotes(vendorId) : null;
		if (String.isBlank(vendorId))
		{
			return spendAcitivities;
		}

		for (EUR_ISP_Spend_Activity__c theActivity : spendAcitivities)
		{
			if (theActivity.EUR_ISP_Approval_Status__c != EUR_ISP_Utils.APPROVED_APPROVAL_STATUS ||
			        theActivity.EUR_ISP_Status__c != EUR_ISP_Utils.COMMITTED_STATUS ||
			        theActivity.EUR_ISP_Vendor__c != vendorId)
			{
				continue;
			}

			Decimal total = theActivity.EUR_ISP_Total_Activity_Amount__c != null ? theActivity.EUR_ISP_Total_Activity_Amount__c : 0;
			Decimal matched = theActivity.EUR_ISP_Matched__c != null ? theActivity.EUR_ISP_Matched__c : 0;
			if (total - matched > 0 )
			{
				outputActivities.add(theActivity);
			}
		}
		return outputActivities;
	}

	@AuraEnabled
	public static Map<String, List<EUR_ISP_Spend_Activity__c>> getISPendActivitiesByIdAndType(String spendId, List<String> activityTypeIds)
	{
		return EUR_ISP_SpendActivityController.getBySpendIdAndType(spendId, activityTypeIds);
	}

	@AuraEnabled
	public static Map<String, List<EUR_ISP_Utils.PicklistValue>> getPicklistValues()
	{
		return EUR_ISP_Utils.getPicklistValuesForObject(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME);
	}

	public class SpendTableData
	{
		@AuraEnabled
		public Integer pageNumber {get; set;}
		@AuraEnabled
		public Integer pageSize {get; set;}
		@AuraEnabled
		public Boolean isCompleteResult {get; set;}
		@AuraEnabled
		public Integer totalRows {get; set;}
		@AuraEnabled
		public List<EUR_ISP_Spend__c> data {get; set;}

		public SpendTableData()
		{
			this.pageNumber = 1;
			this.pageSize = EUR_ISP_Utils.RECORDS_PER_PAGE_SIZE;
			this.isCompleteResult = false;
			this.totalRows = 0;
			this.data = new List<EUR_ISP_Spend__c>();
		}
	}

	public class SpendTableSearchSettings
	{
		@AuraEnabled
		public String spendName {get; set;}
		@AuraEnabled
		public String contractName {get; set;}
		@AuraEnabled
		public String startDate {get; set;}
		@AuraEnabled
		public String endDate {get; set;}
		@AuraEnabled
		public String vendorId {get; set;}
		@AuraEnabled
		public String accountId {get; set;}
		@AuraEnabled
		public String recordTypeId {get; set;}
		@AuraEnabled
		public String approvalStatus {get; set;}
		@AuraEnabled
		public String sortOrder {get; set;}
		@AuraEnabled
		public Integer pageNumber {get; set;}
	}
}