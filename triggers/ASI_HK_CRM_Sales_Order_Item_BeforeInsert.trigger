trigger ASI_HK_CRM_Sales_Order_Item_BeforeInsert on ASI_HK_CRM_Sales_Order_Item__c (before insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeID).DeveloperName.contains('HK_CRM')){   
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_SalesOrderItemETLUpdate()
            ,new ASI_HK_CRM_SalesOrderItemStockRelease()
        };
    
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    if(trigger.new[0].recordTypeId != null &&  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MY_CRM')){
        ASI_MY_CRM_SalesOrderItem_Handler.routineBeforeInsert(Trigger.New, new Map<Id, ASI_HK_CRM_Sales_Order_Item__c>(), new List<ASI_HK_CRM_Sales_Order_Item__c>(), new Map<Id, ASI_HK_CRM_Sales_Order_Item__c>());
    }
}