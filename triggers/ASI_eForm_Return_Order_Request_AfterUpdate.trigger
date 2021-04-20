trigger ASI_eForm_Return_Order_Request_AfterUpdate on ASI_eForm_Return_Order_Request__c (after update) {
	if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_KR')) {
        ASI_eForm_KR_ReturnOrder_TriggerClass.routineAfterUpsert(trigger.new, Trigger.oldMap); 
    }
}