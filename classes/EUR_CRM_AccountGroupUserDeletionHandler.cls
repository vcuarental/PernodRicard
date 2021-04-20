public with sharing class EUR_CRM_AccountGroupUserDeletionHandler {

    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    @TestVisible
    private static final String CANNOT_BE_DELETED = 'A record cannot be deleted.';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleDeletion(List<EUR_CRM_AccountGroupUser__c> accountGroupUsersToDelete) {
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsersToDelete) {
            if ( ! this.isCanBeDeleted(accountGroupUser)) {
                accountGroupUser.addError(CANNOT_BE_DELETED);
            }
        }
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isCanBeDeleted(EUR_CRM_AccountGroupUser__c accountGroupUser) {
        return String.isNotBlank(accountGroupUser.EUR_CRM_Status__c)
            && accountGroupUser.EUR_CRM_Status__c.equalsIgnoreCase(TO_DELETE_STATUS)
            && accountGroupUser.EUR_CRM_AllowDeletion__c == true
        ;
    }

}