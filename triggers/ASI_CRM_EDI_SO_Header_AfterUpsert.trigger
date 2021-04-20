trigger ASI_CRM_EDI_SO_Header_AfterUpsert on ASI_CRM_EDI_SO_Header__c (after insert, after update) {
    
    /*List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
        new ASI_CRM_HK_EDI_SO_Header_TriggerClass()
    };
    
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, null, null);
    }*/
}