trigger ASI_KOR_RSD_Proposal_Header_AfterUpdate on ASI_KOR_RSD_Proposal_Header__c (after update) {
	List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
    	new ASI_KOR_RSD_CalculateNSDAmount(),
		new ASI_KOR_RSD_SendApprovedProposalEmail()
    };
    
    for(ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}