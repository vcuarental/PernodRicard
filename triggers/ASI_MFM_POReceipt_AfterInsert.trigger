trigger ASI_MFM_POReceipt_AfterInsert on ASI_MFM_PO_Receipt__c (after insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MKTEXP')){
        ASI_MFM_MKTEXP_POReceipt_TriggerClass.routineAfterUpsert(trigger.new, null);   
    }
}