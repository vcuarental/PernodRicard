/**
 * Created by larsz on 06.11.2020.
 */

public with sharing class EUR_CRM_VisitRecommendedService {
    private static final String VISIT_FINISHED_STATUS = 'Finished';
    private Map<Id, EUR_CRM_Account__c> recommendedAccounts;

    public void handleRecommendationSuccess(List<EUR_CRM_Visit__c> newVisits, Map<Id,SObject> oldVisitMap) {
        List<EUR_CRM_Visit__c> finishedVisits = getFinishedVisits(newVisits, (Map<Id, EUR_CRM_Visit__c>) oldVisitMap);
        System.debug('\n\n finishedVisits.size() => ' + JSON.serializePretty(finishedVisits.size()) + '\n');
        System.debug('\n\n finishedVisits => ' + JSON.serializePretty(finishedVisits) + '\n');
        if (finishedVisits.isEmpty()) return;

        recommendedAccounts = getRecommendedAccMap();
        System.debug('\n\n recommendedAccounts.size() => ' + JSON.serializePretty(recommendedAccounts.size()) + '\n');
        System.debug('\n\n recommendedAccounts => ' + JSON.serializePretty(recommendedAccounts) + '\n');
        for (EUR_CRM_Visit__c finishedVisit: finishedVisits) {
            if (recommendedAccounts.keySet().contains(finishedVisit.EUR_CRM_Account__c)) {
                finishedVisit.EUR_CRM_IsRecommendationSuccessful__c = true;
                System.debug('\n\n successful recommend visit => ' + JSON.serializePretty(finishedVisit) + '\n');
            }
        }

    }

    private List<EUR_CRM_Visit__c> getFinishedVisits(List<EUR_CRM_Visit__c> newVisits, Map<Id,EUR_CRM_Visit__c>
            oldVisitMap) {
        List<EUR_CRM_Visit__c> result = new List<EUR_CRM_Visit__c>();
        if (oldVisitMap == null) {
            for (EUR_CRM_Visit__c visit: newVisits) {
                if (visit.EUR_CRM_Status__c == VISIT_FINISHED_STATUS) {
                    result.add(visit);
                }
            }
        } else {
            for (EUR_CRM_Visit__c visit: newVisits) {
                if (visit.EUR_CRM_Status__c == VISIT_FINISHED_STATUS && oldVisitMap.get(visit.Id).EUR_CRM_Status__c
                        != VISIT_FINISHED_STATUS) {
                    result.add(visit);
                }
            }
        }
        return result;
    }

    private Map<Id, EUR_CRM_Account__c> getRecommendedAccMap() {
        return new Map<Id, EUR_CRM_Account__c>([
                SELECT Id, EUR_CRM_IsRecommended__c
                FROM EUR_CRM_Account__c
                WHERE EUR_CRM_IsRecommended__c = TRUE
                LIMIT 50000
        ]);
    }
}