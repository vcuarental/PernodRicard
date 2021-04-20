trigger ASI_CRM_CN_IssueZone_BeforeUpdate_Trigger on ASI_CRM_Issue_Zone__c (before update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
 ASI_CRM_CN_IssueZone_TriggerClass.routineBeforeUpdate(trigger.New,null);
    }  
        }