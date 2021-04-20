trigger ASI_TH_CRM_PaymentRequest_BeforeDelete on ASI_TH_CRM_PaymentRequest__c (before delete) {

    if(trigger.old[0].recordTypeid != NULL){

        if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
            ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeDelete(trigger.old);
        }
    }
    if (trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request_Read_Only')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            //new ASI_CRM_SG_Protect_Delete()     
        };
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, null);
        }
    }else if (trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request')) {
         ASI_CRM_SG_PaymentRequest_TriggerCls.routineBeforeDelete(trigger.old);
         List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_RollbackIncentiveHandler(ASI_CRM_SG_RollbackIncentiveHandler.PAYMENT_REQUEST)
         };
         for(ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
             triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, trigger.oldMap);
         }  
    }else if(trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')){
        ASI_CRM_CN_PaymentRequest_TriggerCls.routineBeforeDelete(trigger.old);
    }
    
}