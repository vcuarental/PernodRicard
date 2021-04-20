trigger ASI_HK_CRM_Sales_Order_Item_AfterInsert on ASI_HK_CRM_Sales_Order_Item__c (after insert) {

    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
        new ASI_HK_CRM_SalesOrderItemETLUpdate()
    };
    
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }

}