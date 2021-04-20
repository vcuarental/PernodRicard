trigger ASI_CRM_Pros_Segmentation_AfterInsert on ASI_CRM_Pros_Segmentation__c (after insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TH')){
        ASI_CRM_TH_ProsSeg_TriggerClass.routineAfterAll1(trigger.new, trigger.oldMap);
        ASI_CRM_TH_ProsSeg_TriggerClass.routineAfterAll2(trigger.new, trigger.oldMap); 
    } 
}