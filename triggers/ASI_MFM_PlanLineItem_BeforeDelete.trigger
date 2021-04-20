trigger ASI_MFM_PlanLineItem_BeforeDelete on ASI_MFM_Plan_Line_Item__c (before delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        ASI_MFM_SG_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_MY')){
        ASI_MFM_MY_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
    }else
        ASI_MFM_PlanLineItem_TriggerClass.routineBeforeDelete(trigger.old);
}