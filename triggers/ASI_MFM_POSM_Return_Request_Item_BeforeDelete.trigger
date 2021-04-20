trigger ASI_MFM_POSM_Return_Request_Item_BeforeDelete on ASI_MFM_POSM_Return_Request_Item__c (before delete) {

    if(trigger.old[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
            ASI_MFM_CN_POSM_Request_Item_TriggerCls.routineBeforeDelete(trigger.old);
        }
    }
    
}