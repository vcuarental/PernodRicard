global class EUR_CRM_NightlyScheduledJobs implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(true), 200);
        Database.executeBatch(new EUR_CRM_DelOldContentBatch(), 100);
        Database.executeBatch(new EUR_CRM_DelAttachOfInactiveOPBatch(), 100);
        Database.executeBatch(new EUR_CRM_AccountGeolocationBatch(), 100);

        List<EUR_CRM_Account_Target_Group__c> accountGroups = [
            SELECT Id
            FROM EUR_CRM_Account_Target_Group__c
            WHERE EUR_CRM_isDailyRecalculation__c = TRUE
                AND EUR_CRM_IsDynamic__c = TRUE
            LIMIT 1
        ];
        if ( ! accountGroups.isEmpty()) {
            Database.executeBatch((Database.Batchable<sObject>) Type.forName('EUR_CRM_RefreshDynGroupBatch').newInstance());
        }
    }

}