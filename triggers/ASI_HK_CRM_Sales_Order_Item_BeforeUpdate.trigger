trigger ASI_HK_CRM_Sales_Order_Item_BeforeUpdate on ASI_HK_CRM_Sales_Order_Item__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeID).DeveloperName.contains('HK_CRM')){    
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_SalesOrderItemStockRelease()
        };
    
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    if(trigger.new[0].recordTypeId != null &&  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MY_CRM')){
        ASI_MY_CRM_SalesOrderItem_Handler.routineBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
    }
}