trigger ASI_CRM_Order_Status_AfterDelete on ASI_CRM_Order_Status__c (after delete) {
    if(trigger.old[0].recordTypeId != NULL){
        if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_TW')){
            ASI_CRM_TW_Order_Status_TriggerCls.routineAfterDelete(trigger.Old);
        }
    }
}