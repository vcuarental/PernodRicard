trigger ASI_CRM_Payment_Invoice_BeforeInsert on ASI_CRM_Payment_Invoice__c(before insert) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Cash_Invoice')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
			new ASI_CRM_JP_EncodingConverterHelper(new Set<String>{'ASI_CRM_Remarks__c'}),            
            new ASI_CRM_JP_PaymentInvoiceTgrHdlr(),
            new ASI_CRM_JP_AssignAutoNumber_Invoice(),
            new ASI_CRM_JP_AssignApprover_LineManager(),
            new ASI_CRM_JP_Invoice_AssignApprover()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        
}