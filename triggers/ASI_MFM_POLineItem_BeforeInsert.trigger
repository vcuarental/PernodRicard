trigger ASI_MFM_POLineItem_BeforeInsert on ASI_MFM_PO_Line_Item__c (before insert) {
    if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
    ASI_MFM_POLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null); 
        ASI_MFM_KR_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_HK')){
        ASI_MFM_HK_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }else if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);          
    }else if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);          
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
    // Added by 2017-12-15 Linus@introv
        ASI_MFM_SG_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
    // Added by 2017-12-28 Linus@introv
        ASI_MFM_GF_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
    // Added by 2018-04-30 Linus@introv
        ASI_MFM_TR_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
    // [SH] 2018-11-26
        ASI_MFM_TW_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC')){
    // Added by 2018-07-07 Mark
        ASI_MFM_SC_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if (trigger.new[0].RecordTypeId != null 
      && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG')
        // Added by Hugo Cheung (Laputa) 05May2016
      && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
        ASI_MFM_POLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    } else if (trigger.new[0].RecordTypeId != null 
      && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TW')) {

        ASI_MFM_POLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null); 
    }
    
    //Start Plan Line Balance Calculation Logic Enoch@Introv 201905
    List<ASI_MFM_PO_Line_Item__c> cnPoLineList = new List<ASI_MFM_PO_Line_Item__c>();
    for(ASI_MFM_PO_Line_Item__c poline : trigger.new) {
        if(Global_RecordTypeCache.getRt(poline.recordTypeId).developerName.contains('ASI_MFM_CN')) {
            cnPoLineList.add(poline);
        }
    }
    if(cnPoLineList.size()>0) ASI_MFM_CN_POLine_SetPlan_TriggerClass.routineBeforeInsert(trigger.new);
    //End Plan Line Balance Calculation Logic Enoch@Introv 201905
}