trigger ASI_MFM_POSM_Return_Request_AfterInsert on ASI_MFM_POSM_Return_Request__c (after insert) {

    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
            if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN_Repack_Request_Form')){    
                ASI_MFM_CN_RepackRequest_TriggerCls.routineAfterInsert(trigger.new, null);
            }
            else{

            }
        }
    }
    
}