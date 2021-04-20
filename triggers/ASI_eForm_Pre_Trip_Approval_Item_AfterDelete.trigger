trigger ASI_eForm_Pre_Trip_Approval_Item_AfterDelete on ASI_eForm_Pre_Trip_Approval_Item__c (after delete) {

	ASI_eForm_Pre_Trip_Approval_Item_Trigger.lowestDate(trigger.old);

}