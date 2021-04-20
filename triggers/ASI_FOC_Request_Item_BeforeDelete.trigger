trigger ASI_FOC_Request_Item_BeforeDelete on ASI_FOC_Request_Item__c (before delete) {
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_SG') || Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_SG_CRM')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_Protect_Delete()        
        };
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, null);
        }
    }
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_FOC_CN')){
        ASI_FOC_Request_Item_TriggerClass.routineBeforeDelete(trigger.old);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
        ASI_CRM_TW_RequestItem_TriggerCls.routineBeforeDelete(trigger.old);
    }
}