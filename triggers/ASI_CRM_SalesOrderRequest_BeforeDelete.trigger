trigger ASI_CRM_SalesOrderRequest_BeforeDelete on ASI_KOR_Sales_Order_Request__c (before delete) {
	//Wilken 20170523 Add validation to blcok deletion unless SO is in Draft status
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_SG')){
        ASI_CRM_SG_SalesOrder_TriggerHandler.salesOrderBeforeDeleteValidation(trigger.old);
	}
}