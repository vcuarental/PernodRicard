/**
 * Contract Push Service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_ContractPushService
{
	// for batch testing
	public static Boolean isServiceActive = true;

	public static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
	public static Map<String, Id> RECORD_TYPES = new Map<String, Id>();

	static
	{
		if (RECORD_TYPES.isEmpty())
		{
			Map<String, Id> rtMap = EUR_ISP_Utils.getRecordTypesMap();
			RECORD_TYPES.put(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME, rtMap.get(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME));
			RECORD_TYPES.put(EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME, rtMap.get(EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME + EUR_ISP_Utils.SFA_CONTRACT_RT_NAME));
			RECORD_TYPES.put(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME, rtMap.get(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME + EUR_ISP_Utils.DE_CONTRACT_RT_NAME));
		}
	}

	public static void pushContractData(Set<Id> contractIds)
	{
		EUR_ISP_LogService.clearErrors();
		if (contractIds == null || contractIds.isEmpty() || !isServiceActive)
		{
			return;
		}
		//if (RECORD_TYPES.isEmpty() || RECORD_TYPES.size() < 3)
		//{
		//	EUR_ISP_LogService.addError('Required Record Types can not be found', 'EUR_ISP_Utils:getRecordTypesMap', null);
		//	EUR_ISP_LogService.commitErrors();
		//	return;
		//}

		EUR_ISP_SpendTransactionsService.skipProcessing = true;
		EUR_ISP_ContractPushAbstract pushDataGenerator = new EUR_ISP_ContractPush(RECORD_TYPES);
		EUR_ISP_ContractPushAbstract pushDEDataGenerator = new EUR_ISP_ContractPushDE(RECORD_TYPES);

		List<EUR_CRM_Contract__c> contracts = EUR_ISP_ContractPushService.getContracts(contractIds);
		// START generate User To Account relations
		EUR_ISP_ContractPushService.createUserToAccountRelations(contracts);
		// END generate User To Account relations


		// START generate Spends
		List<EUR_ISP_Spend__c> spends = new List<EUR_ISP_Spend__c>();
		Map<Id, EUR_ISP_ContractPushData> contractIdToContractData = new Map<Id, EUR_ISP_ContractPushData>();
		for (EUR_CRM_Contract__c theContract : contracts)
		{
			EUR_ISP_ContractPushData contractData = new EUR_ISP_ContractPushData(theContract);
			if (EUR_ISP_ContractPushService.isDeContract(theContract))
			{
				EUR_ISP_LogService.setRecordTypeIdDE();
				pushDEDataGenerator.generateSpend(contractData);
			}
			else
			{
				pushDataGenerator.generateSpend(contractData);
			}

			contractIdToContractData.put(theContract.Id, contractData);
			spends.add(contractData.theSpend);
		}
		List<Database.SaveResult> spendSaveResults = Database.insert(spends, false);
		EUR_ISP_LogService.checkSaveResults(spendSaveResults);
		// END generate Spends


		// START Budget Transactions update
		EUR_ISP_ContractPushService.updateBudgetTransactions(contracts, contractIdToContractData);
		// END Budget Transactions update


		// START generate Spend Activities
		Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> contractToContractActivities = EUR_ISP_ContractPushService.getContractToContractActivities(contracts);
		Map<String, EUR_ISP_Spend_Activity_Type__c> externalIdToActvityType = EUR_ISP_ContractPushService.getSpendActivityTypes(contractToContractActivities);
		List<EUR_ISP_Spend_Activity__c> contractSpendActivities = new List<EUR_ISP_Spend_Activity__c> ();
		for (Id theContractId : contractToContractActivities.keySet())
		{
			EUR_ISP_ContractPushData contractData = contractIdToContractData.get(theContractId);
			if (contractData.theSpend == null || contractData.theSpend.Id == null)
			{
				continue;
			}

			Boolean isDeContract = EUR_ISP_ContractPushService.isDeContract(contractData.theContract);

			for (EUR_CRM_Contract_Activity_Item__c theContractActivity : contractToContractActivities.get(theContractId))
			{
				EUR_ISP_Spend_Activity_Type__c theType = externalIdToActvityType.get(theContractActivity.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
				if (theType == null)
				{
					if ( ! EUR_ISP_ContractPushDE.MECH_TYPES_NO_NEED_TO_CREATE_CPPP.contains(theContractActivity.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c))
					{
						EUR_ISP_LogService.addError('EUR_ISP_Spend_Activity_Type__c can not be found for External ID: ' + theContractActivity.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c, 'EUR_ISP_ContractPushService:pushContractData', theContractActivity.Id);
					}
					continue;
				}

				if (isDeContract)
				{
					pushDEDataGenerator.generateSpendActivity(contractData, theContractActivity, theType.Id);
				}
				else
				{
					pushDataGenerator.generateSpendActivity(contractData, theContractActivity, theType.Id);
				}


				List<EUR_ISP_Spend_Activity__c> theSpendActivities = contractData.contractActivityIdToSpendActivities.get(theContractActivity.Id);
				if (theSpendActivities != null && !theSpendActivities.isEmpty())
				{
					contractSpendActivities.addAll(theSpendActivities);
				}
			}
		}
		List<Database.SaveResult> activitiesSaveResults = Database.insert(contractSpendActivities, false);
		EUR_ISP_LogService.checkSaveResults(activitiesSaveResults);
		// END generate Spend Activities


		// START generate Spend Items
		List<EUR_ISP_Spend_Item__c> spendItems = new List<EUR_ISP_Spend_Item__c>();
		Map<Id, List<EUR_CRM_Contract_Product_Item__c>> contractActivityToProducts = EUR_ISP_ContractPushService.getContractActivityToProducts(contracts);
		for (EUR_ISP_ContractPushData contractData : contractIdToContractData.values())
		{
			if (contractData.contractActivityIdToSpendActivities.isEmpty() || contractData.theSpend == null || contractData.theSpend.Id == null)
			{
				continue;
			}

			Boolean isDeContract = EUR_ISP_ContractPushService.isDeContract(contractData.theContract);
			for (Id theContractActivityId : contractData.contractActivityIdToSpendActivities.keySet())
			{
				List<EUR_CRM_Contract_Product_Item__c> theProducts = contractActivityToProducts.get(theContractActivityId);
				if (theProducts == null)
				{
					continue;
				}

				for (EUR_CRM_Contract_Product_Item__c theProduct : theProducts)
				{
					if (isDeContract)
					{
						pushDEDataGenerator.generateSpendItem(contractData, theProduct, theContractActivityId);
					}
					else
					{
						pushDataGenerator.generateSpendItem(contractData, theProduct, theContractActivityId);
					}
				}
			}

			if (contractData.theSpendItems != null && !contractData.theSpendItems.isEmpty())
			{
				spendItems.addAll(contractData.theSpendItems);
			}
		}

		List<Database.SaveResult> itemsSaveResults = Database.insert(spendItems, false);
		EUR_ISP_LogService.checkSaveResults(itemsSaveResults);
		// END generate Spend Items

		// commit all errors to DB if exists
		EUR_ISP_LogService.commitErrors();
		EUR_ISP_LogService.setDefaultRecordTypeId();
	}

	public static Boolean isDeContract(EUR_CRM_Contract__c theContract)
	{
		return theContract.RecordTypeId != null && theContract.RecordTypeId == RECORD_TYPES.get(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME);
	}

	private static List<EUR_CRM_Contract__c> getContracts(Set<Id> contractIds)
	{
		return [SELECT Id, Name, RecordTypeId, CurrencyIsoCode, EUR_CRM_DE_Actual_Contract_Total__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c,
		        EUR_CRM_Account__c, EUR_CRM_Account__r.OwnerId,
		        EUR_CRM_Budget__c, EUR_CRM_Budget__r.OwnerId
		        FROM EUR_CRM_Contract__c WHERE Id IN: contractIds];
	}

	private static Set<String> getCurrentUserToAccountsSet(Set<Id> accountIds, Set<Id> userIds)
	{
		Set<String> outputResults = new Set<String>();
		for (EUR_ISP_UserAccount__c userAccount : [SELECT Id, EUR_ISP_Account__c, EUR_ISP_User__c
		        FROM EUR_ISP_UserAccount__c
		        WHERE EUR_ISP_User__c IN :userIds AND EUR_ISP_Account__c IN: accountIds])
		{
			String userToAccountKey = userAccount.EUR_ISP_Account__c + '' + userAccount.EUR_ISP_User__c;
			if (!outputResults.contains(userToAccountKey))
			{
				outputResults.add(userToAccountKey);
			}
		}
		return outputResults;
	}

	private static Map<Id, List<EUR_CRM_Budget_Transaction__c>> getContractToBudgetTransactions(List<EUR_CRM_Contract__c> contracts)
	{
		Map<Id, List<EUR_CRM_Budget_Transaction__c>> outputResults = new Map<Id, List<EUR_CRM_Budget_Transaction__c>>();
		for (EUR_CRM_Budget_Transaction__c transactionItem : [SELECT Id, EUR_CRM_Spend__c, EUR_CRM_Contract__c
		        FROM EUR_CRM_Budget_Transaction__c
		        WHERE EUR_CRM_Contract__c IN: contracts])
		{
			if (outputResults.containsKey(transactionItem.EUR_CRM_Contract__c))
			{
				outputResults.get(transactionItem.EUR_CRM_Contract__c).add(transactionItem);
				continue;
			}

			outputResults.put(transactionItem.EUR_CRM_Contract__c, new List<EUR_CRM_Budget_Transaction__c> {transactionItem});
		}
		return outputResults;
	}

	private static Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> getContractToContractActivities(List<EUR_CRM_Contract__c> contracts)
	{
		Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> outputResults = new Map<Id, List<EUR_CRM_Contract_Activity_Item__c>>();
		for (EUR_CRM_Contract_Activity_Item__c theActivitiy : [SELECT Id, Name, EUR_CRM_Amount__c, EUR_CRM_End_Date__c, EUR_CRM_Start_Date__c,
		        EUR_CRM_Payment_Term__c, EUR_CRM_Vendor__c, CurrencyIsoCode, EUR_CRM_Contract__c,
		        EUR_CRM_Mechanic_Type__c, EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c,

		        (SELECT Id, EUR_CRM_Contract_Activity_Item__c, EUR_CRM_Contract_Product_Item__c,
		         EUR_CRM_CPPP_Amount__c, EUR_CRM_CPPP_Payment_Term__c,
		         EUR_CRM_Payment_Period_End_Date__c, EUR_CRM_Payment_Period_Start_Date__c
		         FROM Contract_Payment_Plan_Periods__r)

		        FROM EUR_CRM_Contract_Activity_Item__c
		        WHERE EUR_CRM_Contract__c IN: contracts AND EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c != null])
			//AND EUR_CRM_Exclude_Budget_Deduction__c = false
		{
			if (outputResults.containsKey(theActivitiy.EUR_CRM_Contract__c))
			{
				outputResults.get(theActivitiy.EUR_CRM_Contract__c).add(theActivitiy);
				continue;
			}

			outputResults.put(theActivitiy.EUR_CRM_Contract__c, new List<EUR_CRM_Contract_Activity_Item__c> {theActivitiy});
		}
		return outputResults;
	}

	private static Map<String, EUR_ISP_Spend_Activity_Type__c> getSpendActivityTypes(Map<Id, List<EUR_CRM_Contract_Activity_Item__c>> contractActivities)
	{
		Set<String> externalIds = new Set<String>();
		for (List<EUR_CRM_Contract_Activity_Item__c> activityItems : contractActivities.values())
		{
			for (EUR_CRM_Contract_Activity_Item__c activityItem : activityItems)
			{
				if (String.isNotBlank(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c))
				{
					externalIds.add(activityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c);
				}
			}
		}

		Map<String, EUR_ISP_Spend_Activity_Type__c> outputResults = new Map<String, EUR_ISP_Spend_Activity_Type__c>();
		for (EUR_ISP_Spend_Activity_Type__c theType : [SELECT Id, EUR_ISP_External_ID__c
		        FROM EUR_ISP_Spend_Activity_Type__c
		        WHERE EUR_ISP_External_ID__c IN: externalIds
		        LIMIT 1000])
		{
			outputResults.put(theType.EUR_ISP_External_ID__c, theType);
		}
		return outputResults;
	}

	private static Map<Id, List<EUR_CRM_Contract_Product_Item__c>> getContractActivityToProducts(List<EUR_CRM_Contract__c> contracts)
	{
		Map<Id, List<EUR_CRM_Contract_Product_Item__c>> outputResults = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();

		for (EUR_CRM_Contract_Product_Item__c theProduct : [SELECT Id, Name, EUR_CRM_SKU__c, EUR_CRM_Amount__c, EUR_CRM_Unit__c, EUR_CRM_Quantity__c,
		        EUR_CRM_Brand__c, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Contract_Activity_Item__c,

		        (SELECT Id, EUR_CRM_Contract_Activity_Item__c, EUR_CRM_Contract_Product_Item__c,
		         EUR_CRM_CPPP_Rate__c, EUR_CRM_CPPP_Volume__c, EUR_CRM_Payment_Period_Start_Date__c
		         FROM Contract_Payment_Plan_Periods_EU__r)

		        FROM EUR_CRM_Contract_Product_Item__c
		        WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c IN: contracts])
		{
			if (outputResults.containsKey(theProduct.EUR_CRM_Contract_Activity_Item__c))
			{
				outputResults.get(theProduct.EUR_CRM_Contract_Activity_Item__c).add(theProduct);
				continue;
			}

			outputResults.put(theProduct.EUR_CRM_Contract_Activity_Item__c, new List<EUR_CRM_Contract_Product_Item__c> {theProduct});
		}
		return outputResults;
	}

	public static void createUserToAccountRelations(List<EUR_CRM_Contract__c> contracts)
	{
		Set<Id> accountIds = new Set<Id>();
		Set<Id> userIds = new Set<Id>();
		for (EUR_CRM_Contract__c theContract : contracts)
		{
			if (theContract.EUR_CRM_Account__c != null)
			{
				accountIds.add(theContract.EUR_CRM_Account__c);
				userIds.add(theContract.EUR_CRM_Account__r.OwnerId);
				if (theContract.EUR_CRM_Budget__c != null &&  theContract.EUR_CRM_Budget__r.OwnerId != theContract.EUR_CRM_Account__r.OwnerId)
				{
					userIds.add(theContract.EUR_CRM_Budget__r.OwnerId);
				}
			}
		}

		List<EUR_ISP_UserAccount__c> userToAccounts = new List<EUR_ISP_UserAccount__c>();
		Set<String> userToAccountKeys = EUR_ISP_ContractPushService.getCurrentUserToAccountsSet(accountIds, userIds);
		for (EUR_CRM_Contract__c theContract : contracts)
		{
			if (theContract.EUR_CRM_Account__c != null)
			{
				String userToAccountKey = theContract.EUR_CRM_Account__c + '' + theContract.EUR_CRM_Account__r.OwnerId;
				String userToBudgetKey = theContract.EUR_CRM_Budget__c != null ? theContract.EUR_CRM_Account__c + '' + theContract.EUR_CRM_Budget__r.OwnerId : '';
				if (!userToAccountKeys.contains(userToBudgetKey) && !userToAccountKey.equals(userToBudgetKey) && String.isNotBlank(userToBudgetKey))
				{
					userToAccountKeys.add(userToBudgetKey);
					userToAccounts.add(
					    EUR_ISP_ContractPushService.generateUserToAccount(theContract.EUR_CRM_Account__c, theContract.EUR_CRM_Budget__r.OwnerId)
					);
				}
				if (!userToAccountKeys.contains(userToAccountKey))
				{
					userToAccountKeys.add(userToAccountKey);
					userToAccounts.add(
					    EUR_ISP_ContractPushService.generateUserToAccount(theContract.EUR_CRM_Account__c, theContract.EUR_CRM_Account__r.OwnerId)
					);
				}
			}
		}
		List<Database.SaveResult> userToAccountResults = Database.insert(userToAccounts, false);
		EUR_ISP_LogService.checkSaveResults(userToAccountResults);
	}

	private static void updateBudgetTransactions(List<EUR_CRM_Contract__c> contracts, Map<Id, EUR_ISP_ContractPushData> contractIdToContractData)
	{
		Map<Id, List<EUR_CRM_Budget_Transaction__c>> contractToTransactions = EUR_ISP_ContractPushService.getContractToBudgetTransactions(contracts);
		List<EUR_CRM_Budget_Transaction__c> transactionsToUpdate = new List<EUR_CRM_Budget_Transaction__c>();
		for (Id theContractId : contractToTransactions.keySet())
		{
			for (EUR_CRM_Budget_Transaction__c transactionItem : contractToTransactions.get(theContractId))
			{
				EUR_ISP_ContractPushData contractData = contractIdToContractData.get(theContractId);
				if (contractData.theSpend != null && contractData.theSpend.Id != null)
				{
					transactionItem.EUR_CRM_Spend__c = contractData.theSpend.Id;
					transactionsToUpdate.add(transactionItem);
				}
			}
		}
		List<Database.SaveResult> transactionsUpdateResults = Database.update(transactionsToUpdate, false);
		EUR_ISP_LogService.checkSaveResults(transactionsUpdateResults);
	}

	/**
	 * generaet new EUR_ISP_UserAccount__c record
	 */
	private static EUR_ISP_UserAccount__c generateUserToAccount(Id accountId, Id userId)
	{
		return new EUR_ISP_UserAccount__c(
		           EUR_ISP_Account__c = accountId,
		           EUR_ISP_User__c = userId
		       );
	}
}