public class EUR_CRM_EventTriggerHandler extends EUR_CRM_TriggerHandler {

    private final String EMEA_PREFIX = 'EUR_';

    override protected void afterUpdate() {
        List<Event> emeaEvents = this.extractEvents(Trigger.new);
        if (emeaEvents.isEmpty()) { return ; }
        Map<Id, Event> emeaOldEventById = extractOldEventById((Map<Id, Event>)Trigger.oldMap, emeaEvents);

        new EUR_CRM_VisitSyncWithEventService().updatePatentVisits(emeaEvents, emeaOldEventById);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private List<Event> extractEvents(List<Event> events) {
        List<Event> emeaEvents = new List<Event>();
        Map<Id, RecordTypeInfo> recordTypeInfoByRTID = Schema.SObjectType.Event.getRecordTypeInfosById();
        for (Event ev : events) {
            if (this.isEMEART(recordTypeInfoByRTID, ev)) {
                emeaEvents.add(ev);
            }
        }
        return emeaEvents;
    }

    private Map<Id, Event> extractOldEventById(Map<Id, Event> oldEventById, List<Event> emeaEvents) {
        Map<Id, Event> emeaOldEventById = new Map<Id, Event>();
        for (Event ev : emeaEvents) {
            emeaOldEventById.put(ev.Id, oldEventById.get(ev.Id));
        }
        return emeaOldEventById;
    }


    /* ========================================================= */
    /*     Boolean validators
    /* ========================================================= */
    private Boolean isEMEART(Map<Id, RecordTypeInfo> recordTypeInfoByRTID, Event ev) {
        return ev.RecordTypeId != null
            && recordTypeInfoByRTID.containsKey(ev.RecordTypeId)
            && recordTypeInfoByRTID.get(ev.RecordTypeId).getDeveloperName().startsWith(EMEA_PREFIX);
    }
}