public with sharing class EUR_CRM_EventCreationForVisitService {

    private final Map<String, String> EVENT_FIELD_BY_VISIT_FIELD = new Map<String, String> {
        'EUR_CRM_Start_Datetime__c' => 'StartDateTime'
    ,   'EUR_CRM_End_Datetime__c' => 'EndDateTime'
    ,   'OwnerId' => 'OwnerId'
    ,   'EUR_CRM_Account__c' => 'WhatId'
    ,   'Id' => 'EUR_CRM_Visit__c'
    ,   'EUR_CRM_Customer_Response__c' => 'PR_Customer_Response__c'
    ,   'EUR_CRM_Account_Name__c' => 'Subject'
            
    };

    private final Set<String> VISIT_FIELDS_TO_MIRROR_ON_UPDATE = new Set<String> {
        'EUR_CRM_Start_Datetime__c'
    ,   'EUR_CRM_End_Datetime__c'    
    };

    public void createStandardEvents(List<EUR_CRM_Visit__c> insertedVisits) {
        List<EUR_CRM_Visit__c> validVisits = this.extractValidVisits(insertedVisits);
        System.debug('\n\n validVisits.size() => ' + JSON.serializePretty(validVisits.size()) + '\n');
        System.debug('\n\n validVisits => ' + JSON.serializePretty(validVisits) + '\n');
        if (validVisits.isEmpty()) { return ; }

        List<Event> eventsToInsert = this.makeEvents(validVisits);
        System.debug('\n\n eventsToInsert.size() => ' + JSON.serializePretty(eventsToInsert.size()) + '\n');
        System.debug('\n\n eventsToInsert => ' + JSON.serializePretty(eventsToInsert) + '\n');

        //insert without sharing for recoverySync
        EUR_CRM_RecoverySyncWrapper.insertEventsWithoutSharing(eventsToInsert);
    }

    public void updateStandardEvents(List<EUR_CRM_Visit__c> updatedVisits, Map<Id, EUR_CRM_Visit__c> oldVisitById) {
        List<EUR_CRM_Visit__c> updatedValidVisits = this.extractUpdatedValidVisits(updatedVisits, oldVisitById);
        System.debug('\n\n updatedValidVisits.size() => ' + JSON.serializePretty(updatedValidVisits.size()) + '\n');
        System.debug('\n\n updatedValidVisits => ' + JSON.serializePretty(updatedValidVisits) + '\n');
        if (updatedValidVisits.isEmpty()) { return ; }

        Map<Id, List<Event>> eventsByVisitId = this.getEventsByVisitId(new Map<Id, EUR_CRM_Visit__c>(updatedValidVisits).keySet());
        System.debug('\n\n eventsByVisitId.size() => ' + JSON.serializePretty(eventsByVisitId.size()) + '\n');
        System.debug('\n\n eventsByVisitId => ' + JSON.serializePretty(eventsByVisitId) + '\n');
        if (eventsByVisitId.isEmpty()) { return ; }

        List<Event> eventsToUpdate = this.getUpdatedEvents(updatedValidVisits, eventsByVisitId);
        System.debug('\n\n eventsToUpdate.size() => ' + JSON.serializePretty(eventsToUpdate.size()) + '\n');
        System.debug('\n\n eventsToUpdate => ' + JSON.serializePretty(eventsToUpdate) + '\n');
        update eventsToUpdate;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Visit__c> extractValidVisits(List<EUR_CRM_Visit__c> visits) {
        Set<String> rolloutedCountries = this.getRolloutedCountries();
        System.debug('\n\n rolloutedCountries.size() => ' + JSON.serializePretty(rolloutedCountries.size()) + '\n');
        System.debug('\n\n rolloutedCountries => ' + JSON.serializePretty(rolloutedCountries) + '\n');
        if (rolloutedCountries.isEmpty()) { return new List<EUR_CRM_Visit__c>(); }

        List<EUR_CRM_Visit__c> validVisits = new List<EUR_CRM_Visit__c>();
        for (EUR_CRM_Visit__c visit : visits) {
            if (this.isValidVisit(visit, rolloutedCountries)) {
                validVisits.add(visit);
            }
        }
        return validVisits;
    }

    private List<EUR_CRM_Visit__c> extractUpdatedValidVisits(List<EUR_CRM_Visit__c> visits, Map<Id, EUR_CRM_Visit__c> oldVisitById) {
        List<EUR_CRM_Visit__c> updatedVisits = this.extractUpdatedVisits(visits, oldVisitById);
        System.debug('\n\n updatedVisits.size() => ' + JSON.serializePretty(updatedVisits.size()) + '\n');
        System.debug('\n\n updatedVisits => ' + JSON.serializePretty(updatedVisits) + '\n');
        if (updatedVisits.isEmpty()) { return new List<EUR_CRM_Visit__c>(); }

        return this.extractValidVisits(updatedVisits);
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<String> getRolloutedCountries() {
        List<EUR_CRM_Rollout_Country__mdt> rolloutCountries = this.selectRolloutCountries();
        System.debug('\n\n rolloutCountries.size() => ' + JSON.serializePretty(rolloutCountries.size()) + '\n');
        System.debug('\n\n rolloutCountries => ' + JSON.serializePretty(rolloutCountries) + '\n');
        if (rolloutCountries.isEmpty()) { return new Set<String>(); }

        Set<String> rolloutedCountries = new Set<String>();
        for (EUR_CRM_Rollout_Country__mdt rolloutCountry : rolloutCountries) {
            rolloutedCountries.add(rolloutCountry.DeveloperName);
        }
        return rolloutedCountries;
    }

    private List<EUR_CRM_Visit__c> extractUpdatedVisits(List<EUR_CRM_Visit__c> visits, Map<Id, EUR_CRM_Visit__c> oldVisitById) {
        List<EUR_CRM_Visit__c> updatedVisits = new List<EUR_CRM_Visit__c>();
        for (EUR_CRM_Visit__c visit : visits) {
            if (this.isUpdatedVisit(visit, oldVisitById)) {
                updatedVisits.add(visit);
            }
        }
        return updatedVisits;
    }

    private Map<Id, List<Event>> getEventsByVisitId(Set<Id> visitIds) {
        List<Event> events = this.selectEventsWhereVisitIdsIn(visitIds);
        System.debug('\n\n events.size() => ' + JSON.serializePretty(events.size()) + '\n');
        System.debug('\n\n events => ' + JSON.serializePretty(events) + '\n');
        if (events.isEmpty()) { return new Map<Id, List<Event>>(); }

        Map<Id, List<Event>> eventsByVisitId = new Map<Id, List<Event>>();
        for (Event ev : events) {
            if (eventsByVisitId.containsKey(ev.EUR_CRM_Visit__c)) {
                eventsByVisitId.get(ev.EUR_CRM_Visit__c).add(ev);
            } else {
                eventsByVisitId.put(ev.EUR_CRM_Visit__c, new List<Event> { ev });
            }
        }
        return eventsByVisitId;
    }

    private List<Event> getUpdatedEvents(List<EUR_CRM_Visit__c> visits, Map<Id, List<Event>> eventsByVisitId) {
        List<Event> updatedEvents = new List<Event>();
        for (EUR_CRM_Visit__c visit : visits) {
            if ( ! eventsByVisitId.containsKey(visit.Id)) { continue; }

            for (Event ev : eventsByVisitId.get(visit.Id)) {
                for (String visitField : VISIT_FIELDS_TO_MIRROR_ON_UPDATE) {
                    ev.put(EVENT_FIELD_BY_VISIT_FIELD.get(visitField), visit.get(visitField));
                }
                updatedEvents.add(ev);
            }
        }
        return updatedEvents;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isValidVisit(EUR_CRM_Visit__c visit, Set<String> rolloutedCountries) {
        return rolloutedCountries.contains(visit.EUR_CRM_Country_Code__c)
            && visit.EUR_CRM_Account__c != null
            && visit.EUR_CRM_Start_Datetime__c != null
            && visit.EUR_CRM_End_Datetime__c != null
        ;
    }

    private Boolean isUpdatedVisit(EUR_CRM_Visit__c visit, Map<Id, EUR_CRM_Visit__c> oldVisitById) {
        for (String fieldAPI : VISIT_FIELDS_TO_MIRROR_ON_UPDATE) {
            if (visit.get(fieldAPI) != oldVisitById.get(visit.Id).get(fieldAPI)) {
                return true;
            }
        }
        return false;
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private List<Event> makeEvents(List<EUR_CRM_Visit__c> visits) {
        List<Event> events = new List<Event>();
        for (EUR_CRM_Visit__c visit : visits) {
            events.add(this.makeEvent(visit));
        }
        return events;
    }

    private Event makeEvent(EUR_CRM_Visit__c visit) {
//        return new Event(
//            StartDateTime = visit.EUR_CRM_Start_Datetime__c
//        ,   EndDateTime = visit.EUR_CRM_End_Datetime__c
//        ,   OwnerId = visit.OwnerId
//        ,   WhatId = visit.EUR_CRM_Account__c
//        ,   EUR_CRM_Visit__c = visit.Id
//        ,   PR_Customer_Response__c = visit.EUR_CRM_Customer_Response__c
//        );
        Event ev = new Event();
        for (String visitField : EVENT_FIELD_BY_VISIT_FIELD.keySet()) {
            String eventField = EVENT_FIELD_BY_VISIT_FIELD.get(visitField);
            ev.put(eventField, visit.get(visitField));
        }
        return ev;
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private List<EUR_CRM_Rollout_Country__mdt> selectRolloutCountries() {
        return [
            SELECT Id
            ,   DeveloperName
            FROM EUR_CRM_Rollout_Country__mdt
            WHERE EUR_CRM_IsRolloutCompleted__c = TRUE
        ];
    }

    private List<Event> selectEventsWhereVisitIdsIn(Set<Id> visitIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Visit__c
            FROM Event
            WHERE EUR_CRM_Visit__c IN :visitIds
        ];
    }

}