trigger ASI_CRM_EC_Authorization_Req_Trigger on ASI_CRM_EC_AUTHORIZATION_REQUEST__c (before insert,before update) {
    
    boolean isInsert = False;
    if(trigger.isInsert){
        isInsert = True;
        
    }
    
    if (trigger.new[0].recordTypeid != null){
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
            
            ASI_CRM_ECAuthorizationReq_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap,isInsert);
        }
    }
}