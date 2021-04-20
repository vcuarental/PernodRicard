trigger ASI_FOC_Request_Item_AfterUpdate on ASI_FOC_Request_Item__c (after update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_CN')){
        ASI_FOC_Request_Item_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
    }
    //202009 added by LEO Jing BSL
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName ==  'ASI_CRM_CN_POSM_Request_Item_Batch_Approval') {
        ASI_FOC_Request_Item_TriggerClass.autoSubmitOrderApproval(trigger.new, trigger.oldMap);
    }
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_HK')){
        ASI_FOC_HK_Request_Item_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_SG_CRM_Request_Items')){
        
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_RollUpTotal_FreeGoods()
        };
            
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newmap, trigger.oldmap);
        }
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW')){
        ASI_CRM_TW_RequestItem_TriggerCls.routineAfterUpsert(trigger.New, trigger.oldMap);
    }

}