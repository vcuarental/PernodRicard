/**
 * Contract Push Batch job class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public class EUR_ISP_ContractPushBatch implements Database.Batchable<sObject>
{
	public List<String> contractIdsToConvert {get; set;}
	public Boolean runAll {get; set;}

	public EUR_ISP_ContractPushBatch()
	{
		this.runAll = false;
		this.contractIdsToConvert = new List<String>();
	}

	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		String activatedStatus = EUR_ISP_ContractPushService.CONTRACT_STATUS_ACTIVATED;
		String contractId = EUR_ISP_Utils.getRecordTypesMap().get(EUR_ISP_Utils.EUR_CRM_CONTRACT_API_NAME + EUR_ISP_Utils.DE_CONTRACT_RT_NAME);
		String queryString = 'SELECT Id ' +
		                     'FROM EUR_CRM_Contract__c ' +
		                     'WHERE RecordTypeId = :contractId AND EUR_CRM_Status__c = : activatedStatus ';
		if (!this.runAll && !this.contractIdsToConvert.isEmpty())
		{
			queryString += ' AND Id IN: contractIdsToConvert';
		}
		return Database.getQueryLocator(queryString);
	}

	public void execute(Database.BatchableContext bc, List<sObject> scope)
	{
		Set<Id> contractsToPush = new Map<Id, sObject>(scope).keySet();
		try
		{
			EUR_ISP_ContractPushService.pushContractData(contractsToPush);
		}
		catch (Exception e)
		{
			EUR_ISP_LogService.addError(e.getMessage() + '\nDetails:\n' + e.getStackTraceString(), 'EUR_ISP_ContractPushBatch:execute', null);
			EUR_ISP_LogService.commitErrors();
		}
	}

	public void finish(Database.BatchableContext bc) {}

	public static void startBatch(List<String> contractIdsToConvert)
	{
		EUR_ISP_ContractPushBatch theBatchJob = new EUR_ISP_ContractPushBatch();
		theBatchJob.contractIdsToConvert = contractIdsToConvert;
		System.scheduleBatch(theBatchJob, 'Contract Push job', 1, 50);
	}

	public static void startBatch()
	{
		EUR_ISP_ContractPushBatch theBatchJob = new EUR_ISP_ContractPushBatch();
		theBatchJob.runAll = true;
		System.scheduleBatch(new EUR_ISP_ContractPushBatch(), 'Contract Push job', 1, 50);
	}
}