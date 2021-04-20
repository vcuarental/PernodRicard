trigger ASI_MFM_POReceiptItem_BeforeDelete on ASI_MFM_PO_Receipt_Item__c (before delete) {
     if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CN') || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TR') || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_HK')){
        ASI_MFM_CN_POReceiptItem_TriggerClass.routineBeforeDelete(trigger.old);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_JP')){
        ASI_MFM_JP_POReceiptItem_TriggerClass.routineBeforeDelete(trigger.old);  
    }
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_POReceiptItem_TriggerClass.routineBeforeDelete(trigger.old);
    }
}