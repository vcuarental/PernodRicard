trigger ASI_MFM_PO_AfterDelete on ASI_MFM_PO__c (after delete) {
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PO_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }
    else if (!Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_PO_TriggerClass.routineAfterAll(null, trigger.oldMap);
        ASI_MFM_PO_TriggerClass.routineAfterDelete(trigger.old);
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
        ASI_MFM_CAP_PO_TriggerClass.routineAfterAll(null, trigger.oldMap);
        ASI_MFM_CAP_PO_TriggerClass.routineAfterDelete(trigger.old); 
    }
     if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
       ASI_MFM_KR_PO_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_PO_TriggerClass.routineAfterDelete(trigger.old);   
    }
    
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SC_')
       ){
        ASI_MFM_SC_PO_TriggerClass.routineAfterAll(null, trigger.oldMap);
        ASI_MFM_SC_PO_TriggerClass.routineAfterDelete(trigger.old); 
    }
}