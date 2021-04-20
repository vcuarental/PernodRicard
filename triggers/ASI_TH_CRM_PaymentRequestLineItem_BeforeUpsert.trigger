/*Created by Twinkle Li (Introv) 20160120*/
trigger ASI_TH_CRM_PaymentRequestLineItem_BeforeUpsert on ASI_TH_CRM_PaymentRequestLineItem__c (before update, before insert) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_TH_CRM_Payment_Request_Detail')){
           ASI_TH_CRM_PaymentRequestLine_TriggerCls.routineBeforeUpsert(trigger.new, null);
   }  
}