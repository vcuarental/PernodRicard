trigger ASI_CRM_Pros_Segmentation_AfterUpdate on ASI_CRM_Pros_Segmentation__c (after update) {
    
     if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG')){
        ASI_CRM_SG_ProsSeg_TriggerClass.routineAfterUpdate1(trigger.new, trigger.oldMap);
        ASI_CRM_SG_ProsSeg_TriggerClass.routineAfterUpdate2(trigger.new, trigger.oldMap); 
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
        ASI_CRM_TW_ProsSeg_TriggerClass.routineAfterUpdate1(trigger.new, trigger.oldMap);
        ASI_CRM_TW_ProsSeg_TriggerClass.routineAfterUpdate2(trigger.new, trigger.oldMap); 
    }  
    
    //Added by Twinkle @04/03/2016
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TH')){
        ASI_CRM_TH_ProsSeg_TriggerClass.routineAfterAll1(trigger.new, trigger.oldMap);
        ASI_CRM_TH_ProsSeg_TriggerClass.routineAfterAll2(trigger.new, trigger.oldMap); 
    } 
}