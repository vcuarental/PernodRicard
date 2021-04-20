trigger ASI_CRM_Contact_BeforeInsert on Contact (before insert) {
    
    if(trigger.new[0].recordTypeid != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY')){
        ASI_CRM_MY_Contact_TriggerClass.routineBeforeInsert(trigger.New);
    }
}