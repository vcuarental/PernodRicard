trigger ASI_MFM_POSM_Return_Request_Item_BeforeInsert on ASI_MFM_POSM_Return_Request_Item__c (before insert) {

    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        	ASI_MFM_CN_POSM_Request_Item_TriggerCls.routineBeforeUpsert(trigger.new, null);
        }
    }

}