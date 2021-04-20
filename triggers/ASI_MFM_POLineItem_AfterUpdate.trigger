trigger ASI_MFM_POLineItem_AfterUpdate on ASI_MFM_PO_Line_Item__c (after update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_GF_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        ASI_MFM_SG_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-04-30 Linus@introv
        ASI_MFM_TR_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
    }else if (trigger.new[0].RecordTypeId != null 
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG')
        // Added by Hugo Cheung (Laputa) 05May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC')) {
        ASI_MFM_POLineItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_POLineItem_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);   
    }
    //Start Plan Line Balance Calculation Logic Enoch@Introv 201905
    List<ASI_MFM_PO_Line_Item__c> cnPoLineList = new List<ASI_MFM_PO_Line_Item__c>();
    for(ASI_MFM_PO_Line_Item__c poline : trigger.new) {
        if(Global_RecordTypeCache.getRt(poline.recordTypeId).developerName.contains('ASI_MFM_CN')) {
            cnPoLineList.add(poline);
        }
    }
    if(cnPoLineList.size()>0) ASI_MFM_CN_POLine_SetPlan_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    //End Plan Line Balance Calculation Logic Enoch@Introv 201905
}