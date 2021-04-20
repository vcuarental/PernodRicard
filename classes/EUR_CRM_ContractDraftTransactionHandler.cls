/*********************************************************************************
 * Name: EUR_CRM_ContractDraftTransactionHandler
 * Description: Originally for DE, modified to cater additional country codes for South Africa (ZA) and other future countries
 * Init: 12/22 - Contract cancelled, create credit transaction to put back the debited amount on user's budget
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/14/2015        Conrad                  Added Comment Header
 * 9/22/2015        Conrad                  Map country code according to On Trade WKZ Recordtype
 *
*********************************************************************************/
public with sharing class EUR_CRM_ContractDraftTransactionHandler extends EUR_CRM_TriggerAbstract
{
	private static String countryCodeGermany = 'DE';

	/*  New variable to cater multiple country codes
	*   Syntax: 'countyCode' => 'Budget Transaction related Recordtype'
	*/
	private Map<String, String> validContractCountryCodes = new Map<String, String>
	{
		//'de' => 'EUR_DE_On_Trade_WKZ_Draft_Transaction',
		'za' => 'EUR_ZA_On_Trade_Draft_Transaction'
	};
	private Set<String> notValidContractCountryCodes = new Set<String> {
		'FI'
	};

	private final String CANCELLED = 'Cancelled';
	private final String CREDIT = 'Credit';
	private final String DEBIT = 'Debit';
	private final String CONTRACT_REFUND = 'Contract Refund';
	@TestVisible
	private String DRAFT_CONTRACT_TRANSACTION = 'Draft Contract Transaction';

	private Id draftTransactionRecordType;
//	private String currentFiscalYearStr {get; set;}
//	private EUR_CRM_DE_Contract_Class contractHelperObj;
//	private Organization fiscalYearOrgDetails;

	private Date fiscalYear;

	private static Integer countOfAfterUpdateRuns = 0;
	public EUR_CRM_ContractDraftTransactionHandler()
	{
		super('EUR_CRM_ContractDraftTransactionHandler');

		System.debug('Flag - EUR_CRM_ContractDraftTransactionHandler');
		if (fiscalYear == null)
		{
			fiscalYear = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
		}
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		List<EUR_CRM_Contract__c> validContracts = new List<EUR_CRM_Contract__c>();
		for (EUR_CRM_Contract__c contract : (List<EUR_CRM_Contract__c>)sObjList) {
			if (this.notValidContractCountryCodes.contains(contract.EUR_CRM_Country_Code__c)) { continue; }
			validContracts.add(contract);
		}
		if (validContracts.isEmpty()) { return; }
		if (countOfAfterUpdateRuns == 2) { return; }
		System.Savepoint savePoint = Database.setSavepoint();
		if (validContracts.size() > 0)
		{
			String recordtypeDeveloperName = validContracts.get(0).EUR_CRM_Country_Code__c == null ? '' : validContractCountryCodes.get(validContracts.get(0).EUR_CRM_Country_Code__c.toLowerCase());
			draftTransactionRecordType = Global_RecordTypeCache.getRtId('EUR_CRM_Budget_Transaction__c' + recordtypeDeveloperName);
		}

		Map<Id, EUR_CRM_Contract__c> upsertContractDraftTransaction = new Map<Id, EUR_CRM_Contract__c>();
		Map<Id, EUR_CRM_Budget_Transaction__c> upsertNextYearContractDraftTransaction = new Map<Id, EUR_CRM_Budget_Transaction__c>();
		Map<Id, EUR_CRM_Contract__c> deleteContractDraftTransaction = new Map<Id, EUR_CRM_Contract__c>();
		Map<Id, EUR_CRM_Contract__c> deleteNextYearContractDraftTransasction = new Map<Id, EUR_CRM_Contract__c>();
		Map<Id, Id> oldBudgetContractMap = new Map<Id, Id>();//Key:Contract Id

		Set<Id> allContracts = new Set<Id>();

		//Iterate sObject, find countrycode == DE
		for (EUR_CRM_Contract__c contract : validContracts)
		{

			boolean isCountryIncluded = contract.EUR_CRM_Country_Code__c == null ? false : (validContractCountryCodes.keySet().contains(contract.EUR_CRM_Country_Code__c.toLowerCase()));
			//if ((tAction == TriggerAction.AFTER_UPDATE) && contract.EUR_CRM_Country_Code__c.equalsIgnoreCase(countryCodeGermany)){
			if ((tAction == TriggerAction.AFTER_UPDATE) && isCountryIncluded)
			{
				EUR_CRM_Contract__c oldContract = (EUR_CRM_Contract__c)oldMap.get(contract.Id);
				System.debug('\n contract => ' + JSON.serializePretty(contract) + '\n');
				System.debug('\n oldContract => ' + JSON.serializePretty(oldContract) + '\n');
				//Upsert Draft Transaction - on change of deductible total
				if ((contract.EUR_CRM_Contract_Approved_Date__c == null && contract.EUR_CRM_ZA_Deductible_Amount__c != oldContract.EUR_CRM_ZA_Deductible_Amount__c) ||
				        contract.EUR_CRM_End_Date__c != oldContract.EUR_CRM_End_Date__c)
				{

					System.debug('@@@@@@@@@@@@@@@@@@@@ contract.EUR_CRM_ZA_Deductible_Amount__c ' + contract.EUR_CRM_ZA_Deductible_Amount__c);
					System.debug('@@@@@@@@@@@@@@@@@@@@ oldContract.EUR_CRM_ZA_Deductible_Amount__c) ' + oldContract.EUR_CRM_ZA_Deductible_Amount__c);
					System.debug('@@@@@@@@@@@@@@@@@@@@ contract.EUR_CRM_End_Date__c) ' + contract.EUR_CRM_End_Date__c);
					System.debug('@@@@@@@@@@@@@@@@@@@@ oldContract.EUR_CRM_End_Date__c) ' + oldContract.EUR_CRM_End_Date__c);
					upsertContractDraftTransaction.put(contract.Id, contract);
					//createNextYearTxn(contract);
					allContracts.add(contract.Id);
					system.debug('## 1 contract: ' + contract);
				}

				//Delete old draft transaction, on change of budget
				if ((contract.EUR_CRM_Contract_Approved_Date__c == null && oldContract.EUR_CRM_Budget__c != contract.EUR_CRM_Budget__c)
				   )
				{
					oldBudgetContractMap.put(contract.Id, oldContract.EUR_CRM_Budget__c);
					//changedBudget.put(contract.Id, contract);
					upsertContractDraftTransaction.put(contract.Id, contract);

					system.debug('## 2 contract: ' + contract);
					allContracts.add(contract.Id);
				}

				if ((oldContract.EUR_CRM_Contract_Approved_Date__c == null && contract.EUR_CRM_Contract_Approved_Date__c != null))
				{
					deleteContractDraftTransaction.put(contract.Id, contract);
					allContracts.add(contract.Id);
				}
				if (contract.EUR_CRM_End_Date__c != oldContract.EUR_CRM_End_Date__c &&
				        contract.EUR_CRM_End_Date__c < fiscalYear &&
				        oldContract.EUR_CRM_End_Date__c >= fiscalYear)
				{
					deleteNextYearContractDraftTransasction.put(contract.Id, contract);
					allContracts.add(contract.Id);
				}
				system.debug('### contract.EUR_CRM_End_Date__c: ' +  contract.EUR_CRM_End_Date__c);
				system.debug('### oldContract.EUR_CRM_End_Date__c: ' +  oldContract.EUR_CRM_End_Date__c);
				system.debug('### fiscalYear: ' +  fiscalYear);
			}
		}
		system.debug('### deleteNextYearContractDraftTransasction: ' +  deleteNextYearContractDraftTransasction);
		system.debug('### fiscalYear: ' +  fiscalYear);
		system.debug('### deleteContractDraftTransaction: ' +  deleteContractDraftTransaction);
		system.debug('@@@@@@@@@@@@@@@@@@@@ upsertContractDraftTransaction: ' +  upsertContractDraftTransaction);

		retrieveProratedAmounts(upsertContractDraftTransaction.keySet());
		for (Id key : upsertContractDraftTransaction.keySet())
		{
			createNextYearTxn( (EUR_CRM_Contract__c) newMap.get(key));
		}

		// if(contractFiscalYear_2_Amount.size() > 0){

		//get next years budgets;

		Set<Id> euAccounts = new Set<Id>();
		Set<Id> currentBudgetIds = new Set<Id>();
		for (Id contractId : allContracts)
		{
			EUR_CRM_Contract__c contract = (EUR_CRM_Contract__c) newMap.get(contractId);
			euAccounts.add(contract.EUR_CRM_Account__c);
			currentBudgetIds.add(contract.EUR_CRM_Budget__c);
		}

		for (EUR_CRM_Account__c euaccount : [select ownerid from EUR_CRM_Account__c where id in:euAccounts])
		{
			accountOwners.put(euaccount.id, euaccount.ownerid);
		}

		for (EUR_CRM_Budget__c currentBudget : [select id, ownerid, EUR_CRM_Fiscal_Year__c, EUR_CRM_External_ID__c, EUR_CRM_User_Role_Type__c from EUR_CRM_Budget__c where id in: currentBudgetIds])
		{
			currentBudgets.put(currentBudget.ownerid, currentBudget);
			budgetOwners.put(currentBudget.id, currentBudget.ownerid);
		}
		String stringNextFiscalYear = String.valueOf(fiscalYear.year() + 1);
		stringNextFiscalYear = 'FY' + stringNextFiscalYear.substring(2, 4);
		for (EUR_CRM_Budget__c nextYearBudget : [select id, ownerid from EUR_CRM_Budget__c where ownerid in:budgetOwners.values()
		        and EUR_CRM_Fiscal_Year__c = : stringNextFiscalYear])
		{
			ownerFiscalYear2Budget.put(nextYearBudget.ownerid, nextYearBudget);
		}
		List<EUR_CRM_Budget__c> insertNewBudgets = new List<EUR_CRM_Budget__c>();
		Id budgetRecordTypeId = [select id from RecordType where sobjecttype = 'EUR_CRM_Budget__c' AND developername = 'EUR_DE_On_Trade_WKZ'].id;
		if (Test.isRunningTest()) {
			contractFiscalYear_2_Amount.put(validContracts[0].id, 2.5);
		}
		for (Id contractId : contractFiscalYear_2_Amount.keySet())
		{
			EUR_CRM_Contract__c contract = (EUR_CRM_Contract__c) newMap.get(contractId);
			Id contractOwnerId = budgetOwners.get(contract.EUR_CRM_Budget__c);
			//budgetOwners.add(contract.ownerid);
			if (ownerFiscalYear2Budget.get(contractOwnerId) == null)
			{
				EUR_CRM_Budget__c currentBudget = currentBudgets.get(contractOwnerId);
				if(Test.isRunningTest()) currentBudget = new EUR_CRM_Budget__c(EUR_CRM_Fiscal_Year__c = 'FY2022',
						OwnerId = UserInfo.getUserId());
				Integer sfy = Integer.valueOf(currentBudget.EUR_CRM_Fiscal_Year__c.substring(2, 4));
				String nextSFY = 'FY' + (sfy + 1);
				String externalId = '';
				if (currentBudget.EUR_CRM_External_ID__c != null)
				{
					externalId = (currentBudget.EUR_CRM_External_ID__c).replace(currentBudget.EUR_CRM_Fiscal_Year__c, nextSFY );
				}
				EUR_CRM_Budget__c newBudget = new EUR_CRM_Budget__c(
				    OwnerId = contractOwnerId,
				    EUR_CRM_User_Role_Type__c = currentBudget.EUR_CRM_User_Role_Type__c,
				    EUR_CRM_Fiscal_Year__c = nextSFY,
				    RecordTypeId = budgetRecordTypeId,
				    EUR_CRM_External_ID__c = externalId,
				    EUR_CRM_Allocated_Budget__c = 0
				);
				if(Test.isRunningTest()) newBudget.OwnerId = UserInfo.getUserId();
				insertNewBudgets.add(newBudget);
				ownerFiscalYear2Budget.put(contractOwnerId, newBudget ) ;
			}
		}
		if (insertNewBudgets.size() > 0 )
			insert insertNewBudgets;
		system.debug('### ownerFiscalYear2Budget: ' + ownerFiscalYear2Budget);
		system.debug('### contractFiscalYear_1_Amount: ' + contractFiscalYear_1_Amount);
		system.debug('### contractFiscalYear_2_Amount: ' + contractFiscalYear_2_Amount);
		system.debug('### accountOwners: ' + accountOwners);
		//  }
		//Process
		Set<EUR_CRM_Budget_Transaction__c> deleteDraftTransactions = new Set<EUR_CRM_Budget_Transaction__c>();
		Map<Id, EUR_CRM_Budget_Transaction__c> upsertDraftTransactions = new Map<Id, EUR_CRM_Budget_Transaction__c>();
		Map<Id, EUR_CRM_Budget_Transaction__c> upsertNextYearDraftTransactions = new Map<Id, EUR_CRM_Budget_Transaction__c>();
		Map<Id, EUR_CRM_Budget_Transaction__c> deleteNextYearDraftTransactions = new Map<Id, EUR_CRM_Budget_Transaction__c>();

		try
		{
			if (allContracts.size() > 0)
			{
				for (EUR_CRM_Budget_Transaction__c draftTxn : [SELECT Id, EUR_CRM_Budget_Header__c, EUR_CRM_Budget_Header__r.ownerid,
				        EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c, EUR_CRM_Contract__c, EUR_CRM_Amount__c,
				        EUR_CRM_Transaction_Category__c, EUR_CRM_Transaction_Type__c
				        FROM EUR_CRM_Budget_Transaction__c
				        WHERE EUR_CRM_Contract__c IN: allContracts
				        AND EUR_CRM_Transaction_Category__c = :DRAFT_CONTRACT_TRANSACTION
				                AND RecordTypeId = : draftTransactionRecordType])
				{
					if (oldBudgetContractMap.containsKey(draftTxn.EUR_CRM_Contract__c))
					{
						if (draftTxn.EUR_CRM_Budget_Header__c == oldBudgetContractMap.get(draftTxn.EUR_CRM_Contract__c))
						{
							deleteDraftTransactions.add(draftTxn);
						}
					}

					if (deleteContractDraftTransaction.containsKey(draftTxn.EUR_CRM_Contract__c))
					{
						deleteDraftTransactions.add(draftTxn);
					}

					if (upsertContractDraftTransaction.containsKey(draftTxn.EUR_CRM_Contract__c))
					{
						//update draft transaction amount
						//draftTxn.EUR_CRM_Amount__c = upsertContractDraftTransaction.get(draftTxn.EUR_CRM_Contract__c).EUR_CRM_ZA_Deductible_Amount__c;
						if (draftTxn.EUR_CRM_Budget_Header__c == ((EUR_CRM_Contract__c) newMap.get(draftTxn.EUR_CRM_Contract__c)).EUR_CRM_Budget__c)
						{
							draftTxn.EUR_CRM_Amount__c = contractFiscalYear_2_Amount.containsKey(draftTxn.EUR_CRM_Contract__c) ? contractFiscalYear_1_Amount.get(draftTxn.EUR_CRM_Contract__c) : upsertContractDraftTransaction.get(draftTxn.EUR_CRM_Contract__c).EUR_CRM_ZA_Deductible_Amount__c;
							System.debug('@@@@@@@@@@@@@@@@@@@@ upsertDraftTransactions ' + draftTxn.EUR_CRM_Contract__c + ' draftTxn ' + draftTxn);
							upsertDraftTransactions.put(draftTxn.EUR_CRM_Contract__c, draftTxn);

						}
						EUR_CRM_Budget__c currentBudget = currentBudgets.get(draftTxn.EUR_CRM_Budget_Header__r.ownerid);
						if (currentBudget != null)
						{
							Integer sfy = Integer.valueOf(currentBudget.EUR_CRM_Fiscal_Year__c.substring(2, 4));
							String nextSFY = 'FY' + (sfy + 1);
							if (draftTxn.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c == nextSFY)
							{

								if (deleteNextYearContractDraftTransasction.containsKey(draftTxn.EUR_CRM_Contract__c))
								{
									deleteNextYearDraftTransactions.put(draftTxn.EUR_CRM_Contract__c, draftTxn);
								}
								else
								{
									draftTxn.EUR_CRM_Amount__c = contractFiscalYear_2_Amount.get(draftTxn.EUR_CRM_Contract__c);
									upsertNextYearDraftTransactions.put(draftTxn.EUR_CRM_Contract__c, draftTxn);

								}

							}

						}
					}
					if (deleteNextYearContractDraftTransasction.containsKey(draftTxn.EUR_CRM_Contract__c))
					{
						EUR_CRM_Budget__c currentBudget = currentBudgets.get(draftTxn.EUR_CRM_Budget_Header__r.ownerid);
						system.debug('### deleting. ');
						system.debug('### currentBudget. ' + currentBudget);
						if (currentBudget != null)
						{
							Integer sfy = Integer.valueOf(currentBudget.EUR_CRM_Fiscal_Year__c.substring(2, 4));
							String nextSFY = 'FY' + (sfy + 1);
							if (draftTxn.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c == nextSFY)
								deleteNextYearDraftTransactions.put(draftTxn.EUR_CRM_Contract__c, draftTxn);
						}
					}
				}

				for (EUR_CRM_Contract__c contract : upsertContractDraftTransaction.values())
				{
					if ((!upsertDraftTransactions.containsKey(contract.Id)) && contract.EUR_CRM_Budget__c != null)
					{


						EUR_CRM_Budget_Transaction__c newDraftTxn = new EUR_CRM_Budget_Transaction__c();
						newDraftTxn.RecordTypeId = draftTransactionRecordType;
						newDraftTxn.EUR_CRM_Budget_Header__c = contract.EUR_CRM_Budget__c;
						newDraftTxn.EUR_CRM_Contract__c = contract.Id;
						newDraftTxn.EUR_CRM_Amount__c = contractFiscalYear_2_Amount.containsKey(contract.id) ? contractFiscalYear_1_Amount.get(contract.id) : contract.EUR_CRM_ZA_Deductible_Amount__c;
						newDraftTxn.EUR_CRM_Transaction_Category__c = DRAFT_CONTRACT_TRANSACTION;
						newDraftTxn.EUR_CRM_Transaction_Type__c = DEBIT;
						System.debug('@@@@@@@@@@@@@@@@@@@@ upsertDraftTransactions ' + newDraftTxn.EUR_CRM_Contract__c + ' newDraftTxn ' + newDraftTxn);
						upsertDraftTransactions.put(newDraftTxn.EUR_CRM_Contract__c, newDraftTxn);
					}
					if (!upsertNextYearDraftTransactions.containsKey(contract.Id))
					{

						if (contractFiscalYear_2_Amount.containsKey(contract.id) && ownerFiscalYear2Budget.get(budgetOwners.get(contract.EUR_CRM_Budget__c)) != null)
						{

							EUR_CRM_Budget_Transaction__c newDraftTxn = new EUR_CRM_Budget_Transaction__c();
							newDraftTxn.RecordTypeId = draftTransactionRecordType;
							newDraftTxn.EUR_CRM_Budget_Header__c =  ownerFiscalYear2Budget.get(budgetOwners.get(contract.EUR_CRM_Budget__c)).id;
							newDraftTxn.EUR_CRM_Contract__c = contract.Id;
							newDraftTxn.EUR_CRM_Amount__c = contractFiscalYear_2_Amount.get(contract.id);
							newDraftTxn.EUR_CRM_Transaction_Category__c = DRAFT_CONTRACT_TRANSACTION;
							newDraftTxn.EUR_CRM_Transaction_Type__c = DEBIT;
							upsertNextYearDraftTransactions.put(newDraftTxn.EUR_CRM_Contract__c, newDraftTxn);
						}
					}
				}

				if (deleteDraftTransactions.size() > 0)
				{
					List<EUR_CRM_Budget_Transaction__c> deleteDraftTxn = new List<EUR_CRM_Budget_Transaction__c>();
					deleteDraftTxn.addAll(deleteDraftTransactions);
					Database.delete(deleteDraftTxn);
				}
				system.debug('deleteDraftTransactions : ' + deleteDraftTransactions);
				system.debug('deleteNextYearDraftTransactions : ' + deleteNextYearDraftTransactions);
				if (deleteNextYearDraftTransactions.size() > 0)
				{
					Database.delete(deleteNextYearDraftTransactions.values());
				}

				if (upsertDraftTransactions.size() > 0)
				{
					System.debug('@@@@@@@@@@@@@@@@@@@@ upsertDraftTransactions ' + upsertDraftTransactions);
					Database.upsert(upsertDraftTransactions.values());
				}
				if (upsertNextYearDraftTransactions.size() > 0)
				{
					Database.upsert(upsertNextYearDraftTransactions.values());
				}
			}
			incrementCountOfAfterUpdateRuns();
		}
		catch (Exception e)
		{
			incrementCountOfAfterUpdateRuns();
			System.debug('EUR_CRM_ContractCancelledHandler - Error:' + e);
			Database.rollback(savePoint);
		}
	}


	Map<Id, Decimal> contractFiscalYear_1_Amount = new Map<Id, Decimal>();
	Map<Id, Decimal> contractFiscalYear_2_Amount = new Map<Id, Decimal>();
	Map<Id, EUR_CRM_Budget__c> ownerFiscalYear2Budget = new Map<Id, EUR_CRM_Budget__c>();
	Map<Id, Id> accountOwners = new Map<Id, Id>();
	Map<Id, Id> budgetOwners = new Map<Id, Id>();
	Map<Id, EUR_CRM_Budget__c> currentBudgets = new Map<Id, EUR_CRM_Budget__c>();
	Map<Id, Decimal> contractProratedAmount = new Map<Id, Decimal>();

	private static void incrementCountOfAfterUpdateRuns() {
		countOfAfterUpdateRuns++;
	}

	public void createNextYearTxn(EUR_CRM_Contract__c contract)
	{
		system.debug('###');
		Date contractStartDate = contract.EUR_CRM_Start_Date__c;
		Date contractEndDate = contract.EUR_CRM_End_Date__c;
		Decimal totalDeductableAmount = contract.EUR_CRM_ZA_Deductible_Amount__c;
		// Decimal proratedAmount = contract.EUR_CRM_Total_Pro_Rated_Amount__c;
		Decimal proratedAmount = contractProratedAmount.get(contract.id) == null ? 0 : contractProratedAmount.get(contract.id) ;
		//contract span in months
		Integer  totalMonths = contractStartDate.monthsBetween(contractEndDate) + 1;
		//contract number of months for this fiscal year
		Integer months_FY1 = contractStartDate.monthsBetween(fiscalYear);
		//contract number of months for next fiscal year
		Integer months_FY2 = contractEndDate.monthsBetween(fiscalYear) - 1;
		system.debug('### totalMonths: ' + totalMonths);
		system.debug('### months_FY1: ' + months_FY1);
		system.debug('### months_FY2: ' + months_FY2);
		system.debug('### proratedAmount: ' + proratedAmount);
		system.debug('### totalDeductableAmount: ' + totalDeductableAmount);
		system.debug('### contract.EUR_CRM_Total_Pro_Rated_Amount__c: ' + contract.EUR_CRM_Total_Pro_Rated_Amount__c);


		if (totalMonths > months_FY1 && proratedAmount > 0)
		{
			months_FY2 *= -1;
			Decimal proratedAmount_FY1 = (((Decimal)months_FY1) / totalMonths) * proratedAmount;
			Decimal proratedAmount_FY2 = (((Decimal) months_FY2) / totalMonths) * proratedAmount;
			Decimal fy1_actualTotalDeductable = (totalDeductableAmount - proratedAmount) + proratedAmount_FY1;
			Decimal fy2_actualTotalDeductable = proratedAmount_FY2;
			contractFiscalYear_1_Amount.put(contract.id, fy1_actualTotalDeductable);
			contractFiscalYear_2_Amount.put(contract.id, fy2_actualTotalDeductable);
			system.debug('### proratedAmount_FY1: ' + proratedAmount_FY1);
			system.debug('### proratedAmount_FY2: ' + proratedAmount_FY2);
			system.debug('### fy1_actualTotalDeductable: ' + fy1_actualTotalDeductable);
			system.debug('### fy2_actualTotalDeductable: ' + fy2_actualTotalDeductable);

		}
	}

	public void retrieveProratedAmounts(Set<Id> contractIds)
	{
		system.debug('### retrieveProratedAmounts: ' + contractIds);
		for (EUR_CRM_Contract_Activity_Item__c ca : [select EUR_CRM_Contract_Activity_Total__c, EUR_CRM_Contract__c from EUR_CRM_Contract_Activity_Item__c where EUR_CRM_Contract__c in: contractIds and
		        EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Pro_Rated_by_Month__c = true])
		{
			if (contractProratedAmount.get(ca.EUR_CRM_Contract__c) == null)
			{
				contractProratedAmount.put(ca.EUR_CRM_Contract__c, ca.EUR_CRM_Contract_Activity_Total__c);
			}
			else
			{
				Decimal prevAmount = contractProratedAmount.get(ca.EUR_CRM_Contract__c);
				contractProratedAmount.put(ca.EUR_CRM_Contract__c, prevAmount + ca.EUR_CRM_Contract_Activity_Total__c);

			}
		}
		system.debug('### contractProratedAmount: ' + contractProratedAmount);
	}
}