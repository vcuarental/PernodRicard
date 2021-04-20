trigger ASI_TH_CRM_Actual_Offtake_BeforeDelete on ASI_TH_CRM_Actual_Offtake__c (before delete){
    if(trigger.old[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_MY')){
            ASI_CRM_MY_ActualOfftake_TriggerCls.routineBeforeDelete(trigger.old);
        }
    }
}