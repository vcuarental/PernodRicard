trigger ASI_MFM_Event_BeforeUpdate on ASI_MFM_Event__c (before update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_Event_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }  
}