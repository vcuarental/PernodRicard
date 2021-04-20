trigger ASI_MFM_PlanLineItem_BeforeUpdate on ASI_MFM_Plan_Line_Item__c (before update) {  
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }    
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, trigger.oldMap); 
        ASI_MFM_CN_PlanLine_TriggerClass.routineBeforeUpdate(Trigger.New, trigger.oldMap); //Plan Line Remaining Balance Calculation Enoch@introv 201905
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        ASI_MFM_SG_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MY')){
        ASI_MFM_MY_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        // Modified by 2018-06-11 Linus@introv
        ASI_MFM_PH_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, trigger.oldmap);
    }
     else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        // Modified by 2019-02-13 Calvin@Laputa
        ASI_MFM_VN_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, trigger.oldmap);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP')){
        ASI_CRM_CN_TP_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.new, Trigger.oldMap);
    }
    /*else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_HK')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_RM')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_JP')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }    
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TH')){
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);
    }*/
    else
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeUpsert(Trigger.New, null);    
}