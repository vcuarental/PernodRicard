trigger ASI_MFM_PO_BeforeDelete on ASI_MFM_PO__c (before delete) {
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        // Added by 2018-03-26 Linus@introv
        ASI_MFM_GF_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-03-15 Linus@introv
        ASI_MFM_SG_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-04-30 Linus@introv
        ASI_MFM_TR_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (!Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP') 
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('SG')
        // Added by Hugo Cheung (Laputa) 05May2016
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('HK')
        //20170207 Elufa
        && !Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost')
       ){
        ASI_MFM_CAP_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }
  if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SC') ){
        ASI_MFM_SC_PO_TriggerClass.routineBeforeDelete(trigger.old);
    }

}