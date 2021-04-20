trigger ASI_CRM_Event_AfterUpdate on Event (after update) {

    list<Event> trigger_new = new list<Event>();
    map<Id, Event> trigger_oldMap = new map<Id, Event>();
    for(Event e :trigger.new) {
        if(e.recordtypeid != null && Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_')) {
            trigger_new.add(e);
            trigger_oldMap.put(e.Id, trigger.oldMap.get(e.Id));
        }
    }
    if(trigger_new.size()>0)
        ASI_CRM_CN_Event_TriggerClass.routineAfterUpdate(trigger_new, trigger_oldMap);        

}