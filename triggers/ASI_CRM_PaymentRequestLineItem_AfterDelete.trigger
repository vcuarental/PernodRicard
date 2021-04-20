trigger ASI_CRM_PaymentRequestLineItem_AfterDelete on ASI_TH_CRM_PaymentRequestLineItem__c (after delete) {
    if (trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_TH_CRM_Payment_Request_Detail')) {
        ASI_TH_CRM_PaymentRequestLine_TriggerCls.routineAfterDelete(trigger.oldMap);
    }
}