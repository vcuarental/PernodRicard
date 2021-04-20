trigger ASI_eForm_Return_Order_Request_AfterInsert on ASI_eForm_Return_Order_Request__c (after insert) {
	if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_KR')) {
        ASI_eForm_KR_ReturnOrder_TriggerClass.routineAfterUpsert(trigger.new, Trigger.oldMap); 
    }
}