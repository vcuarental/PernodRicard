trigger ASI_FOC_Request_Item_AfterDelete on ASI_FOC_Request_Item__c (after delete) {

    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_SG_CRM_Request_Items')){
        
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_RollUpTotal_FreeGoods()
        };
            
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_DELETE, trigger.old, null, null);
        }
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
        ASI_CRM_TW_RequestItem_TriggerCls.routineAfterDelete(trigger.old);
    }

}