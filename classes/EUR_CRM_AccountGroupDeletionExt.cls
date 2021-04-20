public with sharing class EUR_CRM_AccountGroupDeletionExt {

    public String message { get; set; }

    private ApexPages.StandardController standardController;

    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    @TestVisible
    private static final String CANNOT_DELETE_RECORD_MANUALLY =
        'Cannot delete a record manually. Please, press a button "Mark \'To Delete\'" to start a deletion process.';
    @TestVisible
    private static final String RECORD_ALREADY_MARKED = 'A record already marked \'To Delete\'.';


    public EUR_CRM_AccountGroupDeletionExt(ApexPages.StandardController standardController) {
        this.standardController = standardController;

        Id recordId = this.standardController.getId();

        List<EUR_CRM_AccountGroup__c> accountGroups = this.selectAccountGroupsWhereId(recordId);
        if (accountGroups.isEmpty()) { return ; }

        if ( ! accountGroups[0].EUR_CRM_Status__c.equalsIgnoreCase(TO_DELETE_STATUS)) {
            this.message = CANNOT_DELETE_RECORD_MANUALLY;
        } else {
            this.message = RECORD_ALREADY_MARKED;
        }
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_AccountGroup__c> selectAccountGroupsWhereId(Id recordId) {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            FROM EUR_CRM_AccountGroup__c
            WHERE Id = :recordId
                AND EUR_CRM_Status__c != NULL
        ];
    }

}