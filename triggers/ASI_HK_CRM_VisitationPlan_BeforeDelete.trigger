trigger ASI_HK_CRM_VisitationPlan_BeforeDelete on ASI_HK_CRM_Visitation_Plan__c (before delete) {
    if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
        ASI_CRM_TW_VP_TriggerCls.routineBeforeDelete(trigger.old);
    }
}