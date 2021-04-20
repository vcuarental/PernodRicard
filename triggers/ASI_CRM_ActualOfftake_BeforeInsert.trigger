trigger ASI_CRM_ActualOfftake_BeforeInsert on ASI_TH_CRM_Actual_Offtake__c (before insert) {
    if (trigger.new[0].recordtypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_PH_Actual_Offtake')) ){
         ASI_CRM_PH_ActualOfftake_TriggerCls.routineBeforeUpsert(trigger.new, null);
    }
}