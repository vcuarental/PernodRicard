/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

public with sharing class EUR_CRM_PriceAuditIsLatestService {
    private Set<Id> accIds = new Set<Id>();
    private Set<Id> accIdsForChangesOnAudits = new Set<Id>();
    @TestVisible
    private static final String AUDIT_FINISHED_STATUS = 'Finished';
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
    public void handleIsLatestFieldOnPriceAudits(List<EUR_CRM_Price_Audit__c> newPriceAudits) {
        System.debug('\n\n newPriceAudits size => ' + JSON.serializePretty(newPriceAudits.size()) + '\n');
        System.debug('\n\n newPriceAudits => ' + JSON.serializePretty(newPriceAudits) + '\n');
        this.configureAccountIdsSet(newPriceAudits);
        this.changeIsLatestOnAudits(newPriceAudits);
    }
    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void configureAccountIdsSet(List<EUR_CRM_Price_Audit__c> newPriceAudits) {
        for (EUR_CRM_Price_Audit__c audit : newPriceAudits) {
            accIds.add(audit.EUR_CRM_Account__c);
        }
    }

    private void changeIsLatestOnAudits(List<EUR_CRM_Price_Audit__c> newAudits) {
        List<EUR_CRM_Price_Audit__c> latestAuditsWithNew = this.getLatsAuditsByAccountIds(accIds);
        latestAuditsWithNew.addAll(newAudits);
        System.debug('\n\n latestAuditsWithNew size => ' + JSON.serializePretty(latestAuditsWithNew.size()) + '\n');

        Map<Id, List<EUR_CRM_Price_Audit__c>> auditsByAccountId = this.configureAuditsMapByAccId(latestAuditsWithNew);

        newAudits = setIsLatestForAudits(auditsByAccountId, newAudits);

        System.debug('\n\n accIdsForSelection => ' + JSON.serializePretty(accIdsForChangesOnAudits) + '\n');
        System.debug('\n\n newAudits => ' + JSON.serializePretty(newAudits) + '\n');

        List<EUR_CRM_Price_Audit__c> oldAuditsToUpdate = this.getLatsAuditsByAccountIds(accIdsForChangesOnAudits);
        System.debug('\n\n oldAuditsToUpdate size => ' + JSON.serializePretty(oldAuditsToUpdate.size()) + '\n');
        System.debug('\n\n oldAuditsToUpdate => ' + JSON.serializePretty(oldAuditsToUpdate) + '\n');

        if (!oldAuditsToUpdate.isEmpty()) {
            setToFalseIsLatestField(oldAuditsToUpdate);
            update oldAuditsToUpdate;
        }
    }
    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_Price_Audit__c>> configureAuditsMapByAccId(List<EUR_CRM_Price_Audit__c> latestAuditsWithNew) {
        Map<Id, List<EUR_CRM_Price_Audit__c>> auditsByAccountId = new Map<Id, List<EUR_CRM_Price_Audit__c>>();
        for (EUR_CRM_Price_Audit__c audit : latestAuditsWithNew) {
            if (auditsByAccountId.containsKey(audit.EUR_CRM_Account__c)) {
                auditsByAccountId.get(audit.EUR_CRM_Account__c).add(audit);
            } else {
                auditsByAccountId.put(audit.EUR_CRM_Account__c, new List<EUR_CRM_Price_Audit__c>{
                        audit
                });
            }
        }
        return auditsByAccountId;
    }

    private List<EUR_CRM_Price_Audit__c> setIsLatestForAudits(Map<Id, List<EUR_CRM_Price_Audit__c>>
            auditsByAccId, List<EUR_CRM_Price_Audit__c> newAudits) {
        List<EUR_CRM_Price_Audit__c> result = new List<EUR_CRM_Price_Audit__c>();
        Map<Id, EUR_CRM_Account__c> accountsMap = getAccountsMapByIds(auditsByAccId.keySet());
        for (Id accId : auditsByAccId.keySet()) {
            List<EUR_CRM_Price_Audit__c> audits = auditsByAccId.get(accId);
            if (!audits.isEmpty()) {
                EUR_CRM_Price_Audit__c latestAudit = audits[0];
                for (EUR_CRM_Price_Audit__c audit : audits) {
                    if (needToReplaceLatestAudit(audit, latestAudit, accountsMap)) {
                        latestAudit = audit;
                    }
                }
                if (newAudits.contains(latestAudit)) {
                    latestAudit.EUR_CRM_Is_Latest__c = true;
                    accIdsForChangesOnAudits.add(accId);
                    result.add(latestAudit);
                }
            }
        }
        return result;
    }
    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private void setToFalseIsLatestField(List<EUR_CRM_Price_Audit__c> audits) {
        for (EUR_CRM_Price_Audit__c audit: audits) {
            audit.EUR_CRM_Is_Latest__c = false;
        }
    }
    private Boolean needToReplaceLatestAudit(EUR_CRM_Price_Audit__c currentAudit, EUR_CRM_Price_Audit__c
            latestAudit, Map<Id, EUR_CRM_Account__c> accountsMap) {
        if (IS_LATEST_COUNTRY_CODES.contains(accountsMap.get(currentAudit.EUR_CRM_Account__c).EUR_CRM_Country_Code__c)) {
            return currentAudit.EUR_CRM_Audit_Datetime__c > latestAudit.EUR_CRM_Audit_Datetime__c && currentAudit
                    .EUR_CRM_Status__c == AUDIT_FINISHED_STATUS;
        } else {
            return currentAudit.EUR_CRM_Audit_Datetime__c > latestAudit.EUR_CRM_Audit_Datetime__c;
        }
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Price_Audit__c> getLatsAuditsByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id, EUR_CRM_Is_Latest__c
                        , EUR_CRM_Status__c
                        , EUR_CRM_Audit_Datetime__c
                        , EUR_CRM_Account__c
                FROM EUR_CRM_Price_Audit__c
                WHERE EUR_CRM_Is_Latest__c = TRUE
                AND EUR_CRM_Account__c IN:accIds
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