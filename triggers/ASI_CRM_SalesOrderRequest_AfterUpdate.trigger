trigger ASI_CRM_SalesOrderRequest_AfterUpdate on ASI_KOR_Sales_Order_Request__c (after update) {
	 if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
        ASI_CRM_CN_SalesOrderTriggerClass.afterUpdateMethod(trigger.new, trigger.oldMap);
    }
}