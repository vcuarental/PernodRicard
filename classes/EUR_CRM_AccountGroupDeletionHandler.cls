public with sharing class EUR_CRM_AccountGroupDeletionHandler {

    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    @TestVisible
    private static final String CANNOT_BE_DELETED = 'A record cannot be deleted.';

    private static Boolean byPass = false;

    public static void deleteAccountGroups(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        byPass = true;
        delete [SELECT Id FROM EUR_CRM_AccountGroup__c WHERE EUR_CRM_Account__c = :accounts];
        byPass = false;
    }

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleDeletion(List<EUR_CRM_AccountGroup__c> accountGroupUsersToDelete) {
        if(byPass) return;
        for (EUR_CRM_AccountGroup__c accountGroupUser : accountGroupUsersToDelete) {
            if ( ! this.isCanBeDeleted(accountGroupUser)) {
                accountGroupUser.addError(CANNOT_BE_DELETED);
            }
        }
    }

    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isCanBeDeleted(EUR_CRM_AccountGroup__c accountGroupUser) {
        return String.isNotBlank(accountGroupUser.EUR_CRM_Status__c)
            && accountGroupUser.EUR_CRM_Status__c.equalsIgnoreCase(TO_DELETE_STATUS)
            && accountGroupUser.EUR_CRM_AllowDeletion__c == true
        ;
    }

}