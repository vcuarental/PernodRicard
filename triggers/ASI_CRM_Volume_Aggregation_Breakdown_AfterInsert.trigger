trigger ASI_CRM_Volume_Aggregation_Breakdown_AfterInsert on ASI_CRM_Volume_Aggregation_Breakdown__c (after insert) {
    if (Trigger.new[0].RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Volume_Aggregation_Breakdown__cASI_CRM_CN_HCO_Outlets_Affected_by_Volume_Changes')) {
        ASI_CRM_Volume_Aggregation_TriggerClass.recalculateFI(Trigger.new);
    }
}