trigger ASI_MFM_KR_PR_BeforeDelete on ASI_MFM_Purchase_Request__c (before delete) {
	ASI_MFM_KR_PR_TriggerClass.routineBeforeDelete(trigger.old);
}