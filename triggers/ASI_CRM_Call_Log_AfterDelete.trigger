trigger ASI_CRM_Call_Log_AfterDelete on ASI_CRM_Call_Log__c (after delete) {

    list<ASI_CRM_Call_Log__c> trigger_old = new list<ASI_CRM_Call_Log__c>();
    for(ASI_CRM_Call_Log__c e :trigger.old) {
        if(e.recordtypeid != null && Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CallLog_CN_'))
            trigger_old.add(e);
    }
    if(trigger_old.size()>0)
        ASI_CRM_CN_Call_Log_TriggerClass.routineAfterDelete(trigger_old);
    
}