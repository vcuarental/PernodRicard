/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

public with sharing class EUR_CRM_StoreAuditService {
    @TestVisible
    private static final String AUDIT_FINISHED_STATUS = 'Finished';
    private Set<Id> accIdsForChangesOnStoreAudits = new Set<Id>();
    private Set<Id> accIds = new Set<Id>();
    public static final Set<String> IS_LATEST_COUNTRY_CODES = new Set<String>();
    static {
        for (EUR_CRM_Rollout_Country__mdt setting : [
                SELECT DeveloperName
                FROM EUR_CRM_Rollout_Country__mdt
                WHERE EUR_CRM_Last_Audit_Supported__c = TRUE
        ]) {
            IS_LATEST_COUNTRY_CODES.add(setting.DeveloperName);
        }
    }
    /* ========================================================= */
    /*     Interface (Is_Latest Logic)
    /* ========================================================= */
    public void handleIsLatestFieldOnStoreAudit(List<EUR_CRM_Store_Audit__c> newAudits) {
        System.debug('\n\n New Store Audits => ' + JSON.serializePretty(newAudits) + '\n');
        this.configureAccountIdsSet(newAudits);
        this.changeIsLatestFieldOnStoreAuditWithItems(newAudits);
    }
    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */

    private void configureAccountIdsSet(List<EUR_CRM_Store_Audit__c> newAudits) {
        for (EUR_CRM_Store_Audit__c storeAudit : newAudits) {
            accIds.add(storeAudit.EUR_CRM_Account__c);
        }
    }

    private void changeIsLatestFieldOnStoreAuditWithItems(List<EUR_CRM_Store_Audit__c> newAudits) {
        Map<Id, List<EUR_CRM_Store_Audit__c>> storeAuditsByAccId = new Map<Id, List<EUR_CRM_Store_Audit__c>>();
        List<EUR_CRM_Store_Audit__c> newAuditsWithLatestAudits = this.getLastStoreAuditsByAccountId(accIds);
        newAuditsWithLatestAudits.addAll(newAudits);
        for (EUR_CRM_Store_Audit__c storeAudit : newAuditsWithLatestAudits) {
            if (storeAuditsByAccId.containsKey(storeAudit.EUR_CRM_Account__c)) {
                storeAuditsByAccId.get(storeAudit.EUR_CRM_Account__c).add(storeAudit);
            } else {
                storeAuditsByAccId.put(storeAudit.EUR_CRM_Account__c, new List<EUR_CRM_Store_Audit__c>{
                        storeAudit
                });
            }
        }

        newAudits = setIsLatestForStoreAudits(storeAuditsByAccId, newAudits);

        System.debug('\n\n accIdsForSelection => ' + JSON.serializePretty(accIdsForChangesOnStoreAudits) + '\n');
        System.debug('\n\n newAudits => ' + JSON.serializePretty(newAudits) + '\n');
        List<EUR_CRM_Store_Audit__c> oldStoreAuditsToUpdate = this.getLastStoreAuditsByAccountId
                (accIdsForChangesOnStoreAudits);
        System.debug('\n\n oldStoreAuditsToUpdate => ' + JSON.serializePretty(oldStoreAuditsToUpdate) + '\n');
        if (!oldStoreAuditsToUpdate.isEmpty()) {
            oldStoreAuditsToUpdate = updateIsLatestFieldOnStoreAudits(oldStoreAuditsToUpdate);
        }
        System.debug('\n\n oldStoreAuditsToUpdate Updated => ' + JSON.serializePretty(oldStoreAuditsToUpdate) + '\n');
        if (!oldStoreAuditsToUpdate.isEmpty()) {
            update oldStoreAuditsToUpdate;
        }
    }

    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */

    private List<EUR_CRM_Store_Audit__c> setIsLatestForStoreAudits(Map<Id, List<EUR_CRM_Store_Audit__c>>
            storeAuditsByAccId, List<EUR_CRM_Store_Audit__c> newAudits) {
        List<EUR_CRM_Store_Audit__c> result = new List<EUR_CRM_Store_Audit__c>();
        Map<Id, EUR_CRM_Account__c> accountsMap = getAccountsMapByIds(storeAuditsByAccId.keySet());
        for (Id accId : storeAuditsByAccId.keySet()) {
            List<EUR_CRM_Store_Audit__c> storeAudits = storeAuditsByAccId.get(accId);
            if (!storeAudits.isEmpty()) {
                EUR_CRM_Store_Audit__c latestAudit = storeAudits[0];
                for (EUR_CRM_Store_Audit__c storeAudit: storeAudits) {
                    if (needToReplaceLatestAudit(storeAudit, latestAudit, accountsMap)) {
                        latestAudit = storeAudit;
                    }
                }
                if (newAudits.contains(latestAudit)) {
                    latestAudit.EUR_CRM_Is_Latest__c = true;
                    accIdsForChangesOnStoreAudits.add(accId);
                    result.add(latestAudit);
                }
            }
        }
        return result;
    }
    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Store_Audit__c> updateIsLatestFieldOnStoreAudits(List<EUR_CRM_Store_Audit__c> oldStoreAudits) {
        List<EUR_CRM_Store_Audit__c> result = new List<EUR_CRM_Store_Audit__c>();
        for (EUR_CRM_Store_Audit__c storeAudit : oldStoreAudits) {
            storeAudit.EUR_CRM_Is_Latest__c = false;
            result.add(storeAudit);
        }
        return result;
    }
    private Boolean needToReplaceLatestAudit(EUR_CRM_Store_Audit__c currentAudit, EUR_CRM_Store_Audit__c
            latestAudit, Map<Id, EUR_CRM_Account__c> accountsMap) {
        if (IS_LATEST_COUNTRY_CODES.contains(accountsMap.get(currentAudit.EUR_CRM_Account__c).EUR_CRM_Country_Code__c)) {
            if (latestAudit.EUR_CRM_Status__c != AUDIT_FINISHED_STATUS && currentAudit.EUR_CRM_Status__c ==
                    AUDIT_FINISHED_STATUS){
                return true;
            } else {
                return currentAudit.EUR_CRM_Audit_Datetime__c >= latestAudit.EUR_CRM_Audit_Datetime__c && currentAudit
                        .EUR_CRM_Status__c == AUDIT_FINISHED_STATUS;
            }
        } else {
            return currentAudit.EUR_CRM_Audit_Datetime__c > latestAudit.EUR_CRM_Audit_Datetime__c;
        }
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Store_Audit__c> getLastStoreAuditsByAccountId(Set<Id> accIds) {
        return [
                SELECT Id, EUR_CRM_Is_Latest__c
                        , EUR_CRM_External_ID__c
                        , EUR_CRM_Account__c
                        , EUR_CRM_Audit_Datetime__c
                        , EUR_CRM_Status__c
                FROM EUR_CRM_Store_Audit__c
                WHERE EUR_CRM_Is_Latest__c = TRUE
                AND EUR_CRM_Account__c IN :accIds
        ];
    }
    private Map<Id, EUR_CRM_Account__c> getAccountsMapByIds(Set<Id> ids) {
        return new Map<Id, EUR_CRM_Account__c>([
                SELECT Id, EUR_CRM_Country_Code__c
                FROM EUR_CRM_Account__c
                WHERE Id IN :ids
        ]);
    }
}