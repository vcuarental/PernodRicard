trigger ASI_MFM_Plan_BeforeUpdate on ASI_MFM_Plan__c (before update) {
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')){
        ASI_MFM_CAP_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-03-15 Linus@introv
        ASI_MFM_SG_Plan_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldmap);
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-05-11 Linus@introv
        ASI_MFM_TR_Plan_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldmap);
        ASI_MFM_TR_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldmap);
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        // [SH] 2018-11-26
        ASI_MFM_TW_Plan_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldmap);
        ASI_MFM_TW_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldmap);
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC_')){
        ASI_MFM_SC_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_SC_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_PH_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_VN_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_RM')){
        // Added by 2018-07-26 Linus@introv
        ASI_MFM_RM_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_RM_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }else{
        ASI_MFM_Plan_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }
    
        
    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MFM_TW')){
        triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
            new ASI_MFM_TW_ResetPlanApprover_TgrHdlr()         
        };  
        
        //Added by Introv @20161205
        ASI_MFM_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap);
    }            
            
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
      //for KR, added by Leo, 2015-11-06, B6
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR_Plan')){
         ASI_MFM_KR_Plan_TriggerClass.routineBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    //for KR, added by Leo, 2015-11-06, B6
    
    if (trigger.new[0].recordTypeId != null 
        && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP_Trade_Plan')
        || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP_Approval'))){
        ASI_CRM_CN_TP_Plan_TriggerClass.routineBeforeUpsert(Trigger.New);  
    }
}