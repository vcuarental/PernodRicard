trigger ASI_KOR_SR_Proposal_Header_AfterInsert on ASI_KOR_SR_Proposal_Header__c (after insert) {
	List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
      new ASI_KOR_SRCopyBMbyBrand(),
      new ASI_KOR_SRAssignPrepayment()
    };
  
    for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
      triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
    }
}