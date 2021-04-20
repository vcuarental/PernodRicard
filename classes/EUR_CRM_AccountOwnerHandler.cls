public with sharing class EUR_CRM_AccountOwnerHandler {

    private static Boolean isRunOnce = false;
    private final Set<String> INACTIVE_STATUSES = new Set<String> {
        'Ended'
    ,   'Deactivated'
    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleOwnerChanging(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        if (isRunOnce) { return; }

        List<EUR_CRM_Account__c> accountsWithChangedOwnerId = this.extractAccountsWithChangedOwnerId(accounts, oldAccountById);
        System.debug('\n\n accountsWithChangedOwnerId => ' + JSON.serializePretty(accountsWithChangedOwnerId) + '\n');
        if (accountsWithChangedOwnerId.isEmpty()) { return ; }

        Map<Id, Id> oldOwnerIdByNewOwnerId = new Map<Id, Id>();
        Map<Id, Id> newOwnerIdByOldOwnerId = new Map<Id, Id>();
        for (EUR_CRM_Account__c account : accountsWithChangedOwnerId) {
            oldOwnerIdByNewOwnerId.put(account.OwnerId, oldAccountById.get(account.Id).OwnerId);
            newOwnerIdByOldOwnerId.put(oldAccountById.get(account.Id).OwnerId, account.OwnerId);
        }
        System.debug('\n\n oldOwnerIdByNewOwnerId => ' + JSON.serializePretty(oldOwnerIdByNewOwnerId) + '\n');
        System.debug('\n\n newOwnerIdByOldOwnerId => ' + JSON.serializePretty(newOwnerIdByOldOwnerId) + '\n');

        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = this.selectAccountInTargetGroups(accountsWithChangedOwnerId, newOwnerIdByOldOwnerId.keySet());
        System.debug('\n\n accountInTargetGroups => ' + JSON.serializePretty(accountInTargetGroups) + '\n');
        if (accountInTargetGroups.isEmpty()) { return ; }

        Map<Id, Map<Id, List<EUR_CRM_Account_in_Target_Group__c>>> accountInGroupsByCurrentOwnerIdByGroupId = this.getAccountInGroupsByCurrentOwnerIdByGroupId(accountInTargetGroups);
        System.debug('\n\n accountInGroupsByCurrentOwnerIdByGroupId => ' + JSON.serializePretty(accountInGroupsByCurrentOwnerIdByGroupId) + '\n');

        Map<Id, Id> oldOwnerIdWithSingleAccountInGroupByGroupId = this.getOldOwnerIdWithSingleAccountInGroupByGroupId(accountInGroupsByCurrentOwnerIdByGroupId, oldOwnerIdByNewOwnerId);
        System.debug('\n\n oldOwnerIdWithSingleAccountInGroupByGroupId => ' + JSON.serializePretty(oldOwnerIdWithSingleAccountInGroupByGroupId) + '\n');
        if (oldOwnerIdWithSingleAccountInGroupByGroupId.isEmpty()) { return ; }

        List<EUR_CRM_OP_Target_REP__c> opTargetReps = this.selectOPTargetReps(oldOwnerIdWithSingleAccountInGroupByGroupId.keySet(), oldOwnerIdWithSingleAccountInGroupByGroupId.values());
        System.debug('\n\n opTargetReps => ' + JSON.serializePretty(opTargetReps) + '\n');
        if (opTargetReps.isEmpty()) { return ; }

        this.updateOPTargetReps(opTargetReps, newOwnerIdByOldOwnerId);

        isRunOnce = true;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateOPTargetReps(List<EUR_CRM_OP_Target_REP__c> opTargetReps, Map<Id, Id> newOwnerIdByOldOwnerId) {
        for (EUR_CRM_OP_Target_REP__c opTargetRep : opTargetReps) {
            opTargetRep.EUR_CRM_Target_Owner__c = newOwnerIdByOldOwnerId.get(opTargetRep.EUR_CRM_Target_Owner__c);
        }
        System.debug('\n\n updated opTargetReps => ' + JSON.serializePretty(opTargetReps) + '\n');
        update opTargetReps;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, Map<Id, List<EUR_CRM_Account_in_Target_Group__c>>> getAccountInGroupsByCurrentOwnerIdByGroupId(List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups) {
        Map<Id, Map<Id, List<EUR_CRM_Account_in_Target_Group__c>>> accountInGroupsByCurrentOwnerIdByGroupId = new Map<Id, Map<Id, List<EUR_CRM_Account_in_Target_Group__c>>>();
        for (EUR_CRM_Account_in_Target_Group__c accountInTargetGroup : accountInTargetGroups) {
            Id groupId = accountInTargetGroup.EUR_CRM_Account_Target_Group__c;
            Id currentOwnerId = accountInTargetGroup.EUR_CRM_Account__r.OwnerId;

            if (accountInGroupsByCurrentOwnerIdByGroupId.containsKey(groupId)) {
                if (accountInGroupsByCurrentOwnerIdByGroupId.get(groupId).containsKey(currentOwnerId)) {
                    accountInGroupsByCurrentOwnerIdByGroupId.get(groupId).get(currentOwnerId).add(accountInTargetGroup);
                } else {
                    accountInGroupsByCurrentOwnerIdByGroupId.get(groupId).put(currentOwnerId, new List<EUR_CRM_Account_in_Target_Group__c> { accountInTargetGroup });
                }
            } else {
                accountInGroupsByCurrentOwnerIdByGroupId.put(groupId, new Map<Id, List<EUR_CRM_Account_in_Target_Group__c>> {
                    currentOwnerId => new List<EUR_CRM_Account_in_Target_Group__c> { accountInTargetGroup }
                });
            }
        }
        return accountInGroupsByCurrentOwnerIdByGroupId;
    }

    private Map<Id, Id> getOldOwnerIdWithSingleAccountInGroupByGroupId(Map<Id, Map<Id, List<EUR_CRM_Account_in_Target_Group__c>>> accountInGroupsByCurrentOwnerIdByGroupId, Map<Id, Id> oldOwnerIdByNewOwnerId) {
        Map<Id, Id> oldOwnerIdWithSingleAccountInGroupByGroupId = new Map<Id, Id>();
        for (Id groupId : accountInGroupsByCurrentOwnerIdByGroupId.keySet()) {
            Map<Id, List<EUR_CRM_Account_in_Target_Group__c>> accountInGroupsByAccountOwnerId = accountInGroupsByCurrentOwnerIdByGroupId.get(groupId);
            for (Id ownerId : accountInGroupsByAccountOwnerId.keySet()) {
                if (oldOwnerIdByNewOwnerId.containsKey(ownerId)) {
                    Id oldOwnerId = oldOwnerIdByNewOwnerId.get(ownerId);
                    if (accountInGroupsByAccountOwnerId.get(ownerId).size() == 1 && ! accountInGroupsByAccountOwnerId.containsKey(oldOwnerId)) {
                        oldOwnerIdWithSingleAccountInGroupByGroupId.put(groupId, oldOwnerId);
                    }
                }
            }
        }
        return oldOwnerIdWithSingleAccountInGroupByGroupId;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Account__c> extractAccountsWithChangedOwnerId(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accountsWithChangedOwnerId = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isOwnerIdChanged(account, oldAccountById)) {
                accountsWithChangedOwnerId.add(account);
            }
        }
        return accountsWithChangedOwnerId;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isOwnerIdChanged(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return account.OwnerId != oldAccountById.get(account.Id).OwnerId;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Account_in_Target_Group__c> selectAccountInTargetGroups(List<EUR_CRM_Account__c> accounts, Set<Id> ownerIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Account_Target_Group__c
            ,   EUR_CRM_Account__r.OwnerId
            FROM EUR_CRM_Account_in_Target_Group__c
            WHERE
            EUR_CRM_Account__c IN :accounts
                OR EUR_CRM_Account__r.OwnerId IN :ownerIds
            ORDER BY EUR_CRM_Account__r.Name ASC
            LIMIT 2000
        ];
    }

    private List<EUR_CRM_OP_Target_REP__c> selectOPTargetReps(Set<Id> groupIds, List<Id> oldOwnerIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Target_Owner__c
            FROM EUR_CRM_OP_Target_REP__c
            WHERE EUR_CRM_Objectives_Promotions__r.EUR_CRM_Account_Target_Group__c IN :groupIds
                AND EUR_CRM_Target_Owner__c IN :oldOwnerIds
                AND EUR_CRM_Objectives_Promotions__r.EUR_CRM_Status__c NOT IN :INACTIVE_STATUSES
        ];
    }

}