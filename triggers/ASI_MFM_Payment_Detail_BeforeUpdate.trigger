trigger ASI_MFM_Payment_Detail_BeforeUpdate on ASI_MFM_Payment_Detail__c (before update) {
    
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('_CN_')){
        
        ASI_MFM_CN_PaymentDetail_TriggerCls.beforeUpdateMethod(trigger.New, trigger.oldMap);
    }
}