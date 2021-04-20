/**
 * Contract Budget Trigger Handler class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_ContractBudgetTriggerHandler extends EUR_CRM_TriggerAbstract
{
	public EUR_ISP_ContractBudgetTriggerHandler()
	{
		super('EUR_ISP_ContractBudgetTriggerHandler');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap)
	{
		try
		{
			if (TriggerAction.AFTER_UPDATE == tAction)
			{
				this.processDraftContracts(sObjList, (Map<Id, EUR_CRM_Contract__c>) oldMap);
				this.processClosedContracts(sObjList, (Map<Id, EUR_CRM_Contract__c>) oldMap);
				this.processApprovedContracts(sObjList, (Map<Id, EUR_CRM_Contract__c>) oldMap);
				EUR_ISP_ContractTransactionsServiceDE.commitTransactions();
			}
			if (TriggerAction.AFTER_INSERT == tAction)
			{
				this.processDraftContracts(sObjList, new Map<Id, EUR_CRM_Contract__c>());
				EUR_ISP_ContractTransactionsServiceDE.commitTransactions();
			}
		}
		catch (Exception e)
		{
			System.debug(LoggingLevel.ERROR, 'Details:\n' +  e.getMessage());
			EUR_ISP_LogService.addError(e.getMessage() + '\nDetails:\n' + e.getStackTraceString(), 'EUR_ISP_AccountEUTriggerHandler:transferTransactionIfOwnerChanged', null);
			EUR_ISP_LogService.commitErrors();
		}
	}

	private void processDraftContracts(List<EUR_CRM_Contract__c> contracts, Map<Id, EUR_CRM_Contract__c> oldContractsMap)
	{
		List<Id> draftContractIds = new List<Id>();
		for (EUR_CRM_Contract__c contract : contracts)
		{
			EUR_CRM_Contract__c oldContract = oldContractsMap.get(contract.Id);
			if (contract.RecordTypeId == EUR_ISP_ContractTransactionsServiceDE.DE_CONTRACT_RECORD_TYPE_ID &&
			        contract.EUR_CRM_Start_Date__c != null &&
			        contract.EUR_CRM_End_Date__c != null)
			{
				if (oldContract == null)
				{
					draftContractIds.add(contract.Id);
				}
				else if (oldContract != null && contract.EUR_CRM_Contract_Approved_Date__c == null &&
				         (contract.EUR_CRM_DE_Deductible_Contract_Total__c != oldContract.EUR_CRM_DE_Deductible_Contract_Total__c ||
				          contract.EUR_CRM_Start_Date__c != oldContract.EUR_CRM_Start_Date__c ||
				          contract.EUR_CRM_End_Date__c != oldContract.EUR_CRM_End_Date__c))
				{
					draftContractIds.add(contract.Id);
				}
			}
		}
		System.debug('### ISP\n draftContractIds.size():' + draftContractIds.size());
		EUR_ISP_ContractTransactionsServiceDE.createDraftTransactions(draftContractIds);
	}

	private void processApprovedContracts(List<EUR_CRM_Contract__c> contracts, Map<Id, EUR_CRM_Contract__c> oldContractsMap)
	{
		List<EUR_CRM_Contract__c> approvedContracts = new List<EUR_CRM_Contract__c>();
		for (EUR_CRM_Contract__c contract : contracts)
		{
			EUR_CRM_Contract__c oldContract = oldContractsMap.get(contract.Id);
			if (contract.RecordTypeId == EUR_ISP_ContractTransactionsServiceDE.DE_CONTRACT_RECORD_TYPE_ID &&
			        contract.EUR_CRM_Status__c != oldContract.EUR_CRM_Status__c &&
			        (contract.EUR_CRM_Status__c == EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_APPROVED ||
			         contract.EUR_CRM_Status__c == EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_ACTIVATED))
			{
				approvedContracts.add(contract);
			}
		}
		System.debug('### ISP\n approvedContracts.size():' + approvedContracts.size());
		EUR_ISP_ContractTransactionsServiceDE.createApprovedTransactions(approvedContracts);
	}

	private void processClosedContracts(List<EUR_CRM_Contract__c> contracts, Map<Id, EUR_CRM_Contract__c> oldContractsMap)
	{
		List<EUR_CRM_Contract__c> approvedContracts = new List<EUR_CRM_Contract__c>();
		List<EUR_CRM_Contract__c> abortedContracts = new List<EUR_CRM_Contract__c>();

		for (EUR_CRM_Contract__c contract : contracts)
		{
			EUR_CRM_Contract__c oldContract = oldContractsMap.get(contract.Id);
			if (contract.RecordTypeId == EUR_ISP_ContractTransactionsServiceDE.DE_CONTRACT_RECORD_TYPE_ID &&
			        contract.EUR_CRM_Status__c != oldContract.EUR_CRM_Status__c &&
					contract.EUR_CRM_Status__c == EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_CANCELLED)
			{
				abortedContracts.add(contract);
				if (oldContract.EUR_CRM_Status__c == EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_APPROVED ||
					oldContract.EUR_CRM_Status__c == EUR_ISP_ContractTransactionsServiceDE.CONTRACT_STATUS_ACTIVATED)
				{
					approvedContracts.add(contract);
				}
			}
		}
		System.debug('### ISP\n approvedContracts.size():' + approvedContracts.size());
		EUR_ISP_ContractTransactionsServiceDE.closeTransactionsAfterApprove(approvedContracts);
		System.debug('### ISP\n abortedContracts.size():' + abortedContracts.size());
		EUR_ISP_ContractTransactionsServiceDE.closeTransactions(abortedContracts);
	}
}