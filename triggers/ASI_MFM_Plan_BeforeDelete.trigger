trigger ASI_MFM_Plan_BeforeDelete on ASI_MFM_Plan__c (before delete) {    
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_CAP_Plan_TriggerClass.routineBeforeDelete(trigger.old);  
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-03-15 Linus@introv
        ASI_MFM_SG_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-05-30 Linus@introv
        ASI_MFM_TR_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        // [SH] 2018-11-26
        ASI_MFM_TW_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        // Added for PH 2018-06-12 Linus@introv
        ASI_MFM_PH_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        // Added for VN 2019-02-13 Calvin@Laputa
        ASI_MFM_VN_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_RM')){
        // Added by 2018-07-26 Linus@introv
        ASI_MFM_RM_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SC')){
        ASI_MFM_SC_Plan_TriggerClass.routineBeforeDelete(trigger.old);  
    }else{
        ASI_MFM_Plan_TriggerClass.routineBeforeDelete(trigger.old);
    }
}