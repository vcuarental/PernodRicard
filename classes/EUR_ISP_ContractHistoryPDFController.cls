/**
 * PDF page controller for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_ContractHistoryPDFController
{
	public static final String CONTRACT_ID_PARAM_NAME = 'contractId';
	private Set<String> activityPuringTypeExtIds;
	private Date startFYPeriod;

	public transient EUR_CRM_Contract__c theContract {get; set;}
	public transient Map<String, Map<String, DataWrapper>> refundDataMap {get; set;}	// PERIOD Key => BQ Key => Data
	public transient DataWrapper refundTotal {get; set;}
	public transient List<DataWrapper> marketingData {get; set;}
	public transient DataWrapper marketingTotal {get; set;}
	public transient Integer refundDataSize {get; set;}
	public transient String userLang {get; set;}
	public transient Boolean isDeUser {get; set;}

	public EUR_ISP_ContractHistoryPDFController()
	{
		this.activityPuringTypeExtIds = new Set<String>();
		this.refundDataMap = new Map<String, Map<String, DataWrapper>>();
		this.refundTotal = new DataWrapper();

		this.marketingData = new List<DataWrapper>();
		this.marketingTotal = new DataWrapper();
		this.refundDataSize = 0;
		this.userLang = [SELECT LanguageLocaleKey FROM User WHERE Id = : UserInfo.getUserId()].LanguageLocaleKey;
		this.isDeuser = this.userLang.startsWithIgnoreCase('de');
	}

	public void initAction()
	{
		String contractId = ApexPages.currentPage().getParameters().get(CONTRACT_ID_PARAM_NAME);
		if (String.isBlank(contractId))
		{
			return;
		}

		contractId = String.escapeSingleQuotes(contractId);
		for (EUR_CRM_Contract__c contract : this.getContracts(contractId))
		{
			this.theContract = contract;
		}

		if (this.theContract != null)
		{
			this.setPuringTypeExtIds();
			this.initData();
		}
	}

	private void initData()
	{
		Map<Date, Date> contractPeriodsMap = this.getContractPeriodsMap();
		Map<Id, List<EUR_ISP_Volume_Change_History__c>> historyMap = new Map<Id, List<EUR_ISP_Volume_Change_History__c>>();
		for (EUR_ISP_Volume_Change_History__c history : this.getChangeHistory())
		{
			if (!historyMap.containsKey(history.EUR_ISP_Spend_Activity__c))
			{
				historyMap.put(history.EUR_ISP_Spend_Activity__c, new List<EUR_ISP_Volume_Change_History__c>());
			}
			historyMap.get(history.EUR_ISP_Spend_Activity__c).add(history);
		}

		for (List<EUR_ISP_Volume_Change_History__c> history : historyMap.values())
		{
			EUR_ISP_Volume_Change_History__c activitInitRec = history.get(0);
			if (!activityPuringTypeExtIds.contains(activitInitRec.EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_External_ID__c))
			{
				// Marketing activities generation
				this.populateMarketingData(history);
			}
			else
			{
				this.populateRefundData(activitInitRec, history);
			}
		}

		for (Map<String, DataWrapper> dataMap : this.refundDataMap.values())
		{
			for (DataWrapper data : dataMap.values())
			{
				this.refundTotal.initialVolume += data.initialVolume;
				this.refundTotal.initialAmount += data.initialAmount;
				this.refundTotal.adjustedVolume += data.adjustedVolume;
				this.refundTotal.adjustedAmount += data.adjustedAmount;
			}
		}

		for (DataWrapper data : marketingData)
		{
			this.marketingTotal.initialAmount += data.initialAmount;
			this.marketingTotal.adjustedAmount += data.adjustedAmount;
		}
	}

	private void populateRefundData(EUR_ISP_Volume_Change_History__c activitInitRec, List<EUR_ISP_Volume_Change_History__c> history)
	{
		Date startDate = activitInitRec.EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Start_Date__c;
		startDate = startDate != null ? startDate : Date.today();
		Date endDate = activitInitRec.EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_End_Date__c;
		endDate = endDate != null ? endDate : Date.today();
		String periodKey = String.valueOf(startDate) + String.valueOf(endDate);

		// put item history records to the Map
		Map<Id, List<EUR_ISP_Volume_Change_History__c>> itemIdToHistory = new Map<Id, List<EUR_ISP_Volume_Change_History__c>>();
		for (EUR_ISP_Volume_Change_History__c historyRec : history)
		{
			if (historyRec.EUR_ISP_Spend_Item__c != null)
			{
				if (!itemIdToHistory.containsKey(historyRec.EUR_ISP_Spend_Item__c))
				{
					itemIdToHistory.put(historyRec.EUR_ISP_Spend_Item__c, new List<EUR_ISP_Volume_Change_History__c>());
				}
				itemIdToHistory.get(historyRec.EUR_ISP_Spend_Item__c).add(historyRec);
			}
		}

		for (List<EUR_ISP_Volume_Change_History__c> itemHistory : itemIdToHistory.values())
		{
			// period data
			DataWrapper data = new DataWrapper();
			data.startDate = startDate;
			data.endDate = endDate;
			if (activitInitRec.EUR_ISP_Spend_Item__c == null)
			{
				if (activitInitRec.EUR_ISP_New_Value_Activity_Amount__c != null)
				{
					data.initialAmount += activitInitRec.EUR_ISP_New_Value_Activity_Amount__c;
				}
				if (activitInitRec.EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Amount__c != null)
				{
					data.adjustedAmount += activitInitRec.EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Amount__c;
				}
			}

			// data from the latest History object (constant data)
			EUR_ISP_Volume_Change_History__c historyRecLast = itemHistory.get(itemHistory.size() - 1);
			if (historyRecLast.EUR_ISP_Spend_Item__r.EUR_ISP_Volume__c != null )
			{
				data.adjustedVolume = historyRecLast.EUR_ISP_Spend_Item__r.EUR_ISP_Volume__c;
			}
			if (historyRecLast.EUR_ISP_Spend_Item__r.EUR_ISP_Total_Spend_Item__c != null)
			{
				data.adjustedAmount += historyRecLast.EUR_ISP_Spend_Item__r.EUR_ISP_Total_Spend_Item__c;
			}
			if (historyRecLast.EUR_ISP_SKU__c != null)
			{
				data.bq = historyRecLast.EUR_ISP_SKU__r.Name;
			}
			else if (historyRecLast.EUR_ISP_Brand__c != null)
			{
				data.bq = historyRecLast.EUR_ISP_Brand__r.Name;
			}
			else if (historyRecLast.EUR_ISP_Brand_Quality__c != null)
			{
				data.bq = historyRecLast.EUR_ISP_Brand_Quality__r.Name;
			}
			else if (historyRecLast.EUR_ISP_Brand_Quality_Size__c != null)
			{
				data.bq = historyRecLast.EUR_ISP_Brand_Quality_Size__r.Name;
			}
			else if (historyRecLast.EUR_ISP_Wine_Spirits__c != null)
			{
				data.bq = historyRecLast.EUR_ISP_Wine_Spirits__r.Name;
			}

			// initial data
			for (EUR_ISP_Volume_Change_History__c historyRec : itemHistory)
			{
				// add initial price of items
				if (historyRec.EUR_ISP_New_Value_Total_Spend_Item__c != null && historyRec.EUR_ISP_Old_Value_Total_Spend_Item__c == null)
				{
					data.initialAmount += historyRec.EUR_ISP_New_Value_Total_Spend_Item__c;
				}
				// add initial number of items
				if (historyRec.EUR_ISP_New_Value_Volume__c != null && historyRec.EUR_ISP_Old_Value_Volume__c == null)
				{
					data.initialVolume = historyRec.EUR_ISP_New_Value_Volume__c;
				}
				// we get the latest Rate value
				if (historyRec.EUR_ISP_New_Value_Per_Unit_Amount__c != null)
				{
					data.rate = historyRec.EUR_ISP_New_Value_Per_Unit_Amount__c;
				}
			}

			if (!this.refundDataMap.containsKey(periodKey))
			{
				this.refundDataMap.put(periodKey, new Map<String, DataWrapper>());
			}
			if (!this.refundDataMap.get(periodKey).containsKey(data.bq))
			{
				this.refundDataMap.get(periodKey).put(data.bq, data);
			}
			else
			{
				DataWrapper tmpData = this.refundDataMap.get(periodKey).get(data.bq);
				tmpData.initialAmount += data.initialAmount;
				tmpData.adjustedAmount += data.adjustedAmount;
				tmpData.initialVolume += data.initialVolume;
				tmpData.adjustedVolume += data.adjustedVolume;
			}
		}
		this.refundDataSize = this.refundDataMap.size();
	}

	private void populateMarketingData(List<EUR_ISP_Volume_Change_History__c> history)
	{
		DataWrapper data = new DataWrapper();
		data.startDate = history.get(0).EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Start_Date__c;
		data.endDate = history.get(0).EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_End_Date__c;
		if (history.get(0).EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Amount__c != null)
		{
			data.adjustedAmount += history.get(0).EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Amount__c;
		}
		if (this.isDeUser)
		{
			data.mtype = history.get(0).EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type_Name__c;
		}
		else
		{
			data.mtype = history.get(0).EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c;
		}

		Map<Id, List<EUR_ISP_Volume_Change_History__c>> itemIdToHistory = new Map<Id, List<EUR_ISP_Volume_Change_History__c>>();
		for (EUR_ISP_Volume_Change_History__c historyRec : history)
		{
			// find the first record created for activity only
			if (historyRec.EUR_ISP_Spend_Item__c == null)
			{
				if (historyRec.EUR_ISP_New_Value_Activity_Amount__c != null && historyRec.EUR_ISP_Old_Value_Activity_Amount__c == null)
				{
					data.initialAmount += historyRec.EUR_ISP_New_Value_Activity_Amount__c;
				}
			}

			if (historyRec.EUR_ISP_Spend_Item__c != null)
			{
				// put item history records to the Map
				if (!itemIdToHistory.containsKey(historyRec.EUR_ISP_Spend_Item__c))
				{
					itemIdToHistory.put(historyRec.EUR_ISP_Spend_Item__c, new List<EUR_ISP_Volume_Change_History__c>());
				}
				itemIdToHistory.get(historyRec.EUR_ISP_Spend_Item__c).add(historyRec);

				// add initial price of items
				if (historyRec.EUR_ISP_New_Value_Total_Spend_Item__c != null && historyRec.EUR_ISP_Old_Value_Total_Spend_Item__c == null)
				{
					data.initialAmount += historyRec.EUR_ISP_New_Value_Total_Spend_Item__c;
				}
				// add initial number of items
				if (historyRec.EUR_ISP_New_Value_Volume__c != null && historyRec.EUR_ISP_Old_Value_Volume__c == null)
				{
					data.initialVolume += historyRec.EUR_ISP_New_Value_Volume__c;
				}
				// we get the latest Rate value
				if (historyRec.EUR_ISP_New_Value_Per_Unit_Amount__c != null)
				{
					data.rate = historyRec.EUR_ISP_New_Value_Per_Unit_Amount__c;
				}
			}
		}

		for (List<EUR_ISP_Volume_Change_History__c> itemHistory : itemIdToHistory.values())
		{
			EUR_ISP_Volume_Change_History__c historyRec = itemHistory.get(itemHistory.size() - 1);
			if (historyRec.EUR_ISP_Spend_Item__r.EUR_ISP_Volume__c != null)
			{
				data.adjustedVolume += historyRec.EUR_ISP_Spend_Item__r.EUR_ISP_Volume__c;
			}
			if (historyRec.EUR_ISP_Spend_Item__r.EUR_ISP_Total_Spend_Item__c != null)
			{
				data.adjustedAmount += historyRec.EUR_ISP_Spend_Item__r.EUR_ISP_Total_Spend_Item__c;
			}
			if (historyRec.EUR_ISP_SKU__c != null)
			{
				data.bq += historyRec.EUR_ISP_SKU__r.Name + '<br/>';
			}
			else if (historyRec.EUR_ISP_Brand__c != null)
			{
				data.bq += historyRec.EUR_ISP_Brand__r.Name + '<br/>';
			}
			else if (historyRec.EUR_ISP_Brand_Quality__c != null)
			{
				data.bq += historyRec.EUR_ISP_Brand_Quality__r.Name + '<br/>';
			}
			else if (historyRec.EUR_ISP_Brand_Quality_Size__c != null)
			{
				data.bq += historyRec.EUR_ISP_Brand_Quality_Size__r.Name + '<br/>';
			}
			else if (historyRec.EUR_ISP_Wine_Spirits__c != null)
			{
				data.bq += historyRec.EUR_ISP_Wine_Spirits__r.Name + '<br/>';
			}
		}
		this.marketingData.add(data);
	}

	private List<EUR_ISP_Volume_Change_History__c> getChangeHistory()
	{
		Set<Id> activitiIDs = this.getActivityIds();
		return [SELECT Id,
		        EUR_ISP_Spend_Activity__c,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Amount__c,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Start_Date__c,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_End_Date__c,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type_Name__c,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Spend_Activity_Type_Name_English__c,
		        EUR_ISP_Spend_Activity__r.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_External_ID__c,

		        EUR_ISP_Spend_Item__c,
		        EUR_ISP_Spend_Item__r.EUR_ISP_Per_Unit_Amount__c,
		        EUR_ISP_Spend_Item__r.EUR_ISP_Volume__c,
		        EUR_ISP_Spend_Item__r.EUR_ISP_Total_Spend_Item__c,

		        EUR_ISP_New_Value_Activity_End_Date__c,
		        EUR_ISP_New_Value_Activity_Start_Date__c,
		        EUR_ISP_New_Value_Activity_Amount__c,
		        EUR_ISP_Old_Value_Activity_Amount__c,

		        EUR_ISP_New_Value_Total_Spend_Item__c,
		        EUR_ISP_Old_Value_Total_Spend_Item__c,
		        EUR_ISP_New_Value_Volume__c,
		        EUR_ISP_Old_Value_Volume__c,
		        EUR_ISP_New_Value_Per_Unit_Amount__c,
		        EUR_ISP_Old_Value_Per_Unit_Amount__c,

		        EUR_ISP_SKU__r.Name,
		        EUR_ISP_Brand__r.Name,
		        EUR_ISP_Brand_Quality__r.Name,
		        EUR_ISP_Brand_Quality_Size__r.Name,
		        EUR_ISP_Wine_Spirits__r.Name
		        FROM EUR_ISP_Volume_Change_History__c
		        WHERE EUR_ISP_Spend_Activity__c IN : activitiIDs
		        ORDER BY CreatedDate, EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_Start_Date__c, EUR_ISP_Spend_Activity__r.EUR_ISP_Activity_End_Date__c ASC];
	}

	private void setPuringTypeExtIds()
	{
		Id pouringRefundRtId = Global_RecordTypeCache.getRtId('EUR_CRM_Mechanic_Type__cEUR_DE_Pouring_RV_Mechanic_Type');
		for (EUR_CRM_Mechanic_Type__c type : [SELECT Id, EUR_CRM_External_ID__c
		                                      FROM EUR_CRM_Mechanic_Type__c
		                                      WHERE RecordTypeId = : pouringRefundRtId])
		{
			this.activityPuringTypeExtIds.add(type.EUR_CRM_External_ID__c);
		}
	}

	private Set<Id> getActivityIds()
	{
		return new Map<Id, EUR_ISP_Spend_Activity__c>([SELECT Id FROM EUR_ISP_Spend_Activity__c
		        WHERE EUR_ISP_Spend__r.EUR_ISP_Contract__c = : this.theContract.Id]).keySet();
	}

	private List<EUR_CRM_Contract__c> getContracts(String contractId)
	{
		return [SELECT Id, Name, EUR_CRM_Contract_Number__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c, LastModifiedDate, EUR_CRM_DE_Deductible_Contract_Total__c,
		        EUR_CRM_Account__c, EUR_CRM_Account__r.Name, EUR_CRM_Account__r.EUR_CRM_Street__c, CurrencyIsoCode,
		        EUR_CRM_Account__r.EUR_CRM_Postal_Code__c, EUR_CRM_Account__r.EUR_CRM_City__c
		        FROM EUR_CRM_Contract__c WHERE Id = : contractId];
	}

	private Map<Date, Date> getContractPeriodsMap()
	{
		Date startDate = this.theContract.EUR_CRM_Start_Date__c;
		Date endDate = this.theContract.EUR_CRM_End_Date__c;
		return EUR_ISP_BudgetService.getPeriodsMap(startDate, endDate);
	}

	public class DataWrapper
	{
		public Date startDate {get; set;}
		public Date endDate {get; set;}
		public String bq {get; set;}
		public String mtype {get; set;}

		public Decimal initialVolume {get; set;}
		public Decimal initialAmount {get; set;}
		public Decimal rate {get; set;}

		public Decimal adjustedVolume {get; set;}
		public Decimal adjustedAmount {get; set;}

		public DataWrapper()
		{
			this.bq = '';
			this.initialVolume = 0;
			this.initialAmount = 0;
			this.rate = 0;
			this.adjustedVolume = 0;
			this.adjustedAmount = 0;
		}
	}
}