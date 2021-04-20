/**
 * Spend Trigger Handler class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendTriggerHandler extends EUR_CRM_TriggerAbstract
{
    public EUR_ISP_SpendTriggerHandler()
    {
        super('EUR_ISP_SpendTriggerHandler');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
    {
        if (TriggerAction.AFTER_UPDATE == tAction)
        {
            List<EUR_ISP_Spend__c> spendsToProcess = this.getSpendsForApprovalProcess(sObjList, (Map<Id, EUR_ISP_Spend__c>) oldMap);
            this.doApprovalSynchronization(spendsToProcess);
            //this.transferTransactionIfOwnerChanged(sObjList, (Map<Id, EUR_ISP_Spend__c>) oldMap);
        }
        if (TriggerAction.BEFORE_UPDATE == tAction)
        {
            List<EUR_ISP_Spend__c> spendsToProcess = this.getSpendsForApprovalProcess(sObjList, (Map<Id, EUR_ISP_Spend__c>) oldMap);
            this.doCheckForOpenActivities(spendsToProcess);
        }
    }

    /**
     * TODO: territory split logic commented
     *
     * Transafer budget transactions the correct owner
     */
    //private void transferTransactionIfOwnerChanged(List<EUR_ISP_Spend__c> spends, Map<Id, EUR_ISP_Spend__c> oldSpends)
    //{
    //  Set<Id> spendIdsToProcess = new Set<Id>();
    //  for (EUR_ISP_Spend__c spend : spends)
    //  {
    //      EUR_ISP_Spend__c oldSpend = oldSpends.get(spend.Id);
    //      if (spend.OwnerId != oldSpend.OwnerId)
    //      {
    //          spendIdsToProcess.add(spend.Id);
    //      }
    //  }
    //  if (!spendIdsToProcess.isEmpty())
    //  {
    //      EUR_ISP_SpendTransactionsService.transferTransactionsToNewBudgets(spendIdsToProcess);
    //  }
    //}

    /**
     * get Spends after the Approval Update
     */
    private List<EUR_ISP_Spend__c> getSpendsForApprovalProcess(List<EUR_ISP_Spend__c> spends, Map<Id, EUR_ISP_Spend__c> oldSpends)
    {
        if (EUR_ISP_Utils.COUNTRY_CODE_DE == EUR_ISP_HomeController.getCurrentUserInfo().EUR_CRM_Country_Code__c)
        {
            return new List<EUR_ISP_Spend__c>();
        }

        oldSpends = oldSpends == null ? new Map<Id, EUR_ISP_Spend__c>() : oldSpends;
        List<EUR_ISP_Spend__c> spendsToProcess = new List<EUR_ISP_Spend__c>();

        for (EUR_ISP_Spend__c spend : spends)
        {
            EUR_ISP_Spend__c oldSpend = oldSpends.get(spend.Id);
            if (oldSpend != null && String.isNotBlank(spend.EUR_ISP_Approval_Status__c) && String.isNotBlank(oldSpend.EUR_ISP_Approval_Status__c))
            {
                //System.debug('#####: ' + oldSpend.EUR_ISP_Approval_Status__c + '=== ' + spend.EUR_ISP_Approval_Status__c);
                if (oldSpend.EUR_ISP_Approval_Status__c == EUR_ISP_Utils.AWAITING_APPROVAL_STATUS &&
                        oldSpend.EUR_ISP_Approval_Status__c != spend.EUR_ISP_Approval_Status__c &&
                        EUR_ISP_SpendApprovalService.APPROVAL_STATUSES_TO_PROCESS.contains(spend.EUR_ISP_Approval_Status__c))
                {
                    spendsToProcess.add(spend);
                }
            }
        }
        return spendsToProcess;
    }

    /**
     * check Approved Spends to Open activities
     */
    private void doCheckForOpenActivities(List<EUR_ISP_Spend__c> spends)
    {
        if (spends.isEmpty())
        {
            return;
        }
        List<EUR_ISP_Spend__c> spendsToApprove = new List<EUR_ISP_Spend__c>();
        for (EUR_ISP_Spend__c spend : spends)
        {
            if (spend.EUR_ISP_Approval_Status__c == EUR_ISP_Utils.APPROVED_APPROVAL_STATUS)
            {
                spendsToApprove.add(spend);
            }
        }
        EUR_ISP_SpendApprovalService.checkForOpenActivities(spendsToApprove);
    }

    /**
     * sync Spend Activities Approval Status with
     */
    private void doApprovalSynchronization(List<EUR_ISP_Spend__c> spends)
    {
        if (spends.isEmpty())
        {
            return;
        }

        EUR_ISP_SpendApprovalService.synchActivityApprovalStatus(spends);
    }
}