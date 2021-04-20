trigger ASI_MFM_POSM_Return_Request_AfterUpdate on ASI_MFM_POSM_Return_Request__c (after update) {

    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
            if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN_Repack_Request_Form')){    
                
            }
            else{
                ASI_MFM_CN_POSM_ReturnRequest_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldMap);
            }
        }
        //202009 added by LEO Jing BSL
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName == 'ASI_MFM_CN_POSM_Return_Batch_Approval') {
        	ASI_MFM_CN_POSM_ReturnRequest_TriggerCls.approvalPass(trigger.new, trigger.oldMap);
        }
    }
    
}