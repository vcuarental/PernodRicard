/*********************************************************************************
 * Name: EUR_CRM_ContractCancelledHandler
 * Description: Originally for DE, modified to cater additional country codes for South Africa (ZA) and other future countries
 * Init: 12/22 - Contract cancelled, create credit transaction to put back the debited amount on user's budget
 * Edit 01/09/15: Changed Draft Transaction to Budget Transaction (record type: EUR_DE_On_Trade_WKZ_Draft_Transaction) object
 * Edit 05/13/15:  create only refund for approved contract.
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/14/2015        Conrad                  Added Comment Header
 * 9/22/2015        Conrad                  Map country code according to On Trade WKZ Recordtype
 *
*********************************************************************************/
public with sharing class EUR_CRM_ContractCancelledHandler extends EUR_CRM_TriggerAbstract
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

	private final String CANCELLED = 'Cancelled';
	private final String APPROVED = 'Approved';
	private final String CREDIT = 'Credit';
	private final String CONTRACT_REFUND = 'Contract Refund';
	private String DRAFT_CONTRACT_TRANSACTION = 'Draft Contract Transaction';

	private String currentFiscalYearStr {get; set;}
	private EUR_CRM_DE_Contract_Class contractHelperObj;
	private Organization fiscalYearOrgDetails;


	public EUR_CRM_ContractCancelledHandler()
	{
		super('EUR_CRM_ContractCancelledHandler');

		System.debug('Flag - EUR_CRM_ContractCancelledHandler');
		contractHelperObj = new EUR_CRM_DE_Contract_Class();
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		System.Savepoint savePoint = Database.setSavepoint();
		List<EUR_CRM_Contract__c> contractList = new List<EUR_CRM_Contract__c>();
		List<EUR_CRM_Contract__c> approvedContractList = new List<EUR_CRM_Contract__c>();
		//Iterate sObject, find countrycode == DE
		for (EUR_CRM_Contract__c contract : (List<EUR_CRM_Contract__c>)sObjList)
		{
			boolean isCountryIncluded = contract.EUR_CRM_Country_Code__c == null ? false : (validContractCountryCodes.keySet().contains(contract.EUR_CRM_Country_Code__c.toLowerCase()));
			//if ((tAction == TriggerAction.AFTER_UPDATE) && contract.EUR_CRM_Country_Code__c.equalsIgnoreCase(countryCodeGermany)){ old if
			if ((tAction == TriggerAction.AFTER_UPDATE) && isCountryIncluded)  //new if
			{
				EUR_CRM_Contract__c oldContract = (EUR_CRM_Contract__c)oldMap.get(contract.Id);
				if (contract.EUR_CRM_Status__c != oldContract.EUR_CRM_Status__c && contract.EUR_CRM_Status__c == CANCELLED
				   )
				{
					contractList.add(contract);
					if (oldContract.EUR_CRM_Status__c == APPROVED)
						approvedContractList.add(contract);
				}
			}
		}
		System.debug('@@@@@@@@@@@@@@@@@@@@ contractList ' + contractList);
		try
		{
			if (approvedContractList.size() > 0)
			{
				List<EUR_CRM_Budget_Transaction__c> newTransactionList = new List<EUR_CRM_Budget_Transaction__c>();

				for (EUR_CRM_Budget_Transaction__c txn : [SELECT Id, EUR_CRM_Budget_Header__c,
				        EUR_CRM_Amount__c, EUR_CRM_Contract__c,
				        EUR_CRM_Description__c, EUR_CRM_Ind__c,
				        EUR_CRM_Transaction_Category__c, EUR_CRM_Transaction_Type__c,
				        EUR_CRM_Transfer_From__c, EUR_CRM_Transfer_From_Budget_Header__c,
				        EUR_CRM_Transfer_To__c
				        FROM EUR_CRM_Budget_Transaction__c
				        WHERE EUR_CRM_Contract__c IN: approvedContractList])
				{
					System.debug('@@@@@@@@@@@@@@@@@@@@ txn ' + txn);
					EUR_CRM_Budget_Transaction__c newTransaction = txn.clone(false, false, false, false);
					newTransaction.EUR_CRM_Transaction_Type__c = CREDIT;
					newTransaction.EUR_CRM_Transaction_Category__c = CONTRACT_REFUND;
					newTransactionList.add(newTransaction);
				}

				if (newTransactionList.size() > 0)
				{
					Database.insert(newTransactionList);
				}
			}
			if (contractList.size() > 0)
			{
				//Delete Draft Transactions
				deleteDraftTransactions(contractList);
			}
		}
		catch (Exception e)
		{
			System.debug('EUR_CRM_ContractCancelledHandler - Error:' + e);
			Database.rollback(savePoint);
		}
	}

	private void deleteDraftTransactions(List<EUR_CRM_Contract__c> contractList)
	{
		Id draftTransactionRecordType = null;
		if (contractList.size() > 0)
		{
			String recordtypeDeveloperName = contractList.get(0).EUR_CRM_Country_Code__c == null ? '' : validContractCountryCodes.get(contractList.get(0).EUR_CRM_Country_Code__c.toLowerCase());
			draftTransactionRecordType = Global_RecordTypeCache.getRtId('EUR_CRM_Budget_Transaction__c' + recordtypeDeveloperName);
		}
		List<EUR_CRM_Budget_Transaction__c> deleteDraftTxn = new List<EUR_CRM_Budget_Transaction__c>();

		System.debug('@@@@@@@@@@@@@@@@@@@@ draftTransactionRecordType ' + draftTransactionRecordType);

		for (EUR_CRM_Budget_Transaction__c draftTxn : [SELECT Id, RecordTypeId  FROM EUR_CRM_Budget_Transaction__c
		        WHERE EUR_CRM_Contract__c IN: contractList
		        AND EUR_CRM_Transaction_Category__c = :DRAFT_CONTRACT_TRANSACTION
		                AND RecordTypeId = : draftTransactionRecordType])
		{
			System.debug('@@@@@@@@@@@@@@@@@@@@ draftTxn ' + draftTxn);
			deleteDraftTxn.add(draftTxn);
		}

		if (deleteDraftTxn.size() > 0)
		{
			Database.delete(deleteDraftTxn);
		}
	}
}