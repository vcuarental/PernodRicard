trigger ASI_CRM_SalesOrderRequest_AfterInsert on ASI_KOR_Sales_Order_Request__c (after insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Wholesaler') 
       || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_TBCN')) {
           ASI_CRM_SG_PopulateCustomer.assignRecordShare(trigger.new);
        }
}