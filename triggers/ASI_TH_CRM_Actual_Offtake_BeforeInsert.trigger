trigger ASI_TH_CRM_Actual_Offtake_BeforeInsert on ASI_TH_CRM_Actual_Offtake__c (before insert){
    if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY')){
            ASI_CRM_MY_ActualOfftake_TriggerCls.routineBeforeUpsert(trigger.New);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG')){
            ASI_CRM_SG_ActualOfftake_TriggerCls.routineBeforeUpsert(trigger.New, null);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM')){
            ASI_CRM_TH_ActualOfftake_TriggerCls.routineBeforeInsert(trigger.New);
        }
    }
}