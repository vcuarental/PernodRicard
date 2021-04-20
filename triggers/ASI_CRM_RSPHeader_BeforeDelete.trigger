trigger ASI_CRM_RSPHeader_BeforeDelete on ASI_CRM_RSPHeader__c (before delete) {
    if(trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader')) {
        ASI_CRM_RSPHeader_TriggerClass.routineBeforeDelete(trigger.old);
    }
}