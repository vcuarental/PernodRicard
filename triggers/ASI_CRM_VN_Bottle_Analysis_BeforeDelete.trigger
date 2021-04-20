trigger ASI_CRM_VN_Bottle_Analysis_BeforeDelete on ASI_CRM_VN_Bottle_Analysis__c (before delete) {
	new ASI_CRM_VN_BottleAnalysisCheckDelete().executeTrigger(Trigger.new, Trigger.oldMap);
}