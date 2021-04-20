//noinspection ApexUnusedDeclaration
global class EUR_CRM_AccountEUSharingWebService {

    @TestVisible
    private static final String SUCCESSFULLY_RUN_MIGRATION = 'A batch successfully run. Data will be migrated in few minutes. ' +
        'You will receive an email message when migration is finished.';

    @TestVisible
    private static final String SUCCESSFULLY_RUN_DATA_SHARING = 'A batch successfully run. Data will be shared in few minutes. ' +
        'You will receive an email message when data sharing is finished.';


    webService static String run_EUR_CRM_AccountEUShareBatch(Id accountId) {
        System.debug('\n\n accountId => ' + JSON.serializePretty(accountId) + '\n');

        Database.executeBatch(new EUR_CRM_AccountEUShareBatch(accountId), 200);

        return SUCCESSFULLY_RUN_MIGRATION;
    }

    webService static String run_EUR_CRM_AccGroupUserSharingBatch_for_AG(Id accountGroupId) {
        System.debug('\n\n accountGroupId => ' + JSON.serializePretty(accountGroupId) + '\n');

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(selectAccountGroupUserById(accountGroupId).keySet()), 200);

        return SUCCESSFULLY_RUN_DATA_SHARING;
    }

    webService static String run_EUR_CRM_AccGroupUserSharingBatch_for_AGU(Id accountGroupUserId) {
        System.debug('\n\n accountGroupUserId => ' + JSON.serializePretty(accountGroupUserId) + '\n');

        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(accountGroupUserId), 200);

        return SUCCESSFULLY_RUN_DATA_SHARING;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static Map<Id, EUR_CRM_AccountGroupUser__c> selectAccountGroupUserById(Id agId) {
        return new Map<Id, EUR_CRM_AccountGroupUser__c>([
            SELECT Id
            FROM EUR_CRM_AccountGroupUser__c
            WHERE EUR_CRM_AccountGroup__c = :agId
        ]);
    }

}