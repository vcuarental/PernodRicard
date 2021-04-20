trigger ASI_MFM_Plan_AfterInsert on ASI_MFM_Plan__c (after insert) {
     if(trigger.new[0].RecordTypeId != null &&  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_Plan_TriggerClass.routineAfterInsert(Trigger.new);
     }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-03-15 Linus@introv
        ASI_MFM_SG_Plan_TriggerClass.routineAfterInsert(Trigger.new);
     }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-05-30 Linus@introv
        ASI_MFM_TR_Plan_TriggerClass.routineAfterInsert(Trigger.new);
     }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        // [SH] 2018-11-26
        ASI_MFM_TW_Plan_TriggerClass.routineAfterInsert(Trigger.new);
     }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        // Added for PH 2018-06-12 Linus@introv
        ASI_MFM_PH_Plan_TriggerClass.routineAfterUpsert(Trigger.new,null);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        // Added for VN 2019-02-13 Calvin@Laputa
        ASI_MFM_VN_Plan_TriggerClass.routineAfterUpsert(Trigger.new,null);
    }else if (!Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP') 
         && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC')
         && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP')){
        //System.debug('Enter After Trigger1');
        ASI_MFM_Plan_TriggerClass.routineAfterInsert(Trigger.new);
        //System.debug('Enter After Trigger2');
        ASI_MFM_Plan_TriggerClass.routineAfterUpsert(Trigger.new, null); 
        //System.debug('Leave After Trigger');
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_CAP_Plan_TriggerClass.routineAfterInsert(Trigger.new);
        ASI_MFM_CAP_Plan_TriggerClass.routineAfterUpsert(Trigger.new, null);   
    }else if (trigger.new[0].recordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP_Trade_Plan')){
        ASI_CRM_CN_TP_Plan_TriggerClass.routineAfterUpsert(Trigger.new, null);  
    }
}