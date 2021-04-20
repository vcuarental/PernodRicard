/**
 * Created by osman on 27.01.2021.
 */

public with sharing class EUR_TR_IncentiveTriggerHandler {

    static Set<Id> recordsAlreadyProcessed = new Set<Id>();

    public static void handleAfterInsert(Map<Id, EUR_TR_Incentive__c> newIncentiveMap) {

        Set<Id> accountIds = new Set<Id>();
        for (EUR_TR_Incentive__c newIncentive : newIncentiveMap.values()) {
            if (newIncentive.EUR_TR_RelatedAccount__c != null) {
                if (!recordsAlreadyProcessed.contains(newIncentive.EUR_TR_RelatedAccount__c)) {
                    recordsAlreadyProcessed.add(newIncentive.EUR_TR_RelatedAccount__c);
                    accountIds.add(newIncentive.EUR_TR_RelatedAccount__c);
                }

            }
        }
        assignDoNotShowMeAgainFalseByAccountId(accountIds);

    }

    public static void handleAfterUpdate(Map<Id, EUR_TR_Incentive__c> oldIncentiveMap, Map<Id, EUR_TR_Incentive__c> newIncentiveMap) {

        Set<Id> accountIds = new Set<Id>();
        for (EUR_TR_Incentive__c newIncentive : newIncentiveMap.values()) {
            EUR_TR_Incentive__c oldIncentive = oldIncentiveMap.get(newIncentive.Id);
            if (newIncentive.EUR_TR_RelatedAccount__c != null) {
                if (oldIncentive.EUR_TR_StartDate__c != newIncentive.EUR_TR_StartDate__c || oldIncentive.EUR_TR_EndDate__c != newIncentive.EUR_TR_EndDate__c) {
                    if (!recordsAlreadyProcessed.contains(newIncentive.EUR_TR_RelatedAccount__c)) {
                        recordsAlreadyProcessed.add(newIncentive.EUR_TR_RelatedAccount__c);
                        accountIds.add(newIncentive.EUR_TR_RelatedAccount__c);
                    }
                }
            }
        }

        assignDoNotShowMeAgainFalseByAccountId(accountIds);

    }

    private static void assignDoNotShowMeAgainFalseByAccountId(Set<Id> accountIds) {
        if (!accountIds.isEmpty()) {
            List<EUR_TR_Incentive__c> flaggedWithDoNotShowMeFieldRecords = [
                    SELECT Id
                    FROM EUR_TR_Incentive__c
                    WHERE EUR_TR_EndDate__c > TODAY AND EUR_TR_DoNotShowMeAgain__c = TRUE AND EUR_TR_RelatedAccount__c IN :accountIds
            ];
            for (EUR_TR_Incentive__c incentive : flaggedWithDoNotShowMeFieldRecords) {
                incentive.EUR_TR_DoNotShowMeAgain__c = false;
            }
            update flaggedWithDoNotShowMeFieldRecords;
        }
    }
}