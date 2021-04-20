trigger ASI_CRM_Event_AfterDelete on Event (after delete) {

    list<Event> trigger_old = new list<Event>();
    for(Event e :trigger.old) {
        if(e.recordtypeid != null && Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_'))
            trigger_old.add(e);
    }
    if(trigger_old.size()>0)
        ASI_CRM_CN_Event_TriggerClass.routineAfterDelete(trigger_old);

}