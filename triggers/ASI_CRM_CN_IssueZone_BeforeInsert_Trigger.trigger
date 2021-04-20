trigger ASI_CRM_CN_IssueZone_BeforeInsert_Trigger on ASI_CRM_Issue_Zone__c (before insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_IssueZone_TriggerClass.routineBeforeInsert(trigger.New,null);
    }
}