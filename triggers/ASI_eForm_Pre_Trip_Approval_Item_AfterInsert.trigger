trigger ASI_eForm_Pre_Trip_Approval_Item_AfterInsert on ASI_eForm_Pre_Trip_Approval_Item__c (after insert) {

	ASI_eForm_Pre_Trip_Approval_Item_Trigger.lowestDate(trigger.new);

}