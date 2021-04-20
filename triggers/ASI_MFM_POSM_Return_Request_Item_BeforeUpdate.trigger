trigger ASI_MFM_POSM_Return_Request_Item_BeforeUpdate on ASI_MFM_POSM_Return_Request_Item__c (before update,after update) {
    
    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN') && Trigger.isBefore && Trigger.isUpdate){
            ASI_MFM_CN_POSM_Request_Item_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
        }
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName ==  'ASI_MFM_CN_POSM_Return_Request_Item_Batch_Approval' && Trigger.isAfter && Trigger.isUpdate) {
        	ASI_MFM_CN_POSM_Request_Item_TriggerCls.autoSubmitOrderApproval(trigger.new, trigger.oldMap);
        }
    }

}