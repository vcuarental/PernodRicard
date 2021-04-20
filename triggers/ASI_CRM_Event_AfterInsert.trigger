trigger ASI_CRM_Event_AfterInsert on Event (after insert) {

    list<Event> trigger_new = new list<Event>();
    for(Event e :trigger.new) {
        if(e.recordtypeid != null && Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_'))
            trigger_new.add(e);
    }
    if(trigger_new.size()>0)
        ASI_CRM_CN_Event_TriggerClass.routineAfterInsert(trigger_new);
        
}