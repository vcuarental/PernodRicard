trigger ASI_CRM_CN_Contract_BRSF_Line_Item_AfterDelete on ASI_CRM_CN_Contract_BRSF_Line_Item__c (after delete) {
    // Added by Michael Yip (Introv) 03Jul2014 for CRM CN
    if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_Contract_BRSF_TriggerClass.routineAfterDelete(trigger.old);
    }
}