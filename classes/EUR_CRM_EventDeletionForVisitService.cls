public class EUR_CRM_EventDeletionForVisitService {

    public void deleteRelatedEventsOfVisits(Map<Id, EUR_CRM_Visit__c> oldVisitById) {
        delete this.selectRelatedEvents(oldVisitById.keySet());
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<Event> selectRelatedEvents(Set<Id> visitIds) {
        return [
            SELECT Id
            FROM Event
            WHERE EUR_CRM_Visit__c IN :visitIds
        ];
    }

}