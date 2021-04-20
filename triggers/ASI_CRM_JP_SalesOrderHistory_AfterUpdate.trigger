trigger ASI_CRM_JP_SalesOrderHistory_AfterUpdate on ASI_CRM_JP_Sales_Order_History__c (after update) {

    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();

    ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
        new ASI_CRM_JP_UpdateOrderStockStatus()
    };                    
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}