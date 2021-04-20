trigger ASI_MFM_Budget_BeforeInsert on ASI_MFM_Budget__c (before insert) {

    // Call Trigger Only For CAPEX/OPEX Budget
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_CAP_Budget_TriggerClass.routineBeforeInsert(Trigger.New);  
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_Budget_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }

}