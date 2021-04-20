trigger ASI_CRM_Call_Log_AfterUpdate on ASI_CRM_Call_Log__c (after update) {
    
    list<ASI_CRM_Call_Log__c> trigger_new = new list<ASI_CRM_Call_Log__c>();
    map<Id, ASI_CRM_Call_Log__c> trigger_oldMap = new map<Id, ASI_CRM_Call_Log__c>();
    for(ASI_CRM_Call_Log__c e :trigger.new) {
        if(Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CallLog_CN_')) {
            trigger_new.add(e);
            trigger_oldMap.put(e.Id, trigger.oldMap.get(e.Id));
        }
    }
    
    if(trigger_new.size()>0) 
        ASI_CRM_CN_Call_Log_TriggerClass.routineAfterUpdate(trigger_new, trigger_oldMap);
}