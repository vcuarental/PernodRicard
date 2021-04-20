trigger ASI_MFM_CN_SIR_BeforeInsert on ASI_MFM_Stock_In_Request__c (before insert) {
    
    Private Static Final String CN_SIR_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Stock_In_Request__cASI_MFM_CN_Stock_In_Request');
    
    List<ASI_MFM_Stock_In_Request__c> CN_SIR_List = new List<ASI_MFM_Stock_In_Request__c>();
    
    for(ASI_MFM_Stock_In_Request__c obj : trigger.new){
        if(obj.recordTypeId == CN_SIR_RECORD_TYPE_ID){
            CN_SIR_List.add(obj);
        }
    }
    
    if(CN_SIR_List.size() > 0){
        ASI_MFM_CN_Stock_In_Request_TriggerClass.beforeInsertFunction(CN_SIR_List);
    }
}