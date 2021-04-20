public class EUR_CRM_VisitSyncWithEventService {

    public void updatePatentVisits(List<Event> updatedEvents, Map<Id, Event> oldEventById) {
        List<Event> eventsToSyncWithVisits = this.extractEventsToSyncWithVisits(updatedEvents, oldEventById);
        System.debug('\n\n eventsToSyncWithVisits.size() => ' + JSON.serializePretty(eventsToSyncWithVisits.size()) + '\n');
        System.debug('\n\n eventsToSyncWithVisits => ' + JSON.serializePretty(eventsToSyncWithVisits) + '\n');
        if (eventsToSyncWithVisits.isEmpty()) { return ; }

        this.updateFieldsOnVisits(eventsToSyncWithVisits);
    }


    /* ========================================================= */
    /*     Delegate methods
    /* ========================================================= */
    private void updateFieldsOnVisits(List<Event> events) {
        Set<Id> parentVisitIds = this.extractParentVisitIds(events);
        Map<Id, EUR_CRM_Visit__c> parentVisits = this.selectParentVisitById(parentVisitIds);

        for (Event evt : events) {
            this.syncEventWithParentVisit(evt, parentVisits.get(evt.EUR_CRM_Visit__c));
        }

        update parentVisits.values();
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private List<Event> extractEventsToSyncWithVisits(List<Event> events, Map<Id, Event> oldEventById) {
        List<Event> eventsToSyncWithVisits = new List<Event>();
        for (Event evt : events) {
            if (evt.EUR_CRM_Visit__c != null && this.isCustomerResponseUpdated(evt, oldEventById)) {
                eventsToSyncWithVisits.add(evt);
            }
        }
        return eventsToSyncWithVisits;
    }

    private Set<Id> extractParentVisitIds(List<Event> events) {
        Set<Id> parentVisitIds = new Set<Id>();
        for (Event evt : events) {
            parentVisitIds.add(evt.EUR_CRM_Visit__c);
        }
        return parentVisitIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isCustomerResponseUpdated(Event evt, Map<Id, Event> oldEventById) {
        return evt.PR_Customer_Response__c != oldEventById.get(evt.Id).PR_Customer_Response__c;
    }

    private void syncEventWithParentVisit(Event evt, EUR_CRM_Visit__c visit) {
        visit.EUR_CRM_Customer_Response__c = evt.PR_Customer_Response__c;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private Map<Id, EUR_CRM_Visit__c> selectParentVisitById(Set<Id> visitIds) {
        return new Map<Id, EUR_CRM_Visit__c>([
            SELECT Id
            FROM EUR_CRM_Visit__c
            WHERE Id IN :visitIds
        ]);
    }

}