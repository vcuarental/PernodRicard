trigger ASI_KOR_RSD_Payment_Settlement_Header_AfterUpdate on ASI_KOR_RSD_Payment_Settlement_Header__c (after update) {
	List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
		new ASI_KOR_RSD_SendApprovedPaySettleEmail(),
        new ASI_KOR_RSDTriggerKeymanAllocation()
    };
    
    for(ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}