trigger ASI_FOC_Free_Goods_Request_BeforeDelete on ASI_FOC_Free_Goods_Request__c (before delete) {
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_SG')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_Protect_Delete(),
            new ASI_CRM_SG_RollbackIncentiveHandler(ASI_CRM_SG_RollbackIncentiveHandler.FOC_REQUEST)        
        };
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, trigger.oldMap);
        }
    }
	else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
        ASI_CRM_TW_FreeGoodsRequest_TriggerCls.routineBeforeDelete(trigger.old);
    }
}