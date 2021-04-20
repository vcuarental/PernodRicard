public with sharing class EUR_CRM_AccountGroupUserDeletionExt {

    public String message { get; set; }

    private ApexPages.StandardController standardController;

    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    @TestVisible
    private static final String CANNOT_DELETE_RECORD_MANUALLY =
        'Cannot delete a record manually. Please, press a button "Mark \'To Delete\'" to start a deletion process.';
    @TestVisible
    private static final String RECORD_ALREADY_MARKED =
        'A record already marked \'To Delete\'.';


    public EUR_CRM_AccountGroupUserDeletionExt(ApexPages.StandardController standardController) {
        this.standardController = standardController;

        Id recordId = this.standardController.getId();

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = this.selectAccountGroupUsersWhereId(recordId);
        if (accountGroupUsers.isEmpty()) { return ; }

        if ( ! accountGroupUsers[0].EUR_CRM_Status__c.equalsIgnoreCase('To Delete')) {
            this.message = CANNOT_DELETE_RECORD_MANUALLY;
        } else {
            this.message = RECORD_ALREADY_MARKED;
        }
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsersWhereId(Id recordId) {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_AccountGroupUser__c
            WHERE Id = :recordId
                AND EUR_CRM_Status__c != NULL
        ];
    }

}