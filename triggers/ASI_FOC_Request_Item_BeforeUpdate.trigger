trigger ASI_FOC_Request_Item_BeforeUpdate on ASI_FOC_Request_Item__c (before update) {
    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_CN')){
            ASI_FOC_Request_Item_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        }
        else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_HK')){
            ASI_FOC_HK_Request_Item_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        }
        else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_MY')){
            ASI_CRM_MY_FOCRequestItem_TriggerCls.routineBeforeUpsert(trigger.new);
        }
        else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
            ASI_CRM_TW_RequestItem_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
        }
    }
}