trigger ASI_MFM_PlanLineItem_AfterDelete on ASI_MFM_Plan_Line_Item__c (after delete) {
	ASI_MFM_PlanLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
}