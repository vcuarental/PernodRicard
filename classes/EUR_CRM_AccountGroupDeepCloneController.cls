public with sharing class EUR_CRM_AccountGroupDeepCloneController {

    @TestVisible
    private static final String CANNOT_CHOOSE_SAME_ACCOUNT = 'You cannot choose the same Account.';

    public EUR_CRM_AccountGroup__c accountGroup { get; set; }

    private Id agId;
    private Id previousAccountId;

    public EUR_CRM_AccountGroupDeepCloneController() {
        this.agId = (String)ApexPages.currentPage().getParameters().get('id');

        this.accountGroup = this.selectAccountGroup();
        this.accountGroup.Id = null;
        this.previousAccountId = this.accountGroup.EUR_CRM_Account__c;
    }


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public PageReference doCloning() {
        System.debug('\n\n this.accountGroup => ' + JSON.serializePretty(this.accountGroup) + '\n');
        if (this.accountGroup.EUR_CRM_Account__c == this.previousAccountId) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, CANNOT_CHOOSE_SAME_ACCOUNT));
            return null;
        }

        try {
            insert this.accountGroup;

            List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = this.getCopyAccountGroupUsers();
            System.debug('\n\n accountGroupUsers => ' + JSON.serializePretty(accountGroupUsers) + '\n');
            insert accountGroupUsers;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }

        return new PageReference('/' + this.accountGroup.Id);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private List<EUR_CRM_AccountGroupUser__c> getCopyAccountGroupUsers() {
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = this.selectAccountGroupUsers();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.Id = null;
            accountGroupUser.EUR_CRM_AccountGroup__c = this.accountGroup.Id;
        }
        return accountGroupUsers;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private EUR_CRM_AccountGroup__c selectAccountGroup() {
        return [
            SELECT Id
            ,   EUR_CRM_Account__c
            FROM EUR_CRM_AccountGroup__c
            WHERE Id = :this.agId
            LIMIT 1
        ][0];
    }

    public List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsers() {
        return [
            SELECT Id
            ,   EUR_CRM_User__c
            ,   EUR_CRM_AccessLevel__c
            FROM EUR_CRM_AccountGroupUser__c
            WHERE EUR_CRM_AccountGroup__c = :this.agId
                AND EUR_CRM_AccessLevel__c IN ('Read', 'Edit')
        ];
    }

}