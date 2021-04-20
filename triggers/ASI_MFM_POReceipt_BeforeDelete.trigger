trigger ASI_MFM_POReceipt_BeforeDelete on ASI_MFM_PO_Receipt__c (before delete) {
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_POReceipt_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_POReceipt_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_JP')){
        ASI_MFM_POReceipt_TriggerClass.routineBeforeDelete(trigger.old);
    }
}