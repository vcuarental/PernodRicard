trigger ASI_HK_CRM_VisitationPlanDetail_BeforeDelete on ASI_HK_CRM_Visitation_Plan_Detail__c (before delete) {
    
    //Exclude VN visitation plan
    if (trigger.old[0].RecordTypeId != null && 
        Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_VN') == false){    
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_VisitationPlanDtValidator()
        };
    
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, trigger.oldMap);
        }
    }
    
     if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
        ASI_CRM_TW_VPD_TriggerCls.routineBeforeDelete(trigger.old);
    }
    if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_PH')){    
        //Trigger Record Type Check for PH CRM
        ASI_CRM_PH_TriggerCls.routineBeforeDelete(trigger.old);
    }

}