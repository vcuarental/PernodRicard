/*********************************************************************************
 * Name: EUR_CRM_ContractBudgetLinkHandler
 * Description: Originally for DE, modified to cater additional country codes for South Africa (ZA) and other future countries
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/14/2015        Conrad                  Added Comment Header
 *
*********************************************************************************/
public with sharing class EUR_CRM_ContractBudgetLinkHandler extends EUR_CRM_TriggerAbstract
{
	private static String countryCodeGermany = 'DE'; // Only cater DE country code
	//New variable to cater multiple country codes
	private final Set<String> validContractCountryCodes = new Set<String>
	{
		//'de',
		'za'
	};

	private String currentFiscalYearStr {get; set;}
	private EUR_CRM_DE_Contract_Class contractHelperObj;
	@TestVisible private Organization fiscalYearOrgDetails;

	private static Integer countOfAfterUpdateRuns = 0;
	public EUR_CRM_ContractBudgetLinkHandler()
	{
		super('EUR_CRM_DE_ContractBudgetLinkHandler');

		System.debug('Flag - EUR_CRM_ContractBudgetLinkHandler');
		// Helper Class, needs revision
		contractHelperObj = new EUR_CRM_DE_Contract_Class();
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		if (countOfAfterUpdateRuns == 1) { return; }

		Set<Id>contractIdSet = new Set<Id>();
		Set<Id> ownerIdSet = new Set<Id>();
		Map<Id, String> contractFiscalYearMap = new Map<Id, String>();

		fiscalYearOrgDetails = EUR_CRM_BudgetUtil.retrieveFiscalYearOrg();

		//Get Fiscal Year Start Month

		//Iterate sObject, find countrycode == DE
		for (EUR_CRM_Contract__c contract : (List<EUR_CRM_Contract__c>)sObjList)
		{
			Boolean toProcess = false;
			System.debug('Flag - Trigger Action:' + tAction);
			//if ((tAction == TriggerAction.AFTER_INSERT) && contract.EUR_CRM_Country_Code__c.equalsIgnoreCase(countryCodeGermany)){ old if
			boolean isCountryIncluded = contract.EUR_CRM_Country_Code__c == null ? false : (validContractCountryCodes.contains(contract.EUR_CRM_Country_Code__c.toLowerCase()));
			if ((tAction == TriggerAction.AFTER_INSERT) && isCountryIncluded)  // new if
			{
				toProcess = true;
				//}else if ((tAction == TriggerAction.AFTER_UPDATE) && contract.EUR_CRM_Country_Code__c.equalsIgnoreCase(countryCodeGermany)){ old if
			}
			else if ((tAction == TriggerAction.AFTER_UPDATE) && isCountryIncluded)
			{
				EUR_CRM_Contract__c oldContract = (EUR_CRM_Contract__c)oldMap.get(contract.Id);
				if (contract.EUR_CRM_Start_Date__c != oldContract.EUR_CRM_Start_Date__c)
				{
					toProcess = true;
					incrementCountOfAfterUpdateRuns();
				}
			}

			if (toProcess)
			{
				contractIdSet.add(contract.Id);
				contractFiscalYearMap.put(contract.Id, determineFiscalYear(contract.EUR_CRM_Start_Date__c));
				//if(contract.EUR_CRM_Budget__c == null){
				//ownerIdSet.add(contract.OwnerId);
				//}
			}
		}

		System.debug('Flag - Contract FY Map:' + contractFiscalYearMap);
		if (contractIdSet.size() > 0)
		{
			currentFiscalYearStr = contractHelperObj.formatFiscalYear(EUR_CRM_BudgetUtil.retrieveFiscalYearStart()); //Budget Util helper class, needs revision for comments

			Set<EUR_CRM_Contract__c> contractsForUpdate = new Set<EUR_CRM_Contract__c>();
			List<EUR_CRM_Contract__c> updatedContract = new List<EUR_CRM_Contract__c>();
			Map<Id, Map<String, EUR_CRM_Budget__c>> budgetMap = new Map<Id, Map<String, EUR_CRM_Budget__c>>();//Key: Owner Id. 2nd Key: Budget FY

			for (EUR_CRM_Contract__c contract : [SELECT Id, CreatedById, EUR_CRM_Start_Date__c,
			                                     EUR_CRM_Budget__c, EUR_CRM_Country_Code__c
			                                     From EUR_CRM_Contract__c WHERE Id IN:contractIdSet])
			{
				ownerIdSet.add(contract.CreatedById);
				contractsForUpdate.add(contract);
			}

			//Find Budget - check if exist
			for (EUR_CRM_Budget__c budget : [SELECT Id, Name, OwnerId, EUR_CRM_Fiscal_Year__c FROM EUR_CRM_Budget__c
			                                 WHERE OwnerId IN: ownerIdSet
			                                 AND EUR_CRM_Fiscal_Year__c IN:contractFiscalYearMap.values()
			                                 LIMIT 49999])
			{
				Map<String, EUR_CRM_Budget__c> budgetFYMap = (budgetMap.containsKey(budget.OwnerId)) ? budgetMap.get(budget.OwnerId) : new Map<String, EUR_CRM_Budget__c>();
				budgetFYMap.put(budget.EUR_CRM_Fiscal_Year__c, budget);
				budgetMap.put(budget.OwnerId, budgetFYMap);
			}
			System.debug('Flag - Budget Map:' + budgetMap);

			List <EUR_CRM_Budget__c> newBudgetList = new List<EUR_CRM_Budget__c>();

			for (EUR_CRM_Contract__c uContract : contractsForUpdate)
			{
				boolean isCountryIncluded = uContract.EUR_CRM_Country_Code__c == null ? false : (validContractCountryCodes.contains(uContract.EUR_CRM_Country_Code__c.toLowerCase()));
				/*if (String.valueOf(uContract.EUR_CRM_Country_Code__c).equalsIgnoreCase(countryCodeGermany) &&
				    budgetMap.containsKey(uContract.CreatedById)){ */ //Old if
				if (isCountryIncluded && budgetMap.containsKey(uContract.CreatedById))   //New if
				{
					String contractFY = contractFiscalYearMap.get(uContract.Id);
					if (budgetMap.get(uContract.CreatedById).containsKey(contractFY))
					{
						uContract.EUR_CRM_Budget__c = budgetMap.get(uContract.CreatedById).get(contractFY).Id;
						updatedContract.add(uContract);
					}
					else
					{
						//TODO Create Budget
						uContract.EUR_CRM_Budget__c = null;
						updatedContract.add(uContract);
					}
				}
				else
				{
					//TODO Create Budget
					uContract.EUR_CRM_Budget__c = null;
					updatedContract.add(uContract);
				}
			}

			if (updatedContract.size() > 0)
			{
				System.debug('Flag - Contract for Update:' + updatedContract);
				update(updatedContract);
			}
		}
	}

	private static void incrementCountOfAfterUpdateRuns() {
		countOfAfterUpdateRuns++;
	}

	@TestVisible
	private String determineFiscalYear(Date contractStartDate)
	{
		if (contractStartDate != null)
		{
			Integer contractYear = contractStartDate.year();
			Integer contractMonth = contractStartDate.month();

			if (contractMonth >= fiscalYearOrgDetails.FiscalYearStartMonth)
			{
				return 'FY' + String.valueOf(contractYear + 1).substring(2);
			}
			else
			{
				return 'FY' + String.valueOf(contractYear).substring(2);
			}
		}
		return null;
	}

}