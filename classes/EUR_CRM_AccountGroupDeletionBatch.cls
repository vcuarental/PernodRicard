global class EUR_CRM_AccountGroupDeletionBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable {

//    Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(), 200);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_AccountGroupDeletionBatch scheduledJob = new EUR_CRM_AccountGroupDeletionBatch();
//    System.schedule('Account Group Deletion Scheduled Job', cronExpression, scheduledJob);

    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    private Set<Id> accountGroupIds;

    global EUR_CRM_AccountGroupDeletionBatch() {
        this.accountGroupIds = new Set<Id>();
    }

    global EUR_CRM_AccountGroupDeletionBatch(Id accountGroupId) {
        this.accountGroupIds = new Set<Id> { accountGroupId };
    }

    global EUR_CRM_AccountGroupDeletionBatch(Set<Id> accountGroupIds) {
        this.accountGroupIds = accountGroupIds;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if( ! this.accountGroupIds.isEmpty()) {
            return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_Status__c
                ,   EUR_CRM_AllowDeletion__c
                ,   (
                    SELECT Id
                    FROM EUR_CRM_AccountGroupUsers__r
                )
                FROM EUR_CRM_AccountGroup__c
                WHERE Id IN :this.accountGroupIds
                    AND EUR_CRM_Status__c = :TO_DELETE_STATUS
            ]);
        }

        return Database.getQueryLocator([
            SELECT Id
                ,   EUR_CRM_Status__c
                ,   EUR_CRM_AllowDeletion__c
                ,   (
                SELECT Id
                FROM EUR_CRM_AccountGroupUsers__r
            )
            FROM EUR_CRM_AccountGroup__c
            WHERE EUR_CRM_Status__c = :TO_DELETE_STATUS
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_AccountGroup__c> accountGroups) {
        System.debug('\n\n accountGroups.size() => ' + JSON.serializePretty(accountGroups.size()) + '\n');
        System.debug('\n\n accountGroups => ' + JSON.serializePretty(accountGroups) + '\n');

        List<EUR_CRM_AccountGroup__c> accountGroupsToDelete = this.updateRecordsToDelete(accountGroups);
        System.debug('\n\n accountGroupsToDelete.size() => ' + JSON.serializePretty(accountGroupsToDelete.size()) + '\n');
        System.debug('\n\n accountGroupsToDelete => ' + JSON.serializePretty(accountGroupsToDelete) + '\n');
        if (accountGroupsToDelete.isEmpty()) { return ; }

        this.upsertRecords(accountGroupsToDelete);
        this.deleteRecords(accountGroupsToDelete);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private List<EUR_CRM_AccountGroup__c> updateRecordsToDelete(List<EUR_CRM_AccountGroup__c> accountGroups) {
        List<EUR_CRM_AccountGroup__c> accountGroupsToDelete = new List<EUR_CRM_AccountGroup__c>();
        for (EUR_CRM_AccountGroup__c accountGroup : accountGroups) {
            if (accountGroup.EUR_CRM_AccountGroupUsers__r.isEmpty()) {
                accountGroup.EUR_CRM_AllowDeletion__c = true;
                accountGroupsToDelete.add(accountGroup);
            }
        }
        return accountGroupsToDelete;
    }

}