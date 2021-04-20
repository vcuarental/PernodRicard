trigger ASI_CRM_CN_Contract_BRSF_Line_Item_AfterUpdate on ASI_CRM_CN_Contract_BRSF_Line_Item__c (after update) {
    // Added by Michael Yip (Introv) 03Jul2014 for CRM CN
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_Contract_BRSF_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
    }
}