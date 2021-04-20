trigger ASI_KOR_SR_Proposal_Detail_AfterInsert on ASI_KOR_SR_Proposal_Detail__c (after insert) {
    List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
        new ASI_KOR_RemoveEmptyProposalDetail()
    };
                
    for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
    }
}