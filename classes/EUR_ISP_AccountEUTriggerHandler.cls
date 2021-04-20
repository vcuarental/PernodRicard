/**
 * AccountEU Trigger Handler class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_AccountEUTriggerHandler extends EUR_CRM_TriggerAbstract
{
	public EUR_ISP_AccountEUTriggerHandler()
	{
		super('EUR_ISP_AccountEUTriggerHandler');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		try
		{
			if (TriggerAction.AFTER_UPDATE == tAction)
			{
				this.transferTransactionIfOwnerChanged(sObjList, (Map<Id, EUR_CRM_Account__c>) oldMap);
			}
		}
		catch (Exception e)
		{
			System.debug(LoggingLevel.ERROR, 'Details:\n' +  e.getMessage());
			EUR_ISP_LogService.addError(e.getMessage() + '\nDetails:\n' + e.getStackTraceString(), 'EUR_ISP_AccountEUTriggerHandler:transferTransactionIfOwnerChanged', null);
			EUR_ISP_LogService.commitErrors();
		}
	}

	/**
	 * Transafer budget transactions the correct owner
	 */
	private void transferTransactionIfOwnerChanged(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccounts)
	{
		List<Id> accountsToProcess = new List<Id>();
		for (EUR_CRM_Account__c account : accounts)
		{
			EUR_CRM_Account__c oldAccount = oldAccounts.get(account.Id);
			if (account.OwnerId != oldAccount.OwnerId)
			{
				accountsToProcess.add(account.Id);
			}
		}
		if (!accountsToProcess.isEmpty())
		{
			EUR_ISP_AccountEUTriggerHandler.filterContractsForOwnerUpdate(accountsToProcess);
		}
	}

	public static void filterContractsForOwnerUpdate(List<Id> accountsToProcess)
	{
		List<EUR_CRM_Contract__c> contracts = [SELECT Id, EUR_CRM_Start_Date__c, EUR_CRM_Status__c, EUR_CRM_Contract_Approved_Date__c,
		                                       EUR_CRM_Account__c, EUR_CRM_Account__r.OwnerId,
		                                       EUR_CRM_Budget__c, EUR_CRM_Budget__r.OwnerId
		                                       FROM EUR_CRM_Contract__c
		                                       WHERE EUR_CRM_Account__c IN: accountsToProcess AND RecordTypeId = : EUR_ISP_ContractTransactionsServiceDE.DE_CONTRACT_RECORD_TYPE_ID
		                                               AND EUR_CRM_Start_Date__c != null
		                                               AND EUR_CRM_End_Date__c != null];
		if (!contracts.isEmpty())
		{
			List<EUR_CRM_Contract__c> activatedContracts = new List<EUR_CRM_Contract__c>();
			for (EUR_CRM_Contract__c theContract : contracts)
			{
				if (theContract.EUR_CRM_Status__c == EUR_ISP_ContractPushService.CONTRACT_STATUS_ACTIVATED)
				{
					activatedContracts.add(theContract);
				}
			}
			// TODO: territory split logic commented
			//EUR_ISP_ContractTransactionsServiceDE.transferTransactionsToNewBudgets(contracts);
			EUR_ISP_ContractPushService.createUserToAccountRelations(activatedContracts);
			//this.updateSpendsOwner(activatedContracts);
		}
	}

	// TODO: territory split logic commented
	//private void updateSpendsOwner(List<EUR_CRM_Contract__c> activatedContracts)
	//{
	//	Map<Id, EUR_CRM_Contract__c> contractIdToContract = new Map<Id, EUR_CRM_Contract__c>(activatedContracts);
	//	List<EUR_ISP_Spend__c> spends = [SELECT Id, OwnerId, EUR_ISP_Contract__c FROM EUR_ISP_Spend__c WHERE EUR_ISP_Contract__c IN : activatedContracts];
	//	for (EUR_ISP_Spend__c spend : spends)
	//	{
	//		Id contractId = spend.EUR_ISP_Contract__c;

	//		if (spend.EUR_ISP_Contract__c != null
	//		        && contractIdToContract.containsKey(contractId)
	//		        && contractIdToContract.get(contractId).EUR_CRM_Account__c != null)
	//		{
	//			spend.OwnerId = contractIdToContract.get(contractId).EUR_CRM_Account__r.OwnerId;
	//		}
	//	}
	//	update spends;
	//}
}