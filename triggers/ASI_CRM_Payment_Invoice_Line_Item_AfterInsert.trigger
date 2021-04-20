trigger ASI_CRM_Payment_Invoice_Line_Item_AfterInsert on ASI_CRM_Payment_Invoice_Line_Item__c (After insert) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
            new ASI_CRM_JP_RollUp_Amount_PayInvoiceLine(),
            new ASI_CRM_JP_InvoiceItemUpdateApprover(),
            new ASI_CRM_JP_InvoiceItemCreateAutoNum()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.After_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        
}