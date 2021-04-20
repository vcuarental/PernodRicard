trigger ASI_MFM_PO_BeforeInsert on ASI_MFM_PO__c (before insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){ 
        // Added by 2018-03-26 Linus@introv
        ASI_MFM_GF_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_GF_PO_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-03-15 Linus@introv
        ASI_MFM_SG_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_SG_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-04-30 Linus@introv
        ASI_MFM_TR_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_TR_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_RM')){
        // Added by 2018-07-26 Linus@introv
        ASI_MFM_RM_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_RM_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_PH_PO_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    //Added by Andy Zhang @Laputa 20190216 for VN
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_VN_PO_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        // [SH] 2018-11-26
        ASI_MFM_TW_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_TW_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
    else if (!Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
    
    if (trigger.new[0].recordtypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')
        || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost'))
       ){
           if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN'))
               ASI_MFM_CN_PO_TriggerClass.routineBeforeInsert(trigger.new);
           else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost'))
               ASI_MFM_CN_PO_StructureCost_TriggerClass.beforeInsertMethod(trigger.new);
               
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP') 
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('SG')
        // Added by Hugo Cheung (Laputa) 05May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('HK')
        //20170207 Elufa
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost')
       ){
        ASI_MFM_CAP_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_CAP_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
       //for KR, added by Leo, 2015-11-23, B6
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR_PO')){        
        ASI_MFM_KR_PO_TriggerClass.beforeUpsertMethod(trigger.New,null);        
    }
    //for KR, added by Leo, 2015-11-23, B6
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC_')){
        ASI_MFM_SC_PO_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_SC_PO_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
}