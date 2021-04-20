trigger ASI_eForm_Return_Order_Request_BeforeInsert on ASI_eForm_Return_Order_Request__c (before insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_KR')) {
        ASI_eForm_KR_ReturnOrder_TriggerClass.routineBeforeUpsert(trigger.new, Trigger.oldMap); 
    }
}