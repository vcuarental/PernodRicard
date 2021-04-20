/**
 * Created by Ilarion Tokarskyi on 24.11.2020.
 */

public with sharing class EUR_CRM_RecommendedAccountBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable {

    private Set<Id> accIds = new Set<Id>();
    private Set<Id> weekIds = new Set<Id>();
    List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();

    public Iterable<SObject> start(Database.BatchableContext bc) {
        setIsRecommendedToFalseAndVisitRankToNullInAccount();
        return Database.getQueryLocator([
                SELECT EUR_CRM_Account__c,
                        EUR_CRM_Business_Development_Score__c,
                        EUR_CRM_Promotion_Score__c,
                        EUR_CRM_Visit_Type__c,
                        EUR_CRM_Week_KDP__c,
                        EUR_CRM_Visit_Rank__c,
                        EUR_CRM_Week_KDP__r.EUR_CRM_Country_Code__c,
                        EUR_CRM_Week_KDP__r.EUR_CRM_Week_Start_Date__c,
                        EUR_CRM_Week_KDP__r.EUR_CRM_Number_of_recommended_BD_visits__c
                FROM EUR_CRM_Recommended_Account__c
                WHERE EUR_CRM_Week_KDP__r.EUR_CRM_Week_Start_Date__c = :Date.today()
        ]);
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_RecommendedAccountBatch(), 100);
    }

    public void execute(Database.BatchableContext bc, List<EUR_CRM_Recommended_Account__c> recomAccounts) {
        this.configureIdSets(recomAccounts);
        System.debug('\n accIds.size() => ' + accIds.size() + '\n');
        System.debug('\n weekIds.size() => ' + weekIds.size() + '\n');
        for (EUR_CRM_Recommended_Account__c recAccount : recomAccounts) {
            accountsToUpdate.add(createAccountForUpdate(recAccount));
        }
        System.debug('\n accountsToUpdate.size() => ' + accountsToUpdate.size() + '\n');
        System.debug('\n accountsToUpdate => ' + JSON.serializePretty(accountsToUpdate) + '\n');
        update accountsToUpdate;
    }

    /*
        Sending email finish method implemented in extended EUR_CRM_BatchVirtualClass class
     */

    /* ========================================================= */
    /*     High-level Helpers
    /* ========================================================= */
    private void configureIdSets(List<EUR_CRM_Recommended_Account__c> recomAccounts) {
        for (EUR_CRM_Recommended_Account__c recommendedAccount : recomAccounts) {
            accIds.add(recommendedAccount.EUR_CRM_Account__c);
            weekIds.add(recommendedAccount.EUR_CRM_Week_KDP__c);
        }
    }

    private void setIsRecommendedToFalseAndVisitRankToNullInAccount() {
        List<EUR_CRM_Account__c> accounts = [
                SELECT EUR_CRM_Visit_Rank__c
                FROM EUR_CRM_Account__c
                WHERE EUR_CRM_IsRecommended__c = TRUE
        ];
        for (EUR_CRM_Account__c account : accounts) {
            account.EUR_CRM_IsRecommended__c = false;
            account.EUR_CRM_Visit_Rank__c = null;
            account.EUR_CRM_Visit_Type__c = null;
        }
        Database.update(accounts, false);
    }
    /* ========================================================= */
    /*     Creators
    /* ========================================================= */
    private EUR_CRM_Account__c createAccountForUpdate(EUR_CRM_Recommended_Account__c recAccount) {
        return new EUR_CRM_Account__c(Id = recAccount.EUR_CRM_Account__c,
                EUR_CRM_Business_Development_Score__c = recAccount.EUR_CRM_Business_Development_Score__c,
                EUR_CRM_Promotion_Score__c = recAccount.EUR_CRM_Promotion_Score__c,
                EUR_CRM_Visit_Type__c = recAccount.EUR_CRM_Visit_Type__c,
                EUR_CRM_Visit_Rank__c = recAccount.EUR_CRM_Visit_Rank__c,
                EUR_CRM_IsRecommended__c = TRUE
        );
    }
}