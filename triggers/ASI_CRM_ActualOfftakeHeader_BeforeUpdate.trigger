trigger ASI_CRM_ActualOfftakeHeader_BeforeUpdate on ASI_CRM_ActualOfftakeHeader__c (Before update) {
    if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TH')){
            ASI_CRM_TH_ActualOfftakeHead_TriggerCls.routineBeforeUpdate(trigger.New);
        }

    }


}