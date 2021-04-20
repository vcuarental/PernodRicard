trigger ASI_MFM_VAT_Invoice_BeforeInsert on ASI_MFM_VAT_Invoice__c (before insert) {
    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
            if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN_VAT_Invoice')){    
                ASI_MFM_CN_VAT_Invoice_TriggerCls.routineBeforeInsert(trigger.new);
            }
            else{
                  
            }
        }
    }
}