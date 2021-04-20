/**
 * Created by osman on 6.01.2021.
 */

public with sharing class EUR_TR_CrossComplianceTriggerHandler {

    public static void handleBeforeUpdate(List<EUR_TR_CrossCompliance__c> listOfCrossCompliance) {
        assignExternalId(listOfCrossCompliance);
    }

    public static void handleBeforeInsert(List<EUR_TR_CrossCompliance__c> listOfCrossCompliance) {
        assignExternalId(listOfCrossCompliance);
    }


    private static void assignExternalId(List<EUR_TR_CrossCompliance__c> listOfCrossCompliance) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_TR_CrossCompliance__c accountProfitability : listOfCrossCompliance) {
            if (accountProfitability.EUR_TR_RelatedAccount__c != null) {
                accountIds.add(accountProfitability.EUR_TR_RelatedAccount__c);
            }
        }

        Map<Id, EUR_TR_Account__c> accountMap = new Map<Id, EUR_TR_Account__c>([
                SELECT Id,EUR_TR_AccountCode__c
                FROM EUR_TR_Account__c
                WHERE Id = :accountIds AND EUR_TR_AccountCode__c != NULL
        ]);

        for (EUR_TR_CrossCompliance__c crossCompliance : listOfCrossCompliance) {
            if (crossCompliance.EUR_TR_RelatedAccount__c != null) {
                EUR_TR_Account__c relatedAccount = accountMap.get(crossCompliance.EUR_TR_RelatedAccount__c);
                if (relatedAccount != null) {
                    crossCompliance.EUR_TR_ExternalId__c = relatedAccount.EUR_TR_AccountCode__c;
                }
            }
        }

    }
}