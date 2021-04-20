trigger ASI_CRM_ActualOfftakeHeader_BeforeInsert on ASI_CRM_ActualOfftakeHeader__c (before insert) {
   if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY')){
            ASI_CRM_MY_ActualOfftakeHead_TriggerCls.routineBeforeInsert(trigger.New);
        }
    }
}