/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

public with sharing class EUR_CRM_ContractAuditIsLatestService {
    private Set<Id> contractIds = new Set<Id>();
    private Set<Id> contractIdsForChangesOnAudits = new Set<Id>();
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
    public void handleIsLatestFieldOnContractAudits(List<EUR_CRM_Contract_Audit__c> newContAudits) {
        System.debug('\n\n newContAudits size => ' + JSON.serializePretty(newContAudits.size()) + '\n');
        System.debug('\n\n newContAudits => ' + JSON.serializePretty(newContAudits) + '\n');
        this.configureContractIdsSet(newContAudits);
        this.changeIsLatestOnAudits(newContAudits);
    }
    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void configureContractIdsSet(List<EUR_CRM_Contract_Audit__c> newContrAudits) {
        for (EUR_CRM_Contract_Audit__c audit : newContrAudits) {
            contractIds.add(audit.EUR_CRM_Contract__c);
        }
    }
    private void changeIsLatestOnAudits(List<EUR_CRM_Contract_Audit__c> newAudits) {
        List<EUR_CRM_Contract_Audit__c> latestAuditsWithNew = this.getLatsAuditsByContractIds(contractIds);
        latestAuditsWithNew.addAll(newAudits);
        System.debug('\n\n latestAuditsWithNew size => ' + JSON.serializePretty(latestAuditsWithNew.size()) + '\n');

        Map<Id, List<EUR_CRM_Contract_Audit__c>> auditsByContractId = this.configureAuditsMapByContractId(latestAuditsWithNew);

        newAudits = setIsLatestForAudits(auditsByContractId, newAudits);

        System.debug('\n\n contractIdsForSelection => ' + JSON.serializePretty(contractIdsForChangesOnAudits) + '\n');
        System.debug('\n\n newAudits => ' + JSON.serializePretty(newAudits) + '\n');

        List<EUR_CRM_Contract_Audit__c> oldAuditsToUpdate = this.getLatsAuditsByContractIds(contractIdsForChangesOnAudits);
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
    private Map<Id, List<EUR_CRM_Contract_Audit__c>> configureAuditsMapByContractId(List<EUR_CRM_Contract_Audit__c> latestAuditsWithNew) {
        Map<Id, List<EUR_CRM_Contract_Audit__c>> auditsByContId = new Map<Id, List<EUR_CRM_Contract_Audit__c>>();
        for (EUR_CRM_Contract_Audit__c audit : latestAuditsWithNew) {
            if (auditsByContId.containsKey(audit.EUR_CRM_Contract__c)) {
                auditsByContId.get(audit.EUR_CRM_Contract__c).add(audit);
            } else {
                auditsByContId.put(audit.EUR_CRM_Contract__c, new List<EUR_CRM_Contract_Audit__c>{
                        audit
                });
            }
        }
        return auditsByContId;
    }
    private List<EUR_CRM_Contract_Audit__c> setIsLatestForAudits(Map<Id, List<EUR_CRM_Contract_Audit__c>>
            auditsByContrId, List<EUR_CRM_Contract_Audit__c> newAudits) {
        List<EUR_CRM_Contract_Audit__c> result = new List<EUR_CRM_Contract_Audit__c>();
        Map<Id, EUR_CRM_Contract__c> contractsMap = getContractsMapByIds(auditsByContrId.keySet());
        for (Id contractId : auditsByContrId.keySet()) {
            List<EUR_CRM_Contract_Audit__c> audits = auditsByContrId.get(contractId);
            if (!audits.isEmpty()) {
                EUR_CRM_Contract_Audit__c latestAudit = audits[0];
                for (EUR_CRM_Contract_Audit__c audit : audits) {
                    if (needToReplaceLatestAudit(audit, latestAudit, contractsMap)) {
                        latestAudit = audit;
                    }
                }
                if (newAudits.contains(latestAudit)) {
                    latestAudit.EUR_CRM_Is_Latest__c = true;
                    contractIdsForChangesOnAudits.add(contractId);
                    result.add(latestAudit);
                }
            }
        }
        return result;
    }
    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private void setToFalseIsLatestField(List<EUR_CRM_Contract_Audit__c> audits) {
        for (EUR_CRM_Contract_Audit__c audit : audits) {
            audit.EUR_CRM_Is_Latest__c = false;
        }
    }
    private Boolean needToReplaceLatestAudit(EUR_CRM_Contract_Audit__c currentAudit, EUR_CRM_Contract_Audit__c
            latestAudit, Map<Id, EUR_CRM_Contract__c> contractsMap) {
        if (IS_LATEST_COUNTRY_CODES.contains(contractsMap.get(currentAudit.EUR_CRM_Contract__c).EUR_CRM_Country_Code__c)) {
            return currentAudit.EUR_CRM_Audit_Datetime__c > latestAudit.EUR_CRM_Audit_Datetime__c && currentAudit
                    .EUR_CRM_Status__c == AUDIT_FINISHED_STATUS;
        } else {
            return currentAudit.EUR_CRM_Audit_Datetime__c > latestAudit.EUR_CRM_Audit_Datetime__c;
        }
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Contract_Audit__c> getLatsAuditsByContractIds(Set<Id> contractIds) {
        return [
                SELECT Id, EUR_CRM_Is_Latest__c
                        , EUR_CRM_Status__c
                        , EUR_CRM_Audit_Datetime__c
                        , EUR_CRM_Contract__c
                FROM EUR_CRM_Contract_Audit__c
                WHERE EUR_CRM_Is_Latest__c = TRUE
                AND EUR_CRM_Contract__c IN:contractIds
        ];
    }
    private Map<Id, EUR_CRM_Contract__c> getContractsMapByIds(Set<Id> ids) {
        return new Map<Id, EUR_CRM_Contract__c>([
                SELECT Id, EUR_CRM_Country_Code__c
                FROM EUR_CRM_Contract__c
                WHERE Id IN :ids
        ]);
    }
}