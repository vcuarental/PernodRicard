trigger ASI_TH_CRM_PaymentRequest_BeforeInsert on ASI_TH_CRM_PaymentRequest__c (before insert) {
    // Modified by Michael Yip (Introv) 26Apr2014 Separate trigger class by recordtype, assume same record type for all records in trigger.new 
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request')){
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_TH_CRM_PaymentRequestAutoNumber()        
        };
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
        }
    }
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')){

            ASI_CRM_CN_PaymentRequest_TriggerCls.routineBeforeInsert(trigger.new, null);
        
    }
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request')){
        ASI_CRM_PH_PaymentRequest_TriggerClass.routineBeforeInsert(trigger.new);
    ASI_CRM_PH_PaymentRequest_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }  
    else if (trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_AssignAutoNumber_Payment(),
            new ASI_CRM_SG_AssignInvoiceNumber_Payment()        
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            if(!test.isRunningTest()) {triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);}
        }
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_Payment_Request') )
     //Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_Payment_Request')){
    {
        if(!Test.isRunningTest()) ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeInsert(trigger.New);
        ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeUpsert(trigger.New);
    }
}