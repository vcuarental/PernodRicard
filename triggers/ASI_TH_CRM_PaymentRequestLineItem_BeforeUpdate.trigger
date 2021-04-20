trigger ASI_TH_CRM_PaymentRequestLineItem_BeforeUpdate  on ASI_TH_CRM_PaymentRequestLineItem__c (before update) {
    
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF') ||
       trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other') ||
       trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF')){
           ASI_CRM_CN_PaymentRequestLine_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
       }
    if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
            ASI_CRM_MY_PaymentRequestItm_TriggerCls.routineBeforeUpsert(trigger.New);
        }
    }
}