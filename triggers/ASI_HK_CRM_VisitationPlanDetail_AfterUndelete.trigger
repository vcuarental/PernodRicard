trigger ASI_HK_CRM_VisitationPlanDetail_AfterUndelete on ASI_HK_CRM_Visitation_Plan_Detail__c (after undelete) {
	
	List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
		new ASI_HK_CRM_VisitationPlanDtValidator()
	};
	
	for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
		triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UNDELETE, trigger.new, trigger.newMap, null);
	}

}