trigger ASI_CRM_CN_AntiBribery_BeforeDelete on ASI_CRM_Anti_Bribery__c (Before Delete)
{
    if(trigger.old[0].RecordTypeId != null && 
       (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_CN')))
    {
        ASI_CRM_CN_AntiBriberyTriggerClass.routineBeforeDelete(trigger.old);
    }
}