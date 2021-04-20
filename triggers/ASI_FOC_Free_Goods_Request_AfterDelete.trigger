trigger ASI_FOC_Free_Goods_Request_AfterDelete on ASI_FOC_Free_Goods_Request__c (after delete) {

    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_FOC_CN')){
        ASI_FOC_Free_Goods_Request_TriggerClass.routineAfterAll(null, trigger.oldMap);  
    }
    
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_FOC_HK')){
        ASI_FOC_HK_Request_TriggerClass.routineAfterAll(null, trigger.oldMap);  
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_SG')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_Protect_Delete()        
        };
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_DELETE, trigger.old, null, null);
        }
    }
}