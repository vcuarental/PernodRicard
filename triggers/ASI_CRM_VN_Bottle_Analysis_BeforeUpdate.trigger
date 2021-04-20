trigger ASI_CRM_VN_Bottle_Analysis_BeforeUpdate on ASI_CRM_VN_Bottle_Analysis__c (before update) {
	new ASI_CRM_VN_BottleAnalysis_Duplication().executeTrigger(Trigger.new, Trigger.oldMap);
	new ASI_CRM_VN_BottleAnalysis_CalAllocation().executeTrigger(Trigger.new, Trigger.oldMap);
}