trigger ASI_CRM_Call_Log_AfterInsert on ASI_CRM_Call_Log__c (after insert) {

    list<ASI_CRM_Call_Log__c> trigger_new = new list<ASI_CRM_Call_Log__c>();
    for(ASI_CRM_Call_Log__c e :trigger.new) {
        if(Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CallLog_CN_'))
            trigger_new.add(e);
    }

    if(trigger_new.size()>0)
        ASI_CRM_CN_Call_Log_TriggerClass.routineAfterInsert(trigger_new);
}