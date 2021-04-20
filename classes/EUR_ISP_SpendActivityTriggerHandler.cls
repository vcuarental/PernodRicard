/**
 * SpendActivity Trigger Handler class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendActivityTriggerHandler extends EUR_CRM_TriggerAbstract
{
	public EUR_ISP_SpendActivityTriggerHandler()
	{
		super('EUR_ISP_SpendActivityTriggerHandler');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		if (TriggerAction.AFTER_UPDATE == tAction)
		{
			this.processBudgetTransactionUpdate(sObjList, (Map<Id, EUR_ISP_Spend_Activity__c>) oldMap);
			this.processBudgetTransactionCreateOnUpdate(sObjList, (Map<Id, EUR_ISP_Spend_Activity__c>) oldMap);
			this.updateSpendApprovalStatusAfterUpdate(sObjList, (Map<Id, EUR_ISP_Spend_Activity__c>) oldMap);
			this.saveHistory(sObjList, oldMap);
		}
		if (TriggerAction.AFTER_INSERT == tAction)
		{
			this.processBudgetTransactionCreateOnCreate(sObjList);
			this.updateSpendApprovalStatusAfterCreate(sObjList);
			this.saveHistory(sObjList, oldMap);
		}
		if (TriggerAction.BEFORE_DELETE == tAction)
		{
			this.processBudgetTransactionCreateOnDelete(sObjList);
		}
		if (TriggerAction.AFTER_DELETE == tAction)
		{
			this.updateSpendApprovalStatusAfterUpdate(sObjList, null);
		}
	}

	private void saveHistory(List<sObject> newList, Map<Id, sObject> oldMap)
	{
		oldMap = oldMap == null ? new Map<Id,  sObject>() : oldMap;
		List<String> fieldsToTrack = EUR_ISP_VolumeChangeHistoryService.getFieldsToTrack(EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME);
		Set<sObject> modifiedObjects = EUR_ISP_Utils.getModifiedObjects(fieldsToTrack, newList, oldMap);
		EUR_ISP_VolumeChangeHistoryService.saveUpdatesToHistory(oldMap, new List<sObject>(modifiedObjects), EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME);
	}

	private void processBudgetTransactionCreateOnDelete(List<EUR_ISP_Spend_Activity__c> oldActivities)
	{
		List<EUR_ISP_Spend_Activity__c> activityIdsToProcess = new List<EUR_ISP_Spend_Activity__c>();
		for (EUR_ISP_Spend_Activity__c activity : oldActivities)
		{
			if (activity.EUR_ISP_Status__c != EUR_ISP_Utils.CANCELLED_STATUS)
			{
				activityIdsToProcess.add(activity);
			}
		}
		EUR_ISP_SpendTransactionsService.createTransactionsForCancelled(activityIdsToProcess);
	}
	/**
	 * adjsute Budget Transactions in case if Spend Activity Start or End dates updated
	 */
	private void processBudgetTransactionUpdate(List<EUR_ISP_Spend_Activity__c> activities, Map<Id, EUR_ISP_Spend_Activity__c> oldActivities)
	{
		List<EUR_ISP_Spend_Activity__c> activitiesForTransactionUpdate = new List<EUR_ISP_Spend_Activity__c>();
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			EUR_ISP_Spend_Activity__c oldActivity = oldActivities.get(activity.Id);
			// we have update action and start and end dates updated from the last save, so we need to adjust Transactions to correct Budget
			if (String.isNotBlank(activity.EUR_ISP_Status__c) && EUR_ISP_SpendTransactionsService.isAcceptableStatus(activity.EUR_ISP_Status__c) &&
			        String.isNotBlank(oldActivity.EUR_ISP_Status__c) && EUR_ISP_SpendTransactionsService.isAcceptableStatus(oldActivity.EUR_ISP_Status__c))
			{
				Date oldStartDate = EUR_ISP_SpendTransactionsService.getActivityStartDate(oldActivity);
				Date oldEndDate = EUR_ISP_SpendTransactionsService.getActivityEndDate(oldActivity);
				Date startDate = EUR_ISP_SpendTransactionsService.getActivityStartDate(activity);
				Date endDate = EUR_ISP_SpendTransactionsService.getActivityEndDate(activity);

				if (
				    // added start Date
				    (oldStartDate == null && startDate != null) ||
				    // removed start Date
				    (oldStartDate != null && startDate == null) ||
				    // updated start Date
				    (oldStartDate != null && startDate != null && oldStartDate != startDate) ||
				    // added end Date
				    (oldEndDate == null && endDate != null) ||
				    // updated end Date
				    (oldEndDate != null && endDate != null && oldEndDate != endDate) ||
				    // removed end Date
				    (oldEndDate != null && endDate == null))
				{
					activitiesForTransactionUpdate.add(activity);
				}
			}
		}
		EUR_ISP_SpendTransactionsService.updateTransactions(activitiesForTransactionUpdate);
	}

	private void processBudgetTransactionCreateOnUpdate(List<EUR_ISP_Spend_Activity__c> activities, Map<Id, EUR_ISP_Spend_Activity__c> oldActivities)
	{
		List<EUR_ISP_Spend_Activity__c> activitiesForTransactionCreate = new List<EUR_ISP_Spend_Activity__c>();
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			EUR_ISP_Spend_Activity__c oldActivity = oldActivities.get(activity.Id);
			if (String.isNotBlank(activity.EUR_ISP_Status__c) && EUR_ISP_SpendTransactionsService.isAcceptableStatus(activity.EUR_ISP_Status__c))
			{
				//System.debug('####: activity.EUR_ISP_Status__c ' + activity.EUR_ISP_Status__c);
				//System.debug('####: activity.EUR_ISP_Total_Activity_Amount__c ' + activity.EUR_ISP_Total_Activity_Amount__c);
				if (activity.EUR_ISP_Status__c != oldActivity.EUR_ISP_Status__c || activity.EUR_ISP_Total_Activity_Amount__c != oldActivity.EUR_ISP_Total_Activity_Amount__c)
				{
					//System.debug('####: activity.ID ' + activity.Id);
					activitiesForTransactionCreate.add(activity);
				}
			}
		}
		EUR_ISP_SpendTransactionsService.createTransactionsForUpdated(activitiesForTransactionCreate);
	}

	/**
	 * submit spend activities to budget transaction On Create OR
	 */
	private void processBudgetTransactionCreateOnCreate(List<EUR_ISP_Spend_Activity__c> activities)
	{
		List<EUR_ISP_Spend_Activity__c> activitiesForTransactionCreate = new List<EUR_ISP_Spend_Activity__c>();
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			if (String.isNotBlank(activity.EUR_ISP_Status__c) && EUR_ISP_SpendTransactionsService.isAcceptableStatus(activity.EUR_ISP_Status__c))
			{
				System.debug('####: activity.ID ' + activity.Id);
				activitiesForTransactionCreate.add(activity);
			}
		}
		EUR_ISP_SpendTransactionsService.createTransactions(activitiesForTransactionCreate);
	}

	/**
	 *  update EUR_ISP_Spend__c Approval Status Approved if it is Pending
	 *  DE country dont have approvel processes
	 */
	private void updateSpendApprovalStatusAfterUpdate(List<EUR_ISP_Spend_Activity__c> activities, Map<Id, EUR_ISP_Spend_Activity__c> oldActivities)
	{
		if (EUR_ISP_Utils.COUNTRY_CODE_DE == EUR_ISP_HomeController.getCurrentUserInfo().EUR_CRM_Country_Code__c)
		{
			return;
		}

		oldActivities = oldActivities == null ? new Map<Id, EUR_ISP_Spend_Activity__c>() : oldActivities;

		Set<Id> spendIds = new Set<Id>();
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			EUR_ISP_Spend_Activity__c oldActivity = oldActivities.get(activity.Id);
			Boolean isNotApproved = String.isNotBlank(activity.EUR_ISP_Approval_Status__c) &&
			                        String.isNotBlank(activity.EUR_ISP_Status__c) &&
			                        activity.EUR_ISP_Approval_Status__c != EUR_ISP_Utils.APPROVED_APPROVAL_STATUS;
			Boolean isCancelled = oldActivity != null &&
			                      activity.EUR_ISP_Status__c != oldActivity.EUR_ISP_Status__c &&
			                      activity.EUR_ISP_Status__c == EUR_ISP_Utils.CANCELLED_STATUS;
			Boolean isDeleted = oldActivity == null && activity.EUR_ISP_Status__c != EUR_ISP_Utils.CANCELLED_STATUS;

			if (isNotApproved && (isCancelled || isDeleted))
			{
				spendIds.add(activity.EUR_ISP_Spend__c);
			}
		}

		List<EUR_ISP_Spend__c> spendsToUpdate = new List<EUR_ISP_Spend__c>();
		List<EUR_ISP_Spend__c> spends = [SELECT Id, EUR_ISP_Approval_Status__c, (
		                                     SELECT Id
		                                     FROM Spend_Activities_EU__r
		                                     WHERE EUR_ISP_Approval_Status__c != : EUR_ISP_Utils.APPROVED_APPROVAL_STATUS AND EUR_ISP_Status__c != : EUR_ISP_Utils.CANCELLED_STATUS
		                                 )
		                                 FROM EUR_ISP_Spend__c
		                                 WHERE Id IN: spendIds AND
		                                 EUR_ISP_Approval_Status__c != : EUR_ISP_Utils.APPROVED_APPROVAL_STATUS];
		for (EUR_ISP_Spend__c spend : spends)
		{
			if (spend.Spend_Activities_EU__r.isEmpty())
			{
				spend.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS;
				spendsToUpdate.add(spend);
			}
		}
		update spendsToUpdate;
	}

	/**
	 *  update EUR_ISP_Spend__c Approval Status to Pending if it is Approved
	 *  DE country dont have approvel processes
	 */
	private void updateSpendApprovalStatusAfterCreate(List<EUR_ISP_Spend_Activity__c> activities)
	{
		if (EUR_ISP_Utils.COUNTRY_CODE_DE == EUR_ISP_HomeController.getCurrentUserInfo().EUR_CRM_Country_Code__c)
		{
			return;
		}

		Set<Id> spendIds = new Set<Id>();
		for (EUR_ISP_Spend_Activity__c activity : activities)
		{
			if (activity.EUR_ISP_Status__c != EUR_ISP_Utils.CANCELLED_STATUS &&
			        activity.EUR_ISP_Status__c != EUR_ISP_Utils.INVOICED_STATUS &&
			        activity.EUR_ISP_Approval_Status__c != EUR_ISP_Utils.APPROVED_APPROVAL_STATUS)
			{
				spendIds.add(activity.EUR_ISP_Spend__c);
			}
		}

		List<EUR_ISP_Spend__c> spends = [SELECT Id, EUR_ISP_Approval_Status__c
		                                 FROM EUR_ISP_Spend__c
		                                 WHERE Id IN: spendIds AND
		                                 EUR_ISP_Approval_Status__c = : EUR_ISP_Utils.APPROVED_APPROVAL_STATUS];
		for (EUR_ISP_Spend__c spend : spends)
		{
			spend.EUR_ISP_Approval_Status__c = EUR_ISP_Utils.PENDING_APPROVAL_STATUS;
		}
		update spends;
	}
}