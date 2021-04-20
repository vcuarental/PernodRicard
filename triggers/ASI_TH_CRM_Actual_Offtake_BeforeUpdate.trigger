trigger ASI_TH_CRM_Actual_Offtake_BeforeUpdate on ASI_TH_CRM_Actual_Offtake__c (before update){
    if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY')){
            ASI_CRM_MY_ActualOfftake_TriggerCls.routineBeforeUpsert(trigger.New);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG')){
            ASI_CRM_SG_ActualOfftake_TriggerCls.routineBeforeUpsert(trigger.New, trigger.oldMap);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM')){
            ASI_CRM_TH_ActualOfftake_TriggerCls.routineBeforeUpdate(trigger.New, trigger.oldMap);
        }
    }
}