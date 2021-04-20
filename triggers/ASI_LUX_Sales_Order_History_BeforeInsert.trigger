trigger ASI_LUX_Sales_Order_History_BeforeInsert on ASI_HK_CRM_Sales_Order_History__c (before insert) {
   ASI_LUX_Sales_Order_History_TriggerClass.routineBeforeUpsert(trigger.new, null); 
}