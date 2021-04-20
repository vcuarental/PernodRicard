trigger ASI_CRM_PaymentRequestLineItem_BeforeDelete on ASI_TH_CRM_PaymentRequestLineItem__c (before delete) {
    
    if (trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_Protect_Delete()        
        };
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, null);
        }
    }
}