trigger EUR_CRM_Event_BeforeInsert on Event (before insert) {
    
    List<Event> triggerNewEUR = new List<Event>();
    for(Event eventPP : Trigger.new){
        if(eventPP.RecordTypeId != null && Global_RecordTypeCache.getRt(eventPP.RecordTypeId).developerName.startsWith('EUR_')){
            triggerNewEUR.add(eventPP);
        }
    }
    
    if(triggerNewEUR.size()>0)  {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
            new EUR_CRM_EventAccountHandler()  
        };
        for(EUR_CRM_TriggerAbstract triggerClass: triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
        }
    }
}