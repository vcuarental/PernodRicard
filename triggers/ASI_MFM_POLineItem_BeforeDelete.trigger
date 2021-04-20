trigger ASI_MFM_POLineItem_BeforeDelete on ASI_MFM_PO_Line_Item__c (before delete) {
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
            ASI_MFM_SG_POLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
            ASI_MFM_TR_POLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if ( Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SC')){
        ASI_MFM_SC_POLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_POLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_POLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (trigger.old[0].RecordTypeId != null 
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG')
        // Added by Hugo Cheung (Laputa) 05May2016
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
        ASI_MFM_POLineItem_TriggerClass.routineBeforeDelete(trigger.old);
        }
}