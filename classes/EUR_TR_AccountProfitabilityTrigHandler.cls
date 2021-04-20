/**
 * Created by osman on 6.01.2021.
 */

public with sharing class EUR_TR_AccountProfitabilityTrigHandler {

    public static void handleBeforeUpdate(List<EUR_TR_AccountProfitability__c> listOfAccountProfitability) {
        assignExternalId(listOfAccountProfitability);
    }

    public static void handleBeforeInsert(List<EUR_TR_AccountProfitability__c> listOfAccountProfitability) {
        assignExternalId(listOfAccountProfitability);
    }


    private static void assignExternalId(List<EUR_TR_AccountProfitability__c> listOfAccountProfitability) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_TR_AccountProfitability__c accountProfitability : listOfAccountProfitability) {
            if (accountProfitability.EUR_TR_RelatedAccount__c != null) {
                accountIds.add(accountProfitability.EUR_TR_RelatedAccount__c);
            }
        }

        Map<Id, EUR_TR_Account__c> accountMap = new Map<Id, EUR_TR_Account__c>([
                SELECT Id,EUR_TR_AccountCode__c
                FROM EUR_TR_Account__c
                WHERE Id = :accountIds AND EUR_TR_AccountCode__c != NULL
        ]);

        for (EUR_TR_AccountProfitability__c accountProfitability : listOfAccountProfitability) {
            if (accountProfitability.EUR_TR_RelatedAccount__c != null && String.isNotBlank(accountProfitability.EUR_TR_Year__c) && String.isNotBlank(accountProfitability.EUR_TR_Quarter__c)) {
                EUR_TR_Account__c relatedAccount = accountMap.get(accountProfitability.EUR_TR_RelatedAccount__c);
                if (relatedAccount != null) {
                    accountProfitability.EUR_TR_ExternalId__c = String.format('{0}_{1}_{2}', new List<String>{
                            relatedAccount.EUR_TR_AccountCode__c,
                            accountProfitability.EUR_TR_Year__c,
                            accountProfitability.EUR_TR_Quarter__c
                    });
                }

            }
        }


    }

}