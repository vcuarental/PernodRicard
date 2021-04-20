/**
 * iSPend APP: Approval Service for the Spend object
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendApprovalService
{
	public static final Map<String, Set<String>> STATUS_MAPPING = new Map<String, Set<String>>
	{
		EUR_ISP_Utils.APPROVED_APPROVAL_STATUS => new Set<String> {EUR_ISP_Utils.APPROVED_APPROVAL_STATUS},
		EUR_ISP_Utils.REJECTED_APPROVAL_STATUS => new Set<String> {EUR_ISP_Utils.APPROVED_APPROVAL_STATUS, EUR_ISP_Utils.REJECTED_APPROVAL_STATUS},
		EUR_ISP_Utils.PENDING_APPROVAL_STATUS => new Set<String> {EUR_ISP_Utils.APPROVED_APPROVAL_STATUS, EUR_ISP_Utils.PENDING_APPROVAL_STATUS},
		EUR_ISP_Utils.AWAITING_APPROVAL_STATUS => new Set<String> {EUR_ISP_Utils.AWAITING_APPROVAL_STATUS, EUR_ISP_Utils.APPROVED_APPROVAL_STATUS}
	};
	public static final Set<String> APPROVAL_STATUSES_TO_PROCESS = STATUS_MAPPING.keySet();
	public static final Set<String> OPEN_STATUSES = new Set<String>
	{
		EUR_ISP_Utils.NEW_STATUS,
		EUR_ISP_Utils.RINGFENCE_STATUS,
		EUR_ISP_Utils.PLANNED_STATUS
	};


	public static ApprovalUpdateResult submitSpendForApproval(String spendId)
	{
		ApprovalUpdateResult outputResult = new ApprovalUpdateResult();
		Savepoint sp = Database.setSavepoint();

		// update activities with "Awaiting Approval" status before the Approval Request runs
		List<EUR_ISP_Spend_Activity__c> activitiesToUpdate = EUR_ISP_SpendApprovalService.getSpendActivitiesForApprovalStatusUpdate(spendId, STATUS_MAPPING.get(EUR_ISP_Utils.AWAITING_APPROVAL_STATUS));
		if (!activitiesToUpdate.isEmpty())
		{
			for (EUR_ISP_Spend_Activity__c theActivity : activitiesToUpdate)
			{
				theActivity.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.AWAITING_APPROVAL_STATUS;
			}
			update activitiesToUpdate;
		}

		Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
		submitRequest.setComments('Submitting Spend for approval.');
		submitRequest.setObjectId(spendId);
		Approval.ProcessResult result = Approval.process(submitRequest);

		if (!result.isSuccess())
		{
			Database.rollback(sp);
			return outputResult;
		}

		outputResult.Spend = EUR_ISP_SpendController.getISpend(spendId);
		outputResult.isLocked = EUR_ISP_SpendApprovalService.isRecordLocked(spendId);

		// in case of Auto Approve - we need to update these records with status "Apporved"
		if (!outputResult.isLocked && !activitiesToUpdate.isEmpty())
		{
			for (EUR_ISP_Spend_Activity__c theActivity : activitiesToUpdate)
			{
				theActivity.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS;
			}
			update activitiesToUpdate;
		}
		return outputResult;
	}

	/**
	 * update activities Approval Status based on the Spend Approval Status
	 */
	public static void synchActivityApprovalStatus(List<EUR_ISP_Spend__c> spends)
	{
		// need to check spends with Approval Status PENDING (the status can be changed after checkForOpenActivities)
		Map<Id, List<EUR_ISP_Spend_Activity__c>> spendIdToActivities = EUR_ISP_SpendApprovalService.getSpendActivitiesForApprovalStatusUpdate(spends);
		Map<Id, String> recentApprovalStatusForPendingSpends = EUR_ISP_SpendApprovalService.getRecentProcessInstanceStatus(spends);
		List<EUR_ISP_Spend_Activity__c> activitiesToUpdate = new List<EUR_ISP_Spend_Activity__c>();

		for (EUR_ISP_Spend__c spend : spends)
		{
			List<EUR_ISP_Spend_Activity__c> activities = spendIdToActivities.get(spend.Id);
			activities = activities != null ? activities : new List<EUR_ISP_Spend_Activity__c>();

			String approvaStatus = spend.EUR_ISP_Approval_Status__c;
			// PENDING Approval Status, but Request was Approved
			if (recentApprovalStatusForPendingSpends.containsKey(spend.Id) && recentApprovalStatusForPendingSpends.get(spend.Id) == EUR_ISP_Utils.APPROVED_APPROVAL_STATUS)
			{
				approvaStatus = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS;
			}

			Set<String> exceptionalStatuses = STATUS_MAPPING.get(approvaStatus);
			for (EUR_ISP_Spend_Activity__c activity : activities)
			{
				if (String.isNotBlank(activity.EUR_ISP_Approval_Status__c) && !exceptionalStatuses.contains(activity.EUR_ISP_Approval_Status__c))
				{
					activity.EUR_ISP_Approval_Status__c = approvaStatus;
					activitiesToUpdate.add(activity);
				}
			}
		}
		update activitiesToUpdate;
	}

	/**
	 * returns the SpendID to ProcessInstance Status
	 * needs to verify that Pending Status for the Approval Recall action
	 */
	public static Map<Id, String> getRecentProcessInstanceStatus(List<EUR_ISP_Spend__c> spends)
	{
		List<Id> pendingSpends = new List<Id>();
		for (EUR_ISP_Spend__c spend : spends)
		{
			if (spend.EUR_ISP_Approval_Status__c == EUR_ISP_Utils.PENDING_APPROVAL_STATUS)
			{
				pendingSpends.add(spend.Id);
			}
		}

		Map<Id, String> outputResults = new Map<Id, String>();
		for (EUR_ISP_Spend__c spend : [SELECT Id, (SELECT Status
		                               FROM ProcessInstances
		                               ORDER BY CompletedDate DESC
		                               LIMIT 1)
		                               FROM EUR_ISP_Spend__c
		                               WHERE Id IN :pendingSpends])
		{
			if (!spend.ProcessInstances.isEmpty())
			{
				outputResults.put(spend.Id, spend.ProcessInstances.get(0).Status);
			}
		}
		return outputResults;
	}

	/**
	 * change Approval Status from Approved to Pending when Spend has open activities
	 */
	public static void checkForOpenActivities(List<EUR_ISP_Spend__c> spends)
	{
		Set<Id> spendsWithOpenActivities = getSpendIdsWithOpenActivities(spends);
		for (EUR_ISP_Spend__c spend : spends)
		{
			if (spendsWithOpenActivities.contains(spend.Id))
			{
				spend.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
			}
		}
	}

	public static Set<Id> getSpendIdsWithOpenActivities(List<EUR_ISP_Spend__c> spends)
	{
		Set<Id> outputIDs = new Set<Id>();
		for (AggregateResult result : [SELECT EUR_ISP_Spend__c spendId
		                               FROM EUR_ISP_Spend_Activity__c
		                               WHERE EUR_ISP_Spend__c IN :spends AND EUR_ISP_Status__c IN : OPEN_STATUSES
		                               GROUP BY EUR_ISP_Spend__c])
		{
			outputIDs.add((Id)result.get('spendId'));
		}
		return outputIDs;
	}

	public static Map<Id, List<EUR_ISP_Spend_Activity__c>> getSpendActivitiesForApprovalStatusUpdate(List<EUR_ISP_Spend__c> spends)
	{
		// approved records will be skipped always
		Set<String> exceptionalStatuses = STATUS_MAPPING.get(EUR_ISP_Utils.APPROVED_APPROVAL_STATUS);
		Map<Id, List<EUR_ISP_Spend_Activity__c>> spendIdToActivities = new Map<Id, List<EUR_ISP_Spend_Activity__c>>();
		for (EUR_ISP_Spend_Activity__c activity : [SELECT Id, EUR_ISP_Approval_Status__c, EUR_ISP_Spend__c
		        FROM EUR_ISP_Spend_Activity__c
		        WHERE EUR_ISP_Spend__c IN :spends
		        AND EUR_ISP_Status__c = :EUR_ISP_Utils.COMMITTED_STATUS
		                                AND EUR_ISP_Approval_Status__c NOT IN: exceptionalStatuses])
		{
			if (!spendIdToActivities.containsKey(activity.EUR_ISP_Spend__c))
			{
				spendIdToActivities.put(activity.EUR_ISP_Spend__c, new List<EUR_ISP_Spend_Activity__c>());
			}
			spendIdToActivities.get(activity.EUR_ISP_Spend__c).add(activity);
		}
		return spendIdToActivities;
	}

	public static List<EUR_ISP_Spend_Activity__c> getSpendActivitiesForApprovalStatusUpdate(String spendId, Set<String> exceptionalStatuses)
	{
		return [SELECT Id, EUR_ISP_Approval_Status__c
		        FROM EUR_ISP_Spend_Activity__c
		        WHERE EUR_ISP_Spend__c = :spendId AND EUR_ISP_Status__c = :EUR_ISP_Utils.COMMITTED_STATUS AND EUR_ISP_Approval_Status__c NOT IN: exceptionalStatuses];
	}

	public static Boolean isRecordLocked(String spendId)
	{
		//	return Approval.isLocked(Id.valueOf(spendId));
		return [SELECT count() FROM ProcessInstance WHERE TargetObjectId = : spendId AND Status = :EUR_ISP_Utils.PENDING_APPROVAL_STATUS] > 0;
	}

	public class ApprovalUpdateResult
	{
		@AuraEnabled
		public EUR_ISP_Spend__c Spend {get; set;}
		@AuraEnabled
		public Boolean isLocked {get; set;}

		public ApprovalUpdateResult()
		{
			this.isLocked = false;
		}
	}
}