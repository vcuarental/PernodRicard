/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

public with sharing class EUR_CRM_Visit_IsLatest_Service {
    private Set<Id> accIds = new Set<Id>();
    private Set<Id> accIdsForChangesOnVisits = new Set<Id>();
    @TestVisible
    private static final String VISIT_FINISHED_STATUS = 'Finished';
    /* ========================================================= */
    /*     Interface (Is_Latest Logic)
    /* ========================================================= */
    public void handleIsLatestFieldOnVisits(List<EUR_CRM_Visit__c> newVisits) {
        System.debug('\n\n New Visits size => ' + JSON.serializePretty(newVisits.size()) + '\n');
        System.debug('\n\n New Visits => ' + JSON.serializePretty(newVisits) + '\n');
        this.configureAccountIdsSet(newVisits);
        this.changeIsLatestOnVisits(newVisits);
    }
    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void configureAccountIdsSet(List<EUR_CRM_Visit__c> newVisits) {
        for (EUR_CRM_Visit__c visit : newVisits) {
            accIds.add(visit.EUR_CRM_Account__c);
        }
    }

    private void changeIsLatestOnVisits(List<EUR_CRM_Visit__c> newVisits) {
        List<EUR_CRM_Visit__c> latestVisitsWithNew = this.getLatsVisitsByAccountIds(accIds);
        latestVisitsWithNew.addAll(newVisits);
        System.debug('\n\n latestVisitsWithNew size => ' + JSON.serializePretty(latestVisitsWithNew.size()) + '\n');

        Map<Id, List<EUR_CRM_Visit__c>> visitsByAccountId = this.configureVisitsMapByAccId(latestVisitsWithNew);

        newVisits = setIsLatestForVisits(visitsByAccountId, newVisits);

        System.debug('\n\n accIdsForSelection => ' + JSON.serializePretty(accIdsForChangesOnVisits) + '\n');
        System.debug('\n\n newVisits => ' + JSON.serializePretty(newVisits) + '\n');

        List<EUR_CRM_Visit__c> oldVisitsToUpdate = this.getLatsVisitsByAccountIds(accIdsForChangesOnVisits);
        System.debug('\n\n oldVisitsToUpdate size => ' + JSON.serializePretty(oldVisitsToUpdate.size()) + '\n');
        System.debug('\n\n oldVisitsToUpdate => ' + JSON.serializePretty(oldVisitsToUpdate) + '\n');

        if (!oldVisitsToUpdate.isEmpty()) {
            setToFalseIsLatestField(oldVisitsToUpdate);
            update oldVisitsToUpdate;
        }
    }
    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_Visit__c>> configureVisitsMapByAccId(List<EUR_CRM_Visit__c> latestVisitsWithNew) {
        Map<Id, List<EUR_CRM_Visit__c>> visitsByAccountId = new Map<Id, List<EUR_CRM_Visit__c>>();
        for (EUR_CRM_Visit__c visit : latestVisitsWithNew) {
            if (visitsByAccountId.containsKey(visit.EUR_CRM_Account__c)) {
                visitsByAccountId.get(visit.EUR_CRM_Account__c).add(visit);
            } else {
                visitsByAccountId.put(visit.EUR_CRM_Account__c, new List<EUR_CRM_Visit__c>{
                        visit
                });
            }
        }
        return visitsByAccountId;
    }

    private List<EUR_CRM_Visit__c> setIsLatestForVisits(Map<Id, List<EUR_CRM_Visit__c>>
            visitsByAccId, List<EUR_CRM_Visit__c> newVisits) {
        List<EUR_CRM_Visit__c> result = new List<EUR_CRM_Visit__c>();

        for (Id accId : visitsByAccId.keySet()) {
            List<EUR_CRM_Visit__c> visits = visitsByAccId.get(accId);
            if (!visits.isEmpty()) {
                EUR_CRM_Visit__c latestVisit = visits[0];
                for (EUR_CRM_Visit__c visit : visits) {
                    if (visit.EUR_CRM_Start_Datetime__c > latestVisit.EUR_CRM_Start_Datetime__c) {
                        latestVisit = visit;
                    }
                }
                if (newVisits.contains(latestVisit) && latestVisit.EUR_CRM_Status__c == VISIT_FINISHED_STATUS) {
                    latestVisit.EUR_CRM_Is_Latest__c = true;
                    accIdsForChangesOnVisits.add(accId);
                    result.add(latestVisit);
                }
            }
        }
        return result;
    }

    private void setToFalseIsLatestField(List<EUR_CRM_Visit__c> visits) {
        for (EUR_CRM_Visit__c visit: visits) {
            visit.EUR_CRM_Is_Latest__c = false;
        }
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Visit__c> getLatsVisitsByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id, EUR_CRM_Is_Latest__c
                        , EUR_CRM_Status__c
                        , EUR_CRM_Start_Datetime__c
                        , EUR_CRM_Account__c
                FROM EUR_CRM_Visit__c
                WHERE EUR_CRM_Is_Latest__c = TRUE
                AND EUR_CRM_Account__c IN:accIds
        ];
    }
}