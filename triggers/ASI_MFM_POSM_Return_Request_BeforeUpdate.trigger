trigger ASI_MFM_POSM_Return_Request_BeforeUpdate on ASI_MFM_POSM_Return_Request__c (before update) {

    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
            if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN_Repack_Request_Form')){    
                ASI_MFM_CN_RepackRequest_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
            }
            else{
                ASI_MFM_CN_POSM_ReturnRequest_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
            }
        }
    }
    
}