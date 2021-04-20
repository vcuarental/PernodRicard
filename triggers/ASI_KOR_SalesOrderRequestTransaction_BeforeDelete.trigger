trigger ASI_KOR_SalesOrderRequestTransaction_BeforeDelete on ASI_KOR_Sales_Order_Transaction__c (before delete) {
    
    /* [HC 1.0] BEGIN */
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_SG_Wholesaler')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_SalesOrderTransactionDTCls()
        };

        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, trigger.oldMap);
        }
    }
    /* [HC 1.0] END */
    
    /*[WL 1.0] 20200828 KR Sales Order module is not being used*/
    /* 
    if (!Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_CN_SalesOrder_Item')){
    
    List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
        new ASI_KOR_SalesOrderRequestDtLockSubmitted()
    };
    
    for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.old, null, trigger.oldMap);
    }
    }*/
    
}